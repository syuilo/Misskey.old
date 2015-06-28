require! {
	jade
	'./parse-text'
	'../../config'
}

module.exports = (messages, me) ->
	resolve, reject <- new Promise!
	if messages?
		message-compiler = jade.compile-file "#__dirname/../views/dynamic-parts/user-talk/message.jade"
		resolve (messages |> map (message) ->
			message-compiler do
				message: message
				me: me
				text-parser: parse-text
				config: config.public-config)
	else
		resolve null