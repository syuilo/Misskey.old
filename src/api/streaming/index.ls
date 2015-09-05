#
# Misskey StreaminAPI server
#

require! {
	'../config'
	'./home'
}

exports.server = (server) ->
	home server 