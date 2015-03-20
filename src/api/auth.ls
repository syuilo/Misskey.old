import require \prelude-ls

require! {
	'../models/access-token': AccessToken
	'../models/application': Application
	'../config'
	'../models/user': User
}

exports = (req, res, success) ->
	is-logged = req.session? && req.session.user-id?
	get-parameter = (req, name) -> req[{GET: \query, POST: \body}[req.method]][name]
	consumer-key = get-parameter req, 'consumer_key'
	access-token = get-parameter req, 'access_token'
	fail = res.api-error 401 _
	referer = req.header 'Referer'
	switch
	| any (== null), [consumer-key, access-token, referer] =>
		fail 'CK or CS or referer cannot be empty'
	| !(referer.match new RegExp '^' + config.public-config.url && is-logged) => fail 'not logged'
	| any (== null), [req.session.consumer-key, req.session.access-token] =>
		fail 'You are logged in, but, Ck or CS has not been set.'
	| _ =>
		consumer-key = req.session.consumer-key
		access-token = req.session.access-token

		AccessToken.find access-token, (access-token-instance) ->
			| !access-token-instance? => fail 'Bad request'
			| _ => Application.find-by-consumer-key consumer-key, (application) ->
				| !application? || access-token-instance.app-id != application.id => fail 'Bad request'
				| _ => User.find access-token-instance.user-id, (user) ->
					| user? => success user, application
					| _ => fail 'Bad requst'
