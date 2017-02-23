uniform float time;

varying vec3 vNorm;
varying vec3 vlNorm;
varying vec3 vPos;
varying vec2 vUv;
varying vec3 vViewPosition;
#define eye -normalize(vViewPosition)

// Declare non-sense function to satisfy declaration requirements in lights_pars
float punctualLightIntensityToIrradianceFactor (const in float lightDistance, const in float cutoffDistance, const in float decayExponent) {
  return 1.;
}

// Import THREE Lighting
#pragma glslify: import(three/src/renderers/shaders/ShaderChunk/common)
#pragma glslify: import(three/src/renderers/shaders/ShaderChunk/lights_pars)
#pragma glslify: cnoise3 = require(glsl-noise/classic/3d)
#pragma glslify: cnoise2 = require(glsl-noise/classic/2d)

vec3 baseColor2 () {
  float v = sin(5. * vPos.x + .001 * time + .8 * sin(vPos.y));
  v = smoothstep(.3, .5, v);
  return vec3(v);
}
vec3 baseColor3 (in vec3 pos) {
  float n = cnoise2(pos.xz);
  float v = sin(7. * pos.z + 4. * n + .9 * sin(pos.y) + .001 * time);
  v = abs(v);
  v = smoothstep(.89, .9, v);
  return vec3(v);
}

float sinRamp (in float t) {
  return .5 * (1. + sin(t));
}

// Inspired by:
// http://www.upvector.com/?section=Tutorials&subsection=Intro%20to%20Procedural%20Textures
vec3 baseColor (in vec3 pos) {
  float n = cnoise3(pos);
  float t = pos.x + sin(pos.y) + .5 * n + .001 * time;
  float v = max(sinRamp(t), sinRamp(t * 10.));

  // ramp & clamp values
  // v = smoothstep(.89, .9, v);

  return vec3(v);
}

void main(){
  vec3 diffuseColor = baseColor(vPos); // baseColor2(); // baseColor3(vPos);
  vec3 color = ambientLightColor * diffuseColor;

  // Diffuse
  for (int i = 0; i < NUM_POINT_LIGHTS; i++) {
    vec3 lightDir = normalize(pointLights[i].position - vPos);
    color += .7 * diffuseColor * pointLights[i].color * clamp(dot(normalize(vlNorm), -lightDir), 0., 1.);
  }

  // Fresnel
  color += pow(clamp(1. + dot(vlNorm, eye), 0., 1.), 4.);

  gl_FragColor = vec4(color, 1.);
}
