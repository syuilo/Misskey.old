require! {
	request
	'../config'
}

module.exports = (type, image-name, image) ->
	resolve, reject <- new Promise!
	
	request-data =
		passkey: config.image-server-passkey
		'image-name': image-name
		image: image
	
	url = "http://#{config.image-server-ip}:#{config.image-server-port}/register-#{type}"
	console.log url
	request.post {url: url, form-data: request-data} (err, res, body) ->
		if err
			console.log err
			reject err
		else
			resolve!
