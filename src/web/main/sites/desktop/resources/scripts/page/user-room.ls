room-items = JSON.parse ($ \html .attr \data-room-items)
SELECTEDITEM = null
item-controller-viewer-scene = null

$controller = $ \#item-controller
$controller-item-title = $controller.find \.title
$controller-pos-back-button = $controller.find \.pos-back-button
$controller-pos-forward-button = $controller.find \.pos-forward-button
$controller-pos-left-button = $controller.find \.pos-left-button
$controller-pos-right-button = $controller.find \.pos-right-button
$controller-pos-up-button = $controller.find \.pos-up-button
$controller-pos-down-button = $controller.find \.pos-down-button
$controller-pos-x-input = $controller.find \.pos-x
$controller-pos-y-input = $controller.find \.pos-y
$controller-pos-z-input = $controller.find \.pos-z
$controller-rotate-x-input = $controller.find \.rotate-x
$controller-rotate-y-input = $controller.find \.rotate-y
$controller-rotate-z-input = $controller.find \.rotate-z

init!
init-item-controller!

function init
	shadow-quolity = 8192
	debug = no

	width = window.inner-width
	height = window.inner-height

	items = []
	unactive-items = []

	# Scene settings
	scene = new THREE.Scene!

	# Renderer settings
	renderer = new THREE.WebGLRenderer {-antialias}
		..set-pixel-ratio window.device-pixel-ratio
		..set-size width, height
		..auto-clear = off
		..set-clear-color new THREE.Color 0x051f2d
		..shadow-map.enabled = on
		#..shadow-map-soft = off
		#..shadow-map-cull-front-faces = on
		..shadow-map.cull-face = THREE.CullFaceBack
	#document.get-element-by-id \main .append-child renderer.dom-element
	document.body.append-child renderer.dom-element

	# Camera settings
	#camera = new THREE.PerspectiveCamera 75 (width / height), 0.1 1000
	camera = new THREE.OrthographicCamera width / - 2, width / 2, height / 2, height / - 2, -10, 10
		..zoom = 100
		..position.x = 2
		..position.y = 2
		..position.z = 2
		..update-projection-matrix!
	scene.add camera

	# AmbientLight
	ambient-light = new THREE.AmbientLight 0xffffff 1
		..cast-shadow = no
	scene.add ambient-light

	# Room light (for shadow)
	room-light = new THREE.SpotLight 0xffffff 0.2
		..position.set 0 8 0
		..cast-shadow = on
		..shadow-map-width = shadow-quolity
		..shadow-map-height = shadow-quolity
		..shadow-camera-near = 0.1
		..shadow-camera-far = 9
		..shadow-camera-fov = 45
		#..only-shadow = on
		#..shadow-camera-visible = on #debug
	#scene.add room-light

	out-light = new THREE.SpotLight 0xffffff 0.4
		..position.set 9 3 -2
		..cast-shadow = on
		..shadow-bias = -0.001 # アクネ、アーチファクト対策 その代わりピーターパンが発生する可能性がある
		..shadow-map-width = shadow-quolity
		..shadow-map-height = shadow-quolity
		..shadow-camera-near = 6
		..shadow-camera-far = 15
		..shadow-camera-fov = 45
		..shadow-camera-visible = debug
		#..only-shadow = on
	scene.add out-light

	# Controller setting
	controls = new THREE.OrbitControls camera, renderer.dom-element
		..target.set 0 1 0
		..enable-zoom = debug
		..enable-pan = debug
		..min-polar-angle = 0
		..max-polar-angle = if debug then Math.PI else Math.PI / 2
		..min-azimuth-angle = 0
		..max-azimuth-angle = if debug then Math.PI else Math.PI / 2

	# DEBUG
	if debug
		scene.add new THREE.AxisHelper 1000
		scene.add new THREE.GridHelper 10 1

	################################
	# POST FXs

	render-target = new THREE.WebGLRenderTarget width, height, {
		min-filter: THREE.LinearFilter
		mag-filter: THREE.LinearFilter
		format: THREE.RGBFormat
		-stencil-buffer
	}

	fxaa = new THREE.ShaderPass THREE.FXAAShader
		..uniforms['resolution'].value = new THREE.Vector2 (1 / width), (1 / height)

	to-screen = new THREE.ShaderPass THREE.CopyShader
		..render-to-screen = on

	composer = new THREE.EffectComposer renderer, render-target
		..add-pass new THREE.RenderPass scene, camera
		..add-pass new THREE.BloomPass 0.5 25 128.0 512
		..add-pass fxaa
		..add-pass to-screen

	################################

	# Hover highlight
	renderer.dom-element.onmousemove = (e) ->
		rect = e.target.get-bounding-client-rect!
		x = ((e.client-x - rect.left) / renderer.dom-element.width) * 2 - 1
		y = -((e.client-y - rect.top) / renderer.dom-element.height) * 2 + 1
		pos = new THREE.Vector2 x, y
		camera.update-matrix-world!
		raycaster = new THREE.Raycaster!
		raycaster.set-from-camera pos, camera
		intersects = raycaster.intersect-objects items, on

		items.for-each (item) ->
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

	renderer.dom-element.onmousedown = (e) ->
		if (e.target == renderer.dom-element) and (e.button == 2)
			rect = e.target.get-bounding-client-rect!
			x = ((e.client-x - rect.left) / renderer.dom-element.width) * 2 - 1
			y = -((e.client-y - rect.top) / renderer.dom-element.height) * 2 + 1
			pos = new THREE.Vector2 x, y
			camera.update-matrix-world!
			raycaster = new THREE.Raycaster!
			raycaster.set-from-camera pos, camera
			intersects = raycaster.intersect-objects items, on

			SELECTEDITEM := null
			update-item-controller!

			items.for-each (item) ->
				item.traverse (child) ->
					if child instanceof THREE.Mesh
						child.material.emissive.set-hex 0x000000
						child.is-active = no

			if intersects.length > 0
				console.log intersects
				INTERSECTED = intersects[0].object.source
				SELECTEDITEM := INTERSECTED
				update-item-controller!
				# Highlight
				INTERSECTED.traverse (child) ->
					if child instanceof THREE.Mesh
						child.material.emissive.set-hex 0xff0000
						child.is-active = yes

	#init-sky!
	init-items!

	render!

	function init-sky
		sun-sphere = new THREE.Mesh do
			new THREE.SphereBufferGeometry 20000 16 8
			new THREE.MeshBasicMaterial {color: 0xffffff}
		sun-sphere.position.y = -700000
		sun-sphere.visible = no
		scene.add sun-sphere

		sky = new THREE.Sky!
		sky.uniforms.turbidity.value = 10
		sky.uniforms.reileigh.value = 4
		sky.uniforms.luminance.value = 1
		sky.uniforms.mie-coefficient.value = 0.005
		sky.uniforms.mie-directional-g.value = 0.8

		inclination = 0
		azimuth = 0

		theta = Math.PI * (inclination - 0.5)
		phi = 2 * Math.PI * (azimuth - 0.5)

		distance = 400000

		sun-sphere.position.x = distance * (Math.cos phi)
		sun-sphere.position.y = distance * (Math.sin phi) * (Math.sin theta)
		sun-sphere.position.z = distance * (Math.sin phi) * (Math.cos theta)

		sky.uniforms.sun-position.value.copy sun-sphere.position

		scene.add sky.mesh

	function init-items
		loader = new THREE.OBJMTLLoader!
		loader.load '/resources/common/3d-models/room/room.obj' '/resources/common/3d-models/room/room.mtl' (object) ->
			object.traverse (child) ->
				if child instanceof THREE.Mesh
					child.receive-shadow = on
					child.cast-shadow = on
			object.position.set 0 0 0
			scene.add object

		room-items.for-each (item) ->
			console.log item
			if item.position?
				switch (item.obj.model-type)
				| \json =>
					loader = new THREE.ObjectLoader!
					loader.load "/resources/common/3d-models/#{item.obj.id}/#{item.obj.id}.json" (object) ->
						object.position.x = item.position.x
						object.position.y = item.position.y
						object.position.z = item.position.z
						object.rotation.x = item.rotation.x
						object.rotation.y = item.rotation.y
						object.rotation.z = item.rotation.z
						object.cast-shadow = on
						object.receive-shadow = on
						object.name = item.individual-id
						scene.add object
						items.push object
				| \objmtl =>
					loader = new THREE.OBJMTLLoader!
					loader.load "/resources/common/3d-models/#{item.obj.id}/#{item.obj.id}.obj" "/resources/common/3d-models/#{item.obj.id}/#{item.obj.id}.mtl" (object) ->
						object.position.x = item.position.x
						object.position.y = item.position.y
						object.position.z = item.position.z
						object.rotation.x = item.rotation.x
						object.rotation.y = item.rotation.y
						object.rotation.z = item.rotation.z
						object.name = item.individual-id
						object.room-item-info = item
						object.traverse (child) ->
							if child instanceof THREE.Mesh
								child.source = object
								child.cast-shadow = on
								child.receive-shadow = on
						scene.add object
						items.push object
			else
				unactive-items.push item

	# Renderer
	function render
		#timer = Date.now! * 0.0004
		request-animation-frame render
		#out-light.position.z = (Math.cos timer) * 10
		#out-light.position.x = (Math.sin timer) * 10
		controls.update!
		renderer.clear!
		composer.render!
		#renderer.render scene, camera

