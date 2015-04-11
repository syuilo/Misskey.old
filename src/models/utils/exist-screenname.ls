require! {
	'../user': User
	'../../utils/map-promise'
	'./mongoose-case-insensitive'
}

# String -> Promise Boolean
module.exports = (screen-name) ->
	User.find {screen-name: mongoose-case-insensitive screen-name} .limit 1 .exec! |> map-promise (empty) >> (!)
