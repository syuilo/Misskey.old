require! {
	'../config'
	'../utils/get-express-params'
	'../models/access-token': AccessToken
	'../models/application': Application
	'../models/user': User
	'../utils/is-null'
}

module.exports = (req, res, success) ->
	function is-logged
		req.session? && req.session.user-id?
		
	referer = req.header \Referer
	
	switch
	| empty referer => res.api-error 401 'refer is empty'
	| not is-logged req => res.api-error 401 'not logged'
	| (req.header\Referer == //^#{config.public-config.url}//) => res.api-error 401 'invalid request'
	| _ =>
		(, user) <- User.find-by-id req.session.user-id
		(, application) <- Application.find-by-id config.webappid
		success user, application


