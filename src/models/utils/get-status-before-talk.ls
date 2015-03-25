

require! {
	'../status': Status
}

# Number -> Promise [Status]
module.exports = fix (get-status-before-talk, id) -->
	resolve, reject <- new Promise!
	err, status <- Status.find-by-id id
	switch
	| err? => reject err
	| status.in-reply-to-status-id? or status.in-reply-to-status-id == 0 =>
		resolve [status]
	| _ => get-status-before-talk status.in-reply-to-status-id .then (next-statuses) -> resolve next-statuses ++ [status]
