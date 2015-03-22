require! {
	redis
	'../config'
	'../models/access-token': AccessToken
}
publisher = redis.create-client config.redis.port, config.redis.host

# Number -> Number -> Promise String
exports = (user-id, app-id) -> new Promise (resolve, reject) ->
	access-token <- AccessToken.find-by-user-id-and-app-id user-id, app-id
	if !access-token?
		AccessToken.create app-id, user-id, resolve
	else
		reject!
