require! {
	redis
	'../config'
	'../models/access-token': AccessToken
}

publisher = redis.create-client config.redis.port, config.redis.host

# Number -> Number -> Promise String
module.exports = (user-id, app-id) ->
	resolve, reject <- new Promise!
	access-token <- AccessToken.find-by-user-id-and-app-id user-id, app-id
	if access-token?
		then reject!
		else AccessToken.create app-id, user-id, resolve
