/// <reference path="../../typings/bundle.d.ts" />

import config = require('../config');
import redis = require('redis');

var publisher = redis.createClient(config.redis.port, config.redis.host);

export function publish(channel: string, value: any): void {
	publisher.publish('misskey:' + channel, value);
}
