require! {
	request
	'../config'
}

module.exports = (user, type, image-name, image-format-type, image) ->
	resolve, reject <- new Promise!
	
	request-data =
		passkey: config.image-server-passkey
		'image-name': image-name
		'user-id': user.id
		image:
			value: image
			options:
				filename: image-name
				content-type: "image/#{image-format-type}"
	
	url = "http://#{config.image-server-ip}:#{config.image-server-port}/register-#{type}"

	request.post {url: url, form-data: request-data} (err, res, body) ->
		if err
			console.log err
			reject err
		else
			resolve!
