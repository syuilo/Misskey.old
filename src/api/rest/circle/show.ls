require! {
	'../../auth': authorize
	'../../../models/circle': Circle
	'../../../utils/get-express-params'
}
module.exports = (req, res) -> authorize req, res, (user, app) ->
	[ circle-id ] = get-express-params req, <[ circle-id ]>
	| empty circle-id => res.api-error 400 'circle-id is required :('
	| _ => Circle.find-by-id circle-id, (, circle) ->
		| !circle? => res.api-error 404 'Not found that circle :('
		| _ => res.api-render circle
