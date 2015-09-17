$ ->
	# オートセーブがあるなら復元
	if $.cookie \post-autosave
		$ '#textarea' .val $.cookie \post-autosave
	
	$ \#form .submit (event) ->
		event.prevent-default!

		$form = $ @
		$submit-button = $form.find '[type=submit]'

		$submit-button.attr \disabled yes
		$submit-button.attr \value 'Updating...'

		$.ajax config.api-url + '/status/update' {
			type: \post
			-process-data
			-content-type
			data: new FormData $form.0
			data-type: \json
			xhr-fields: {+with-credentials}}
		.done (data) ->
			$.remove-cookie \post-autosave {path: '/'}
			location.href = '/'
		.fail (data) ->
			#$form[0].reset!
			$form.find \textarea .focus!
			$submit-button.attr \disabled no
			$submit-button.attr \value '投稿 \uf1d8'
			error-code = JSON.parse data.response-text .error.code
			switch error-code
			| \empty-text => window.alert 'テキストを入力してください。'
			| \too-long-text => window.alert 'テキストが長過ぎます。'
			| \duplicate-content => window.alert '投稿が重複しています。'
			| \failed-attach-image => window.alert '画像の添付に失敗しました。Misskeyが対応していない形式か、ファイルが壊れているかもしれません。'
			| _ => window.alert "不明なエラー (#error-code)"
	
	$ '#textarea' .bind \input ->
		text = $ '#textarea' .val!

		# オートセーブ
		$.cookie \post-autosave text, { path: '/', expires: 365 }
