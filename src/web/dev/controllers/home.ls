require! {
	'../../../models/user': User
	'../../../config'
}

module.exports = (req, res) ->
	res.display req, res, \home
