require! {
	seedrandom
}

module.exports = (text) ->
	random = seedrandom text
	r = random! * 255
	g = random! * 255
	b = random! * 255
	r-color-str = r.to-string 16
	g-color-str = g.to-string 16
	b-color-str = b.to-string 16
	'#' + r-color-str + g-color-str + b-color-str