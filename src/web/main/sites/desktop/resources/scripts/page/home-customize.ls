$ ->
	$ \.misskey-home-widget .each ->
		$widget = $ @
		$widget-lapper = $ '<div>' .attr {
			class: \misskey-home-widget-lapper
			title: 'ドラッグして並び替え'
		}

		$widget-lapper.mousedown (e) ->
			function end-move
				$widget.css {
					position: \relative
					top: 0
					left: 0
					'z-index': 0
				}

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
			}

			$widget.after $shadow

			$shadow.animate {
				height: 0
				margin-top: 0
				margin-bottom: 0
			}, 500ms \swing ->
				$shadow.remove!

			$ \html .css {
				user-select: \none
				'-moz-user-select': \none
				'-webkit-user-select': \none
				'-ms-user-select': \none
			}

			$ \html .mousemove (me) ->
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

		$widget.append $widget-lapper
