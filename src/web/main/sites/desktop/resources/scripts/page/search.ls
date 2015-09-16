prelude = require 'prelude-ls'

$ ->
	q = $ \html .attr \data-query
	q = $ '<div>' .text q .html!
	q-reg = new RegExp q, \i

	$ '#statuses .timeline .statuses .status .status.article' .each ->
		$status = $ @
		window.STATUS_CORE.set-event $status
		$text = $status.find '> article > .main > .main > .content > .text'
		$text .html ($text.html!.replace q-reg, "<mark>#{q}</mark>")

	$ '#search input' .bind \input ->
			$input = $ @
			$result = $ '#search .result'
			if $input .val! == ''
				$input.attr \data-active \false
				$result.empty!
			else
				$input.attr \data-active \true
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
										'href': "#{config.url}/#{user.screen-name}"
										'title': user.comment}
									.append do
										$ '<img class="icon" alt="icon">' .attr \src user.icon-image-url
									.append do
										$ '<span class="name">' .text user.name
									.append do
										$ '<span class="screen-name">' .text "@#{user.screen-name}"
						window.init-waves-effects!
				.fail ->
