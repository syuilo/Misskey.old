class ItemController
	(room) ->
		THIS = @

		@room = room

		################################
		# Init UI
		@$controller = $ \#item-controller
		@$controller-item-title = @$controller.find \.title
		@$controller-item-hide-button = @$controller.find \.item-hide-button
		@$controller-pos-back-button = @$controller.find \.pos-back-button
		@$controller-pos-forward-button = @$controller.find \.pos-forward-button
		@$controller-pos-left-button = @$controller.find \.pos-left-button
		@$controller-pos-right-button = @$controller.find \.pos-right-button
		@$controller-pos-up-button = @$controller.find \.pos-up-button
		@$controller-pos-down-button = @$controller.find \.pos-down-button
		@$controller-pos-x-input = @$controller.find \.pos-x
		@$controller-pos-y-input = @$controller.find \.pos-y
		@$controller-pos-z-input = @$controller.find \.pos-z
		@$controller-rotate-x-input = @$controller.find \.rotate-x
		@$controller-rotate-y-input = @$controller.find \.rotate-y
		@$controller-rotate-z-input = @$controller.find \.rotate-z

		$ \html .keydown (e) ->
			switch (e.which)
			| 39 => # Key[→]
				if e.shift-key
					THIS.change-pos-z THIS.item.position.z - 0.01
				else
					THIS.change-pos-z THIS.item.position.z - 0.1
			| 37 => # Key[←]
				if e.shift-key
					THIS.change-pos-z THIS.item.position.z + 0.01
				else
					THIS.change-pos-z THIS.item.position.z + 0.1
			| 38 => # Key[↑]
				if e.shift-key
					THIS.change-pos-x THIS.item.position.x - 0.01
				else
					THIS.change-pos-x THIS.item.position.x - 0.1
			| 40 => # Key[↓]
				if e.shift-key
					THIS.change-pos-x THIS.item.position.x + 0.01
				else
					THIS.change-pos-x THIS.item.position.x + 0.1

		# しまうボタン
		@$controller-item-hide-button.click ->
			THIS.room.add-item-to-box THIS.item.room-item-info
			THIS.update null

		@$controller-pos-back-button.click ->
			THIS.change-pos-x THIS.item.position.x + 0.1

		@$controller-pos-forward-button.click ->
			THIS.change-pos-x THIS.item.position.x - 0.1

		@$controller-pos-left-button.click ->
			THIS.change-pos-z THIS.item.position.z + 0.1

		@$controller-pos-right-button.click ->
			THIS.change-pos-z THIS.item.position.z - 0.1

		@$controller-pos-up-button.click ->
			THIS.change-pos-y THIS.item.position.y + 0.1

		@$controller-pos-down-button.click ->
			THIS.change-pos-y THIS.item.position.y - 0.1

		@$controller-pos-x-input.bind \input ->
			THIS.change-pos-x THIS.$controller-pos-x-input.val!

		@$controller-pos-y-input.bind \input ->
			THIS.change-pos-y THIS.$controller-pos-y-input.val!

		@$controller-pos-z-input.bind \input ->
			THIS.change-pos-z THIS.$controller-pos-z-input.val!

		@$controller-rotate-x-input.bind \input ->
			THIS.change-rotate-x THIS.$controller-rotate-x-input.val!

		@$controller-rotate-y-input.bind \input ->
			THIS.change-rotate-y THIS.$controller-rotate-y-input.val!

		@$controller-rotate-z-input.bind \input ->
			THIS.change-rotate-z THIS.$controller-rotate-z-input.val!

		################################
		# Init viewer
		canvas = document.get-element-by-id \item-controller-preview-canvas
		width = canvas.width
		height = canvas.height

		# Scene settings
		@scene = new THREE.Scene!

		# Renderer settings
		@renderer = new THREE.WebGLRenderer {canvas, +antialias, +alpha}
			..set-pixel-ratio window.device-pixel-ratio
			..set-size width, height
			..set-clear-color 0x000000 0
			..auto-clear = off
			..shadow-map.enabled = on
			..shadow-map.cull-face = THREE.CullFaceBack

		# Camera settings
		@camera = new THREE.PerspectiveCamera 75 (width / height), 0.1 100
			..zoom = 10
			..position.x = 0
			..position.y = 2
			..position.z = 0
			..update-projection-matrix!
		@scene.add @camera

		# AmbientLight
		ambient-light = new THREE.AmbientLight 0xffffff 1
			..cast-shadow = no
		@scene.add ambient-light

		# PointLight
		light = new THREE.PointLight 0xffffff 1 100
			..position.set 3 3 3
		@scene.add light

		#@scene.add new THREE.AxisHelper 5
		grid = new THREE.GridHelper 5 0.5
			..set-colors 0x444444 0x444444
		@scene.add grid

		@render!

	render: ->
		timer = Date.now! * 0.0004

		# SEE:
		# http://stackoverflow.com/questions/22039180/failed-to-execute-requestanimationframe-on-window-the-callback-provided-as
		# http://stackoverflow.com/questions/6065169/requestanimationframe-with-this-keyword
		# https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Global_Objects/Function/bind
		request-animation-frame @render.bind @

		if @item?
			item-height = @item-bounding-box.size!.y

			@camera
				..position.y = 2 + (item-height / 2)
				..position.z = (Math.cos timer) * 10
				..position.x = (Math.sin timer) * 10
				..look-at new THREE.Vector3 0, (item-height / 2), 0

			@renderer.render @scene, @camera

	update:	(item) ->
		@item = item
		if item?
			@$controller.css \display \block
			@$controller-item-title.text item.room-item-info.obj.name
			@$controller-pos-x-input.val item.position.x
			@$controller-pos-y-input.val item.position.y
			@$controller-pos-z-input.val item.position.z
			@$controller-rotate-x-input.val item.rotation.x
			@$controller-rotate-y-input.val item.rotation.y
			@$controller-rotate-z-input.val item.rotation.z

			# Remove old object
			old = @scene.get-object-by-name \obj
			if old?
				@scene.remove old

			# Add new object
			preview-obj = item.clone!
				..name = \obj
				..position.x = 0
				..position.y = 0
				..position.z = 0
				..rotation.x = 0
				..rotation.y = 0
				..rotation.z = 0

			preview-obj.traverse (child) ->
				if child instanceof THREE.Mesh
					child.material = child.material.clone!
					child.material.emissive.set-hex 0x000000

			@item-bounding-box = new THREE.Box3!.set-from-object preview-obj
			@scene.add preview-obj
		else
			@$controller.css \display \none

	change-pos-x: (x) ->
		x = Number x
		if x > 2.5 then x = 2.5
		if x < -2.5 then x = -2.5
		@item.position.x = x
		@item.room-item-info.position.x = x
		@$controller-pos-x-input.val x

	change-pos-y: (y) ->
		y = Number y
		if y > 1.5 then y = 1.5
		if y < 0 then y = 0
		@item.position.y = y
		@item.room-item-info.position.y = y
		@$controller-pos-y-input.val y

	change-pos-z: (z) ->
		z = Number z
		if z > 2.5 then z = 2.5
		if z < -2.5 then z = -2.5
		@item.position.z = z
		@item.room-item-info.position.z = z
		@$controller-pos-z-input.val z

	change-rotate-x: (x) ->
		x = Number x
		@item.rotation.x = x
		@item.room-item-info.rotation.x = x
		@$controller-rotate-x-input.val x

	change-rotate-y: (y) ->
		y = Number y
		@item.rotation.y = y
		@item.room-item-info.rotation.y = y
		@$controller-rotate-y-input.val y

	change-rotate-z: (z) ->
		z = Number z
		@item.rotation.z = z
		@item.room-item-info.rotation.z = z
		@$controller-rotate-z-input.val z

