require! {
	'../../../models/user': User
	'../../../config'
}

module.exports = (req, res) ->
	console.log \kyoppie
	res.display req, res, \home
