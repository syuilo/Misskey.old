require! {
	'../user': User
	'../../utils/map-promise'
}

# String -> Promise Boolean
module.exports = (screen-name) -> User.find {screen-name} .limit 1 .exec |> map-promise (empty) >> (!)
