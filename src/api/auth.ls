require! {
	'../config'
	'../utils/get-express-params'
	'../models/access-token': AccessToken
	'../models/application': Application
	'../models/user': User
	'../utils/is-null'
}

module.exports = (req, res, success) ->
	is-logged = req.session? && req.session.user-id?
	
	fail = res.api-error 401 _
	referer = req.header \Referer
	
	switch
	| empty referer => fail 'refer is empty'
	| !(referer == //^#{config.public-config.url}// && is-logged) => fail 'not logged'
	| _ =>
		(, user) <- User.find-by-id req.session.user-id
		(, application) <- Application.find-by-id config.webappid
		success user, application
