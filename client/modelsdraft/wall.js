define([
	'modelsdraft/item',	
	'modelsdraft/items',	
	'backbone',
	'backbone-relational'
], function(Item, Items, Backbone){

	return Wall = Backbone.RelationalModel.extend({
		urlRoot : '/api/walls',
		
		relations : [
			{
				type : Backbone.HasMany,
				key : 'items',
				relatedModel : Item,
				collectionType : Items,
				includeInJSON : Backbone.Model.prototype.idAttribute,				
				reverseRelation : {
					key : 'wall',
					includeInJSON : Backbone.Model.prototype.idAttribute,														
				}
			},
			{
				type : Backbone.HasOne,
				key : 'owner',
				relatedModel : 'User',
				includeInJSON : Backbone.Model.prototype.idAttribute,				
				reverseRelation : {
					key : 'wall',
					type : Backbone.HasOne,					
					includeInJSON : Backbone.Model.prototype.idAttribute,														
				}
			}			
		]
				
	})
	
	
})
