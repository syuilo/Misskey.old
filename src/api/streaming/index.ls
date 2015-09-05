#
# Misskey StreaminAPI server
#

require! {
	express
	redis
	'connect-redis'
	'../config'
}

# Create server
server = express!
	..disable 'x-powered-by'

session-store = new RedisStore do
	db: 1
	prefix: 'misskey-session:'

require './home'

exports.server = server