require! {
	'../../auth': authorize
	'../../../utils/get-express-params'
	'../../../models/status': Status
	'../../../models/utils/status-get-timeline'
	'../../../web/utils/timeline-serialyzer'
	'../../../web/utils/parse-text'
	'../../../config'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[since-cursor, max-cursor] = get-express-params req, <[ since-cursor, max-cursor ]>
	status-get-timeline do
		user.id
		30statuses
		if !empty since-cursor then Number since-cursor else null
		if !empty max-cursor then Number max-cursor else null
	.then (statuses) ->
		status-compiler = jade.compile-file "#__dirname/../../../web/views/templates/status/status.jade"
		timeline-serialyzer statuses, viewer .then (timeline) ->
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
