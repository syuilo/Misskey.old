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
				req.root-bbs-thread = req.data.root-bbs-thread = thread
				next!
			else
				res
					..status 404
					..display req, res, 'thread-not-found' {}

	function CallController(req, res, name, options = null)
		if req.is-mobile
			(require "./sites/mobile/controllers/#name") req, res, options
		else
			(require "./sites/desktop/controllers/#name") req, res, options

	# Config javascript
	app.get '/config' (req, res) ->
		res.set 'Content-Type' 'application/javascript'
		res.send "var config = conf = #{to-json config.public-config};"

	# Root
	app.get '/' (req, res) -> CallController req, res, \home

	# log viewer
	app.get '/log' (req, res) -> res.render './sites/desktop/views/pages/log'

	# search
	app.get '/search' (req, res) -> (require './sites/desktop/controllers/search')

	# questionnaire
	app.get '/questionnaire' (req, res) -> res.display req, res, 'questionnaire'

	# questionnaire (submit)
	app.post '/questionnaire' (req, res) -> (require './controllers/questionnaire-post') req, res

	# about
	app.get '/about/:title' (req, res) ->
		res.display req, res, "about-articles/#{req.params.title}"

	# talk widget
	app.get '/widget/talk/:userSn' (req, res) -> CallController req, res, \user-talk do
		user: req.root-user
		view: \widget

	# BBS home
	app.get '/bbs' (req, res) -> CallController req, res, \bbs-home

	# BBS thread
	app.get '/bbs/thread/:bbsThreadId' (req, res) -> CallController req, res, \bbs-thread do
		thread: req.root-bbs-thread

	# BBS thread settings form
	app.get '/bbs/thread/:bbsThreadId/settings' (req, res) -> (require './controllers/bbs-thread-settings') req, res

	# BBS new thread form
	app.get '/bbs/new' (req, res) -> res.display req, res, 'bbs-new-thread'

	# Create status form
	app.get '/i/status-new' (req, res) -> (require './controllers/i-status-new') req, res

	# mentions
	app.get '/i/mentions' (req, res) -> CallController req, res, \i-mentions

	# talks
	app.get '/i/talks' (req, res) -> CallController req, res, \i-talks

	# settings
	app.get '/i/settings' (req, res) -> CallController req, res, \i-settings

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
	app.get '/:userSn' (req, res) -> CallController req, res, \user do
		page: \home
		user: req.root-user

	# User profile
	app.get '/:userSn/profile' (req, res) -> CallController req, res, \user do
		page: \profile
		user: req.root-user

	# User followings
	app.get '/:userSn/followings' (req, res) -> CallController req, res, \user do
		page: \followings
		user: req.root-user

	# User followers
	app.get '/:userSn/followers' (req, res) -> CallController req, res, \user do
		page: \followers
		user: req.root-user

	# talk
	app.get '/:userSn/talk' (req, res) -> (require './controllers/user-talk') req, res, \normal

	# staus detail page
	app.get '/:userSn/status/:statusId' (req, res) -> CallController req, res, \status do
		user: req.root-user
		status: req.root-status

	# User profile widget
	app.get '/widget/user/:userSn' (req, res) -> CallController req, res, \widget-user-profile do
		user: req.root-user