class Room
	(graphics-quality) ->
		THIS = @

		@graphics-quality = graphics-quality

		shadow-quality = switch (@graphics-quality)
			| \ultra => 8192
			| \high => 8192
			| \medium => 4096
			| \low => 2048
			| \very-low => 1024
			| \super-low => 0

		debug = no

		@room-items = JSON.parse ($ \html .attr \data-room-items)
		@is-me = ($ \html .attr \data-is-me) == \true

		if @is-me
			@item-controller = new ItemController @

		@active-items = []
		@unactive-items = []

		width = window.inner-width
		height = window.inner-height

		################################
		# Init scene

		# Scene settings
		@scene = new THREE.Scene!

		# Renderer settings
		@renderer = new THREE.WebGLRenderer {-antialias}
			..set-pixel-ratio window.device-pixel-ratio
			..set-size width, height
			..auto-clear = off
			..set-clear-color new THREE.Color 0x051f2d
			..shadow-map.enabled = if @graphics-quality == \super-low then off else on
			..shadow-map-cascade = if @graphics-quality == \ultra then on else off
			..shadow-map.cull-face = THREE.CullFaceBack
		#document.get-element-by-id \main .append-child renderer.dom-element
		document.body.append-child @renderer.dom-element

		# Camera settings
		#camera = new THREE.PerspectiveCamera 75 (width / height), 0.1 1000
		@camera = new THREE.OrthographicCamera width / - 2, width / 2, height / 2, height / - 2, -10, 10
			..zoom = 100
			..position.x = 2
			..position.y = 2
			..position.z = 2
			..update-projection-matrix!
		@scene.add @camera

		# AmbientLight
		ambient-light = new THREE.AmbientLight 0xffffff 1
			..cast-shadow = no
		@scene.add ambient-light

		if @graphics-quality == \ultra
			# Room light
			room-light = new THREE.SpotLight 0xffffff 0.2
				..position.set 0 8 0
				..cast-shadow = on
				..shadow-bias = -0.0001
				..shadow-map-width = shadow-quality
				..shadow-map-height = shadow-quality
				..shadow-camera-near = 0.1
				..shadow-camera-far = 9
				..shadow-camera-fov = 45
				..only-shadow = on
				..shadow-camera-visible = debug
			@scene.add room-light

		out-light = new THREE.SpotLight 0xffffff 0.4
			..position.set 9 3 -2
			..cast-shadow = on
			..shadow-bias = -0.001 # アクネ、アーチファクト対策 その代わりピーターパンが発生する可能性がある
			..shadow-map-width = shadow-quality
			..shadow-map-height = shadow-quality
			..shadow-camera-near = 6
			..shadow-camera-far = 15
			..shadow-camera-fov = 45
			..shadow-camera-visible = debug
			#..only-shadow = on
		@scene.add out-light

		# Controller setting
		@controls = new THREE.OrbitControls @camera, @renderer.dom-element
			..target.set 0 1 0
			#..enable-zoom = debug
			#..enable-pan = debug
			..enable-zoom = on
			..enable-pan = off
			..min-polar-angle = 0
			..max-polar-angle = if debug then Math.PI else Math.PI / 2
			..min-azimuth-angle = 0
			..max-azimuth-angle = if debug then Math.PI else Math.PI / 2

		# DEBUG
		if debug
			@scene.add new THREE.AxisHelper 10
			@scene.add new THREE.GridHelper 5 1

		################################
		# POST FXs

		if @graphics-quality != \super-low
			render-target = new THREE.WebGLRenderTarget width, height, {
				min-filter: THREE.LinearFilter
				mag-filter: THREE.LinearFilter
				format: THREE.RGBFormat
				-stencil-buffer
			}

			fxaa = new THREE.ShaderPass THREE.FXAAShader
				..uniforms['resolution'].value = new THREE.Vector2 (1 / width), (1 / height)
				..render-to-screen = on

			/*
			bokeh = new THREE.BokehPass @scene, @camera, {
				focus: 1.0
				aperture: 0.025
				maxblur: 1.0
				width: width
				height: height
			}
			*/

			#to-screen = new THREE.ShaderPass THREE.CopyShader
			#	..render-to-screen = on

			@composer = new THREE.EffectComposer @renderer, render-target
				..add-pass new THREE.RenderPass @scene, @camera
				..add-pass new THREE.BloomPass 0.5 25 128.0 512
				..add-pass fxaa
				#..add-pass to-screen
		else
			@composer = null

		################################

		if @is-me
			# Hover highlight
			@renderer.dom-element.onmousemove = (e) ->
				rect = e.target.get-bounding-client-rect!
				x = ((e.client-x - rect.left) / THIS.renderer.dom-element.width) * 2 - 1
				y = -((e.client-y - rect.top) / THIS.renderer.dom-element.height) * 2 + 1
				pos = new THREE.Vector2 x, y
				THIS.camera.update-matrix-world!
				raycaster = new THREE.Raycaster!
				raycaster.set-from-camera pos, THIS.camera
				intersects = raycaster.intersect-objects THIS.active-items, on

				THIS.active-items.for-each (item) ->
					item.traverse (child) ->
						if child instanceof THREE.Mesh
							if (not child.is-active?) or (not child.is-active)
								child.material.emissive.set-hex 0x000000

				if intersects.length > 0
					INTERSECTED = intersects[0].object.source
					INTERSECTED.traverse (child) ->
						if child instanceof THREE.Mesh
							if (not child.is-active?) or (not child.is-active)
								child.material.emissive.set-hex 0x191919

			@renderer.dom-element.onmousedown = (e) ->
				if (e.target == THIS.renderer.dom-element) and (e.button == 2)
					rect = e.target.get-bounding-client-rect!
					x = ((e.client-x - rect.left) / THIS.renderer.dom-element.width) * 2 - 1
					y = -((e.client-y - rect.top) / THIS.renderer.dom-element.height) * 2 + 1
					pos = new THREE.Vector2 x, y
					THIS.camera.update-matrix-world!
					raycaster = new THREE.Raycaster!
					raycaster.set-from-camera pos, THIS.camera
					intersects = raycaster.intersect-objects THIS.active-items, on

					THIS.selected-item = null
					THIS.item-controller.update null

					THIS.active-items.for-each (item) ->
						item.traverse (child) ->
							if child instanceof THREE.Mesh
								child.material.emissive.set-hex 0x000000
								child.is-active = no

					if intersects.length > 0
						selected-obj = intersects[0].object.source
						THIS.select-item selected-obj

		################################
		# Load items of room

		# Room
		loader = new THREE.OBJMTLLoader!
		loader.load '/resources/common/3d-models/room/room.obj' '/resources/common/3d-models/room/room.mtl' (object) ->
			object.traverse (child) ->
				if child instanceof THREE.Mesh
					child.receive-shadow = on
					child.cast-shadow = on
			object.position.set 0 0 0
			THIS.scene.add object

		# Label
		icon-image-url = $ \html .attr \data-user-icon-url
		THREE.ImageUtils.cross-origin = ''
		icon-texture = THREE.ImageUtils.load-texture icon-image-url
			..wrap-s = THREE.RepeatWrapping
			..wrap-t = THREE.RepeatWrapping
			..anisotropy = 16

		icon-material = new THREE.MeshPhongMaterial {
			specular: 0x030303
			emissive: 0x111111
			map: icon-texture
			side: THREE.DoubleSide
			alpha-test: 0.5
		}

		icon-geometry = new THREE.PlaneGeometry 1 1

		icon-object = new THREE.Mesh icon-geometry, icon-material
			..position.set -3 2.5 2
			..rotation.y = Math.PI / 2
			..cast-shadow = off

		@scene.add icon-object

		screen-name = $ \html .attr \data-user-screen-name
		name-geometry = new THREE.TextGeometry screen-name, {
			size: 0.5
			height: 0
			curve-segments: 8
			font: \helvetiker
			weight: \normal
			style: \normal
			bevel-thickness: 0
			bevel-size: 0
			bevel-enabled: no
		}

		name-material = new THREE.MeshLambertMaterial {color: 0xffffff}

		name-object = new THREE.Mesh name-geometry, name-material
			..position.set -3 2.25 1.25
			..rotation.y = Math.PI / 2
			..cast-shadow = off

		@scene.add name-object

		# User items
		@room-items.for-each (item) ->
			if item.position?
				load-item item, (object) ->
					THIS.scene.add object
					THIS.active-items.push object
			else
				THIS.add-item-to-box item

		if @graphics-quality == \super-low
			@direct-render!
		else
			@post-render!

	post-render: ->
		request-animation-frame @post-render.bind @

		# Camera controller
		@controls.update!

		@renderer.clear!
		@composer.render!

	direct-render: ->
		request-animation-frame @direct-render.bind @

		# Camera controller
		@controls.update!

		@renderer.render @scene, @camera

	select-item: (item-obj) ->
		@selected-item = item-obj

		# Highlight
		item-obj.traverse (child) ->
			if child instanceof THREE.Mesh
				child.material.emissive.set-hex 0xff0000
				child.is-active = yes

		# Display to controller
		@item-controller.update @selected-item

	add-item-to-box: (item) ->
		THIS = @

		item.position = null
		item.rotation = null

		# Remove the item from scene
		@scene.remove @scene.get-object-by-name item.individual-id

		# Remove the item from active items list
		@active-items.some (v, i) ->
			if v.name == item.individual-id
				THIS.active-items.splice i, 1

		# Add the item to unactive items list
		@unactive-items.push item

		# Add to Box
		$item = $ "<li><p class='name'>#{item.obj.name}</p></li>"
		$set-button = $ "<button>置く</button>"
			..click ->
				$item.remove!

				# Remove the item from unactive items list
				THIS.unactive-items.some (v, i) ->
					if v.individual-id == item.individual-id
						THIS.unactive-items.splice i, 1

				# Load item
				load-item item, (object) ->
					object
						..position.set 0 0 0
						..rotation.set 0 0 0
						..room-item-info.position = {}
						..room-item-info.position.x = 0
						..room-item-info.position.y = 0
						..room-item-info.position.z = 0
						..room-item-info.rotation = {}
						..room-item-info.rotation.x = 0
						..room-item-info.rotation.y = 0
						..room-item-info.rotation.z = 0

					# Add to scene and active items list
					THIS.scene.add object
					THIS.active-items.push object

					# Select
					THIS.select-item object
		$item.append $set-button
		$ \#box .find \ul .append $item

	export-layout: ->
		layout = []
		@unactive-items.for-each (item) ->
			layout.push item
		@active-items.for-each (item) ->
			layout.push item.room-item-info
		layout

	export-layout-json: ->
		JSON.stringify @export-layout!

	save: (done, fail) ->
		json = @export-layout-json!

		$.ajax config.api-url + '/account/update-room' {
			type: \put
			data: {
				'layout': json
			}
			data-type: \json
			xhr-fields: {+with-credentials}}
		.done (data) ->
			done!
		.fail (data) ->
			fail!

