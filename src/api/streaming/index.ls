#
# Misskey StreaminAPI server
#

require! {
	'../../config'
	'./home'
}

exports.server = ->
	home!
