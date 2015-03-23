import require \prelude-ls
import require './mongoose-query'

require! {
	'../status': Status
	'../status-mention': StatusMention
	'../../utils/is-null'
}

exports = (user-id, limit, since-id, max-id) ->
	resolve, reject <- new Promise!
	
	query = | all is-null, [since-id, max-id] => {user-id}
		| since-id? => {user-id} `$and` {status-id: {$gt: since-id}}
		| max-id?   => {user-id} `$and` {status-id: {$lt: max-id}}
	(, mentions) <- StatusMention
		.find query
		.sort \-status-id
		.limit limit
		.exec
	
	promises = mentions |> map (mention) -> new Promise (resolve-mention, reject-mention) ->
		Status.find-by-id mention.status-id, (, status) -> resolve-mention status
	Promise.all promises .then resolve
