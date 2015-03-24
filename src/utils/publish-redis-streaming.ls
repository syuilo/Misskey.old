require! {
	redis
	'../config'
}
publisher = redis.create-client config.redis.port, config.redis.host

# String -> String -> Undefined
module.exports = (channel, msg) --> publisher.publish "misskey:#channel" msg
