#
# Web index router
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

	# Root
	app.get '/' (req, res) ->
		if req.login
			(require './controllers/home') req, res
		else
			res.display req, res, 'entrance', {}

	# Config javascript
	app.get '/config' (req, res) ->
		res.set 'Content-Type' 'application/javascript'
		res.send "var config = conf = #{to-json config.public-config};"

	# log viewer
	app.get '/log' (req, res) -> res.display req, res, 'log'

	# search
	app.get '/search' (req, res) -> (require './sites/desktop/controllers/search') req, res

	# questionnaire
	app.get '/questionnaire' (req, res) -> res.display req, res, 'questionnaire'

	# questionnaire (submit)
	app.post '/questionnaire' (req, res) -> (require './sites/desktop/controllers/questionnaire-post') req, res

	# about
	app.get '/about/:title' (req, res) ->
		res.display req, res, "about-articles/#{req.params.title}"

	# talk widget
	app.get '/widget/talk/:userSn' (req, res) -> (require './sites/desktop/controllers/user-talk') req, res, \widget

	# BBS home
	app.get '/bbs' (req, res) -> (require './sites/desktop/controllers/bbs-home') req, res

	# BBS thread
	app.get '/bbs/thread/:bbsThreadId' (req, res) -> (require './sites/desktop/controllers/bbs-thread') req, res

	# BBS thread settings form
	app.get '/bbs/thread/:bbsThreadId/settings' (req, res) -> (require './sites/desktop/controllers/bbs-thread-settings') req, res

	# BBS new thread form
	app.get '/bbs/new' (req, res) -> res.display req, res, 'bbs-new-thread'

	# Create status form
	app.get '/i/status-new' (req, res) ->
		if req.is-mobile
			(require './sites/mobile/controllers/i-status-new') req, res
		else
			(require './sites/desktop/controllers/i-status-new') req, res

	# mentions
	app.get '/i/mentions' (req, res) ->
		if req.is-mobile
			(require './sites/mobile/controllers/i-mentions') req, res
		else
			(require './sites/desktop/controllers/i-mentions') req, res

	# notices
	app.get '/i/notices' (req, res) ->
		if req.is-mobile
			(require './sites/mobile/controllers/i-notices') req, res
		else
			#(require '../controllers/i-notices') req, res

	# talks
	app.get '/i/talks' (req, res) ->
		if req.is-mobile
			(require './sites/mobile/controllers/i-talks') req, res
		else
			(require './sites/desktop/controllers/i-talks') req, res

	# settings
	app.get '/i/settings' (req, res) ->
		if req.is-mobile
			(require './sites/mobile/controllers/i-settings') req, res
		else
			(require './sites/desktop/controllers/i-settings') req, res

	# profile setting
	app.get '/i/settings/profile' (req, res) ->
		(require './sites/mobile/controllers/i-settings-profile') req, res

	# name setting
	app.get '/i/settings/name' (req, res) ->
		res.display req, res, './sites/mobile/views/pages/i-settings-name'

	# comment setting
	app.get '/i/settings/comment' (req, res) ->
		res.display req, res, './sites/mobile/views/pages/i-settings-comment'

	# bio setting
	app.get '/i/settings/bio' (req, res) ->
		res.display req, res, './sites/mobile/views/pages/i-settings-bio'

	# location setting
	app.get '/i/settings/location' (req, res) ->
		res.display req, res, 'mobile/i-settings-location'

	# website url setting
	app.get '/i/settings/url' (req, res) ->
		res.display req, res, 'mobile/i-settings-url'

	# color setting
	app.get '/i/settings/color' (req, res) ->
		res.display req, res, 'mobile/i-settings-color'

	# icon setting
	app.get '/i/settings/icon' (req, res) ->
		res.display req, res, 'mobile/i-settings-icon'

	# header setting
	app.get '/i/settings/header' (req, res) ->
		res.display req, res, 'mobile/i-settings-header'

	# mobile header design setting
	app.get '/i/settings/mobile-header-design' (req, res) ->
		(require '../controllers/mobile/i-settings-mobile-header-design') req, res

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
	app.get '/:userSn' (req, res) ->
		if req.is-mobile
			(require '../controllers/mobile/user') req, res, \home
		else
			(require '../controllers/user') req, res, \home

	# User profile
	app.get '/:userSn/profile' (req, res) -> (require '../controllers/user') req, res, \profile

	# User followings
	app.get '/:userSn/followings' (req, res) -> (require '../controllers/user') req, res, \followings

	# User followers
	app.get '/:userSn/followers' (req, res) -> (require '../controllers/user') req, res, \followers

	# talk
	app.get '/:userSn/talk' (req, res) ->
		if req.is-mobile
			(require '../controllers/mobile/user-talk') req, res, \normal
		else
			(require '../controllers/user-talk') req, res, \normal

	# staus detail page
	app.get '/:userSn/status/:statusId' (req, res) ->
		if req.is-mobile
			(require '../controllers/mobile/status') req, res
		else
			(require '../controllers/status') req, res

	# User profile widget
	app.get '/widget/user/:userSn' (req, res) -> (require '../controllers/widget-user-profile') req, res
