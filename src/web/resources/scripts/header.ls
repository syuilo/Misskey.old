music-center-open = no

function update-statuses
	$.ajax "#{config.api-url}/account/unreadalltalks-count" {
		type: \get
		data-type: \json
		xhr-fields: {+with-credentials}}
	.done (result) ->
		if $ '#misskey-main-header > .main .mainContentsContainer .left nav .mainNav ul .talk a .unreadCount' .0
			$ '#misskey-main-header > .main .mainContentsContainer .left nav .mainNav ul .talk a .unreadCount' .remove!
		if result != 0
			$ '#misskey-main-header > .main .mainContentsContainer .left nav .mainNav ul .talk a' .append do
				$ '<span class="unreadCount">' .text result
	.fail ->

$ ->
	#update-statuses!
	#set-interval update-statuses, 5000ms

	$ '#misskey-main-header > .main .mainContentsContainer .left nav .mainNav .misskey' .click ->
		if music-center-open
			$ '#misskey-main-header > .informationCenter' .css \height '0'
		else
			$ '#misskey-main-header > .informationCenter' .css \height '200px'
		music-center-open = !music-center-open
	
	$ \body .css \margin-top "#{$ 'body > #misskey-main-header' .outer-height!}px"

	$ '#misskey-main-header .search input' .bind \input ->
		$result = $ '#misskey-main-header .search .result'
		if $ @ .val! == ''
			$result.empty!
		else
			$.ajax "#{config.api-url}/search/user" {
				type: \get
				data: {'query': $ @ .val!}
				data-type: \json
				xhr-fields: {+with-credentials}}
			.done (result) ->
				$result.empty!
				if result.length > 0
					$result.append $ '<ol class="users">'
					result.for-each (user) ->
						$result.find \ol .append do
							$ \<li> .append do
								$ \<a> .attr {
									'href': "#{config.url}/#{user.screen-name}"
									'title': user.comment}
								.append do
									$ '<img class="icon" alt="icon">' .attr \src "#{config.url}/img/icon/#{user.screen-name}"
								.append do
									$ '<span class="name">' .text user.name
								.append do
									$ '<span class="screenName">' .text "@#{user.screen-name}"
								
			.fail ->

$ window .load ->
	$ \body .css \margin-top "#{$ 'body > #misskey-main-header' .outer-height!}px"

