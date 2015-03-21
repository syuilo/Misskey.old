require! {
	'../models/status': Status
}

exports = func

function func(id, callback)
	Status.find-by-id id, (status) ->
		| status.in-reply-to-status-id? or status.in-reply-to-status-id == 0 => callback [status]
		| _ =>
			func status.in-reply-to-status-id, (next-statuses) ->
				next-statuses.push status
				callback next-statuses