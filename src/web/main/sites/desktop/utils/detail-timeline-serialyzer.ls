require! {
	'./serialize-detail-timeline-status'
	'../../../../../config'
}

# [Status] -> User -> Promise [Status]
module.exports = (statuses, me) ->
	Promise.all (statuses |> map (status) ->
		resolve, reject <- new Promise!
		serialize-detail-timeline-status status, me, (serialized-status) ->
			resolve serialized-status)
