#
# Web router
#

require! {
	fs
	express
	'../../models/user': User
	'../../models/status': Status
	'../../models/bbs-thread': BBSThread
	'../../utils/login': do-login
	'../../config'
}

module.exports = (app) ->
	console.log 'Web router loaded'

	# Preset
	app.param \userSn (req, res, next, screen-name) ->
		User.find-one {screen-name-lower: screen-name.to-lower-case!} (, user) ->
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
	app.param \bbsThreadId (req, res, next, thread-id) ->
		BBSThread.find-by-id thread-id, (, thread) ->
			if thread?
				req.root-thread = req.data.root-thread = thread
				next!
			else
				res
					..status 404
					..display req, res, 'thread-not-found' {}

	function CallController(req, res, name)
		if req.is-mobile
			(require "./sites/mobile/controllers/#name") req, res
		else
			(require "./sites/desktop/controllers/#name") req, res

	# Root
	app.get '/' (req, res) -> CallController req, res, \home

	# Config javascript
	app.get '/config' (req, res) ->
		res.set 'Content-Type' 'application/javascript'
		res.send "var config = conf = #{to-json config.public-config};"

	# log viewer
	app.get '/log' (req, res) -> res.display req, res, 'log'

	# search
	app.get '/search' (req, res) -> (require './controllers/search') req, res

	# questionnaire
	app.get '/questionnaire' (req, res) -> res.display req, res, 'questionnaire'

	# questionnaire (submit)
	app.post '/questionnaire' (req, res) -> (require './controllers/questionnaire-post') req, res

	# about
	app.get '/about/:title' (req, res) ->
		res.display req, res, "about-articles/#{req.params.title}"

	# talk widget
	app.get '/widget/talk/:userSn' (req, res) -> (require './controllers/user-talk') req, res, \widget

	# BBS home
	app.get '/bbs' (req, res) -> (require './controllers/bbs-home') req, res

	# BBS thread
	app.get '/bbs/thread/:bbsThreadId' (req, res) -> (require './controllers/bbs-thread') req, res

	# BBS thread settings form
	app.get '/bbs/thread/:bbsThreadId/settings' (req, res) -> (require './controllers/bbs-thread-settings') req, res

	# BBS new thread form
	app.get '/bbs/new' (req, res) -> res.display req, res, 'bbs-new-thread'

	# Create status form
	app.get '/i/status-new' (req, res) -> (require './controllers/i-status-new') req, res

	# mentions
	app.get '/i/mentions' (req, res) -> (require './controllers/i-mentions') req, res

	# talks
	app.get '/i/talks' (req, res) -> (require './controllers/i-talks') req, res

	# settings
	app.get '/i/settings' (req, res) -> (require './controllers/i-settings') req, res

	# login
	app.get '/login' (req, res) -> res.display req, res, 'login', {}
	app.post '/login' (req, res) ->
		do-login req, req.body.\screen-name, req.body.password, (user) ->
			res.send-status 200
		, -> res.send-status 400

	# logout
	app.get '/logout' (req, res) ->
		req.session.destroy (err) -> res.redirect '/'

	# User page
	app.get '/:userSn' (req, res) -> (require './controllers/user') req, res, \home

	# User profile
	app.get '/:userSn/profile' (req, res) -> (require './controllers/user') req, res, \profile

	# User followings
	app.get '/:userSn/followings' (req, res) -> (require './controllers/user') req, res, \followings

	# User followers
	app.get '/:userSn/followers' (req, res) -> (require './controllers/user') req, res, \followers

	# talk
	app.get '/:userSn/talk' (req, res) -> (require './controllers/user-talk') req, res, \normal

	# staus detail page
	app.get '/:userSn/status/:statusId' (req, res) -> (require './controllers/status') req, res

	# User profile widget
	app.get '/widget/user/:userSn' (req, res) -> (require './controllers/widget-user-profile') req, res
