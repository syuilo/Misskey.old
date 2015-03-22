require! {
	redis
	'../config'
}
publisher = redis.create-client config.redis.port, config.redis.host

# String -> String -> Undefined
exports = (channel, value) --> publisher.publish "misskey:#channel" value
