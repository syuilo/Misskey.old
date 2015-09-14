require! {
	jade
	nodemailer
	'../../../models/user': User
	'../../../config'
}

module.exports = (req, res) ->
	me = if req.login then req.me else null
	
	status-timeline-frequency = req.body\status-timeline-frequency
	status-timeline-usability = req.body\status-timeline-usability
	status-timeline-usability-suggestion = req.body\status-timeline-usability-suggestion
	talk-frequency = req.body\talk-frequency
	talk-usability = req.body\talk-usability
	talk-usability-suggestion = req.body\talk-usability-suggestion
	bbs-frequency = req.body\bbs-frequency
	bbs-usability = req.body\bbs-usability
	bbs-usability-suggestion = req.body\bbs-usability-suggestion
	design = req.body\design
	message = req.body\message
	
	questionnaire-compiler = jade.compile-file "#__dirname/../views/questionnaire.jade"
	
	html = questionnaire-compiler {
		me
		status-timeline-frequency
		status-timeline-usability
		status-timeline-usability-suggestion
		talk-frequency
		talk-usability
		talk-usability-suggestion
		bbs-frequency
		bbs-usability
		bbs-usability-suggestion
		design
		message
	}
	
	# SMTP Settings
	setting =
		host: config.email-smtp-host
		port: config.email-smtp-port
		secure-connection: no
		auth:
			user: config.email-smtp-user
			pass: config.email-smtp-pass

	mail-options =
		from: 'syuilo@misskey.xyz'
		to: 'syuilotan@yahoo.co.jp'
		subject: 'Questionnaire'
		html: html

	smtp = nodemailer.create-transport setting

	smtp.send-mail mail-options, (err) ->
		if err
			console.log err
			res.display req, res, \something-happened
		else
			res.display req, res, \questionnaire-submitted
		smtp.close!
