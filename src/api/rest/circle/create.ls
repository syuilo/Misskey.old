require! {
	'../../auth': authorize
	'../../../models/circle': Circle
	'../../../models/utils/circle-exist-screen-name'
}

module.exports = ({body:{name, screen-name, description}}: req, res) -> authorize req, res, ->
	| !name? => res.api-error 400 'name parameter is required :('
	| !screen-name? => res.api-error 400 'screen-name parameter is required :('
	| !description? => res.api-error 400 'description parameter is required :('
	| _ => circle-exist-screen-name screen-name, (exist) ->
		| exist => res.api-error 400 'That screen name is exist :('
		| _ => Circle.insert {user-id: user.id, name, screen-name, description} (, circle) -> res.api-render circle
