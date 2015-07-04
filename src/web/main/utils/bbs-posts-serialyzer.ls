require! {
	'./bbs-post-serialyzer'
	'../../../config'
}

module.exports = (posts) ->
	Promise.all (posts |> map (post) ->
		resolve, reject <- new Promise!
		bbs-post-serialyzer post, (serialized-post) ->
			resolve serialized-post)
