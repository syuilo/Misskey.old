$ ->
	$ '#search input' .bind \input ->
		$input = $ @
		$result = $ '#search .result'
		if $input .val! == ''
			$result.empty!
		else
			$.ajax "#{config.api-url}/search/user" {
				type: \get
				data: {'query': $input .val!}
				data-type: \json
				xhr-fields: {+with-credentials}}
			.done (result) ->
				$result.empty!
				if (result.length > 0) && ($input .val! != '')
					$result.append $ '<ol class="users">'
					result.for-each (user) ->
						$result.find \ol .append do
							$ \<li> .append do
								$ '<a class="ui-waves-effect">' .attr {
									'href': "#{config.url}/widget/talk/#{user.screen-name}"
									'title': user.comment}
								.append do
									$ '<img class="icon" alt="icon">' .attr \src user.icon-image-url
								.append do
									$ '<span class="name">' .text user.name
								.append do
									$ '<span class="screen-name">' .text "@#{user.screen-name}"
					window.init-waves-effects!
