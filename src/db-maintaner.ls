require! {
	'./models/status': Status
	'./config'
}

global <<< require \prelude-ls

Status.find {} (err, statuses) ->
	statuses |> each (status) ->
		status.image-urls = undefined
		status.save!
