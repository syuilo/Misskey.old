require! {
	'../../models/bbs-post-image': BBSPostImage
}

module.exports = (app, user, id) ->
	resolve, reject <- new Promise!
	
	function throw-error(code, message)
		reject {code, message}
	
	if user.is-plus
		BBSPostImage.find-one {post-id: id} (err, image) ->
			| !image? => throw-error \image-not-found 'Image not found.'
			| image.is-disabled => throw-error \image-already-disabled 'Image already disabled.'
			| _ =>
				image
					..is-disabled = yes
					..save ->
						resolve image
	else
		throw-error \access-denied 'Access denied.'