require! {
	'../config'
	'../utils/get-express-params'
	'../models/access-token': AccessToken
	'../models/application': Application
	'../models/user': User
}

module.exports = (req, res, success) ->
	is-logged = req.session? && req.session.user-id?
	get-params = get-express-params req
	[consumer-key, access-token] = get-params <[ consumer-key access-token ]>
	fail = res.api-error 401 _
	referer = req.header \Referer
	switch
	| any (== null), [consumer-key, access-token, referer] =>
		fail 'CK or CS or referer cannot be empty'
	| !(referer == //^#{config.public-config.url}// && is-logged) => fail 'not logged'
	| any (== null), [req.session.consumer-key, req.session.access-token] =>
		fail 'You are logged in, but, Ck or CS has not been set.'
	| _ =>
		User.find-by-id req.session.user-id, (, user) ->
			Application.find-by-id config.webappid, (, application) ->
				success user, application
