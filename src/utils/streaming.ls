require! {
	redis
	'../config'
}
publisher = redis.createClient config.redis.port, config.redis.host
export publish = (channel, value) -> publisher.publish 'misskey:' + channel, value
