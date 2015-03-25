#
# Web index router
#

require! {
	fs
	express
	'../../models/access-token': AccessToken
	'../../models/user': User
	'../../models/status': Status
	'../utils/login': do-login
	'../../config': config
	'./image': image-router
}

module.exports = (app) ->
	# unstatic images
	image-router app
	
	# Preset
	app.param \userSn (req, res, next, screen-name) ->
		User.find-one {screen-name} (, user) ->
			if user?
				req.root-user = req.data.root-user = user
				next!
			else
				res
					..status 404
					..display req, res, 'user-not-found' {}
	app.param \statusId (req, res, next, status-id) ->
		Status.find-by-id status-id, (, status) ->
			if status?
				req.root-status = req.data.root-status = status
				next!
			else
				res
					..status 404
					..display req, res, 'status-not-found' {}
	app.get '/' (req, res, next) ->
		if req.login
			then (require '../controllers/home') req, res
			else res.display req, res, 'entrance', {}
	app.get '/config' (req, res, next) ->
		res.set 'Content-Type' 'application/javascript'
		res.send 'var conf = ' + (JSON.stringify config.public-config) + ';'
	app.get '/new' (req, res, next) -> (require '../controllers/new') req, res
	app.get '/i/mention' (req, res, next) -> (require '../controllers/i-mention') req, res
	app.get '/i/mentions' (req, res, next) -> (require '../controllers/i-mention') req, res
	app.get '/i/talk' (req, res, next) -> (require '../controllers/i-talks') req, res
	app.get '/i/talks' (req, res, next) -> (require '../controllers/i-talks') req, res
	app.get '/i/setting' (req, res, next) -> (require '../controllers/i-setting') req, res
	app.get '/i/settings' (req, res, next) -> (require '../controllers/i-setting') req, res
	app.get '/dev' (req, res, next) -> (require '../controllers/dev') req, res
	app.get '/dev/myapp' (req, res, next) -> (require '../controllers/dev-myapp') req, res
	app.get '/dev/myapp/new' (req, res, next) -> (require '../controllers/dev-myapp-new') req, res
	app.get '/dev/usertheme' (req, res, next) -> (require '../controllers/dev-usertheme') req, res
	app.get '/dev/usertheme/new' (req, res, next) -> (require '../controllers/dev-usertheme-new') req, res
	app.get '/login' (req, res) -> res.display req, res, 'login', {}
	app.post '.login' (req, res) ->
		doLogin req, req.body.screen_name, req.body.password, (user) ->
			res.send-status 200
		, -> res.send-status 400
	app.get '/logout' (reqy, res) ->
		req.session.destroy (err) -> res.redirect '/'
	app.get '/:userSn' (req, res, next) -> (require '../controllers/user') req, res, \home
	app.get '/:userSn/followings' (req, res, next) -> (require '../controllers/user') req, res, \followings
	app.get '/:userSn/followers' (req, res, next) -> (require '../controllers/user') req, res, \followers
	app.get '/:userSn/talk' require '../controllers/user-talk'
	app.get '/:userSn/:postId(\\d+)' (req, res, next) -> (require '../controllers/post') req, res
	app.get '/:userSn/post/:postId(\\d+)' (req, res, next) -> (require '../controllers/post') req, res
