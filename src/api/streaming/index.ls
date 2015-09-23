#
# Misskey StreaminAPI server
#

require! {
	'../../config'
	'./home'
}

console.log 'Streaming servers loader loaded'
home!
