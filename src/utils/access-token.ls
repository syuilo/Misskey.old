require! {
	redis
	'../config': config
	'../models/access-token': AccessToken
}
publisher = redis.create-client config.redis.port, config.redis.host
module.exports.create = (user-id, app-id, fail, success) ->
	AccessToken.find-by-user-id-and-app-id userId, appId, (access-token-str) ->
		if access-token-str == null
			AccessToken.create app-id, user-id, (access-token) ->
				success access-token
		else
			fail!
