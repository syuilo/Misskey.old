require! {
	jade
	'./notice-serialyzer'
	'../../../config'
}

module.exports = (user, notice) -> new Promise (resolve, reject) ->
	console.log \yuppie
	notice-compiler = jade.compile-file "#__dirname/../views/dynamic-parts/notice/mobile/timeline-item.jade"
	notice-serialyzer notice .then (serialized-notice) ->
		console.log \kyoppie
		html = notice-compiler do
			me: user
			notice: serialized-notice
			config: config.public-config
		console.log html
		resolve html
