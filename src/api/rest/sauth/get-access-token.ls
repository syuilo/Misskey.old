require! {
	'../../../utils/access-token': AccessTokenManager
	'../../../models/sauth-pincode': SauthPinCode
	'../../../models/sauth-request-token': SauthRequestToken
}

module.exports = (req, res) ->
	| !(consumer-key = req.query.consumer-key)? => res.api-error 400 'consumerKey parameter is required :('
	| !(request-token = req.query.request-token)? => res.api-error 400 'requestToken parameter is required :('
	| !(pincode = req.query.pincode)? => req.api-error 400 'pincode parameter is required :('
	|  _ => Application.find-by-consumer-key consumer-key, (app) ->
		| app? => SauthRequestToken.find request-token, (request-token-instance) ->
			| !request-token-instance? => res.api-error 404 'Invalid request token'
			| request-token-instance.app-id != app.id => res.api-error 400 'Invalid token :('
			| _ => SauthPinCode.find pincode, (pincode-instance) ->
				| !pincode-instance? => res.api-error 404 'Invalid request token :('
				| pincode-instance.app-id !== app.id => res.api-error 400 'Invalid pincode :('
				| _ =>
					pincode-instance.destroy!
					request-token-instance-destroy!
					AccessTokenManager.create pincode-instance.user-id, app.id, ->, (access-token) ->
						res.api-render access-token: access-token.token
		| _ => res.api-error 404, 'Invalid consumer key :('
