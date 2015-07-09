prelude = require 'prelude-ls'

window.TALKSTREAM = {}
	..set-event = ($message) ->
		id = $message.attr \data-id
		user-id = $message.attr \data-user-id

		if user-id == $ \html .attr \data-me-id
			$message.find \.content .dblclick ->
				$text = $message.find \.text
				text = $text.text!
				$textarea = $ '<textarea class="text">' .text text
				$textarea.css {
					width: ($text.outer-width! + 1) + \px
					height: ($text.outer-height! + 1) + \px
				}
				$text.replace-with $textarea
				$textarea.focus!
				$textarea.change ->
					text = $ @ .val!
					$textp = $ '<p class="text">' .text text
					$textarea.replace-with $textp
					$.ajax config.api-url + '/talk/fix' {
						type: \put
						data: {'message-id': id, text: text}
						data-type: \json
						xhr-fields: {+with-credentials}
					} .done (data) ->
					.fail (data) ->

				$textarea.blur ->
					$textp = $ '<p class="text">' .text text
					$textarea.replace-with $textp

			$message.find \.delete-button .click ->
				$button = $ @
				$button.attr \disabled yes
				$.ajax config.api-url + '/talk/delete' {
					type: \delete
					data: {'message-id': id}
					data-type: \json
					xhr-fields: {+with-credentials}
				} .done (data) ->
					$message.attr \data-is-deleted \true
					$button.remove!
				.fail (data) ->
					$button.attr \disabled no

function add-message($message)
	new Audio '/resources/sounds/talk-message.mp3' .play!
	can-scroll = check-can-scroll!
	$message = ($ '<li class="message">' .append $message).hide!
	window.TALKSTREAM.set-event $message.children \.message
	$message.append-to $ '#stream .messages' .show 200ms
	if can-scroll
		scroll 0, ($ \html .outer-height!)
		timer = set-interval ->
			scroll 0, ($ document .height!)
		, 1ms
		set-timeout ->
			clear-interval timer
		, 300ms

function check-can-scroll
	$window = $ window
	height = $window.height()
	scroll-top = $window.scroll-top!
	document-height = $ document .height!
	height + scroll-top >= (document-height - 64px)

