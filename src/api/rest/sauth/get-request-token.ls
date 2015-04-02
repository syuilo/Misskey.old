require! {
	'../../../models/sauth-request-token': SauthRequestToken
	'../../../models/application': Application
}

module.exports = (req, res) -> 
	| !(consumer-key = req.query.consumer-key)? => res.api-error 400 'consumerKey parameter is required :('
	| _ => Application.find-by-consumer-key consumer-key, (app) -> 
		| !app? => res.api-error 404 'Invalid consumer key :('
		| _ => SauthRequestToken.create app.id, (request-token) -> res.api-render token: request-token.token
