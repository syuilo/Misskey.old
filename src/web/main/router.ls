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
	app.get '/' (req, res) ->
		if req.login
			CallController req, res, \home
		else
			res.display req, res, "#__dirname/sites/desktop/views/pages/entrance"

	# home
	app.get '/home' (req, res) ->
		if req.login
			CallController req, res, \home
		else
			res.display req, res, "#__dirname/sites/desktop/views/pages/entrance"

	# home customize
	app.get '/home/customize' (req, res) ->
		CallController req, res, \home do
			customize: yes

	# log viewer
	app.get '/log' (req, res) -> res.display req, res, "#__dirname/sites/desktop/views/pages/log"
	
	app.get '/latest-deploy-log' (req, res) -> CallController req, res, \latest-deploy-log

	# search
	app.get '/search' (req, res) -> CallController req, res, \search

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
	app.get '/i/status-new' (req, res) -> CallController req, res, \i-status-new

	# mentions
	app.get '/i/mentions' (req, res) -> CallController req, res, \i-mentions

	# talks
	app.get '/i/talks' (req, res) -> CallController req, res, \i-talks

	# notices
	app.get '/i/notices' (req, res) -> CallController req, res, \i-notices

	# settings
	app.get '/i/settings' (req, res) -> CallController req, res, \i-settings

	# apps
	app.get '/i/apps' (req, res) -> CallController req, res, \i-apps

	# profile setting
	app.get '/i/settings/profile' (req, res) ->
		(require './sites/mobile/controllers/i-settings-profile') req, res

	# name setting
	app.get '/i/settings/name' (req, res) ->
		(require './sites/mobile/controllers/i-settings-name') req, res

	# comment setting
	app.get '/i/settings/comment' (req, res) ->
		(require './sites/mobile/controllers/i-settings-comment') req, res

	# bio setting
	app.get '/i/settings/bio' (req, res) ->
		(require './sites/mobile/controllers/i-settings-bio') req, res

	# location setting
	app.get '/i/settings/location' (req, res) ->
		(require './sites/mobile/controllers/i-settings-location') req, res

	# website url setting
	app.get '/i/settings/url' (req, res) ->
		(require './sites/mobile/controllers/i-settings-url') req, res

	# color setting
	app.get '/i/settings/color' (req, res) ->
		(require './sites/mobile/controllers/i-settings-color') req, res

	# icon setting
	app.get '/i/settings/icon' (req, res) ->
		(require './sites/mobile/controllers/i-settings-icon') req, res

	# header setting
	app.get '/i/settings/header' (req, res) ->
		(require './sites/mobile/controllers/i-settings-header') req, res

	# mobile header design setting
	app.get '/i/settings/mobile-header-design' (req, res) ->
		(require './sites/mobile/controllers/i-settings-mobile-header-design') req, res

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
		user: req.root-user

	# User profile
	app.get '/:userSn/profile' (req, res) -> CallController req, res, \user-profile do
		user: req.root-user

	# User followings
	app.get '/:userSn/followings' (req, res) -> CallController req, res, \user-followings do
		user: req.root-user

	# User followers
	app.get '/:userSn/followers' (req, res) -> CallController req, res, \user-followers do
		user: req.root-user

	# talk
	app.get '/:userSn/talk' (req, res) -> CallController req, res, \user-talk do
		view: \normal
		user: req.root-user
	
	# User room
	app.get '/:userSn/room' (req, res) -> CallController req, res, \user-room do
		user: req.root-user

	# staus detail page
	app.get '/:userSn/status/:statusId' (req, res) -> CallController req, res, \status do
		user: req.root-user
		status: req.root-status
	app.get '/:userSn/status/:statusId/reposts' (req, res) -> CallController req, res, \status-reposts do
		user: req.root-user
		status: req.root-status
	app.get '/:userSn/status/:statusId/favorites' (req, res) -> CallController req, res, \status-favorites do
		user: req.root-user
		status: req.root-status

	# User profile widget
	app.get '/widget/user/:userSn' (req, res) -> CallController req, res, \widget-user-profile do
		user: req.root-user
