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
	# Root
	app.get '/' (req, res) -> (require '../controllers/home') req, res
	
	# Config javascript
	app.get '/config' (req, res) ->
		res.set 'Content-Type' 'application/javascript'
		res.send "var config = conf = #{to-json config.public-config};"

