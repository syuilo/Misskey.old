init!

function init
	shadow-quolity = 4096
	
	# Settings
	scene = new THREE.Scene!
	width = window.inner-width
	height = window.inner-height
	scale = 256
	#camera = new THREE.PerspectiveCamera 75 (width / height), 0.1 1000
	camera = new THREE.OrthographicCamera -(width / scale), (width / scale), (height / scale), -(height / scale), -100, 100
	
	renderer = new THREE.WebGLRenderer {+antialias}
	renderer.set-pixel-ratio window.device-pixel-ratio
	renderer.set-size width, height
	renderer.auto-clear = off
	#renderer.set-clear-color new THREE.Color 0x8ebddb
	renderer.set-clear-color new THREE.Color 0x051f2d
	renderer.shadow-map.enabled = on
	#renderer.shadow-map-soft = off
	#renderer.shadow-map-cull-front-faces = on
	renderer.shadow-map.cull-face = THREE.CullFaceBack
	
	#document.get-element-by-id \main .append-child renderer.dom-element
	document.body.append-child renderer.dom-element

	# DEBUG GUIDE
	#scene.add new THREE.AxisHelper 1000
	#scene.add new THREE.GridHelper 10 1
	
	#init-sky!
	
	# SKY
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
	
	loader = new THREE.OBJMTLLoader!
	loader.load '/resources/common/3d-models/room/room.obj' '/resources/common/3d-models/room/room.mtl' (object) ->
		object.traverse (child) ->
			if child instanceof THREE.Mesh
				child.receive-shadow = on
				child.cast-shadow = on
		object.position.set 0 0 0
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



	# AmbientLight
	ambient-light = new THREE.AmbientLight 0xffffff 1
	ambient-light.cast-shadow = no
	scene.add ambient-light

	# Room light (for shadow)
	room-light = new THREE.SpotLight 0xffffff 0.2
	room-light.position.set 0 8 0
	room-light.cast-shadow = on
	room-light.shadow-map-width = shadow-quolity
	room-light.shadow-map-height = shadow-quolity
	room-light.shadow-camera-near = 0.1
	room-light.shadow-camera-far = 9
	room-light.shadow-camera-fov = 45
	#room-light.only-shadow = on
	#room-light.shadow-camera-visible = on #debug
	#scene.add room-light

	out-light = new THREE.SpotLight 0xffffff 0.4
	out-light.position.set 9 3 -2
	out-light.cast-shadow = on
	out-light.shadow-bias = -0.001
	out-light.shadow-map-width = shadow-quolity
	out-light.shadow-map-height = shadow-quolity
	out-light.shadow-camera-near = 6
	out-light.shadow-camera-far = 15
	out-light.shadow-camera-fov = 45
	#out-light.only-shadow = on
	#out-light.shadow-camera-visible = on #debug
	scene.add out-light

	# Camera setting
	camera.position.x = 2
	camera.position.y = 2
	camera.position.z = 2
	scene.add camera

	# Controller setting
	controls = new THREE.OrbitControls camera
	controls.target.set 0 1 0
	controls.enable-zoom = yes
	controls.enable-pan = yes
	controls.min-polar-angle = 0
	controls.max-polar-angle = Math.PI / 2
	controls.min-azimuth-angle = 0
	controls.max-azimuth-angle = Math.PI / 2
	
	################################
	# POST FXs

	render-target = new THREE.WebGLRenderTarget width, height, {
		min-filter: THREE.LinearFilter
		mag-filter: THREE.LinearFilter
		format: THREE.RGBFormat
		-stencil-buffer
	}

	fxaa = new THREE.ShaderPass THREE.FXAAShader
	fxaa.uniforms['resolution'].value = new THREE.Vector2 (1 / width), (1 / height)
	
	to-screen = new THREE.ShaderPass THREE.CopyShader
	to-screen.render-to-screen = on
	
	composer = new THREE.EffectComposer renderer, render-target
	composer.add-pass new THREE.RenderPass scene, camera
	composer.add-pass new THREE.BloomPass 0.5 25 128.0 512
	composer.add-pass fxaa
	composer.add-pass to-screen
	
	################################
	
	render!

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