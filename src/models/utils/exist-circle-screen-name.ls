require! {
	'../circle': Circle
}

module.exports = (screen-name) -> Circle .find screen-name .limit 1 .count! > 0
