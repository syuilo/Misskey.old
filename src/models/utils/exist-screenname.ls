require! {
	'../user': User
	'../../utils/map-promise'
	'./mongoose-case-insensitive'
}

# String -> Promise Boolean
module.exports = (screen-name) -> new Promise (resolve, reject) ->
	#User.find {screen-name-lower: screen-name.to-lower-case!} .limit 1 .exec! |> map-promise (empty) >> (!)
	User.find {screen-name-lower: screen-name.to-lower-case!} .limit 1 .exec (err, res) ->
		resolve not empty res