function init-item-controller
	init-item-controller-viewer!

	$ \html .keydown (e) ->
		switch (e.which)
		| 39 => # Key[→]
			if e.shift-key
				change-pos-z SELECTEDITEM.position.z - 0.01
			else
				change-pos-z SELECTEDITEM.position.z - 0.1
		| 37 => # Key[←]
			if e.shift-key
				change-pos-z SELECTEDITEM.position.z + 0.01
			else
				change-pos-z SELECTEDITEM.position.z + 0.1
		| 38 => # Key[↑]
			if e.shift-key
				change-pos-x SELECTEDITEM.position.x - 0.01
			else
				change-pos-x SELECTEDITEM.position.x - 0.1
		| 40 => # Key[↓]
			if e.shift-key
				change-pos-x SELECTEDITEM.position.x + 0.01
			else
				change-pos-x SELECTEDITEM.position.x + 0.1

	$controller-pos-back-button.click ->
		change-pos-x SELECTEDITEM.position.x + 0.1

	$controller-pos-forward-button.click ->
		change-pos-x SELECTEDITEM.position.x - 0.1

	$controller-pos-left-button.click ->
		change-pos-z SELECTEDITEM.position.z + 0.1

	$controller-pos-right-button.click ->
		change-pos-z SELECTEDITEM.position.z - 0.1

	$controller-pos-up-button.click ->
		change-pos-y SELECTEDITEM.position.y + 0.1

	$controller-pos-down-button.click ->
		change-pos-y SELECTEDITEM.position.y - 0.1

	$controller-pos-x-input.bind \input ->
		change-pos-x $controller-pos-x-input.val!

	$controller-pos-y-input.bind \input ->
		change-pos-y $controller-pos-y-input.val!

	$controller-pos-z-input.bind \input ->
		change-pos-z $controller-pos-z-input.val!

	$controller-rotate-x-input.bind \input ->
		change-rotate-x $controller-rotate-x-input.val!

	$controller-rotate-y-input.bind \input ->
		change-rotate-y $controller-rotate-y-input.val!

	$controller-rotate-z-input.bind \input ->
		change-rotate-z $controller-rotate-z-input.val!

	function change-pos-x(x)
		x = Number x
		if x > 2.5 then x = 2.5
		if x < -2.5 then x = -2.5
		SELECTEDITEM.position.x = x
		$controller-pos-x-input.val x

	function change-pos-y(y)
		y = Number y
		if y > 1.5 then y = 1.5
		if y < 0 then y = 0
		SELECTEDITEM.position.y = y
		$controller-pos-y-input.val y

	function change-pos-z(z)
		z = Number z
		if z > 2.5 then z = 2.5
		if z < -2.5 then z = -2.5
		SELECTEDITEM.position.z = z
		$controller-pos-z-input.val z

	function change-rotate-x(x)
		x = Number x
		SELECTEDITEM.rotation.x = x
		$controller-rotate-x-input.val x

	function change-rotate-y(y)
		y = Number y
		SELECTEDITEM.rotation.y = y
		$controller-rotate-y-input.val y

	function change-rotate-z(z)
		z = Number z
		SELECTEDITEM.rotation.z = z
		$controller-rotate-z-input.val z

