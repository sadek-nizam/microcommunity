exports.index = function(req,res) {
	res.render('settings',{current_user: req.user});
};
	
