$.fn.extend {
	viewport-offset: ->
		$window = $ window
		p = @.offset!
		{ left: p.left - $window.scroll-left!, top: p.top - $window.scroll-top! }
}

window.escapeHTML = (val) ->
	$ '<div />' .text(val).html!
	
window.init-waves-effects ->
	Waves.attach '.ui-button'
	Waves.attach '.ui-waves-effect'
	Waves.init!

$ ->
	update-relative-times!

	# Update relative times
	set-interval update-relative-times, 1000ms

	function update-relative-times
		now = new Date!
		$ "time[data-display-type='relative']" .each ->
			date = new Date($ @ .attr \datetime)
			ago = ~~((now - date) / 1000)
			time-text = switch
				| ago >= 31536000s => ~~(ago / 31536000s) + '年前'
				| ago >= 2592000s  => ~~(ago / 2592000s) + 'ヶ月前'
				| ago >= 604800s   => ~~(ago / 604800s) + '週間前'
				| ago >= 86400s    => ~~(ago / 86400s) + '日前'
				| ago >= 3600s     => ~~(ago / 3600s) + '時間前'
				| ago >= 60s       => ~~(ago / 60s) + '分前'
				| ago >= 5s        => ~~(ago % 60s) + '秒前'
				| ago <  5s        => 'いま'
				| _ => ''
			$ @ .text time-text
	
	# Attach Waves effects 
	window.init-waves-effects!

window.open-window = (id, $content, title, width, height, can-popout = false, popout-url = null) ->
	$window = $ '''
		<div class="ui window" id="''' + id + '''">
			<header>
				<h1>''' + title + '''</h1>
				<div class="buttons">
					<button class="popout" title="ポップアウト"><img src="/resources/images/window-popout.png" alt="Popout"></button>
					<button class="close" title="閉じる"><img src="/resources/images/window-close.png" alt="Close"></button>
				</div>
			</header>
			<div class="content"></div>
		</div>
	''' .css {
		width
		height
	}
	$window.find \.content .append $content
	$ \body .prepend $window

	function top
		window.window-z = 0
		$ \.window .each ->
			if ($ @ .css \z-index) > window.window-z
				window.window-z = Number($ @ .css \z-index)
		$window.css \z-index window.window-z + 1

	function popout
		opened-window = window.open do
			popout-url
			popout-url
			"width=#{width},height=#{height},menubar=no,toolbar=no,location=no,status=no"
		close!

	function close
		$window.css {
			transform: 'perspective(512px) rotateX(22.5deg) scale(0.9)'
			opacity: \0
			transition: 'all ease-in 0.3s'
		}
		set-timeout ->
			$window.remove!
		, 300ms
	
	function end-move
		$window.find \.content .css {
			'pointer-events': \auto
			'user-select': \auto
		}

	$window.ready ->
		top!

		#$window.css({
		#	"top": ($(window).scrollTop() + (($(window).height() / 2) - ($window.outerHeight() / 2) + ((Math.random() * 128) - 64))) + "px",
		#	"left": (($(window).width() / 2) - ($window.outerWidth() / 2) + ((Math.random() * 128) - 64)) + "px",
		#});
		$window.css {
			bottom: (($ window .height! / 2) - ($window.height! / 2) + ((Math.random! * 128) - 64)) + \px
			right: (($ window .width! / 2) - ($window.width! / 2) + ((Math.random! * 128) - 64)) + \px
		}
		$window.animate {
			opacity: \1
			transform: 'scale(1)'
		}, 200

	$window.find 'header > .buttons > .popout' .click popout

	$window.find 'header > .buttons > .close' .click close

	$window.mousedown top

	$window.find \header .mousedown (e) ->
		| $ e.target .is \button =>
		| $ e.target .is \img =>
		| _ =>
			$window.find \.content .css {
				'pointer-events': \none
				'user-select': \none
			}

			position = $window.position!

			click-x = e.client-x
			click-y = e.client-y
			move-base-x = click-x - position.left
			move-base-y = click-y - position.top
			browser-width = $ window .width!
			browser-height = $ window .height!
			window-width = $window.outer-width!
			window-height = $window.outer-height!
			page-top = parse-int ($ \body .css \margin-top)

			$ \html .mousemove (me) ->
				$window.remove-class \snap-top
				$window.remove-class \snap-right
				$window.remove-class \snap-bottom
				$window.remove-class \snap-left
				
				#move-right = browser-width - ((window-width + me.client-x) - move-base-x)
				#move-bottom = browser-height - ((window-height + me.client-y) - move-base-y)
				move-left = me.client-x - move-base-x
				move-top = me.client-y - move-base-y
				
				#if move-right < 0
				#	move-right = 0
				#	
				#if move-bottom < 0
				#	move-bottom = 0
				#	
				#if move-right + window-width > browser-width
				#	move-right = browser-width - window-width
				#	
				#if move-bottom + window-height > browser-height
				#	move-bottom = browser-height - window-height
				
				if move-left < 0
					move-left = 0
				
				if move-top < page-top
					move-top = page-top
				
				if move-left + window-width > browser-width
					move-left = browser-width - window-width
				
				if move-top + window-height > browser-height
					move-top = browser-height - window-height
				
				# snap window border
				threshold = 16px
				
				if move-left < threshold
					$window.add-class \snap-left
					move-left = 0
				
				if (move-top - page-top) < threshold
					$window.add-class \snap-top
					move-top = page-top
				
				if move-left + window-width > browser-width - threshold
					$window.add-class \snap-right
					move-left = browser-width - window-width
				
				if move-top + window-height > browser-height - threshold
					$window.add-class \snap-bottom
					move-top = browser-height - window-height
				
				$window.css {
					left: move-left + \px
					top: move-top + \px
				}

			$ \html .mouseleave ->
				$ @ .unbind 'mouseup mousemove mouseleave'
				end-move!
			
			$ \html .mouseup ->
				$ @ .unbind 'mouseup mousemove mouseleave'
				end-move!

			$ \html .bind \dragstart (e) ->
				$ @ .unbind 'mouseup mousemove mouseleave'
				end-move!

			$ \html .bind \dragend (e) ->
				$ @ .unbind 'mouseup mousemove mouseleave'
				end-move!

	$ window .resize ->
		position = $window.position!
		browser-width = $ window .width!
		browser-height = $ window .height!
		window-width = $window.outer-width!
		window-height = $window.outer-height!
		page-top = parse-int ($ \body .css \margin-top)

		if position.left < 0
			$window.css {
				left: 0
			}
		
		if position.top < page-top
			$window.css {
				top: page-top
			}

		if position.left + window-width > browser-width
			$window.css {
				left: 0
			}
		
		if position.top + window-height > browser-height
			$window.css {
				top: page-top
			}
		
		if $window.has-class \snap-top
			$window.css {
				top: page-top
			}
		
		if $window.has-class \snap-right
			$window.css {
				left: browser-width - window-width + \px
			}
			
		if $window.has-class \snap-bottom
			$window.css {
				top: browser-height - window-height + \px
			}
		
		if $window.has-class \snap-left
			$window.css {
				left: 0
			}