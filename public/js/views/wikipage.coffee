define [
	'jquery'
	'backbone'
	'cs!models/activity'
	'text!templates/wikipage/show.html'
	'text!templates/wikipage/edit-buttons.html'
	'text!templates/wikipage/save-buttons.html'
	'text!templates/wikipage/body-view.html'
	'text!templates/wikipage/body-edit.html'
	'jquery.gravatar'
	'general'
	'moment'
	'diff'

], ($, Backbone, Activity, show, edit_btns, save_btns, view_b, edit_b) ->
	class WikiPageView extends Backbone.View
		className : "wikipage"

		normalTemplate: _.template(show)
		editButtons: _.template(edit_btns)
		saveButtons: _.template(save_btns)
		wikipageBodyView: _.template(view_b)
		wikipageBodyEdit: _.template(edit_b)
		hoveredParagraph: null
		selectedParagraph: null

		events:
			"click .edit-button": "editButton"
			"click .cancel-button": "cancelButton"
			"click .save-button": "saveButton"
			"mouseenter p": "showEditButton"
			"mouseleave p": "hideEditButton"
			"click .quick-edit-button": "openQuickEditBox"
			"keypress .quick-edit-box": "onQuickEditBoxKeypress"
		initialize: (options)->
			_.bindAll @
			if options.embeded
				@embeded = true
			@fullview = false
			@template = @normalTemplate
			@quickEditButton = $("<button class='btn btn-info btn-mini quick-edit-button' style='position: absolute;'>Edit</button>")
			@quickEditBox = $("<textarea class='quick-edit-box'></textarea>")
			$(@quickEditBox).hide()
			$(@quickEditButton).hide()

		render: ->
			$(@el).html @template @model.toJSON()
			if window.current_user?
				$(@el).find(".buttons").html @editButtons
			$(@el).find(".wikipage-body-area").html @wikipageBodyView body: @model.get('body')
			$(@el).append(@quickEditButton)
			$(@el).append(@quickEditBox)
			@

		expand: ->
			$(@el).find(".wikipage-body-area").html @wikipageBodyView {body: @model.get('body'), fullview: true}

		collapse: ->
			$(@el).find(".wikipage-body-area").html @wikipageBodyView {body: @model.get('body')}

		disable: ->
			$(@el).find(".wikipage-body-area").spin()
			$(@el).find('.wikipage-summary').attr('disabled','disabled'	)
			$(@el).find('.wikipage-body').attr('disabled','disabled'	)
			$(@el).find('.buttons .btn').addClass('disabled')

		enable: ->
			$(@el).find(".wikipage-body-area").spin(false)
			$(@el).find('.wikipage-summary').removeAttr('disabled'	)
			$(@el).find('.wikipage-body').removeAttr('disabled'	)
			$(@el).find('.buttons .btn').removeClass('disabled')

		editButton: ->
			page_hieght = $($(@el).find(".wikipage-view-body")).outerHeight()
			$(@el).find(".wikipage-body-area").html @wikipageBodyEdit body: @model.get('body')
			$(@el).find(".wikipage-body").height(page_hieght + 20)
			#$(@el).find(".wikipage-body").attr("rows", 3 + (@model.get('body').length/100) )
			$(@el).find(".buttons").html @saveButtons

		saveButton: ->
			@disable()
			old_text = @model.get('body')
			@model.get('page').save({ body: $(@el).find(".wikipage-body").val(), summary : $(@el).find(".wikipage-summary").val(), diff : JsDiff.diffWords(old_text, $(@el).find(".wikipage-body").val() ), user:  current_user._id },
				success : (model, response)=>
					console.debug model.toJSON().current_revision
					@model.set
						body : model.toJSON().current_revision.body
						_id : model.toJSON().current_revision._id
					activity = new Activity
						actor : current_user
						object: model.toJSON().current_revision
						object_type: "Revision"
						verb: "edit"
					activity.save(null,
						success: (activity)=>
							@enable()
							window.mediator.trigger("new-silent-activity", activity)
							$(@el).find(".wikipage-body-area").html @wikipageBodyView body: model.get 'body'
							$(@el).find(".buttons").html @editButtons
						)

				url : "/api/wikipages/#{@model.get('page').id}"
			)
		save: (new_text, old_text, summary='', success) ->
			@model.get('page').save({ body: new_text, summary : summary, diff : JsDiff.diffWords(old_text, new_text ), user:  current_user._id },
				success : (model, response)=>
					console.debug model.toJSON().current_revision
					@model.set
						body : model.toJSON().current_revision.body
						_id : model.toJSON().current_revision._id
					activity = new Activity
						actor : current_user
						object: model.toJSON().current_revision
						object_type: "Revision"
						verb: "edit"
					activity.save(null,
						success: (activity)=>
							@enable()
							window.mediator.trigger("new-silent-activity", activity)
							$(@el).find(".wikipage-body-area").html @wikipageBodyView body: model.get 'body'
							$(@el).find(".buttons").html @editButtons
						)
					success(model, response) if success

				url : "/api/wikipages/#{@model.get('page').id}"
			)
		cancelButton: ->
			$(@el).find(".wikipage-body-area").html @wikipageBodyView body: @model.get('body')
			$(@el).find(".buttons").html @editButtons
		showEditButton: (e) ->
			$(@quickEditButton).fadeIn('fast');
			current_p = e.currentTarget
			@hoveredParagraph = current_p
			p_pos = $(current_p).offset()
			p_pos.left += ($(current_p).innerWidth() - $(@quickEditButton).outerWidth())
			$(@quickEditButton).offset(p_pos)
		hideEditButton: (e) ->
			if (e.toElement isnt @quickEditButton[0])
				$(@quickEditButton).hide()
		openQuickEditBox: ->
			@selectedParagraph = @hoveredParagraph
			p_width = $(@selectedParagraph).width()
			p_height= $(@selectedParagraph).height()
			$(@quickEditButton).hide()
			$(@selectedParagraph).after(@quickEditBox)
			$(@selectedParagraph).hide()
			$(@quickEditBox).html($(@selectedParagraph).html())
			$(@quickEditBox).show()
			$(@quickEditBox).width(p_width)
			$(@quickEditBox).height(p_height+ 15)
		onQuickEditBoxKeypress: (e) ->
			code = e.keyCode or e.which
			if (code == 13 && !e.shiftKey)
				old_text = @getBody()
				new_text = $(@quickEditBox).val()
				$(@selectedParagraph).html(new_text)
				$(@quickEditBox).hide()
				$(@quickEditBox).remove()
				$(@selectedParagraph).show()
				new_text = $(@el).find('.wikipage-view-body').html()
				@save(new_text,old_text,'partial edit')
				
		getBody: ->
			return @model.get('page').attributes.current_revision.body