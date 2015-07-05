function add-post($post)
	new Audio '/resources/sounds/pop.mp3' .play!
		
	$post = $ '<li class="post">' .append($post).hide!
	$post.append-to ($ '#posts .timeline > .posts') .show 200

$ ->
	thread-id = $ \html .attr \data-thread-id
	cookie-id = "bbs-thread-post-autosave-#{thread-id}"
	
	# オートセーブがあるなら復元
	if $.cookie cookie-id
		$ '#post-form textarea' .val $.cookie cookie-id
	
	socket = io.connect config.web-streaming-url + '/streaming/web/bbs-thread'

	socket.on \connect ->
		console.log 'Connected'
		socket.json.emit \init {
			'thread-id': thread-id
		}
		
	socket.on \inited ->
		console.log 'Inited'

	socket.on \disconnect (client) ->
		
	socket.on \post (post) ->
		console.log \post post
		add-post $ post

	$ \#post-form .submit (event) ->
		event.prevent-default!
		post $ @

	function post($form)
		$submit-button = $form.find '[type=submit]'

		$submit-button.attr \disabled yes
		$submit-button.attr \value '投稿しています...'

		$.ajax config.api-url + '/bbs/post/create' {
			type: \post
			-process-data
			-content-type
			data: new FormData $form.0
			data-type: \json
			xhr-fields: {+with-credentials}}
		.done (data) ->
			$form[0].reset!
			$form.find \textarea .focus!
			$form.find \.image-attacher .find 'p, img' .remove!
			$form.find \.image-attacher .append $ '<p><i class="fa fa-picture-o"></i></p>'
			$submit-button.attr \disabled no
			$submit-button.attr \value '投稿 \uf1d8'
			$.remove-cookie cookie-id
			window.display-message '投稿しました！'
		.fail (data) ->
			#$form[0].reset!
			$form.find \textarea .focus!
			$submit-button.attr \disabled no
			$submit-button.attr \value '投稿 \uf1d8'
			error-code = JSON.parse data.response-text .error.code
			switch error-code
			| \empty-text => window.display-message 'テキストを入力してください。'
			| \too-long-text => window.display-message 'テキストが長過ぎます。'
			| \duplicate-content => window.display-message '投稿が重複しています。'
			| \failed-attach-image => window.display-message '画像の添付に失敗しました。Misskeyが対応していない形式か、ファイルが壊れているかもしれません。'
			| _ => window.display-message "不明なエラー (#error-code)"
	
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
	
	$ '#post-form textarea' .bind \input ->
		text = $ '#post-form textarea' .val!

		# オートセーブ
		$.cookie cookie-id, text, { path: '/', expires: 365 }
