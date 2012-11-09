exports.settings = function(app,db){
	app.get('/settings',function(req,res){
		res.render('settings',{current_user: req.user});
	});
};
	