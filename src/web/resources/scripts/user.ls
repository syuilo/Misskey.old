$ window .load ->
	header-set-blur-image!

$ ->
	function header-set-blur-image
		screen-width = $ window .width!
		max-width = $ '#headerMain' .width!
		header-nav-height = $ '#headerNav' .outer-height!
		if screen-width < max-width
			$ '#headerUserAreaBackground' .css \width "#{screen-width}px"
		else
			$ '#headerUserAreaBackground' .css \width "#{max-width}px"
	
	header-set-blur-image!
	$ window .resize header-set-blur-image
	
	function check-follow
		$ \html .attr \data-is-following == \true
	
	$ '#followButton' .click ->
		$button = $ @
			..attr \disabled on
		if check-follow!
			$.ajax "#{config.api-url}/users/unfollow" {
				type: \delete
				data: {'user-id': $ \html .attr \data-user-id}
				data-type: \json
				xhr-fields: {+withCredentials}}
			.done ->
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
				xhr-fields: {+withCredentials}}
			.done ->
				$button
					..attr \disabled off
					..remove-class \notFollowing
					..add-class \following
					..text 'フォロー中'
				$ \html .attr \data-is-following \false
			.fail ->
				$button.attr \disabled off