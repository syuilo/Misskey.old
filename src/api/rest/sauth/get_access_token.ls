require! {
	'../../../utils/access-token': AccessTokenManager
	'../../../models/application': Application
	'../../../models/sauth-pincode': SauthPinCode
	'../../../models/sauth-request-token': SauthRequestToken
}

module.exports = (req, res) ->
	consumer-key = req.query.consumer_key
	request-token = req.query.request_token
	pincode  = req.query.pincode		

	switch
		| req.query.consumer_key == null =>
			res.api-error 400 'consumer_key parameter is required :('
		| req.query.request_token == null =>
			res.api-error 400 'request_token parameter is required :('
		| req.query.pincode == null =>
			req.api-errow 400 'pincode parameter is required :('
		|  _ =>
			Application.find-by-consumer-key consumer-key, (app) ->
				if app != null
					SauthRequestToken.find request-token, (request-token-instance) ->
						switch
							| request-token-instance == null =>
								res.api-error 404 'Invalid request token'
							| request-token-instance.app-id !== app.id =>
								res.api-error 400 'Invalid token :('
							| _ =>
								SauthPinCode.find pincode, (pincode-instance) ->
									switch
										| pincode-instance == null =>
											res.api-error 404, 'Invalid request token :('
										| pincode-instance.app-id !== app.id
											res.api-error 400 'Invalid pincode :('
										| _ =>
											pincode-instance.destroy!
											request-token-instance-destroy!
											AccessTokenManager.create pincode-instance.user-id, app.id, ->, (access-token) ->
												res.api-render do
													access_token: access-token.token

				else
					res.api-error 404, 'Invalid consumer key :('
