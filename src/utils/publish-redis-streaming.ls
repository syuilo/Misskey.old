require! {
	redis
	'../config'
}
publisher = redis.create-client config.redis.port, config.redis.host
exports = (channel, value) --> publisher.publish "misskey:#channel" value
