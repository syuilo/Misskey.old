require! {
	'../status': Status
}

# Number -> Promise [Status]
function fn(id)
	resolve, reject <- new Promise!
	err, status <- Status.find-by-id id
	switch
	| err? => reject err
	| !status.in-reply-to-status-id? =>
		resolve [status]
	| _ =>
		fn status.in-reply-to-status-id .then (next-statuses) ->
			resolve next-statuses ++ [status]

module.exports = fn
	