# Settings
scene = new THREE.Scene!
camera = new THREE.PerspectiveCamera 75 (window.inner-width / window.inner-height), 0.1 1000
renderer = new THREE.WebGLRenderer {+antialias}
renderer.set-size window.inner-width, window.inner-height
renderer.shadow-map.enabled = on
document.get-element-by-id \main .append-child renderer.dom-element

# DEBUG GUIDE
scene.add new THREE.AxisHelper 1000
scene.add new THREE.GridHelper 10 1

loader = new THREE.JSONLoader!
loader.load '/resources/common/3d-models/milk.json' (geometry, materials) ->
	geo = geometry
	mat = new THREE.MeshFaceMaterial materials
	#mat = new THREE.MeshPhongMaterial {color: 0x0000ff, ambient: 0x0000ff}
	mesh = new THREE.Mesh geo, mat
	mesh.position.set 0 0 0
	mesh.scale.set 1 1 1
	mesh.cast-shadow = on
	scene.add mesh

console.log 'WORK PLEASE'
loader.load '/resources/common/3d-models/desk.json' (geometry, materials) ->
	console.log 'DESK LOADED'
	console.log geometry
	console.log materials
	geo = geometry
	mat = new THREE.MeshFaceMaterial materials
	#mat = new THREE.MeshPhongMaterial {color: 0x0000ff, ambient: 0x0000ff}
	mesh = new THREE.Mesh geo, mat
	mesh.position.set 0 0 0
	mesh.scale.set 1 1 1
	mesh.cast-shadow = on
	scene.add mesh

# Floor
floor-geometry = new THREE.CubeGeometry 10 1 10
floor-material = new THREE.MeshPhongMaterial {color: 0xdcc38d}
floor = new THREE.Mesh floor-geometry, floor-material
floor.receive-shadow = on
floor.position.set 0 -0.5 0
scene.add floor

# AmbientLight
ambient-light = new THREE.AmbientLight 0xffffff 1
ambient-light.cast-shadow = no
scene.add ambient-light

# Room light (for shadow)
room-light = new THREE.SpotLight 0xffffff 1
room-light.position.set 0, 10, 0
room-light.cast-shadow = on
room-light.shadow-map-width = 4096
room-light.shadow-map-height = 4096
room-light.shadow-camera-near = 1
room-light.shadow-camera-far = 10
room-light.shadow-camera-fov = 90
#room-light.only-shadow = on
room-light.shadow-camera-visible = on #debug
scene.add room-light

# Camera setting
camera.position.x = 10
camera.position.y = 10
camera.position.z = 10
camera.look-at new THREE.Vector3 0, 0, 0

# Controller setting
controls = new THREE.OrbitControls camera, renderer.dom-element

# Renderer
function render
	request-animation-frame render
	controls.update!
	renderer.render scene, camera

# Rendering
render!