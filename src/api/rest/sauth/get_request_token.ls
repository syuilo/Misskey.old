require! {
	'../../../models/sauth-request-token': SauthRequestToken
	'../../../models/application': Application
}
module.exports = (req, res) ->
	consumer-key = if typeof req.query.consumer_key !== 'undefined' then req.query.consumer_key else null
	if consumer-key != null
		Application.find-by-consumer-key consumer-key, (app) ->
			if app != null
				SauthRequestToken.create app.id, (request-token) ->
					res.api-render token: request-token.token
			else
				res.api-error 404 'Invalid consumer key :('
	else
		res.api-error 400 'consumer_key parameter is required :('
