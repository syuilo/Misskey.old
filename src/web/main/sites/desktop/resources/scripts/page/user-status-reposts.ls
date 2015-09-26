$ ->
	window.STATUS_CORE.set-event $ '#status .main .status.article'

	SYUILOUI.Tab $ '#hima > .tab > ul'

	$ '#hima .users-list' .each ->
		$user-list = $ @
		$user-list.find '.users > .user' .each ->
			$user = $ @
			user-id = $user.attr \data-user-id

			function check-follow
				($user.attr \data-is-following) == \true

			$friend-status = $user.find '.friend-form .friend-status'
			$tooltip = $ '<p class="ui-tooltip">' .text $friend-status.attr \data-tooltip
			$friend-status .hover do
				->
					$tooltip.css \bottom $friend-status.outer-height! + 4px
					$friend-status.append $tooltip
					$friend-status.find \.ui-tooltip .css \left ($friend-status.outer-width! / 2) - ($tooltip.outer-width! / 2)
				->
					$friend-status.find \.ui-tooltip .remove!

			$friend-button = $user.find '.friend-form .friend-button'
			$friend-button .hover do
				->
					if check-follow!
						$friend-button .add-class \danger
						$friend-button .text 'Unfollow'
				->
					if check-follow!
						$friend-button .remove-class \danger
						$friend-button .text 'Following'

			$friend-button.click ->
				$friend-button.attr \disabled on
				if check-follow!
					$.ajax "#{config.api-url}/users/unfollow" {
						type: \delete
						data: {'user-id': user-id}
						data-type: \json
						xhr-fields: {+with-credentials}}
					.done ->
						$friend-button.remove-class \danger
						$friend-button
							..attr \disabled off
							..attr \title 'フォローする'
							..remove-class \following
							..add-class \not-following
							..text 'Follow'
						$user.attr \data-is-following \false
					.fail ->
						$friend-button.attr \disabled off
				else
					$.ajax "#{config.api-url}/users/follow" {
						type: \post
						data: {'user-id': user-id}
						data-type: \json
						xhr-fields: {+with-credentials}}
					.done ->
						$friend-button
							..attr \disabled off
							..attr \title 'フォローを解除する'
							..remove-class \not-following
							..add-class \following
							..text 'Following'
						$user.attr \data-is-following \true
					.fail ->
						$friend-button.attr \disabled off
