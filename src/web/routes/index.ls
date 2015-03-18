require! {
	fs
	express
	'../../models/access-token': AccessToken
	'../../models/user': User
	'../utils/login': do-login
	'../../config': config
	'./image': image-router
}
module.exports = (app) ->
	image-router app
	
	app
		..param
			.. 'userSn' (req, res, next, sn) ->
				User.find-by-screen-name sn, (user) ->
					if user != null
						req.root-user = req.data.root-user = user
						next!
					else
						res.status 404
					
			.. 'postId' (req, res, next, post-id) ->
				Post.find post-id, (post) ->
					if post != null
						req.root-post = req.data.root-post = post
						next!
					else
						res.status 404
						res.display req, res, 'post-notFound', {}
		..get
			.. '/' (req, res, next) ->
				if req.login
					then (require '../controllers/home') req, res
					else res.display req, res, 'entrance', {}
			.. '/config' (req, res, next) ->
				res.set 'Content-Type' 'application/javascript'
				res.send 'var conf = ' + (JSON.stringify config.public-config) + ';'
			.. '/new' (req, res, next) -> (require '../controllers/new') req, res
			.. '/i/mention' (req, res, next) -> (require '../controllers/i-mention') req, res
			.. '/i/mentions' (req, res, next) -> (require '../controllers/i-mention') req, res
			.. '/i/talk' (req, res, next) -> (require '../controllers/i-talks') req, res
			.. '/i/talks' (req, res, next) -> (require '../controllers/i-talks') req, res
			.. '/i/setting' (req, res, next) -> (require '../controllers/i-setting') req, res
			.. '/i/settings' (req, res, next) -> (require '../controllers/i-setting') req, res
			.. '/dev' (req, res, next) -> (require '../controllers/dev') req, res
			.. '/dev/reference' (req, res, next) -> (require '../controllers/dev-reference') req, res
			.. '/dev/myapp' (req, res, next) -> (require '../controllers/dev-myapp') req, res
			.. '/dev/myapp/new' (req, res, next) -> (require '../controllers/dev-myapp-new') req, res
			.. '/dev/usertheme' (req, res, next) -> (require '../controllers/dev-usertheme') req, res
			.. '/dev/usertheme/new' (req, res, next) -> (require '../controllers/dev-usertheme-new') req, res
			.. '/login' (req, res) -> res.display req, res, 'login', {}
		..post '.login' (req, res) ->
			doLogin req, req.body.screen_name, req.body.password, (user, webAccessToken) ->
				res.sendStatus200
			, -> res.sendStatus 400
		..get
			.. '/logout' (reqy, res) ->
				req.session.destroy (err) -> res.redirect '/'
			.. '/:userSn' (req, res, next) -> (require '../controllers/user') req, res, \home
			.. '/:userSn/followings' (req, res, next) -> (require '../controllers/user') req, res, \followings
			.. '/:userSn/followers' (req, res, next) -> (require '../controllers/user') req, res, \followers
			..  (req, res, next) -> (require ) req, res, 
			.. '/:userSn/talk' require '../controllers/user-talk'
			.. '/:userSn/:postId(\\d+)' (req, res, next) -> (require '../controllers/post') req, res
			.. '/:userSn/post/:postId(\\d+)' (req, res, next) -> (require '../controllers/post') req, res
