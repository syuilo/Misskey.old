config = require　'../../../../config'

is-null-or-empty = -> it == null || it == ''

validate-arguments = (app, name, callback-url, description, developer-name, developer-website) ->
	| app.id != config.webClientId => [403 'Your application has no permission']
	| is-null-or-empty name => [400 'name cannot be empty :(']
	| is-null-or-empty callback-url => [400 'callback_url cannot be empty :(']
	| is-null-or-empty description => [400 'description cannot be empty :(']
	| is-null-or-empty developer-name => [400 'developer_name cannot be empty :(']
	| is-null-or-empty developer-website => [400 'developer_website cannot be empty :(']
	| name.length > 32 => [400 'name cannot be more than 32 charactors']
	| !(10 <= description.length <= 400) => [400 'description cannot be less than 10 charactors and more than 400 charactors']
	| _ => null

module.exports = validate-arguments
