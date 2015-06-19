require! {
	jade
	'./notice-serialyzer'
	'../../config'
}

module.exports = (notice) -> new Promise (resolve, reject) ->
	notice-compiler = jade.compile-file "#__dirname/../views/templates/notice/timeline-item.jade"
	notice-serialyzer notice .then (serialized-notice) ->
		resolve status-compiler do
			notice: serialized-notice
			config: config.public-config
