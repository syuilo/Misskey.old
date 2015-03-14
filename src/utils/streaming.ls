require! {
	redis
	'../config': config
}
publisher = redis.createClient config.redis.port, config.redis.host
module.export.publish = (channel, value) -> publisher.publish 'misskey:' + channel, value
