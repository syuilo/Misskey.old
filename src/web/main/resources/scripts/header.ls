window.music-center-open = no

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

function update-clock
	yyyymmdd = moment!.format 'YYYY/MM/DD'
	yyyymmdd = "<span class='yyyymmdd'>#yyyymmdd</span>"
	hhmm = moment!.format 'HH:mm'
	if (new Date!).get-seconds! % 2 == 0
		hhmm .= replace \: '<span style=\'visibility:visible\'>:</span>'
	else
		hhmm .= replace \: '<span style=\'visibility:hidden\'>:</span>'
	clock = $ '#misskey-main-header .time .now' 
	clock.html "#yyyymmdd<br>#hhmm"

$ ->
	update-statuses!
	set-interval update-statuses, 10000ms
	
	update-clock!
	set-interval update-clock, 1000ms


	$ '#misskey-main-header > .main .mainContentsContainer .left nav .mainNav .misskey' .click ->
		if window.music-center-open
			$ '#misskey-main-header > .informationCenter' .css \height '0'
		else
			$ '#misskey-main-header > .informationCenter' .css \height '200px'
		window.music-center-open = !music-center-open
	
	$ '#misskey-main-header > .main .mainContentsContainer .left nav .mainNav ul .talk a' .click ->
		window-id = "misskey-window-talk-histories"
		$content = $ '<iframe>' .attr {src: '/i/talks', +seamless}
		window.open-window do
			window-id
			$content
			"<i class=\"fa fa-comments\"></i>トーク"
			500px
			560px
			yes
			'/i/talks'
		false
	
	$ \body .css \margin-top "#{$ 'body > #misskey-main-header' .outer-height!}px"
	
	$ '#misskey-main-header .account .dropdown .dropdown-header' .click ->
		$dropdown = $ '#misskey-main-header .account .dropdown'
		
		function close
			$dropdown.attr \data-active \false
			$dropdown.find 'i.fa.fa-angle-up' .attr \class 'fa fa-angle-down'
		
		function open
			$ document .one \click (e) ->
				if !$.contains $dropdown[0], e.target
					close!
			$dropdown.attr \data-active \true
			$dropdown.find 'i.fa.fa-angle-down' .attr \class 'fa fa-angle-up'
		
		if ($dropdown.attr \data-active) == \true
			close!
		else
			open!
	
	$ '#misskey-main-header .time .dropdown .dropdown-header' .click ->
		$dropdown = $ '#misskey-main-header .time .dropdown'
		if ($dropdown.attr \data-active) == \true
			$dropdown.attr \data-active \false
		else
			$dropdown.attr \data-active \true
		
	$ '#misskey-main-header .search input' .bind \input ->
		$input = $ @
		$result = $ '#misskey-main-header .search .result'
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

$ window .load ->
	header-height = $ 'body > #misskey-main-header' .outer-height!
	$ \body .css \margin-top "#{header-height}px"
	$ \html .css \background-position "center #{header-height}px"
	$ '[data-ui-background-wallpaper-blur="true"]' .each ->
		$ @ .css \background-position "center #{header-height}px"
		
