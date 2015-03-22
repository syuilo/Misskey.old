require! {
	'../models/status': Status
}

# Number -> Promise [Status]
exports = get-status-before-talk

function get-status-before-talk id
	(resolve, reject) <- new Promise!
	(, status) <- Status.find-by-id id
	if status.in-reply-to-status-id? or status.in-reply-to-status-id == 0
		resolve [status]
	else
		get-status-before-talk status.in-reply-to-status-id .then -> resolve next-statuses ++ [status]
