require! {
	'./serialize-detail-one-status'
	'../../../../../config'
}

# [Status] -> User -> Promise [Status]
module.exports = (statuses, me) ->
	Promise.all (statuses |> map (status) ->
		resolve, reject <- new Promise!
		serialize-detail-one-status status, me, (serialized-status) ->
			resolve serialized-status)
