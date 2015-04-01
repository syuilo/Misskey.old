require! {
	'../user': User
	'../status': Status
}

# Status -> Promise Statuses
module.exports = (status) ->
	| !status.replies? => new Promise((resolve) -> resolve null)
	| _ => Promise.all (status.replies |> map (reply-status-id) ->
			new Promise (resolve, reject) ->
				Status.find-by-id reply-status-id, (, reply-status) ->
					| reply-status? => resolve reply-status
					| _ => resolve null)
