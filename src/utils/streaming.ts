/// <reference path="../../typings/bundle.d.ts" />

import config = require('../config');
import redis = require('redis');

var publisher = redis.createClient(config.redis.port, config.redis.host);

export = Streamer;

class Streamer {
	public static publish(channel: string, value: any) {
		publisher.publish('misskey:' + channel, value);
	}
}