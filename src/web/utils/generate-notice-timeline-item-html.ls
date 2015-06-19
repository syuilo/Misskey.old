require! {
	jade
	'./notice-serialyzer'
	'../../config'
}

module.exports = (user, notice) -> new Promise (resolve, reject) ->
	notice-compiler = jade.compile-file "#__dirname/../views/templates/notice/timeline-item.jade"
	notice-serialyzer notice .then (serialized-notice) ->
		resolve notice-compiler do
			me: user
			notice: serialized-notice
			config: config.public-config
