require! {
	'../models/circle': Circle
}

exports = (screen-name) -> Circle .find screen-name .limit 1 .count! > 0
