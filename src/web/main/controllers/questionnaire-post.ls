require! {
	nodemailer
	'../../../models/user': User
	'../../../config'
}

module.exports = (req, res) ->
	me = if req.login then req.me else null
	
	# SMTP Settings
	setting =
		service: \Gmail
		auth:
			user: config.email-smtp-user
			pass: config.email-smtp-pass

	mail-options =
		from: config.email-smtp-user #'syuilo@misskey.xyz'
		to: 'syuilotan@yahoo.co.jp'
		subject: 'Questionnaire'
		html: 'test'

	smtp = nodemailer.create-transport setting

	smtp.send-mail mail-options, (err) ->
		if err
			console.log err
			res.display req, res, \something-happened
		else
			res.display req, res, \questionnaire-submitted
		smtp.close!
