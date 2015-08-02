require! {
	seedrandom
}

module.exports = (text) ->
	# Init randomizer
	random = seedrandom text
	
	r = Math.floor random! * 255
	g = Math.floor random! * 255
	b = Math.floor random! * 255
	
	r-color = r.to-string 16
	g-color = g.to-string 16
	b-color = b.to-string 16
	
	r-color-str = "0#r-color".slice -2
	g-color-str = "0#g-color".slice -2
	b-color-str = "0#b-color".slice -2
	
	'#' + r-color-str + g-color-str + b-color-str