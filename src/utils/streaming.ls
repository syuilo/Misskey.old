require! {
	redis
	'../config'
}
publisher = redis.create-client config.redis.port, config.redis.host
export publish = (channel, value) -> publisher.publish 'misskey:' + channel, value
