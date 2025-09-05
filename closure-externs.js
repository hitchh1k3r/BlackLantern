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

Navigator.prototype.xr;

XRSession.prototype.requestAnimationFrame = function(callback) {};

/**
 * @constructor
 */
function XRRenderState() {}

/** @type {XRWebGLLayer} */
XRRenderState.prototype.baseLayer;

XRSession.prototype.renderState;

XRSession.prototype.updateRenderState = function(init) {};

var XRWebGLLayerInit;

var XRRenderStateInit;

var XRReferenceSpaceType;

/**
 * @constructor
 */
function XRReferenceSpace() {}
