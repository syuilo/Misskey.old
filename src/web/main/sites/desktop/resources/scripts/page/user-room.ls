# Settings
scene = new THREE.Scene!
camera = new THREE.PerspectiveCamera 75 (window.inner-width / window.inner-height), 0.1 1000
renderer = new THREE.WebGLRenderer!
renderer.set-size window.inner-width, window.inner-height
document.get-element-by-id \main .append-child renderer.dom-element

# DEBUG GUIDE
scene.add new THREE.AxisHelper 1000
scene.add new THREE.GridHelper 10 1

# DEBUG OBJECT
cube-geometry = new THREE.CubeGeometry 1 1 1
cube-material = new THREE.MeshPhongMaterial {color: 0xff2200}
cube = new THREE.Mesh cube-geometry, cube-material
cube.position.y = 2
scene.add cube

# Floor
floor-geometry = new THREE.CubeGeometry 10 1 10
floor-material = new THREE.MeshPhongMaterial {color: 0xdcc38d}
floor = new THREE.Mesh floor-geometry, floor-material
scene.add floor

# Room light
#room-light = new THREE.DirectionalLight 0xffffff 1
#room-light.position.set 0, 10, 0
#scene.add room-light
room-light = new THREE.SpotLight 0xffffff 1
room-light.position.set 0, 10, 0
room-light.cast-shadow = on
room-light.shadow-map-width = 1024
room-light.shadow-map-height = 1024
room-light.shadow-camera-near = 500
room-light.shadow-camera-far = 4000
room-light.shadow-camera-fov = 30
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