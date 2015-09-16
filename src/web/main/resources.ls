#
# Resources router
#

require! {
	fs
	path
	express
	gm
	compression
	less
	'../../models/user': User
	'../../models/webtheme': Webtheme
	'../../config'
}

module.exports = (app) ->
	# General
	app.get /^\/resources\/.*/ (req, res, next) ->
		| (req.path.index-of '..') > -1 =>
			res
				..status 400
				..send 'invalid path'
		| _ =>
			resolved-path = path.resolve "#__dirname/#{req.path}"
			if fs.exists-sync resolved-path
				res.send-file resolved-path
			else
				next!
