init!

function init
	shadow-quolity = 8192
	debug = no

	width = window.inner-width
	height = window.inner-height

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
	scale = 256
	#camera = new THREE.PerspectiveCamera 75 (width / height), 0.1 1000
	camera = new THREE.OrthographicCamera -(width / scale), (width / scale), (height / scale), -(height / scale), -100, 100
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
		..enable-zoom = no
		..enable-pan = no
		..min-polar-angle = 0
		..max-polar-angle = Math.PI / 2
		..min-azimuth-angle = 0
		..max-azimuth-angle = Math.PI / 2

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

	window.onmousedown = (ev) ->
		if (ev.target == renderer.dom-element) and (ev.button == 2)
			rect = ev.target.get-bounding-client-rect!
			mouse = { x: 0, y: 0 }
			mouse.x = ((ev.client-x - rect.left) / width) * 2 - 1
			mouse.y = ((ev.client-y - rect.top) / height) * 2 + 1
			vector = new THREE.Vector3 mouse.x, mouse.y, 1
			vector.unproject camera
			ray = new THREE.Raycaster camera.position, (vector.sub camera.position).normalize!
			obj = ray.intersect-objects!
			if obj.length > 0
				alert obj

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

		loader = new THREE.OBJMTLLoader!
		loader.load '/resources/common/3d-models/mat/mat.obj' '/resources/common/3d-models/mat/mat.mtl' (object) ->
			object.traverse (child) ->
				if child instanceof THREE.Mesh
					child.receive-shadow = on
					child.cast-shadow = on
			object.position.set -2.2 0 0.4
			scene.add object

		loader = new THREE.OBJMTLLoader!
		loader.load '/resources/common/3d-models/carpet/carpet.obj' '/resources/common/3d-models/carpet/carpet.mtl' (object) ->
			object.traverse (child) ->
				if child instanceof THREE.Mesh
					child.receive-shadow = on
					child.cast-shadow = on
			object.position.set 0 0 0
			scene.add object

		loader = new THREE.OBJMTLLoader!
		loader.load '/resources/common/3d-models/bed/bed.obj' '/resources/common/3d-models/bed/bed.mtl' (object) ->
			object.traverse (child) ->
				if child instanceof THREE.Mesh
					child.receive-shadow = on
					child.cast-shadow = on
			object.position.set 1.95 0 -1.4
			object.rotation.y = Math.PI
			scene.add object

		loader = new THREE.OBJMTLLoader!
		loader.load '/resources/common/3d-models/book/book.obj' '/resources/common/3d-models/book/book.mtl' (object) ->
			object.traverse (child) ->
				if child instanceof THREE.Mesh
					child.receive-shadow = on
					child.cast-shadow = on
			object.position.set 1.95 0 -0.2
			object.rotation.y = Math.PI
			scene.add object

		loader = new THREE.OBJMTLLoader!
		loader.load '/resources/common/3d-models/cardboard-box/cardboard-box.obj' '/resources/common/3d-models/cardboard-box/cardboard-box.mtl' (object) ->
			object.traverse (child) ->
				if child instanceof THREE.Mesh
					child.receive-shadow = on
					child.cast-shadow = on
			object.position.set -2.2 0 1.9
			#object.rotation.y = Math.PI
			scene.add object

		loader = new THREE.ObjectLoader!
		loader.load '/resources/common/3d-models/desk/desk.json' (object) ->
			object.position.set -2.2 0 -1.9
			object.rotation.y = Math.PI
			scene.add object

		loader = new THREE.OBJMTLLoader!
		loader.load '/resources/common/3d-models/chair3/chair3.obj' '/resources/common/3d-models/chair3/chair3.mtl' (object) ->
			object.traverse (child) ->
				if child instanceof THREE.Mesh
					child.cast-shadow = on
					child.receive-shadow = on
			object.position.set -1.8 0 -1.9
			object.rotation.y = Math.PI / 2
			scene.add object

		loader = new THREE.OBJMTLLoader!
		loader.load '/resources/common/3d-models/pc/pc.obj' '/resources/common/3d-models/pc/pc.mtl' (object) ->
			object.traverse (child) ->
				if child instanceof THREE.Mesh
					child.cast-shadow = on
					child.receive-shadow = on
			object.position.set -2.2 0 -1.15
			scene.add object

		loader = new THREE.OBJMTLLoader!
		loader.load '/resources/common/3d-models/mousepad/mousepad.obj' '/resources/common/3d-models/mousepad/mousepad.mtl' (object) ->
			object.traverse (child) ->
				if child instanceof THREE.Mesh
					child.cast-shadow = on
					child.receive-shadow = on
			object.position.set -2.025 0.7 -2.25
			object.rotation.y = - Math.PI / 16
			scene.add object

		loader = new THREE.ObjectLoader!
		loader.load '/resources/common/3d-models/monitor/monitor.json' (object) ->
			object.position.set -2.2 0.7 -1.9
			scene.add object
		loader.load '/resources/common/3d-models/keyboard/keyboard.json' (object) ->
			object.position.set -2 0.7 -1.9
			object.rotation.y = Math.PI
			scene.add object
		loader = new THREE.ObjectLoader!
		loader.load '/resources/common/3d-models/plant/plant.json' (object) ->
			object.position.set -2.3 0.7 -1.5
			scene.add object
		loader = new THREE.ObjectLoader!
		loader.load '/resources/common/3d-models/eraser/eraser.json' (object) ->
			object.position.set -2.1 0.7 -1.5
			scene.add object
		loader = new THREE.JSONLoader!
		loader.load '/resources/common/3d-models/milk/milk.json' (geometry, materials) ->
			geo = geometry
			mat = new THREE.MeshFaceMaterial materials
			mesh = new THREE.Mesh geo, mat
			mesh.position.set -2.3 0.7 -2.2
			mesh.rotation.y = - Math.PI / 8
			scene.add mesh
		loader = new THREE.ObjectLoader!
		loader.load '/resources/common/3d-models/facial-tissue/facial-tissue.json' (object) ->
			object.position.set -2.35 0.7 -2.35
			object.rotation.y = - Math.PI / 4
			scene.add object
		loader = new THREE.ObjectLoader!
		loader.load '/resources/common/3d-models/corkboard/corkboard.json' (object) ->
			object.position.set -2 0.9 -2.495
			object.rotation.y = Math.PI / 2
			scene.add object
		loader = new THREE.ObjectLoader!
		loader.load '/resources/common/3d-models/piano/piano.json' (object) ->
			object.position.set 0 0 -2.5
			object.rotation.y = Math.PI / 2
			scene.add object

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