function load-item(item, cb)
	switch (item.obj.model-type)
	| \json => # No longer supported
		loader = new THREE.ObjectLoader!
		loader.load "/resources/common/3d-models/#{item.obj.id}/#{item.obj.id}.json" (object) ->
			object
				..position.x = if item.position? and item.position.x? then item.position.x else 0
				..position.y = if item.position? and item.position.y? then item.position.y else 0
				..position.z = if item.position? and item.position.z? then item.position.z else 0
				..rotation.x = if item.rotation? and item.rotation.x? then item.rotation.x else 0
				..rotation.y = if item.rotation? and item.rotation.y? then item.rotation.y else 0
				..rotation.z = if item.rotation? and item.rotation.z? then item.rotation.z else 0
				..cast-shadow = on
				..receive-shadow = on
				..name = item.individual-id
			cb object
	| \objmtl =>
		loader = new THREE.OBJMTLLoader!
		loader.load "/resources/common/3d-models/#{item.obj.id}/#{item.obj.id}.obj" "/resources/common/3d-models/#{item.obj.id}/#{item.obj.id}.mtl" (object) ->
			object
				..position.x = if item.position? and item.position.x? then item.position.x else 0
				..position.y = if item.position? and item.position.y? then item.position.y else 0
				..position.z = if item.position? and item.position.z? then item.position.z else 0
				..rotation.x = if item.rotation? and item.rotation.x? then item.rotation.x else 0
				..rotation.y = if item.rotation? and item.rotation.y? then item.rotation.y else 0
				..rotation.z = if item.rotation? and item.rotation.z? then item.rotation.z else 0
				..name = item.individual-id
				..room-item-info = item
				..traverse (child) ->
					if child instanceof THREE.Mesh
						child
							..source = object
							..cast-shadow = on
							..receive-shadow = on
			cb object

