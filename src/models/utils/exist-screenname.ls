require! {
	'../user': User
	'../../utils/map-promise'
}

# String -> Promise Boolean
module.exports = (screen-name) -> map-promise empty >> not, User.find {screen-name} .limit 1 .exec
