#
# Misskey StreaminAPI server
#

require! {
	'../../config'
	'./home'
}

module.exports = ->
	console.log 'Streaming servers loader loaded'
	home!
