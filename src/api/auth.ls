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

	if consumer-key == null || access-token == null
		if (req.header 'Referer') != null
			referer = req.header 'Referer'
			if referer.match new RegExp '^' + config.public-config.url
				if is-logged
					if req.session.consumer-key != null && req.session.access-token != null
						consumer-key = req.session.consumer-key
						access-token = req.session.access-token
					else
						fail 'You are logged in, but, Ck or CS has not been set.'
						return
				else
					fail 'not logged'
					return
		else
			fail 'CK or CS is null and Empty Referer'
			return

	AccessToken.find access-token, (access-token-instance) ->
		if access-token-instance != null
			Application.find-by-consumer-key consumer-key, (application) ->
				if application != null
					if access-token-instance.app-id === application.id
						User.find access-token-instance.user-id, (user) ->
							if user != null
								success user, application
							else
								fail 'Bad request'
					else
						fail 'Bad request'
				else
					fail 'Bad request'
		else
			fail 'Bad request'
