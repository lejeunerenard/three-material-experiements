varying vec3 vNorm;
varying vec3 vlNorm;
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vViewPosition;

void main() {
  vUv = uv;
  vPos = (modelMatrix * vec4(position, 1.)).xyz;

  // World Space
  vNorm = (modelMatrix * vec4(normal, 1.)).xyz;

  // Local Space
  vlNorm = normalize(normalMatrix * normal);

  vec4 mvPosition = modelViewMatrix * vec4( position, 1.0 );
  vViewPosition = -mvPosition.xyz;

  gl_Position = projectionMatrix * mvPosition;
}
