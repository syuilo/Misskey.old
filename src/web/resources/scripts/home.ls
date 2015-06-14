$ ->
	Notification.request-permission!

	# オートセーブがあるなら復元
	if $.cookie \post-autosave
		$ '#post-form textarea' .val $.cookie \post-autosave

	socket = io.connect config.web-streaming-url + '/streaming/web/home'

	socket.on \connect ->
		console.log 'Connected'

	socket.on \disconnect (client) ->

	socket.on \status (status) ->
		console.log \status status
		new Audio '/resources/sounds/pop.mp3' .play!
		
		$status = $ '<li class="status">' .append($ status).hide!
		window.STATUSTIMELINE.set-event $status.children '.status.article'
		$status.prepend-to ($ '#timeline .timeline > .statuses') .show 200

	socket.on \repost (status) ->
		console.log \repost status
		new Audio '/resources/sounds/pop.mp3' .play!
		
		$status = $ '<li class="status">' .append($ status).hide!
		window.STATUSTIMELINE.set-event $status.children '.status.article'
		$status.prepend-to ($ '#timeline .timeline > .statuses') .show 200

	socket.on \reply (status) ->
		console.log \reply status
		new Audio '/resources/sounds/pop.mp3' .play!
		
		$status = $ '<li class="status">' .append($ status).hide!
		window.STATUSTIMELINE.set-event $status.children '.status.article'
		$status.prepend-to ($ '#timeline .timeline > .statuses') .show 200
		n = new Notification post.user.name, {
			body: post.text
			icon: conf.url + '/img/icon/' + post.user.screen-name
		}
		n.onshow = ->
			set-timeout n.close, 10000
		n.onclick = ->
			window.open conf.url + '/' + post.user.screenName + '/post/' + post.id

	socket.on \talk-message (message) ->
		console.log \talk-message message
		window-id = 'misskey-window-talk-' + message.user.id
		if $('#' + window-id).0
			return
		n = new Notification message.user.name, {
			body: message.text,
			icon: conf.url + '/img/icon/' + message.user.screenName
		}
		n.onshow = ->
			set-timeout n.close, 10000
		n.onclick = ->
			url = config.url + '/' + message.user.screen-name + '/talk?noheader=true'
			$content = $ '<iframe>' .attr {
				src: url
				+seamless
			}
			open-window do
				window-id
				$content
				'<i class="fa fa-comments"></i>' + escapeHTML message.user.name
				300
				450
				true
				url

	$ \#post-form .find '.image-attacher input[name=image]' .change ->
		$input = $ @
		file = $input.prop(\files).0
		if file.type.match 'image.*'
			reader = new FileReader!
			reader.onload = ->
				$img = $ '<img>' .attr \src reader.result
				$input.parent '.image-attacher' .find 'p, img' .remove!
				$input.parent '.image-attacher' .append $img
			reader.read-as-dataURL file

	$ window .keypress (e) ->
		if e.char-code == 13 && e.ctrl-key
			post $ '#postForm textarea'

	$ \#post-form .submit (event) ->
		event.prevent-default!
		post $ @

	function post($form)
		$submit-button = $form.find '[type=submit]'

		$submit-button.attr \disabled yes
		$submit-button.text 'Updating...'

		$.ajax config.api-url + '/status/update' {
			type: \post
			-process-data
			-content-type
			data: new FormData $form.0
			data-type: \json
			xhr-fields: {+with-credentials}
		} .done (data) ->
			$form[0].reset!
			$form.find \textarea .focus!
			$form.find \.image-attacher .find 'p, img' .remove!
			$form.find \.image-attacher .append $ '<p><i class="fa fa-picture-o"></i></p>'
			$submit-button.attr \disabled no
			$submit-button.text 'Update'
			$.remove-cookie \post-autosave
		.fail (data) ->
			$form[0].reset!
			$form.find \textarea .focus!
			/*alert('error');*/
			$submit-button.attr \disabled no
			$submit-button.text 'Update'
	
	$ '#post-form textarea' .bind \input ->
		text = $ '#post-form textarea' .val!

		# オートセーブ
		$.cookie \post-autosave text, { path: '/', expires: 365 }

	$ '#timeline .load-more' .click ->
		$button = $ @
		$button.attr \disabled yes
		$button.text 'Loading...'
		$.ajax config.api-url + '/status/timeline-webhtml' {
			type: \get
			data: {
				'max-id': $ '#timeline .timeline .statuses > .status:last-child' .attr \data-id
			}
			data-type: \json
			xhr-fields: {+with-credentials}
		} .done (data) ->
			$button.attr \disabled no
			$button.text 'Read more!'
			$statuses = $ data
			$statuses.each ->
				$status = $ '<li class="status">' .append $ @
				window.STATUSTIMELINE.set-event $status.children '.status.article'
				$status.append-to $ '#timeline .timeline > .statuses'
		.fail (data) ->
			$button.attr \disabled no
			$button.text 'Failed...'

	$ '#recommendation-users > .users > .user' .each ->
		$user = $ @
		$user.find \.follow-button .click ->
			$button = $ @
			$button.attr \disabled yes

			if ($user.attr \data-is-following) == \true
				$.ajax config.api-url + '/users/unfollow' {
					type: \delete
					data: { 'user-id': $user.attr \data-user-id }
					data-type: \json
					xhr-fields: {+with-credentials}
				} .done ->
					$button.attr \disabled no
					$button.remove-class \following
					$button.add-class \notFollowing
					$button.text 'フォロー'
					$user.attr \data-is-following \false
				.fail ->
					$button.attr \disabled no
			else
				$.ajax config.api-url + '/users/follow' {
					type: \post
					data: { 'user-id': $user.attr \data-user-id }
					data-type: \json
					xhr-fields: {+with-credentials}
				} .done ->
					$button.attr \disabled no
					$button.remove-class \notFollowing
					$button.add-class \following
					$button.text 'フォロー解除'
					$user.attr \data-is-following \true
				.fail ->
					$button.attr \disabled no
