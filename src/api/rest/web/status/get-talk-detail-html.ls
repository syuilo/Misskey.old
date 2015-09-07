require! {
	jade
	'../../../auth': authorize
	'../../../../utils/get-express-params'
	'../../../../models/user': User
	'../../../../models/status': Status
	'../../../../models/utils/status-get-talk'
	'../../../../web/main/utils/parse-text'
	'../../../../config'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[status-id] = get-express-params req, <[ status-id ]>
	(err, source-status) <- Status.find-by-id status-id
	if source-status?
		if source-status.in-reply-to-status-id?
			status-get-talk source-status .then (talk) ->
				status-compiler = jade.compile-file "#__dirname/../../../../web/main/views/dynamic-parts/status/detail/reply.jade"
				Promise.all (talk |> map (status) -> new Promise (resolve,) ->
					status .= to-object!
					(err, status-user) <- User.find-by-id status.user-id
					status.user = status-user
					resolve status)
				.then (timeline) ->
					statuses-htmls = timeline |> map (status) ->
						status-compiler do
							status: status
							login: yes
							me: user
							text-parser: parse-text
							config: config.public-config
					res.api-render statuses-htmls.join ''
