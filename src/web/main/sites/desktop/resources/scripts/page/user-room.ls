room-items = JSON.parse ($ \html .attr \data-room-items)

init!

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
	renderer = new THREE.WebGLRenderer {+antialias}
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
	camera.zoom = 1000
		..position.x = 2
		..position.y = 2
		..position.z = 2
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
	controls = new THREE.OrbitControls camera
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

	window.onmousemove = (e) ->
		#if (e.target == renderer.dom-element) and (e.button == 2)
		rect = e.target.get-bounding-client-rect!
		x = ((e.client-x - rect.left) / renderer.dom-element.width) * 2 - 1
		y = -((e.client-y - rect.top) / renderer.dom-element.height) * 2 + 1
		pos = new THREE.Vector2 x, y
		camera.update-matrix-world!
		raycaster = new THREE.Raycaster!
		raycaster.set-from-camera pos, camera
		intersects = raycaster.intersect-objects scene.children
		console.log intersects

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
						object.id = item.individual-id
						scene.add object
						items.push object
				| \objmtl =>
					loader = new THREE.OBJMTLLoader!
					loader.load "/resources/common/3d-models/#{item.obj.id}/#{item.obj.id}.obj" "/resources/common/3d-models/#{item.obj.id}/#{item.obj.id}.mtl" (object) ->
						object.traverse (child) ->
							if child instanceof THREE.Mesh
								child.cast-shadow = on
								child.receive-shadow = on
						object.position.x = item.position.x
						object.position.y = item.position.y
						object.position.z = item.position.z
						object.rotation.x = item.rotation.x
						object.rotation.y = item.rotation.y
						object.rotation.z = item.rotation.z
						object.id = item.individual-id
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
