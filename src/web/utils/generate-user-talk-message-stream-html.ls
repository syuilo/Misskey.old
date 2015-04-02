require! {
	jade
	'./parse-text'
	'../../config'
}

module.exports = (messages, me) ->
	resolve, reject <- new Promise!
	console.log '#####################'
	console.log messages
	message-compiler = jade.compile-file "#__dirname/../views/templates/user-talk/message.jade" {pretty: '  '}
	if !empty messages
		resolve (messages |> map (message) ->
			message-compiler do
				message: message
				me: me
				text-parser: parse-text
				config: config.public-config)
	else
		resolve null