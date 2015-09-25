require! {
	fs
	'../../../../../config'
}

module.exports = (req, res) ->
	fs.read-file "#__dirname/../../../../../../latest-deploy-log" \utf8 (err, text) ->
		if err?
			res
				..write-head 500 'Content-Type': 'text/plain'
				..end err
		else
			res
				..write-head 200 'Content-Type': 'text/plain'
				..end text
		