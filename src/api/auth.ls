import require \prelude-ls

require! {
	'../models/access-token': AccessToken
	'../models/application': Application
	'../config': config
	'../models/user': User
}

export (req, res, success) ->
	is-logged = req.session? && req.session.user-id?
	get-parameter = (req, name) -> req[if req.method == \GET then \query else \body][name]
	consumer-key = get-parameter req, 'consumer_key'
	access-token = get-parameter req, 'access_token'
	fail = (message) -> res.api-error 401 message
	referer = req.header 'Referer'
	switch
	| [consumer-key, access-token, referer] |> map (== null) |> or-list =>
		fail 'CK or CS or referer cannot be empty'
	| !(referer.match new RegExp '^' + config.public-config.url && is-logged) => fail 'not logged'
	| [req.session.consumer-key, req.session.access-token] |> map (== null) |> or-list =>
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
