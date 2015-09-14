require! {
	'./serialize-mobile-timeline-status'
	'../../../config'
}

# [Status] -> User -> Promise [Status]
module.exports = (statuses, me) ->
	Promise.all (statuses |> map (status) ->
		resolve, reject <- new Promise!
		serialize-mobile-timeline-status status, me, (serialized-status) ->
			resolve serialized-status)
