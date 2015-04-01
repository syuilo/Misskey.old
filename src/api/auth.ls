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
	[consumer-key, access-token] = get-express-params req, <[ consumer-key access-token ]>
	
	fail = res.api-error 401 _
	required = (key) -> res.api-error 401 "#key is required"
	referer = req.header \Referer
	
	switch
	| empty consumer-key => required 'consumer-key'
	| empty access-token => required 'access-token'
	| empty referer => fail 'refer is empty'
	| !(referer == //^#{config.public-config.url}// && is-logged) => fail 'not logged'
	| any is-null, [req.session.consumer-key, req.session.access-token] =>
		fail 'You are logged in, but, Ck or CS has not been set.'
	| _ =>
		(, user) <- User.find-by-id req.session.user-id
		(, application) <- Application.find-by-id config.webappid
		success user, application
