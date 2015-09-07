require! {
	jade
	'../../../auth': authorize
	'../../../../utils/get-express-params'
	'../../../../models/status': Status
	'../../../../models/utils/status-get-talk'
	'../../../../web/main/utils/detail-timeline-serialyzer'
	'../../../../web/main/utils/parse-text'
	'../../../../config'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[status-id] = get-express-params req, <[ status-id ]>
	(err, status) <- Status.find-by-id status-id
	if status?
		if status.is-reply
			status-get-talk status .then (talk) ->
				status-compiler = jade.compile-file "#__dirname/../../../../web/main/views/dynamic-parts/status/detail/reply.jade"
				detail-timeline-serialyzer talk, user .then (timeline) ->
					statuses-htmls = map do
						(status) ->
							status-compiler do
								status: status
								login: yes
								me: user
								text-parser: parse-text
								config: config.public-config
						timeline
					res.api-render statuses-htmls.join ''