################################################################

# ENTORY POINT

################################
# Load graphics quality setting
graphics-quality = $.cookie \room-graphics-quality
if not $.cookie \room-graphics-quality
	graphics-quality = \high
	$.cookie \room-graphics-quality graphics-quality, { path: '/', expires: 365 }
################################

# INIT ROOM
room = new Room graphics-quality

################################
# Init settings button
$ \#setting-button .click ->
	$ \#settings-form-background .css \display \block
	$ \#settings-form-background .animate {
		opacity: 1
	} 100ms \linear
	$ \#settings-form-container .css \display \block
	$ \#settings-form .animate {
		opacity: 1
	} 100ms \linear
################################

################################
# Init settings form
$ \#settings-form .click (e) ->
	e.stop-propagation!

$ \#settings-form-container .click ->
	$ \#settings-form-background .animate {
		opacity: 0
	} 100ms \linear -> $ \#settings-form-background .css \display \none
	$ \#settings-form .animate {
		opacity: 0
	} 100ms \linear -> $ \#settings-form-container .css \display \none

switch (graphics-quality)
	| \ultra => $ \#settings-form .find \.graphics-quality .find 'option[value=ultra]' .attr \selected \true
	| \high => $ \#settings-form .find \.graphics-quality .find 'option[value=high]' .attr \selected \true
	| \medium => $ \#settings-form .find \.graphics-quality .find 'option[value=medium]' .attr \selected \true
	| \low => $ \#settings-form .find \.graphics-quality .find 'option[value=low]' .attr \selected \true
	| \very-low => $ \#settings-form .find \.graphics-quality .find 'option[value=very-low]' .attr \selected \true
	| \super-low => $ \#settings-form .find \.graphics-quality .find 'option[value=super-low]' .attr \selected \true

$ \#settings-form .find \.graphics-quality .find \select .change ->
	graphics-quality = $ \#settings-form .find \.graphics-quality .find \select .val!
	$.cookie \room-graphics-quality graphics-quality, { path: '/', expires: 365 }
	alert 'グラフィックスの設定は、ページのリロード後に反映されます。'
################################

################################
# Init save button
$save-button = $ \#save-button
$save-button.click ->
	$save-button
		..attr \disabled on
		..find \p .text '保存しています...'

	# Save the room
	room.save do
		-> # Success
			$save-button
				..attr \disabled off
				..find \p .text '部屋を保存'

			window.display-message '保存しました'
		-> # Failed
			$save-button
				..attr \disabled off
				..find \p .text '部屋を保存'

			window.display-message '保存に失敗しました。再度お試しください。'
################################
