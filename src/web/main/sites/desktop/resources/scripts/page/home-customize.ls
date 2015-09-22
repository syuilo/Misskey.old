function update-available-widgets-list
	$ \#customizer-available-widgets .empty!
	$ '#customizer-garbage-storage > .misskey-home-widget' .each ->
		$widget = $ @
		$item = $ '<option>'
		$item.attr \value $widget.attr \data-widget-id
		$item.text $widget.attr \data-widget-name
		$ \#customizer-available-widgets .append $item

$ ->
	$ \html .css {
		user-select: \none
		'-moz-user-select': \none
		'-webkit-user-select': \none
		'-ms-user-select': \none
	}

	update-available-widgets-list!

	#$ \#left-contents .css {
	#	background: 'rgba(0, 0, 0, 0.1)'
	#}

	#$ \#right-contents .css {
	#	background: 'rgba(0, 0, 0, 0.1)'
	#}

	$ \#customizer-add-widget-button .click ->
		add-widget-id = $ \#customizer-available-widgets .val!
		$widget = ($ \#customizer-garbage-storage .find "[data-widget-id='#add-widget-id']").0
		$ \#left-contents .prepend $widget
		update-available-widgets-list!

	$ \#customizer-cancel-button .click ->
		document.location.href = '/'

	$ \#customizer-save-button .click ->
		$submit-button = $ \#customizer-save-button
		$submit-button.attr \disabled yes
		$submit-button.attr \value '保存中...'

		layout = {
			left: []
			center: []
			right: []
		}

		$ '#left-contents > .misskey-home-widget' .each ->
			$widget = $ @
			layout.left.push $widget.attr \data-widget-id
		$ '#main-contents > .misskey-home-widget' .each ->
			$widget = $ @
			layout.center.push $widget.attr \data-widget-id
		$ '#right-contents > .misskey-home-widget' .each ->
			$widget = $ @
			layout.right.push $widget.attr \data-widget-id

		fd = new FormData!
		fd.append \layout JSON.stringify layout

		$.ajax "#{config.api-url}/account/update-home-layout" {
			type: \put
			-process-data
			-content-type
			data: fd
			data-type: \json
			xhr-fields: {+with-credentials}}
		.done (data) ->
			document.location.href = '/'
		.fail (data) ->
			$submit-button.attr \disabled no
			$submit-button.attr \value '失敗'

	$ \.misskey-home-widget .each ->
		$widget = $ @
		$widget-lapper = $ '<div>' .attr {
			class: \misskey-home-widget-lapper
			title: if (($widget.attr \data-widget-not-allow-move) != \true) then 'ドラッグして並び替え' else 'このウィジェットは編集できません'
		}

		function end-move(x, y)
			$widget.moved = no

			$widget.css {
				width: ''
				height: ''
			}

			$ \.misskey-home-widget .each ->
				$target-widget = $ @
				if ($target-widget.attr \id) != ($widget.attr \id)
					target-widget-position = $target-widget.offset!
					target-widget-width = $target-widget.outer-width!
					target-widget-height = $target-widget.outer-height!

					if (x > target-widget-position.left) and (x < target-widget-position.left + target-widget-width) and (y > target-widget-position.top) and (y < target-widget-position.top + target-widget-height)
						if y > (target-widget-position.top + (target-widget-height / 2))
							$target-widget.after $widget
						else
							$target-widget.before $widget
						$widget.moved = yes

			if not $widget.moved
				$left-area = $ \#left-contents
				left-area-position = $left-area.offset!
				left-area-width = $left-area.outer-width!
				left-area-height = $left-area.outer-height!
				if (x < left-area-position.left + left-area-width) and (y > left-area-position.top) and (y < left-area-position.top + left-area-height)
					$left-area.append $widget
					$widget.moved = yes

			if not $widget.moved
				$right-area = $ \#right-contents
				right-area-position = $right-area.offset!
				right-area-width = $right-area.outer-width!
				right-area-height = $right-area.outer-height!
				if (x > right-area-position.left) and (y > right-area-position.top) and (y < right-area-position.top + right-area-height)
					$right-area.append $widget
					$widget.moved = yes

			$widget.css {
				position: \relative
				top: 0
				left: 0
				'z-index': 0
			}

		if ($widget.attr \data-widget-not-allow-remove) != \true
			$widget-remove-button = $ '<button><i class="fa fa-times"></button>' .attr {
				title: 'このウィジェットをリムーブ'
			}

			$widget-remove-button.click ->
				$ \#customizer-garbage-storage .append $widget
				update-available-widgets-list!

			$widget-lapper.append $widget-remove-button

		$widget-caption = $ '<p class="caption">' .text $widget.attr \data-widget-name
		$widget-lapper.append $widget-caption

		if ($widget.attr \data-widget-not-allow-move) != \true
			$widget-lapper.mousedown (e) ->
				| $ e.target .is \button =>
				| _ =>
					position = $widget.offset!
					click-x = e.client-x
					click-y = e.client-y
					margin-top = parse-int($widget.css \margin-top)
					margin-left = parse-int($widget.css \margin-left)
					margin-bottom = parse-int($widget.css \margin-bottom)
					scroll-top = $ window .scroll-top!
					move-base-x = click-x - position.left
					move-base-y = click-y - position.top + scroll-top
					browser-width = $ window .width!
					browser-height = $ window .height!
					widget-width = $widget.outer-width!
					widget-height = $widget.outer-height!
					page-top = parse-int($ \body .css \margin-top)

					$widget.x = 0
					$widget.y = 0

					$widget.css {
						position: \fixed
						top: position.top - scroll-top - margin-top
						left: position.left - margin-left
						width: widget-width
						height: widget-height
						'z-index': 128
					}

					$shadow = $ '<div>' .attr {
						class: \misskey-home-widget-shadow
					}
					$shadow.css {
						height: "#{widget-height}px"
						'margin-top':  "#{margin-top}px"
						'margin-bottom':  "#{margin-bottom}px"
						'pointer-events': \none
					}

					$widget.after $shadow

					$shadow.animate {
						height: 0
						margin-top: \0px
						margin-bottom: \0px
					}, 500ms \swing ->
						$shadow.remove!

					$ \html .mousemove (me) ->
						$widget.x = me.client-x
						$widget.y = me.client-y + ($ window .scroll-top!)
						move-top = me.client-y - move-base-y - margin-top
						move-left = me.client-x - move-base-x - margin-left

						#if move-left < 0
						#	move-left = 0
						#if move-top < page-top
						#	move-top = page-top
						#if move-left + widget-width > browser-width
						#	move-left = browser-width - widget-width
						#if move-top + widget-height > browser-height
						#	move-top = browser-height - widget-height

						$widget.css {
							left: move-left + \px
							top: move-top + \px
						}

					$ \html .mouseleave ->
						$ @ .unbind 'mouseup mousemove mouseleave'
						end-move $widget.x, $widget.y

					$ \html .mouseup ->
						$ @ .unbind 'mouseup mousemove mouseleave'
						end-move $widget.x, $widget.y

					$ \html .bind \dragstart (e) ->
						$ @ .unbind 'mouseup mousemove mouseleave'
						end-move $widget.x, $widget.y

					$ \html .bind \dragend (e) ->
						$ @ .unbind 'mouseup mousemove mouseleave'
						end-move $widget.x, $widget.y

		$widget.append $widget-lapper

$ window .load ->
	header-height = $ '#customizer-menu' .outer-height!
	$ \body .css \margin-top "#{header-height}px"
	$ \html .css \background-position "center #{header-height}px"
	$ '[data-ui-background-wallpaper-blur="true"]' .each ->
		$ @ .css \background-position "center #{header-height}px"
