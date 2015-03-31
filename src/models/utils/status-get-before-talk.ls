require! {
	'../status': Status
	'./status-get-before-talk'
}

# Number -> Promise [Status]
module.exports = fix (get-status-before-talk, id) -->
	resolve, reject <- new Promise!
	err, status <- Status.find-by-id id
	switch
	| err? => reject err
	| status.in-reply-to-status-id? =>
		resolve [status]
	| _ => status-get-before-talk status.in-reply-to-status-id .then (next-statuses) -> resolve next-statuses ++ [status]
