require! {
	'../../auth': authorize
	'../../../models/application': Application
	'../../../models/circle': Circle
	'../../../utils/get-express-params'
	'../../../models/user': User
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[circle-id, name, description] = get-express-params req, <[ circle-id name description ]>
	| empty circle-id => res.api-error 400, 'circle_id parameter is required :('
	| _ => Circle.find circle-id, (circle) ->
		| !circle? => res.api-error 404 'Not found that circle :('
		| circle.user-id != user.id => res.api-error 403 'That is not your circle :('
		| _ =>
			circle
				..name = name if !empty name
				..description = description if !empty description
				..save (err) -> res.api-render circle
