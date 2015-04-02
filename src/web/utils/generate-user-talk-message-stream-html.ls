require! {
	jade
	'./parse-text'
	'../../config'
}

module.exports = (messages, me, callback) ->
	message-compiler = jade.compile-file "#__dirname/../views/templates/user-talk/message.jade" {pretty: '  '}
	if messages?
		callback (messages |> map (message) ->
			message-compiler do
				message: message
				me: me
				text-parser: parse-text
				config: config.public-config)
	else
		callback null