$ ->
	me-id = $ \html .attr \data-me-id
	me-sn = $ \html .attr \data-me-screen-name
	otherparty-id = $ \html .attr \data-otherparty-id
	otherparty-sn = $ \html .attr \data-otherparty-screen-name
	
	$ '.messages .message.me' .each ->
		window.TALKSTREAM.set-event $ @

	# オートセーブがあるなら復元
	if $.cookie "talk-autosave-#{otherparty-id}"
		$ '#post-form textarea' .val $.cookie "talk-autosave-#{otherparty-id}"

	$ \body .css \margin-bottom ($ '#post-form-container' .outer-height! + \px)
	scroll 0, ($ \html .outer-height!)

	socket = io.connect "#{config.web-streaming-url}/streaming/talk"

	socket.on \connected ->
		console.log 'Connected'
		socket.json.emit \init {
			'otherparty-id': otherparty-id
		}

	socket.on \inited ->
		console.log 'Inited'
		socket.emit \alive
		$ '.messages .message.otherparty' .each ->
			socket.emit \read ($ @ .attr \data-id)

	socket.on \disconnect (client) ->
		console.log 'Disconnected'

	socket.on \otherparty-enter-the-talk (client) ->
		console.log '相手が入室しました'

	socket.on \otherparty-left-the-talk (client) ->
		console.log '相手が退室しました'

	socket.on \otherparty-message (message) ->
		console.log \otherparty-message message
		$message = $ message
		message-id = $message.attr \data-id
		socket.emit \read message-id
		if ($ '#otherparty-status #otherparty-typing')[0]
			$ '#otherparty-status #otherparty-typing' .remove!
		add-message $message
		$.ajax config.api-url + '/talk/read' {
			type: \post
			data: {'message-id': message-id}
			data-type: \json
			xhr-fields: {+with-credentials}
		} .done (data) ->
		.fail (data) ->

	socket.on \me-message (message) ->
		console.log \me-message message
		add-message $ message

	socket.on \otherparty-message-update (message) ->
		console.log \otherparty-message-update message
		$message = $ '#stream > .messages' .find ".message[data-id=#{message.id}]"
		if $message?
			$message.find \.text .text message.text

	socket.on \me-message-update (message) ->
		console.log \me-message-update message
		$message = $ '#stream > .messages' .find ".message[data-id=#{message.id}]"
		if $message?
			$message.find \.text .text message.text

	socket.on \otherparty-message-delete (id) ->
		console.log \otherparty-message-delete id
		$message = $ '#stream > .messages' .find ".message[data-id=#{id}]"
		if $message?
			$message.find \.content .empty!
			$message.find \.content .append '<p class="is-deleted">このメッセージは削除されました</p>'

	socket.on \me-message-delete (id) ->
		console.log \me-message-delete id
		$message = $ '#stream > .messages' .find ".message[data-id=#{id}]"
		if $message?
			$message.find \.content .empty!
			$message.find \.content .append '<p class="is-deleted">このメッセージは削除されました</p>'

	socket.on \read (id) ->
		console.log \read id
		$message = $ '#stream > .messages' .find ".message[data-id=#{id}]"
		if $message?
			if ($message.attr \data-is-readed) == \false
				$message.attr \data-is-readed \true
				$message.find \.content-container .prepend ($ '<p class="readed">' .text '既読')

	socket.on \alive ->
		console.log 'alive'
		$status = $ "<img src=\"/img/icon/#{otherparty-sn}\" alt=\"icon\" id=\"alive\">"
		if ($ '#otherparty-status #alive')[0]
			$ '#otherparty-status #alive' .remove!
		else
			$status.add-class \opening
		$ \#otherparty-status .prepend $status
		set-timeout ->
			$status.add-class \normal
			$status.remove-class \opening
		, 500ms
		set-timeout ->
			$status.add-class \closing
			set-timeout ->
				$status.remove!
			, 1000ms
		, 3000ms

	socket.on \type (type) ->
		console.log \type type
		if ($ '#otherparty-status #otherparty-typing')[0]
			$ '#otherparty-status #otherparty-typing' .remove!
		if type != ''
			$typing = $ "<p id=\"otherparty-typing\">#{window.escapeHTML type}</p>"
			$typing.append-to $ \#otherparty-status .animate {
				opacity: 0
			} 5000ms
			set-timeout ->
				$typing.remove!
			, 5000ms

	# Send alive signal
	set-interval ->
		socket.emit \alive
	, 2000ms

	$ '#post-form textarea' .bind \input ->
		text = $ '#post-form textarea' .val!

		# オートセーブ
		$.cookie "talk-autosave-#{otherparty-id}" text, {expires: 365days}

		socket.emit \type text

	$ \#post-form .find '.image-attacher input[name=image]' .change ->
		$input = $ @
		file = ($input.prop \files)[0]
		if file.type.match 'image.*'
			reader = new FileReader!
			reader.onload = ->
				$img = $ '<img>' .attr \src reader.result
				$input.parent \.image-attacher .find 'p, img' .remove!
				$input.parent \.image-attacher .append $img
			reader.readAsDataURL file

	$ \#post-form .submit (event) ->
		event.prevent-default!
		$form = $ @
		$submit-button = $form.find '[type=submit]'

		$submit-button.attr \disabled yes

		$.ajax config.api-url + '/talk/say' {
			type: \post
			-process-data
			-content-type
			data: new FormData $form[0]
			data-type: \json
			xhr-fields: {+with-credentials}
		} .done (data) ->
			$form[0].reset!
			$form.find \textarea .focus!
			$form.find \.image-attacher .find 'p, img' .remove!
			$form.find \.image-attacher .append $ '<p><i class="fa fa-picture-o"></i></p>'
			$submit-button.attr \disabled no
			$.remove-cookie "talk-autosave-#{otherparty-id}"
		.fail (data) ->
			$form[0].reset!
			$form.find \textarea .focus!
			/*alert('error');*/
			$submit-button.attr \disabled no
	
	$ '#read-more' .click ->
		$button = $ @
		$button.attr \disabled yes
		$button.text '読み込み中'
		$.ajax config.api-url + '/web/talk/timeline-html' {
			type: \get
			data: {
				'otherparty-id': otherparty-id
				'max-cursor': $ '#stream > .messages > .message:first-child > .message' .attr \data-cursor
			}
			data-type: \json
			xhr-fields: {+with-credentials}}
		.done (data) ->
			$button.attr \disabled no
			$button.text 'もっと読み込む'
			$messages = $ data
			$messages.each ->
				$message = $ '<li class="message">' .append $ @
				window.TALKSTREAM.set-event $message.children \.message
				$message.prepend-to $ '#stream .messages'
		.fail (data) ->
			$button.attr \disabled no
			$button.text '失敗'

$ window .load ->
	$ \body .css \margin-bottom ($ \#post-form-container .outer-height! + \px)
	scroll 0, document.body.client-height

$ window .resize ->
	$ \body .css \margin-bottom ($ \#post-form-container .outer-height! + \px)
	
