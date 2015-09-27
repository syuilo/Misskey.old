require! {
	jade
	'../../../auth': authorize
	'../../../../utils/get-express-params'
	'../../../../models/status': Status
	'../../../../models/utils/status-get-user-timeline'
	'../../../../web/main/sites/desktop/utils/serialize-detail-one-status'
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
			1status
			if not empty since-cursor then Number since-cursor else null
			if not empty max-cursor then Number max-cursor else null
		.then (statuses) ->
			status = statuses.0
			status-compiler = jade.compile-file "#__dirname/../../../../web/main/sites/desktop/views/dynamic-parts/status/detail-one/status.jade"
			serialize-detail-one-status status, user, (detail-status) ->
				html = status-compiler do
					status: detail-status
					login: user?
					me: user
					text-parser: parse-text
					config: config.public-config
				res.api-render html
