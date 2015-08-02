require! {
	seedrandom
}

module.exports = (text) ->
	random = seedrandom text
	r = Math.floor random! * 255
	g = Math.floor random! * 255
	b = Math.floor random! * 255
	r-color-str = r.to-string 16
	g-color-str = g.to-string 16
	b-color-str = b.to-string 16
	'#' + r-color-str + g-color-str + b-color-str