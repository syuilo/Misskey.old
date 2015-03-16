require! {
	'../../../models/application': Application
	'../../auth': authorize
	'./create/validate-arguments': validate-arguments
}
module.exports = (req, res) -> authorize req, res, (user, app) ->
		name = typeof req.body.name !== 'undefined' ? req.body.name : null
		callback-url = typeof req.body.callback_url !== 'undefined' ? req.body.callback_url : null
		description = typeof req.body.description !== 'undefined' ? req.body.description : null
		developer-name = typeof req.body.developer_name !== 'undefined' ? req.body.developer_name : null
		developer-website = typeof req.body.developer_website !== 'undefined' ? req.body.developer_website : null

		err = validate-arguments app, name, callback-url, description, developer-name, developer-website

		if err === null
			res.apiError err[0], err[1]
		else if !user.isPremium
			has-app-one-or-more (one-or-more) ->
				if one-or-more
					res.api-error 403 'Cannot create application at twon or more. You need PlusAccount to do so :('
				else
					create!
		else
			create!

		create = ->
			Application.create name, user.id, callback-url, description, developer-name, developer-website, (created-app) ->
				if created-app == null
					res.api-error 500 'Sorry, register failed :(';
					return
				res.api-render created-app

		has-app-one-or-more = (callback) ->
			Application.find-by-user-id user.id, (apps) ->
				callback 1 <= apps.length
