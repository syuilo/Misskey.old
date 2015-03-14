require! {
	redis
	'../config': config
}
publisher = redis.createClient config.redis.port, config.redis.host
module.export = (channel, value) -> publisher.publish 'misskey:' + channel, value
