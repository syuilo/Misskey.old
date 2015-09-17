require! {
	jade
	'./generate-notice-timeline-item-html'
}

module.exports = (user, notices) -> new Promise (resolve, reject) ->
	notices-compiler = jade.compile-file "#__dirname/../views/dynamic-parts/notice/timeline.jade"
	promises = notices |> map (notice) ->
		generate-notice-timeline-item-html user, notice
	Promise.all promises .then (notice-htmls) ->
		resolve notices-compiler do
			notices: notice-htmls.join ''
