require! {
	async
	'../models/application': Application
	'../models/user': User
	'../models/status': Status
	'./user-response-filter'
	'../config'
}
exports = (status, callback) ->
	status.is-reply = status.in-reply-to-status-id == 0 or status.in-reply-to-status-id == null
	async.series do
		[
			# Get application
			(next) ->
				Application.find-by-id status.app-id, (, application) ->
					| application? => next null application
					| _ => next nul null
			
			# Get author
			(next) ->
				User.find-by-id status.user-id, (, user) ->
					user-response-filter user, (user) ->
						next null user
			
			# Get reply from
			(next) ->
				| status.is-reply =>
					Status.find-by-id status.in-reply-to-status-id, (, replyfrom) ->
						| replyfrom? =>
							replyfrom.is-reply = replyfrom.in-reply-to-status-id == 0 or replyfrom.in-reply-to-status-id == null
								User.find-by-id replyfrom.user-id, (, replyfromauthor) ->
									user-response-filter replyfromauthor, (replyfromauthor) ->
										replyfrom.user = replyfromauthor
										next null replyfrom
						| _ => next null null
				| _ => next null null
		]
		(, result) ->
			status.application = result.0
			status.user = result.1
			status.reply = result.2
			callback status
