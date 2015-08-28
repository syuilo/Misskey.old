require! {
	nodemailer
	'../../../models/user': User
	'../../../config'
}

module.exports = (req, res) ->
	me = if req.login then req.me else null
	
	# SMTP Settings
	setting =
		host: config.email-smtp-host
		auth:
			user: config.email-smtp-user
			pass: config.email-smtp-pass
			port: config.email-smtp-port

	mail-options =
		from: 'syuilo@misskey.xyz'
		to: 'syuilotan@yahoo.co.jp'
		subject: 'Questionnaire'
		html: 'test'

	smtp = nodemailer.create-transport \SMTP setting

	smtp.send-mail mail-options, (err) ->
		if err
			console.log err
			res.display req, res, \something-happened
		else
			res.display req, res, \questionnaire-submitted
		smtp.close!
