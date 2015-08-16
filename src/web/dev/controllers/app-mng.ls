require! {
	'../../../models/user': User
	'../../../models/application': Application
	'../../../config'
}

module.exports = (req, res) ->
	if req.login
		(err, app) <- Application.find-by-id req.params.app-id
		if app?
			if req.me.id.to-string! == app.user-id.to-string!
				res.display req, res, \app-mng {
					app
				}
