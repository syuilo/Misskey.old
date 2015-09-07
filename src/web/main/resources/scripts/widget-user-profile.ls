$ ->
	is-me = $ \html .attr \data-is-me

	function check-follow
		($ \html .attr \data-is-following) == \true

	$ '#friend-button' .hover do
		->
			if check-follow!
				$ '#friend-button' .add-class \danger
				$ '#friend-button' .text 'フォロー解除'
		->
			if check-follow!
				$ '#friend-button' .remove-class \danger
				$ '#friend-button' .text 'フォロー中'

	$ '#friend-button' .click ->
		$button = $ @
			..attr \disabled on
		if check-follow!
			$.ajax "#{config.api-url}/users/unfollow" {
				type: \delete
				data: {'user-id': $ \html .attr \data-user-id}
				data-type: \json
				xhr-fields: {+with-credentials}}
			.done ->
				$button .remove-class \danger
				$button
					..attr \disabled off
					..remove-class \following
					..add-class \notFollowing
					..text 'フォロー'
				$ \html .attr \data-is-following \false
			.fail ->
				$button.attr \disabled off
		else
			$.ajax "#{config.api-url}/users/follow" {
				type: \post
				data: {'user-id': $ \html .attr \data-user-id}
				data-type: \json
				xhr-fields: {+with-credentials}}
			.done ->
				$button
					..attr \disabled off
					..remove-class \notFollowing
					..add-class \following
					..text 'フォロー中'
				$ \html .attr \data-is-following \true
			.fail ->
				$button.attr \disabled off
