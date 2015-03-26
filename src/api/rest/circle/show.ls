require! {
	'../../auth': authorize
	'../../../models/circle': Circle
}
module.exports = (req, res) -> authorize req, res, (user, app) ->
	| !(circle-id = req.query\circle-id)? => res.api-error 400 'circle-id is required :('
	| _ => Circle.find-by-id circle-id, (, circle) ->
		| !circle? => res.api-error 404 'Not found that circle :('
		| _ => res.api-render circle
