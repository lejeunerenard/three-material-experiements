const glslify = require('glslify')
import * as THREE from 'three'
import createLoop from 'canvas-fit-loop'
var OrbitControls = require('three-orbit-controls')(THREE)

const dpr = Math.max(4, window.devicePixelRatio || 1)

const MANUAL = false

const renderer = new THREE.WebGLRenderer({ antialias: true })
renderer.setSize(window.innerWidth, window.innerHeight)
renderer.setClearColor(0xffffff)

const canvas = renderer.domElement
document.body.appendChild(canvas)

// Init
const camera = new THREE.PerspectiveCamera(70, window.innerWidth / window.innerHeight, 1, 1000)
const cameraRadius = 15
camera.position.set(0, 0, cameraRadius)

let controls
if (MANUAL) {
  controls = new OrbitControls(camera, renderer.domElement)
}

const scene = new THREE.Scene()

// Lights
let pLight1 = new THREE.PointLight(0xddddff, 1)
pLight1.position.set(0, 0, -50)
scene.add(pLight1)
let pLight2 = new THREE.PointLight(0xfff0f0, 1)
pLight2.position.set(0, -10, 50)
scene.add(pLight2)

let aLight = new THREE.AmbientLight(0x222f22)
scene.add(aLight)

// Object
let geo = new THREE.SphereBufferGeometry(5, 64, 64)
let mat = new THREE.ShaderMaterial({
  uniforms: THREE.UniformsUtils.merge([
    THREE.UniformsLib['lights'],
    {
      time: { value: 0 }
    }
  ]),
  lights: true,
  vertexShader: glslify('./vert.glsl'),
  fragmentShader: glslify('./frag.glsl')
})
let obj = new THREE.Mesh(geo, mat)
scene.add(obj)

// App functions
function resize () {
  let [width, height] = app.shape

  renderer.setSize(width, height)

  camera.aspect = width / height
  camera.updateProjectionMatrix()
}
function tick (dt) {
  let now = performance.now()

  if (MANUAL) {
    controls.update(now)
  } else {
    // Camera Animation
    let angle = now / 1000 / 2
    camera.position.x = cameraRadius * Math.cos(angle)
    camera.position.z = cameraRadius * Math.sin(angle)
    camera.lookAt(new THREE.Vector3(0, 0, 0))
  }

  mat.uniforms.time.value = now
  renderer.render(scene, camera)
}

const app = createLoop(canvas, { scale: dpr })
  .on('resize', resize)
  .on('tick', tick)

app.emit('resize')
app.start()
