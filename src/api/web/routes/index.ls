#
# Web index router
#

require! {
	fs
	express
	'../../../models/user': User
	'../../../config'
}

module.exports = (app) ->
	app.get '/authorize@:sessionKey' (req, res) ->
		(require '../controllers/authorize') req, res
	
	# Config javascript
	app.get '/config' (req, res) ->
		res.set 'Content-Type' 'application/javascript'
		res.send "var config = conf = #{to-json config.public-config};"

