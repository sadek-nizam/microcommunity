// https://github.com/jrburke/amdefine
if (typeof define !== 'function') { var define = require('amdefine')(module); }

/* require additional modules if needed
define(['./other-module.js'], function (other-module) {*/
define([], function () {
  return {
  
  	message : function(model, singleMode){
  	  	
			//var name = "<a href='/profile/" + model.actor.id + '>'+ model.actor.profile.displayName + "</a>";
			var name = model.actor.displayName;	
			
			var phrases = {}
			
			if ( model.object_type ==  'Revision')	{
				var target = (model.target_type == 'users') ? " on his wall" : " in " + model.target.displayName	;
				phrases = {
					edit: name + " edited a wikipage titled " + model.object.page.displayName + target,
					aggr_edit : name + " made several edits on the wikipage titled " + model.object.page.displayName,
					create: name + " created a wikipage titled " + model.object.page.displayName ,
					upvote: name + " upvoted a revision" + target,
					downvote: name + " downvoted a revision" + target
				};			
			
			}	else if ( model.object_type ==  'Post' ) {
				phrases = {
					comment: name + " commented a post",
					create: name + " created a new post"				
				}									
			}			
	
			if (singleMode)
				return phrases[model.verb]
			else
				return phrases.aggr_edit  	
  	}
  	
  };
});
