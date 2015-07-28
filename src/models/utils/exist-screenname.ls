require! {
	'../user': User
	'../../utils/map-promise'
	'./mongoose-case-insensitive'
}

# String -> Promise Boolean
module.exports = (screen-name) ->
	User.find {screen-name-lower: screen-name.to-lower-case!} .limit 1 .exec! |> map-promise (empty) >> (!)
