require! {
	'../models/access-token': AccessToken
	'../models/application': Application
	'../config': config
	'../models/user': User
}
module.exports = (req, res, success) ->
	is-logged = req.session != null && req.session.user-id != null
	get-parameter = (req, name) -> req[req.mathod === 'GET' ? 'query' : 'body'][name]
	consumer-key = get-parameter req, 'consumer_key'
	access-token = get-parameter req, 'access_token'
	fail = (message) -> res.api-error 401 message
	referer = req.header 'Referer'
	if consumer-key == null || access-token == null || referer  == null
		fail 'CK or CS or referer cannot be empty'
	else if !(referer.match new RegExp '^' + config.public-config.url && is-logged)
		fail 'not logged'
	else if req.session.consumer-key == null || req.session.access-token == null
		fail 'You are logged in, but, Ck or CS has not been set.'
	else
		consumer-key = req.session.consumer-key
		access-token = req.session.access-token

		AccessToken.find access-token, (access-token-instance) ->
			if access-token-instance == null
				fail 'Bad request'
			else
				Application.find-by-consumer-key consumer-key, (application) ->
					if application == null || access-token-instance.app-id !== application.id
						fail 'Bad request'
					else
						User.find access-token-instance.user-id, (user) ->
							if user == null
								then fail 'Bad requst'
								else success user, application
