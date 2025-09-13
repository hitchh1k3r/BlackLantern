/**
 * @constructor
 */
function XRWebGLLayer(session, gl) {}

XRWebGLLayer.prototype.framebuffer;

/**
 * @constructor
 */
function XRSystem() {}

XRSystem.prototype.requestSession = function(mode) {};

XRSystem.prototype.isSessionSupported = function(mode) {};

/**
 * @constructor
 */
function XRSession() {}

XRSession.prototype.updateRenderState = function(init) {};

XRSession.prototype.requestReferenceSpace = function(type) {};

/**
 * @constructor
 */
function XRFrame() {}

XRFrame.prototype.getViewerPose = function(referenceSpace) {};

/**
 * @constructor
 */
function XRViewerPose() {}

XRViewerPose.prototype.views;

Navigator.prototype.xr;

XRSession.prototype.requestAnimationFrame = function(callback) {};

/**
 * @constructor
 */
function XRView() {}
XRView.prototype.projectionMatrix;

/**
 * @constructor
 */
function XRRenderState() {}

/** @type {XRWebGLLayer} */
XRRenderState.prototype.baseLayer;

XRRenderState.prototype.getViewport = function(view) {};

XRSession.prototype.renderState;

XRSession.prototype.updateRenderState = function(init) {};

var XRWebGLLayerInit;

var XRRenderStateInit;

var XRReferenceSpaceType;

/**
 * @constructor
 */
function XRReferenceSpace() {}

WebGLRenderingContext.prototype.makeXRCompatible = function() {};

WebGL2RenderingContext.prototype.makeXRCompatible = function() {};