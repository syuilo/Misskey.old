require! {
	'../../../models/notice': Notice
	'../../auth': authorize
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	if app?
		(err, notices) <- Notice.find {user-id: user.id, app-id: app.id}
		Promise.all (notices |> map (notice) -> new Promise (resolve,) -> notice.remove -> resolve!)
			.then -> res.api-render status: \success
	else
		(err, notices) <- Notice.find {user-id: user.id}
		Promise.all (notices |> map (notice) -> new Promise (resolve,) -> notice.remove -> resolve!)
			.then -> res.api-render status: \success