require! {
	'../../../models/sauth-request-token': SauthRequestToken
	'../../../models/application': Application
}

module.exports = (req, res) ->
	consumer-key = req.query.consumer-key ? null
	if consumer-key?
		Application.find-by-consumer-key consumer-key, (app) ->
			if app?
				SauthRequestToken.create app.id, (request-token) ->
					res.api-render token: request-token.token
			else
				res.api-error 404 'Invalid consumer key :('
	else
		res.api-error 400 'consumerKey parameter is required :('
