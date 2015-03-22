require! {
	'../models/circle': Circle
}
exports = (screen-name, callback) ->
	callback Circle .find screen-name .limit 1 .count! > 0
