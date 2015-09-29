# Settings
scene = new THREE.Scene!
camera = new THREE.PerspectiveCamera 75 (window.inner-width / window.inner-height), 0.1 1000
renderer = new THREE.WebGLRenderer!
renderer.set-size window.inner-width, window.inner-height
document.get-element-by-id \main .append-child renderer.dom-element

# DEBUG GUIDE
scene.add new THREE.AxisHelper 1000
scene.add new THREE.GridHelper 10 1

# test object(s)
cube-geometry = new THREE.CubeGeometry 1 1 1
cube-material = new THREE.MeshBasicMaterial {color: 0x00ff00}
cube = new THREE.Mesh cube-geometry, cube-material
scene.add cube

# Camera setting
camera.position.z = 5

# Controller setting
controls = new THREE.OrbitControls camera, renderer.dom-element

# Renderer
function render
	request-animation-frame render
	controls.update!
	renderer.render scene, camera

# Rendering
render!