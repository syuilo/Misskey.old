require! {
	'../../../models/application': Application
	'../../auth': authorize
	'../../../utils/get-express-params'
	'../../../config'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[name, callback-url, description, developer-name, developer-website] =
		get-express-params <[ name callback-url description developer-name developer-website ]>
	
	err =
	| app.id != config.web-client-id => [403 'Your application has no permission']
	| empty name => [400 'name cannot be empty :(']
	| empty callback-url => [400 'callback_url cannot be empty :(']
	| empty description => [400 'description cannot be empty :(']
	| empty developer-name => [400 'developer_name cannot be empty :(']
	| empty developer-website => [400 'developer_website cannot be empty :(']
	| name.length > 32 => [400 'name cannot be more than 32 charactors']
	| !(10 <= description.length <= 400) => [400 'description cannot be less than 10 charactors and more than 400 charactors']
	| _ => null

	match
	| err? => res.api-error err.0, err.1
	| not user.is-premium => has-app-one-or-more.then (one-or-more) ->
		| one-or-more => res.api-error 403 'Cannot create application at twon or more. You need PlusAccount to do so :('
		| _ => create!
	| create!

	create = ->
		created-app <- Application.create name, user.id, callback-url, description, developer-name, developer-website
		
		if created-app?
			then res.api-render created-app
			else res.api-error 500 'Sorry, register failed :(';

	has-app-one-or-more = ->
		resolve, reject <- new Promise!
		apps <- Application.find-by-user-id user.id
		resolve 1 <= apps.length
