require! {
	'../application': Application
	'../../utils/map-promise'
	'./mongoose-case-insensitive'
}

# String -> Promise Boolean
module.exports = (screen-id) ->
	Application.find {screen-id-lower: screen-id.to-lower-case!} .limit 1 .exec! |> map-promise (empty) >> (!)
