require! {
	async
	'../application': Application
	'../user': User
	'../status': Status
	'./filter-user-for-response'
	'../../config'
}
module.exports = (source-status, callback) ->
	status = {
		app-id: source-status.app-id
		created-at: source-status.created-at
		favorites-count: source-status.favorites-count
		in-reply-to-status-id: source-status.in-reply-to-status-id
		is-image-attached: source-status.is-image-attached
		reposts-count: source-status.reposts-count
		repost-from-status-id: source-status.repost-from-status-id
		text: source-status.text
		user-id: source-status.user-id
	}
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
				(, user) <- User.find-by-id status.user-id
				next null filter-user-for-response user
			
			# Get reply from
			(next) ->
				| status.is-reply =>
					Status.find-by-id status.in-reply-to-status-id, (, replyfrom) ->
						| replyfrom? =>
							replyfrom.is-reply = replyfrom.in-reply-to-status-id == 0 or replyfrom.in-reply-to-status-id == null
							User.find-by-id replyfrom.user-id, (, replyfromauthor) ->
								filter-user-for-response replyfromauthor, (replyfromauthor) ->
									replyfrom.user = replyfromauthor
									next null replyfrom
						| _ => next null null
				| _ => next null null
		]
		(, [status.application, status.user, status.reply]) -> callback status
