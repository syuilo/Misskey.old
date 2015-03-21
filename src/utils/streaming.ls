require! {
	redis
	'../config'
}
publisher = redis.createClient config.redis.port, config.redis.host
exports publish = (channel, value) -> publisher.publish 'misskey:' + channel, value
