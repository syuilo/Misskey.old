# Settings
scene = new THREE.Scene!
camera = new THREE.PerspectiveCamera 75 (window.inner-width / window.inner-height), 0.1 1000
renderer = new THREE.WebGLRenderer!
renderer.set-size window.inner-width, window.inner-height
document.get-element-by-id \main .append-child renderer.dom-element

# DEBUG GUIDE
scene.add new THREE.AxisHelper 1000
scene.add new THREE.GridHelper 10 1

# Floor
floor-geometry = new THREE.CubeGeometry 10 1 10
floor-material = new THREE.MeshBasicMaterial {color: 0xdcc38d}
floor = new THREE.Mesh floor-geometry, floor-material
scene.add floor

# Room light
room-light = new THREE.DirectionalLight '#ffffff', 1
room-light.position.set 0, 10, 0
scene.add room-light

# Camera setting
camera.position.z = 20

# Controller setting
controls = new THREE.OrbitControls camera, renderer.dom-element

# Renderer
function render
	request-animation-frame render
	controls.update!
	renderer.render scene, camera

# Rendering
render!