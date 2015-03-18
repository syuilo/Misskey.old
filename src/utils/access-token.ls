require! {
	redis
	'../config'
	'../models/access-token': AccessToken
}
publisher = redis.create-client config.redis.port, config.redis.host
export create = (user-id, app-id, fail, success) ->
	AccessToken.find-by-user-id-and-app-id userId, appId, (access-token-str) ->
		| access-token-str == null => AccessToken.create app-id, user-id, (access-token) -> success access-token
		| _ => fail!
