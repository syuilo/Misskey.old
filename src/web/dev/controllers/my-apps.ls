require! {
	'../../../models/application': Application
	'../../../models/user': User
	'../../../config'
}

module.exports = (req, res) ->
	Application.find {user-id: req.me.id} (err, apps) ->
		res.display req, res, \my-apps {
			apps
		}
