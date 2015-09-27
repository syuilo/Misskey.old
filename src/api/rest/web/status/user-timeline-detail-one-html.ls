require! {
	jade
	'../../../auth': authorize
	'../../../../utils/get-express-params'
	'../../../../models/status': Status
	'../../../../models/utils/status-get-user-timeline'
	'../../../../web/main/sites/desktop/utils/detail-one-timeline-serialyzer'
	'../../../../web/main/sites/desktop/utils/parse-text'
	'../../../../config'
}

module.exports = (req, res) ->
	authorize req, res, case-login, case-not-login

	function case-login(user, app)
		main user

	function case-not-login
		main null

	function main(user)
		[user-id, since-cursor, max-cursor] = get-express-params req, <[ user-id since-cursor max-cursor ]>
		status-get-user-timeline do
			user-id
			10statuses
			if not empty since-cursor then Number since-cursor else null
			if not empty max-cursor then Number max-cursor else null
		.then (statuses) ->
			status-compiler = jade.compile-file "#__dirname/../../../../web/main/sites/desktop/views/dynamic-parts/status/detail-one/status.jade"
			detail-timeline-serialyzer statuses, user .then (timeline) ->
				statuses-htmls = map do
					(status) ->
						status-compiler do
							status: status
							login: user?
							me: user
							text-parser: parse-text
							config: config.public-config
					timeline
				res.api-render statuses-htmls.join ''