function update-item-controller
	if SELECTEDITEM?
		$controller.css \display \block
		$controller-item-title.text SELECTEDITEM.room-item-info.obj.name
		$controller-pos-x-input.val SELECTEDITEM.position.x
		$controller-pos-y-input.val SELECTEDITEM.position.y
		$controller-pos-z-input.val SELECTEDITEM.position.z
		$controller-rotate-x-input.val SELECTEDITEM.rotation.x
		$controller-rotate-y-input.val SELECTEDITEM.rotation.y
		$controller-rotate-z-input.val SELECTEDITEM.rotation.z

		################################
		# Display preview

		# Remove old object
		old = item-controller-viewer-scene.get-object-by-name \obj
		if old?
			item-controller-viewer-scene.remove old

		# Add new object
		preview-obj = SELECTEDITEM.clone!
			..name = \obj
			..position.x = 0
			..position.y = 0
			..position.z = 0
		preview-obj.traverse (child) ->
			if child instanceof THREE.Mesh
				child.material.emissive.set-hex 0x000000
		item-controller-viewer-scene.add preview-obj
		################################
	else
		$controller.css \display \none

function init-item-controller-viewer
	canvas = document.get-element-by-id \item-controller-preview-canvas
	width = canvas.width
	height = canvas.height

	# Scene settings
	item-controller-viewer-scene := new THREE.Scene!

	# Renderer settings
	renderer = new THREE.WebGLRenderer {canvas, +antialias}
		..set-pixel-ratio window.device-pixel-ratio
		..set-size width, height
		..auto-clear = off
		..shadow-map.enabled = on
		#..shadow-map-soft = off
		#..shadow-map-cull-front-faces = on
		..shadow-map.cull-face = THREE.CullFaceBack

	# Camera settings
	camera = new THREE.PerspectiveCamera 75 (width / height), 0.1 100
		..zoom = 100
		..position.x = 0
		..position.y = 2
		..position.z = 0
	item-controller-viewer-scene.add camera

	# AmbientLight
	ambient-light = new THREE.AmbientLight 0xffffff 1
		..cast-shadow = no
	item-controller-viewer-scene.add ambient-light

	item-controller-viewer-scene.add new THREE.AxisHelper 5
	item-controller-viewer-scene.add new THREE.GridHelper 5 0.5

	render!

	function render
		timer = Date.now! * 0.0004
		request-animation-frame render

		camera.position.z = (Math.cos timer) * 10
		camera.position.x = (Math.sin timer) * 10
		camera.look-at new THREE.Vector3 0 0 0

		#controls.update!
		renderer.render item-controller-viewer-scene, camera
