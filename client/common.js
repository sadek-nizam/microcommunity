require.config({
	baseUrl: "../client",

  paths: {
    cs: 'cs',
    'coffee-script': 'coffee-script',
    jquery : 'lib/jquery.min',
    text : 'lib/require/text',
    backbone : 'lib/backbone.min',
    'backbone-relational' : 'lib/backbone-relational',    
    underscore: 'lib/underscore.min',
    bootstrap: 'lib/bootstrap.min',
    bootbox: 'lib/bootbox.min',
    'jquery.gravatar': 'lib/jquery.gravatar',
    'jquery.spin': 'lib/jquery.spin',
    'spin': 'lib/spin.min',
    'md5' : 'lib/md5',
    'general' : 'lib/general',
    'moment' : 'lib/moment.min',
    'diff' : 'lib/diff',
    'bootstrap-notify' : 'lib/bootstrap-notify'
  },
  
  shim: {
  	'backbone' : {
  		deps: ["underscore", "jquery"],
  		exports: "Backbone"
  	}, 
  	'underscore' : {
  		exports : "_"
  	},  
  	'jquery' : {
  		exports : 'jQuery'
  	},
  	
  	'jquery.gravatar' : ['jquery', 'md5'],
  	'jquery.spin' : ['jquery', 'spin'],
  	'md5' : [],
  	'general' : ['jquery'],
  	'moment' : [],
  	'diff' : [],
  	'bootstrap-notify': ['jquery'],
  	'bootbox' : ['bootstrap'],
  	'backbone-relational' : ['backbone'],

  	'bootstrap' : {
  		exports: ''
  	}  	
  	
  }
  
});
