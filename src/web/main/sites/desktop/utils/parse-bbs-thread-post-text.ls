require! {
	'escape-html'
	'../../../../../config'
}

# String -> String
module.exports = escape-html >> parse-url >> parse-reply >> parse-newline

function parse-url text
	text.replace /https?:\/\/[-_.!~*a-zA-Z0-9;\/?:\@&=+\$,%#]+/g (url) ->
		"<a href='#{url}' target='_blank' class='url'>#{url}</a>"

function parse-reply text
	text.replace /@([a-zA-Z0-9_\/]+)/g (, screen-name) ->
		"<a href='#{config.public-config.url}/#{screen-name}' target='_blank' class='screen-name'>@#{screen-name}</a>"

function parse-newline text
	text.replace /(\r\n|\r|\n)/g '<br>'
