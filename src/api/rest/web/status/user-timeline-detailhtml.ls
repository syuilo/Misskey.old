require! {
	jade
	'../../../auth': authorize
	'../../../../utils/get-express-params'
	'../../../../models/status': Status
	'../../../../models/utils/status-get-user-timeline'
	'../../../../web/main/utils/detail-timeline-serialyzer'
	'../../../../web/main/utils/parse-text'
	'../../../../config'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[user-id, since-cursor, max-cursor] = get-express-params req, <[ user-id since-cursor max-cursor ]>
	status-get-user-timeline do
		user-id
		10statuses
		if not empty since-cursor then Number since-cursor else null
		if not empty max-cursor then Number max-cursor else null
	.then (statuses) ->
		status-compiler = jade.compile-file "#__dirname/../../../../web/main/views/dynamic-parts/status/detail/status.jade"
		detail-timeline-serialyzer statuses, user .then (timeline) ->
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
