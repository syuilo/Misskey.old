require! {
	'../models/status': Status
	'../models/status-mention': StatusMention
}

exports = (user-id, limit, since-id, max-id, callback) ->
	function query-callback(, mentions)
		promises |> map (mention) -> new Promise (on-fulfilled, ) -> 
			Status.find-by-id mention.status-id, (, status) ->
				on-fulfilled status
		Promise.all promises .then (statuses) -> callback statuses
	query = switch
		| !since-id? and !max-id? => { user-id }
		| since-id? => { $and: [ user-id, status-id: { $gt: since-id } ] }
		| max-id? => { $and: [ user-id, status-id: { $lt: max-id } ] }
	StatusMention
		.find query
		.sort \-status-id # Desc
		.limit limit
		.exec query-callback
