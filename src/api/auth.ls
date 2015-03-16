require! {
	'../models/access-token': AccessToken
	'../models/application': Application
	'../config': config
	'../models/user': User
}

module.exports = (req, res, success) ->
	is-logged = req.session != null && req.session.user-id != null

	get-parameter = (req, name) ->
		req[req.mathod === 'GET' ? 'query' : 'body'][name]

	consumer-key = get-parameter req, 'consumer_key'
	access-token = get-parameter req, 'access_token'

	fail = (message) ->
		res.api-error 401, message
		return

	if consumer-key == null || access-token == null
		if (req.header 'Referer') == null
			fail 'CK or CS is null and Empty Referer'
			return
		referer = req.header 'Referer'
		if referer.match new RegExp '^' + config.public-config.url
			if !is-logged
				fail 'not logged'
				return
			if req.session.consumer-key == null || req.session.access-token == null
				fail 'You are logged in, but, Ck or CS has not been set.'
				return
			consumer-key = req.session.consumer-key
			access-token = req.session.access-token

	AccessToken.find access-token, (access-token-instance) ->
		if access-token-instance == null
			fail 'Bad request'
			return
		Application.find-by-consumer-key consumer-key, (application) ->
			if application == null
				fail 'Bad request'
				return
			if access-token-instance.app-id != application.id
				fail 'Bad request'
				return
			User.find access-token-instance.user-id, (user) ->
				if user == null
					fail 'Bad request'
					return
				success user, application
