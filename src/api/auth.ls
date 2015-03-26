

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
		{consumer-key, access-token} = req.session
		AccessToken.find access-token, (access-token-instance) ->
			| !access-token-instance? => fail 'Bad request'
			| _ => Application.find-by-consumer-key consumer-key, (application) ->
				| !application? || access-token-instance.app-id != application.id => fail 'Bad request'
				| _ => User.find access-token-instance.user-id, (user) ->
					| user? => success user, application
					| _ => fail 'Bad requst'
