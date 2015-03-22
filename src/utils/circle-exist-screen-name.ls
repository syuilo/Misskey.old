require! {
	'../models/circle': Circle
}
exports = (screen-name, callback) ->
	Circle.count { screen-name } (, count) ->
		callback count > 0
