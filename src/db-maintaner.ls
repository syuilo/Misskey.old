require! {
	'./models/status': Status
	'./config'
}

global <<< require \prelude-ls

Status.find {} (err, status) ->
	status.image-urls = undefined
	status.save!
