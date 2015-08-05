require! {
	'./models/user': User
	'./models/status': Status
	'./models/user-icon': UserIcon
	'./models/user-header': UserHeader
	'./models/user-wallpaper': UserWallpaper
	'./models/status-image': StatusImage
	'./models/bbs-post': BBSPost
	'./models/bbs-thread': BBSThread
	'./models/bbs-post-image': BBSPostImage
	'./models/bbs-thread-eyecatch': BBSThreadEyecatch
	'./utils/register-image': register-image
	'./config'
}

global <<< require \prelude-ls

StatusImage.find {} (err, images) ->
	images |> each (image) ->
		Status.find-by-id image.status-id, (err, status) ->
			User.find-by-id status.user-id, (err, user) ->
				status.images = ["#{status.id}-1.jpg"]
				status.save!
				register-image user, \status-image, "#{status.id}-1.jpg", \jpg, image.image

BBSPostImage.find {} (err, images) ->
	images |> each (image) ->
		BBSPost.find-by-id image.post-id, (err, post) ->
			User.find-by-id post.user-id, (err, user) ->
				post.images = ["#{post.id}-1.jpg"]
				post.save!
				register-image user, \bbs-post-image, "#{post.id}-1.jpg", \jpg, image.image

BBSThreadEyecatch.find {} (err, images) ->
	images |> each (image) ->
		BBSThread.find-by-id image.thread-id, (err, thread) ->
			User.find-by-id thread.user-id, (err, user) ->
				thread.eyecatch-image = "#{thread.id}.jpg"
				thread.save!
				register-image user, \bbs-thread-eyecatch, "#{thread.id}.jpg", \jpg, image.image

UserIcon.find {} (err, images) ->
	images |> each (image) ->
		User.find-by-id image.id, (err, user) ->
			user.icon-image = "#{user.id}.jpg"
			user.save!
			register-image user, \user-icon, "#{user.id}.jpg", \jpg, image.image

UserHeader.find {} (err, images) ->
	images |> each (image) ->
		User.find-by-id image.id, (err, user) ->
			user.banner-image = "#{user.id}.jpg"
			user.save!
			register-image user, \user-banner, "#{user.id}.jpg", \jpg, image.image

UserWallpaper.find {} (err, images) ->
	images |> each (image) ->
		User.find-by-id image.id, (err, user) ->
			user.wallpaper-image = "#{user.id}.jpg"
			user.save!
			register-image user, \user-wallpaper, "#{user.id}.jpg", \jpg, image.image