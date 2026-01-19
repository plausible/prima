var __defProp = Object.defineProperty;
var __defProps = Object.defineProperties;
var __getOwnPropDescs = Object.getOwnPropertyDescriptors;
var __getOwnPropSymbols = Object.getOwnPropertySymbols;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __propIsEnum = Object.prototype.propertyIsEnumerable;
var __defNormalProp = (obj, key, value) => key in obj ? __defProp(obj, key, { enumerable: true, configurable: true, writable: true, value }) : obj[key] = value;
var __spreadValues = (a, b) => {
  for (var prop in b || (b = {}))
    if (__hasOwnProp.call(b, prop))
      __defNormalProp(a, prop, b[prop]);
  if (__getOwnPropSymbols)
    for (var prop of __getOwnPropSymbols(b)) {
      if (__propIsEnum.call(b, prop))
        __defNormalProp(a, prop, b[prop]);
    }
  return a;
};
var __spreadProps = (a, b) => __defProps(a, __getOwnPropDescs(b));
var __objRest = (source, exclude) => {
  var target = {};
  for (var prop in source)
    if (__hasOwnProp.call(source, prop) && exclude.indexOf(prop) < 0)
      target[prop] = source[prop];
  if (source != null && __getOwnPropSymbols)
    for (var prop of __getOwnPropSymbols(source)) {
      if (exclude.indexOf(prop) < 0 && __propIsEnum.call(source, prop))
        target[prop] = source[prop];
    }
  return target;
};

// node_modules/@floating-ui/utils/dist/floating-ui.utils.mjs
var min = Math.min;
var max = Math.max;
var round = Math.round;
var floor = Math.floor;
var createCoords = (v) => ({
  x: v,
  y: v
});
var oppositeSideMap = {
  left: "right",
  right: "left",
  bottom: "top",
  top: "bottom"
};
var oppositeAlignmentMap = {
  start: "end",
  end: "start"
};
function evaluate(value, param) {
  return typeof value === "function" ? value(param) : value;
}
function getSide(placement) {
  return placement.split("-")[0];
}
function getAlignment(placement) {
  return placement.split("-")[1];
}
function getOppositeAxis(axis) {
  return axis === "x" ? "y" : "x";
}
function getAxisLength(axis) {
  return axis === "y" ? "height" : "width";
}
var yAxisSides = /* @__PURE__ */ new Set(["top", "bottom"]);
function getSideAxis(placement) {
  return yAxisSides.has(getSide(placement)) ? "y" : "x";
}
function getAlignmentAxis(placement) {
  return getOppositeAxis(getSideAxis(placement));
}
function getAlignmentSides(placement, rects, rtl) {
  if (rtl === void 0) {
    rtl = false;
  }
  const alignment = getAlignment(placement);
  const alignmentAxis = getAlignmentAxis(placement);
  const length = getAxisLength(alignmentAxis);
  let mainAlignmentSide = alignmentAxis === "x" ? alignment === (rtl ? "end" : "start") ? "right" : "left" : alignment === "start" ? "bottom" : "top";
  if (rects.reference[length] > rects.floating[length]) {
    mainAlignmentSide = getOppositePlacement(mainAlignmentSide);
  }
  return [mainAlignmentSide, getOppositePlacement(mainAlignmentSide)];
}
function getExpandedPlacements(placement) {
  const oppositePlacement = getOppositePlacement(placement);
  return [getOppositeAlignmentPlacement(placement), oppositePlacement, getOppositeAlignmentPlacement(oppositePlacement)];
}
function getOppositeAlignmentPlacement(placement) {
  return placement.replace(/start|end/g, (alignment) => oppositeAlignmentMap[alignment]);
}
var lrPlacement = ["left", "right"];
var rlPlacement = ["right", "left"];
var tbPlacement = ["top", "bottom"];
var btPlacement = ["bottom", "top"];
function getSideList(side, isStart, rtl) {
  switch (side) {
    case "top":
    case "bottom":
      if (rtl)
        return isStart ? rlPlacement : lrPlacement;
      return isStart ? lrPlacement : rlPlacement;
    case "left":
    case "right":
      return isStart ? tbPlacement : btPlacement;
    default:
      return [];
  }
}
function getOppositeAxisPlacements(placement, flipAlignment, direction, rtl) {
  const alignment = getAlignment(placement);
  let list = getSideList(getSide(placement), direction === "start", rtl);
  if (alignment) {
    list = list.map((side) => side + "-" + alignment);
    if (flipAlignment) {
      list = list.concat(list.map(getOppositeAlignmentPlacement));
    }
  }
  return list;
}
function getOppositePlacement(placement) {
  return placement.replace(/left|right|bottom|top/g, (side) => oppositeSideMap[side]);
}
function expandPaddingObject(padding) {
  return __spreadValues({
    top: 0,
    right: 0,
    bottom: 0,
    left: 0
  }, padding);
}
function getPaddingObject(padding) {
  return typeof padding !== "number" ? expandPaddingObject(padding) : {
    top: padding,
    right: padding,
    bottom: padding,
    left: padding
  };
}
function rectToClientRect(rect) {
  const {
    x,
    y,
    width,
    height
  } = rect;
  return {
    width,
    height,
    top: y,
    left: x,
    right: x + width,
    bottom: y + height,
    x,
    y
  };
}

// node_modules/@floating-ui/core/dist/floating-ui.core.mjs
function computeCoordsFromPlacement(_ref, placement, rtl) {
  let {
    reference,
    floating
  } = _ref;
  const sideAxis = getSideAxis(placement);
  const alignmentAxis = getAlignmentAxis(placement);
  const alignLength = getAxisLength(alignmentAxis);
  const side = getSide(placement);
  const isVertical = sideAxis === "y";
  const commonX = reference.x + reference.width / 2 - floating.width / 2;
  const commonY = reference.y + reference.height / 2 - floating.height / 2;
  const commonAlign = reference[alignLength] / 2 - floating[alignLength] / 2;
  let coords;
  switch (side) {
    case "top":
      coords = {
        x: commonX,
        y: reference.y - floating.height
      };
      break;
    case "bottom":
      coords = {
        x: commonX,
        y: reference.y + reference.height
      };
      break;
    case "right":
      coords = {
        x: reference.x + reference.width,
        y: commonY
      };
      break;
    case "left":
      coords = {
        x: reference.x - floating.width,
        y: commonY
      };
      break;
    default:
      coords = {
        x: reference.x,
        y: reference.y
      };
  }
  switch (getAlignment(placement)) {
    case "start":
      coords[alignmentAxis] -= commonAlign * (rtl && isVertical ? -1 : 1);
      break;
    case "end":
      coords[alignmentAxis] += commonAlign * (rtl && isVertical ? -1 : 1);
      break;
  }
  return coords;
}
var computePosition = async (reference, floating, config) => {
  const {
    placement = "bottom",
    strategy = "absolute",
    middleware = [],
    platform: platform2
  } = config;
  const validMiddleware = middleware.filter(Boolean);
  const rtl = await (platform2.isRTL == null ? void 0 : platform2.isRTL(floating));
  let rects = await platform2.getElementRects({
    reference,
    floating,
    strategy
  });
  let {
    x,
    y
  } = computeCoordsFromPlacement(rects, placement, rtl);
  let statefulPlacement = placement;
  let middlewareData = {};
  let resetCount = 0;
  for (let i = 0; i < validMiddleware.length; i++) {
    const {
      name,
      fn
    } = validMiddleware[i];
    const {
      x: nextX,
      y: nextY,
      data,
      reset
    } = await fn({
      x,
      y,
      initialPlacement: placement,
      placement: statefulPlacement,
      strategy,
      middlewareData,
      rects,
      platform: platform2,
      elements: {
        reference,
        floating
      }
    });
    x = nextX != null ? nextX : x;
    y = nextY != null ? nextY : y;
    middlewareData = __spreadProps(__spreadValues({}, middlewareData), {
      [name]: __spreadValues(__spreadValues({}, middlewareData[name]), data)
    });
    if (reset && resetCount <= 50) {
      resetCount++;
      if (typeof reset === "object") {
        if (reset.placement) {
          statefulPlacement = reset.placement;
        }
        if (reset.rects) {
          rects = reset.rects === true ? await platform2.getElementRects({
            reference,
            floating,
            strategy
          }) : reset.rects;
        }
        ({
          x,
          y
        } = computeCoordsFromPlacement(rects, statefulPlacement, rtl));
      }
      i = -1;
    }
  }
  return {
    x,
    y,
    placement: statefulPlacement,
    strategy,
    middlewareData
  };
};
async function detectOverflow(state, options) {
  var _await$platform$isEle;
  if (options === void 0) {
    options = {};
  }
  const {
    x,
    y,
    platform: platform2,
    rects,
    elements,
    strategy
  } = state;
  const {
    boundary = "clippingAncestors",
    rootBoundary = "viewport",
    elementContext = "floating",
    altBoundary = false,
    padding = 0
  } = evaluate(options, state);
  const paddingObject = getPaddingObject(padding);
  const altContext = elementContext === "floating" ? "reference" : "floating";
  const element = elements[altBoundary ? altContext : elementContext];
  const clippingClientRect = rectToClientRect(await platform2.getClippingRect({
    element: ((_await$platform$isEle = await (platform2.isElement == null ? void 0 : platform2.isElement(element))) != null ? _await$platform$isEle : true) ? element : element.contextElement || await (platform2.getDocumentElement == null ? void 0 : platform2.getDocumentElement(elements.floating)),
    boundary,
    rootBoundary,
    strategy
  }));
  const rect = elementContext === "floating" ? {
    x,
    y,
    width: rects.floating.width,
    height: rects.floating.height
  } : rects.reference;
  const offsetParent = await (platform2.getOffsetParent == null ? void 0 : platform2.getOffsetParent(elements.floating));
  const offsetScale = await (platform2.isElement == null ? void 0 : platform2.isElement(offsetParent)) ? await (platform2.getScale == null ? void 0 : platform2.getScale(offsetParent)) || {
    x: 1,
    y: 1
  } : {
    x: 1,
    y: 1
  };
  const elementClientRect = rectToClientRect(platform2.convertOffsetParentRelativeRectToViewportRelativeRect ? await platform2.convertOffsetParentRelativeRectToViewportRelativeRect({
    elements,
    rect,
    offsetParent,
    strategy
  }) : rect);
  return {
    top: (clippingClientRect.top - elementClientRect.top + paddingObject.top) / offsetScale.y,
    bottom: (elementClientRect.bottom - clippingClientRect.bottom + paddingObject.bottom) / offsetScale.y,
    left: (clippingClientRect.left - elementClientRect.left + paddingObject.left) / offsetScale.x,
    right: (elementClientRect.right - clippingClientRect.right + paddingObject.right) / offsetScale.x
  };
}
var flip = function(options) {
  if (options === void 0) {
    options = {};
  }
  return {
    name: "flip",
    options,
    async fn(state) {
      var _middlewareData$arrow, _middlewareData$flip;
      const {
        placement,
        middlewareData,
        rects,
        initialPlacement,
        platform: platform2,
        elements
      } = state;
      const _a = evaluate(options, state), {
        mainAxis: checkMainAxis = true,
        crossAxis: checkCrossAxis = true,
        fallbackPlacements: specifiedFallbackPlacements,
        fallbackStrategy = "bestFit",
        fallbackAxisSideDirection = "none",
        flipAlignment = true
      } = _a, detectOverflowOptions = __objRest(_a, [
        "mainAxis",
        "crossAxis",
        "fallbackPlacements",
        "fallbackStrategy",
        "fallbackAxisSideDirection",
        "flipAlignment"
      ]);
      if ((_middlewareData$arrow = middlewareData.arrow) != null && _middlewareData$arrow.alignmentOffset) {
        return {};
      }
      const side = getSide(placement);
      const initialSideAxis = getSideAxis(initialPlacement);
      const isBasePlacement = getSide(initialPlacement) === initialPlacement;
      const rtl = await (platform2.isRTL == null ? void 0 : platform2.isRTL(elements.floating));
      const fallbackPlacements = specifiedFallbackPlacements || (isBasePlacement || !flipAlignment ? [getOppositePlacement(initialPlacement)] : getExpandedPlacements(initialPlacement));
      const hasFallbackAxisSideDirection = fallbackAxisSideDirection !== "none";
      if (!specifiedFallbackPlacements && hasFallbackAxisSideDirection) {
        fallbackPlacements.push(...getOppositeAxisPlacements(initialPlacement, flipAlignment, fallbackAxisSideDirection, rtl));
      }
      const placements2 = [initialPlacement, ...fallbackPlacements];
      const overflow = await detectOverflow(state, detectOverflowOptions);
      const overflows = [];
      let overflowsData = ((_middlewareData$flip = middlewareData.flip) == null ? void 0 : _middlewareData$flip.overflows) || [];
      if (checkMainAxis) {
        overflows.push(overflow[side]);
      }
      if (checkCrossAxis) {
        const sides2 = getAlignmentSides(placement, rects, rtl);
        overflows.push(overflow[sides2[0]], overflow[sides2[1]]);
      }
      overflowsData = [...overflowsData, {
        placement,
        overflows
      }];
      if (!overflows.every((side2) => side2 <= 0)) {
        var _middlewareData$flip2, _overflowsData$filter;
        const nextIndex = (((_middlewareData$flip2 = middlewareData.flip) == null ? void 0 : _middlewareData$flip2.index) || 0) + 1;
        const nextPlacement = placements2[nextIndex];
        if (nextPlacement) {
          const ignoreCrossAxisOverflow = checkCrossAxis === "alignment" ? initialSideAxis !== getSideAxis(nextPlacement) : false;
          if (!ignoreCrossAxisOverflow || // We leave the current main axis only if every placement on that axis
          // overflows the main axis.
          overflowsData.every((d) => getSideAxis(d.placement) === initialSideAxis ? d.overflows[0] > 0 : true)) {
            return {
              data: {
                index: nextIndex,
                overflows: overflowsData
              },
              reset: {
                placement: nextPlacement
              }
            };
          }
        }
        let resetPlacement = (_overflowsData$filter = overflowsData.filter((d) => d.overflows[0] <= 0).sort((a, b) => a.overflows[1] - b.overflows[1])[0]) == null ? void 0 : _overflowsData$filter.placement;
        if (!resetPlacement) {
          switch (fallbackStrategy) {
            case "bestFit": {
              var _overflowsData$filter2;
              const placement2 = (_overflowsData$filter2 = overflowsData.filter((d) => {
                if (hasFallbackAxisSideDirection) {
                  const currentSideAxis = getSideAxis(d.placement);
                  return currentSideAxis === initialSideAxis || // Create a bias to the `y` side axis due to horizontal
                  // reading directions favoring greater width.
                  currentSideAxis === "y";
                }
                return true;
              }).map((d) => [d.placement, d.overflows.filter((overflow2) => overflow2 > 0).reduce((acc, overflow2) => acc + overflow2, 0)]).sort((a, b) => a[1] - b[1])[0]) == null ? void 0 : _overflowsData$filter2[0];
              if (placement2) {
                resetPlacement = placement2;
              }
              break;
            }
            case "initialPlacement":
              resetPlacement = initialPlacement;
              break;
          }
        }
        if (placement !== resetPlacement) {
          return {
            reset: {
              placement: resetPlacement
            }
          };
        }
      }
      return {};
    }
  };
};
var originSides = /* @__PURE__ */ new Set(["left", "top"]);
async function convertValueToCoords(state, options) {
  const {
    placement,
    platform: platform2,
    elements
  } = state;
  const rtl = await (platform2.isRTL == null ? void 0 : platform2.isRTL(elements.floating));
  const side = getSide(placement);
  const alignment = getAlignment(placement);
  const isVertical = getSideAxis(placement) === "y";
  const mainAxisMulti = originSides.has(side) ? -1 : 1;
  const crossAxisMulti = rtl && isVertical ? -1 : 1;
  const rawValue = evaluate(options, state);
  let {
    mainAxis,
    crossAxis,
    alignmentAxis
  } = typeof rawValue === "number" ? {
    mainAxis: rawValue,
    crossAxis: 0,
    alignmentAxis: null
  } : {
    mainAxis: rawValue.mainAxis || 0,
    crossAxis: rawValue.crossAxis || 0,
    alignmentAxis: rawValue.alignmentAxis
  };
  if (alignment && typeof alignmentAxis === "number") {
    crossAxis = alignment === "end" ? alignmentAxis * -1 : alignmentAxis;
  }
  return isVertical ? {
    x: crossAxis * crossAxisMulti,
    y: mainAxis * mainAxisMulti
  } : {
    x: mainAxis * mainAxisMulti,
    y: crossAxis * crossAxisMulti
  };
}
var offset = function(options) {
  if (options === void 0) {
    options = 0;
  }
  return {
    name: "offset",
    options,
    async fn(state) {
      var _middlewareData$offse, _middlewareData$arrow;
      const {
        x,
        y,
        placement,
        middlewareData
      } = state;
      const diffCoords = await convertValueToCoords(state, options);
      if (placement === ((_middlewareData$offse = middlewareData.offset) == null ? void 0 : _middlewareData$offse.placement) && (_middlewareData$arrow = middlewareData.arrow) != null && _middlewareData$arrow.alignmentOffset) {
        return {};
      }
      return {
        x: x + diffCoords.x,
        y: y + diffCoords.y,
        data: __spreadProps(__spreadValues({}, diffCoords), {
          placement
        })
      };
    }
  };
};

// node_modules/@floating-ui/utils/dist/floating-ui.utils.dom.mjs
function hasWindow() {
  return typeof window !== "undefined";
}
function getNodeName(node) {
  if (isNode(node)) {
    return (node.nodeName || "").toLowerCase();
  }
  return "#document";
}
function getWindow(node) {
  var _node$ownerDocument;
  return (node == null || (_node$ownerDocument = node.ownerDocument) == null ? void 0 : _node$ownerDocument.defaultView) || window;
}
function getDocumentElement(node) {
  var _ref;
  return (_ref = (isNode(node) ? node.ownerDocument : node.document) || window.document) == null ? void 0 : _ref.documentElement;
}
function isNode(value) {
  if (!hasWindow()) {
    return false;
  }
  return value instanceof Node || value instanceof getWindow(value).Node;
}
function isElement(value) {
  if (!hasWindow()) {
    return false;
  }
  return value instanceof Element || value instanceof getWindow(value).Element;
}
function isHTMLElement(value) {
  if (!hasWindow()) {
    return false;
  }
  return value instanceof HTMLElement || value instanceof getWindow(value).HTMLElement;
}
function isShadowRoot(value) {
  if (!hasWindow() || typeof ShadowRoot === "undefined") {
    return false;
  }
  return value instanceof ShadowRoot || value instanceof getWindow(value).ShadowRoot;
}
var invalidOverflowDisplayValues = /* @__PURE__ */ new Set(["inline", "contents"]);
function isOverflowElement(element) {
  const {
    overflow,
    overflowX,
    overflowY,
    display
  } = getComputedStyle2(element);
  return /auto|scroll|overlay|hidden|clip/.test(overflow + overflowY + overflowX) && !invalidOverflowDisplayValues.has(display);
}
var tableElements = /* @__PURE__ */ new Set(["table", "td", "th"]);
function isTableElement(element) {
  return tableElements.has(getNodeName(element));
}
var topLayerSelectors = [":popover-open", ":modal"];
function isTopLayer(element) {
  return topLayerSelectors.some((selector) => {
    try {
      return element.matches(selector);
    } catch (_e) {
      return false;
    }
  });
}
var transformProperties = ["transform", "translate", "scale", "rotate", "perspective"];
var willChangeValues = ["transform", "translate", "scale", "rotate", "perspective", "filter"];
var containValues = ["paint", "layout", "strict", "content"];
function isContainingBlock(elementOrCss) {
  const webkit = isWebKit();
  const css = isElement(elementOrCss) ? getComputedStyle2(elementOrCss) : elementOrCss;
  return transformProperties.some((value) => css[value] ? css[value] !== "none" : false) || (css.containerType ? css.containerType !== "normal" : false) || !webkit && (css.backdropFilter ? css.backdropFilter !== "none" : false) || !webkit && (css.filter ? css.filter !== "none" : false) || willChangeValues.some((value) => (css.willChange || "").includes(value)) || containValues.some((value) => (css.contain || "").includes(value));
}
function getContainingBlock(element) {
  let currentNode = getParentNode(element);
  while (isHTMLElement(currentNode) && !isLastTraversableNode(currentNode)) {
    if (isContainingBlock(currentNode)) {
      return currentNode;
    } else if (isTopLayer(currentNode)) {
      return null;
    }
    currentNode = getParentNode(currentNode);
  }
  return null;
}
function isWebKit() {
  if (typeof CSS === "undefined" || !CSS.supports)
    return false;
  return CSS.supports("-webkit-backdrop-filter", "none");
}
var lastTraversableNodeNames = /* @__PURE__ */ new Set(["html", "body", "#document"]);
function isLastTraversableNode(node) {
  return lastTraversableNodeNames.has(getNodeName(node));
}
function getComputedStyle2(element) {
  return getWindow(element).getComputedStyle(element);
}
function getNodeScroll(element) {
  if (isElement(element)) {
    return {
      scrollLeft: element.scrollLeft,
      scrollTop: element.scrollTop
    };
  }
  return {
    scrollLeft: element.scrollX,
    scrollTop: element.scrollY
  };
}
function getParentNode(node) {
  if (getNodeName(node) === "html") {
    return node;
  }
  const result = (
    // Step into the shadow DOM of the parent of a slotted node.
    node.assignedSlot || // DOM Element detected.
    node.parentNode || // ShadowRoot detected.
    isShadowRoot(node) && node.host || // Fallback.
    getDocumentElement(node)
  );
  return isShadowRoot(result) ? result.host : result;
}
function getNearestOverflowAncestor(node) {
  const parentNode = getParentNode(node);
  if (isLastTraversableNode(parentNode)) {
    return node.ownerDocument ? node.ownerDocument.body : node.body;
  }
  if (isHTMLElement(parentNode) && isOverflowElement(parentNode)) {
    return parentNode;
  }
  return getNearestOverflowAncestor(parentNode);
}
function getOverflowAncestors(node, list, traverseIframes) {
  var _node$ownerDocument2;
  if (list === void 0) {
    list = [];
  }
  if (traverseIframes === void 0) {
    traverseIframes = true;
  }
  const scrollableAncestor = getNearestOverflowAncestor(node);
  const isBody = scrollableAncestor === ((_node$ownerDocument2 = node.ownerDocument) == null ? void 0 : _node$ownerDocument2.body);
  const win = getWindow(scrollableAncestor);
  if (isBody) {
    const frameElement = getFrameElement(win);
    return list.concat(win, win.visualViewport || [], isOverflowElement(scrollableAncestor) ? scrollableAncestor : [], frameElement && traverseIframes ? getOverflowAncestors(frameElement) : []);
  }
  return list.concat(scrollableAncestor, getOverflowAncestors(scrollableAncestor, [], traverseIframes));
}
function getFrameElement(win) {
  return win.parent && Object.getPrototypeOf(win.parent) ? win.frameElement : null;
}

// node_modules/@floating-ui/dom/dist/floating-ui.dom.mjs
function getCssDimensions(element) {
  const css = getComputedStyle2(element);
  let width = parseFloat(css.width) || 0;
  let height = parseFloat(css.height) || 0;
  const hasOffset = isHTMLElement(element);
  const offsetWidth = hasOffset ? element.offsetWidth : width;
  const offsetHeight = hasOffset ? element.offsetHeight : height;
  const shouldFallback = round(width) !== offsetWidth || round(height) !== offsetHeight;
  if (shouldFallback) {
    width = offsetWidth;
    height = offsetHeight;
  }
  return {
    width,
    height,
    $: shouldFallback
  };
}
function unwrapElement(element) {
  return !isElement(element) ? element.contextElement : element;
}
function getScale(element) {
  const domElement = unwrapElement(element);
  if (!isHTMLElement(domElement)) {
    return createCoords(1);
  }
  const rect = domElement.getBoundingClientRect();
  const {
    width,
    height,
    $
  } = getCssDimensions(domElement);
  let x = ($ ? round(rect.width) : rect.width) / width;
  let y = ($ ? round(rect.height) : rect.height) / height;
  if (!x || !Number.isFinite(x)) {
    x = 1;
  }
  if (!y || !Number.isFinite(y)) {
    y = 1;
  }
  return {
    x,
    y
  };
}
var noOffsets = /* @__PURE__ */ createCoords(0);
function getVisualOffsets(element) {
  const win = getWindow(element);
  if (!isWebKit() || !win.visualViewport) {
    return noOffsets;
  }
  return {
    x: win.visualViewport.offsetLeft,
    y: win.visualViewport.offsetTop
  };
}
function shouldAddVisualOffsets(element, isFixed, floatingOffsetParent) {
  if (isFixed === void 0) {
    isFixed = false;
  }
  if (!floatingOffsetParent || isFixed && floatingOffsetParent !== getWindow(element)) {
    return false;
  }
  return isFixed;
}
function getBoundingClientRect(element, includeScale, isFixedStrategy, offsetParent) {
  if (includeScale === void 0) {
    includeScale = false;
  }
  if (isFixedStrategy === void 0) {
    isFixedStrategy = false;
  }
  const clientRect = element.getBoundingClientRect();
  const domElement = unwrapElement(element);
  let scale = createCoords(1);
  if (includeScale) {
    if (offsetParent) {
      if (isElement(offsetParent)) {
        scale = getScale(offsetParent);
      }
    } else {
      scale = getScale(element);
    }
  }
  const visualOffsets = shouldAddVisualOffsets(domElement, isFixedStrategy, offsetParent) ? getVisualOffsets(domElement) : createCoords(0);
  let x = (clientRect.left + visualOffsets.x) / scale.x;
  let y = (clientRect.top + visualOffsets.y) / scale.y;
  let width = clientRect.width / scale.x;
  let height = clientRect.height / scale.y;
  if (domElement) {
    const win = getWindow(domElement);
    const offsetWin = offsetParent && isElement(offsetParent) ? getWindow(offsetParent) : offsetParent;
    let currentWin = win;
    let currentIFrame = getFrameElement(currentWin);
    while (currentIFrame && offsetParent && offsetWin !== currentWin) {
      const iframeScale = getScale(currentIFrame);
      const iframeRect = currentIFrame.getBoundingClientRect();
      const css = getComputedStyle2(currentIFrame);
      const left = iframeRect.left + (currentIFrame.clientLeft + parseFloat(css.paddingLeft)) * iframeScale.x;
      const top = iframeRect.top + (currentIFrame.clientTop + parseFloat(css.paddingTop)) * iframeScale.y;
      x *= iframeScale.x;
      y *= iframeScale.y;
      width *= iframeScale.x;
      height *= iframeScale.y;
      x += left;
      y += top;
      currentWin = getWindow(currentIFrame);
      currentIFrame = getFrameElement(currentWin);
    }
  }
  return rectToClientRect({
    width,
    height,
    x,
    y
  });
}
function getWindowScrollBarX(element, rect) {
  const leftScroll = getNodeScroll(element).scrollLeft;
  if (!rect) {
    return getBoundingClientRect(getDocumentElement(element)).left + leftScroll;
  }
  return rect.left + leftScroll;
}
function getHTMLOffset(documentElement, scroll) {
  const htmlRect = documentElement.getBoundingClientRect();
  const x = htmlRect.left + scroll.scrollLeft - getWindowScrollBarX(documentElement, htmlRect);
  const y = htmlRect.top + scroll.scrollTop;
  return {
    x,
    y
  };
}
function convertOffsetParentRelativeRectToViewportRelativeRect(_ref) {
  let {
    elements,
    rect,
    offsetParent,
    strategy
  } = _ref;
  const isFixed = strategy === "fixed";
  const documentElement = getDocumentElement(offsetParent);
  const topLayer = elements ? isTopLayer(elements.floating) : false;
  if (offsetParent === documentElement || topLayer && isFixed) {
    return rect;
  }
  let scroll = {
    scrollLeft: 0,
    scrollTop: 0
  };
  let scale = createCoords(1);
  const offsets = createCoords(0);
  const isOffsetParentAnElement = isHTMLElement(offsetParent);
  if (isOffsetParentAnElement || !isOffsetParentAnElement && !isFixed) {
    if (getNodeName(offsetParent) !== "body" || isOverflowElement(documentElement)) {
      scroll = getNodeScroll(offsetParent);
    }
    if (isHTMLElement(offsetParent)) {
      const offsetRect = getBoundingClientRect(offsetParent);
      scale = getScale(offsetParent);
      offsets.x = offsetRect.x + offsetParent.clientLeft;
      offsets.y = offsetRect.y + offsetParent.clientTop;
    }
  }
  const htmlOffset = documentElement && !isOffsetParentAnElement && !isFixed ? getHTMLOffset(documentElement, scroll) : createCoords(0);
  return {
    width: rect.width * scale.x,
    height: rect.height * scale.y,
    x: rect.x * scale.x - scroll.scrollLeft * scale.x + offsets.x + htmlOffset.x,
    y: rect.y * scale.y - scroll.scrollTop * scale.y + offsets.y + htmlOffset.y
  };
}
function getClientRects(element) {
  return Array.from(element.getClientRects());
}
function getDocumentRect(element) {
  const html = getDocumentElement(element);
  const scroll = getNodeScroll(element);
  const body = element.ownerDocument.body;
  const width = max(html.scrollWidth, html.clientWidth, body.scrollWidth, body.clientWidth);
  const height = max(html.scrollHeight, html.clientHeight, body.scrollHeight, body.clientHeight);
  let x = -scroll.scrollLeft + getWindowScrollBarX(element);
  const y = -scroll.scrollTop;
  if (getComputedStyle2(body).direction === "rtl") {
    x += max(html.clientWidth, body.clientWidth) - width;
  }
  return {
    width,
    height,
    x,
    y
  };
}
var SCROLLBAR_MAX = 25;
function getViewportRect(element, strategy) {
  const win = getWindow(element);
  const html = getDocumentElement(element);
  const visualViewport = win.visualViewport;
  let width = html.clientWidth;
  let height = html.clientHeight;
  let x = 0;
  let y = 0;
  if (visualViewport) {
    width = visualViewport.width;
    height = visualViewport.height;
    const visualViewportBased = isWebKit();
    if (!visualViewportBased || visualViewportBased && strategy === "fixed") {
      x = visualViewport.offsetLeft;
      y = visualViewport.offsetTop;
    }
  }
  const windowScrollbarX = getWindowScrollBarX(html);
  if (windowScrollbarX <= 0) {
    const doc = html.ownerDocument;
    const body = doc.body;
    const bodyStyles = getComputedStyle(body);
    const bodyMarginInline = doc.compatMode === "CSS1Compat" ? parseFloat(bodyStyles.marginLeft) + parseFloat(bodyStyles.marginRight) || 0 : 0;
    const clippingStableScrollbarWidth = Math.abs(html.clientWidth - body.clientWidth - bodyMarginInline);
    if (clippingStableScrollbarWidth <= SCROLLBAR_MAX) {
      width -= clippingStableScrollbarWidth;
    }
  } else if (windowScrollbarX <= SCROLLBAR_MAX) {
    width += windowScrollbarX;
  }
  return {
    width,
    height,
    x,
    y
  };
}
var absoluteOrFixed = /* @__PURE__ */ new Set(["absolute", "fixed"]);
function getInnerBoundingClientRect(element, strategy) {
  const clientRect = getBoundingClientRect(element, true, strategy === "fixed");
  const top = clientRect.top + element.clientTop;
  const left = clientRect.left + element.clientLeft;
  const scale = isHTMLElement(element) ? getScale(element) : createCoords(1);
  const width = element.clientWidth * scale.x;
  const height = element.clientHeight * scale.y;
  const x = left * scale.x;
  const y = top * scale.y;
  return {
    width,
    height,
    x,
    y
  };
}
function getClientRectFromClippingAncestor(element, clippingAncestor, strategy) {
  let rect;
  if (clippingAncestor === "viewport") {
    rect = getViewportRect(element, strategy);
  } else if (clippingAncestor === "document") {
    rect = getDocumentRect(getDocumentElement(element));
  } else if (isElement(clippingAncestor)) {
    rect = getInnerBoundingClientRect(clippingAncestor, strategy);
  } else {
    const visualOffsets = getVisualOffsets(element);
    rect = {
      x: clippingAncestor.x - visualOffsets.x,
      y: clippingAncestor.y - visualOffsets.y,
      width: clippingAncestor.width,
      height: clippingAncestor.height
    };
  }
  return rectToClientRect(rect);
}
function hasFixedPositionAncestor(element, stopNode) {
  const parentNode = getParentNode(element);
  if (parentNode === stopNode || !isElement(parentNode) || isLastTraversableNode(parentNode)) {
    return false;
  }
  return getComputedStyle2(parentNode).position === "fixed" || hasFixedPositionAncestor(parentNode, stopNode);
}
function getClippingElementAncestors(element, cache) {
  const cachedResult = cache.get(element);
  if (cachedResult) {
    return cachedResult;
  }
  let result = getOverflowAncestors(element, [], false).filter((el) => isElement(el) && getNodeName(el) !== "body");
  let currentContainingBlockComputedStyle = null;
  const elementIsFixed = getComputedStyle2(element).position === "fixed";
  let currentNode = elementIsFixed ? getParentNode(element) : element;
  while (isElement(currentNode) && !isLastTraversableNode(currentNode)) {
    const computedStyle = getComputedStyle2(currentNode);
    const currentNodeIsContaining = isContainingBlock(currentNode);
    if (!currentNodeIsContaining && computedStyle.position === "fixed") {
      currentContainingBlockComputedStyle = null;
    }
    const shouldDropCurrentNode = elementIsFixed ? !currentNodeIsContaining && !currentContainingBlockComputedStyle : !currentNodeIsContaining && computedStyle.position === "static" && !!currentContainingBlockComputedStyle && absoluteOrFixed.has(currentContainingBlockComputedStyle.position) || isOverflowElement(currentNode) && !currentNodeIsContaining && hasFixedPositionAncestor(element, currentNode);
    if (shouldDropCurrentNode) {
      result = result.filter((ancestor) => ancestor !== currentNode);
    } else {
      currentContainingBlockComputedStyle = computedStyle;
    }
    currentNode = getParentNode(currentNode);
  }
  cache.set(element, result);
  return result;
}
function getClippingRect(_ref) {
  let {
    element,
    boundary,
    rootBoundary,
    strategy
  } = _ref;
  const elementClippingAncestors = boundary === "clippingAncestors" ? isTopLayer(element) ? [] : getClippingElementAncestors(element, this._c) : [].concat(boundary);
  const clippingAncestors = [...elementClippingAncestors, rootBoundary];
  const firstClippingAncestor = clippingAncestors[0];
  const clippingRect = clippingAncestors.reduce((accRect, clippingAncestor) => {
    const rect = getClientRectFromClippingAncestor(element, clippingAncestor, strategy);
    accRect.top = max(rect.top, accRect.top);
    accRect.right = min(rect.right, accRect.right);
    accRect.bottom = min(rect.bottom, accRect.bottom);
    accRect.left = max(rect.left, accRect.left);
    return accRect;
  }, getClientRectFromClippingAncestor(element, firstClippingAncestor, strategy));
  return {
    width: clippingRect.right - clippingRect.left,
    height: clippingRect.bottom - clippingRect.top,
    x: clippingRect.left,
    y: clippingRect.top
  };
}
function getDimensions(element) {
  const {
    width,
    height
  } = getCssDimensions(element);
  return {
    width,
    height
  };
}
function getRectRelativeToOffsetParent(element, offsetParent, strategy) {
  const isOffsetParentAnElement = isHTMLElement(offsetParent);
  const documentElement = getDocumentElement(offsetParent);
  const isFixed = strategy === "fixed";
  const rect = getBoundingClientRect(element, true, isFixed, offsetParent);
  let scroll = {
    scrollLeft: 0,
    scrollTop: 0
  };
  const offsets = createCoords(0);
  function setLeftRTLScrollbarOffset() {
    offsets.x = getWindowScrollBarX(documentElement);
  }
  if (isOffsetParentAnElement || !isOffsetParentAnElement && !isFixed) {
    if (getNodeName(offsetParent) !== "body" || isOverflowElement(documentElement)) {
      scroll = getNodeScroll(offsetParent);
    }
    if (isOffsetParentAnElement) {
      const offsetRect = getBoundingClientRect(offsetParent, true, isFixed, offsetParent);
      offsets.x = offsetRect.x + offsetParent.clientLeft;
      offsets.y = offsetRect.y + offsetParent.clientTop;
    } else if (documentElement) {
      setLeftRTLScrollbarOffset();
    }
  }
  if (isFixed && !isOffsetParentAnElement && documentElement) {
    setLeftRTLScrollbarOffset();
  }
  const htmlOffset = documentElement && !isOffsetParentAnElement && !isFixed ? getHTMLOffset(documentElement, scroll) : createCoords(0);
  const x = rect.left + scroll.scrollLeft - offsets.x - htmlOffset.x;
  const y = rect.top + scroll.scrollTop - offsets.y - htmlOffset.y;
  return {
    x,
    y,
    width: rect.width,
    height: rect.height
  };
}
function isStaticPositioned(element) {
  return getComputedStyle2(element).position === "static";
}
function getTrueOffsetParent(element, polyfill) {
  if (!isHTMLElement(element) || getComputedStyle2(element).position === "fixed") {
    return null;
  }
  if (polyfill) {
    return polyfill(element);
  }
  let rawOffsetParent = element.offsetParent;
  if (getDocumentElement(element) === rawOffsetParent) {
    rawOffsetParent = rawOffsetParent.ownerDocument.body;
  }
  return rawOffsetParent;
}
function getOffsetParent(element, polyfill) {
  const win = getWindow(element);
  if (isTopLayer(element)) {
    return win;
  }
  if (!isHTMLElement(element)) {
    let svgOffsetParent = getParentNode(element);
    while (svgOffsetParent && !isLastTraversableNode(svgOffsetParent)) {
      if (isElement(svgOffsetParent) && !isStaticPositioned(svgOffsetParent)) {
        return svgOffsetParent;
      }
      svgOffsetParent = getParentNode(svgOffsetParent);
    }
    return win;
  }
  let offsetParent = getTrueOffsetParent(element, polyfill);
  while (offsetParent && isTableElement(offsetParent) && isStaticPositioned(offsetParent)) {
    offsetParent = getTrueOffsetParent(offsetParent, polyfill);
  }
  if (offsetParent && isLastTraversableNode(offsetParent) && isStaticPositioned(offsetParent) && !isContainingBlock(offsetParent)) {
    return win;
  }
  return offsetParent || getContainingBlock(element) || win;
}
var getElementRects = async function(data) {
  const getOffsetParentFn = this.getOffsetParent || getOffsetParent;
  const getDimensionsFn = this.getDimensions;
  const floatingDimensions = await getDimensionsFn(data.floating);
  return {
    reference: getRectRelativeToOffsetParent(data.reference, await getOffsetParentFn(data.floating), data.strategy),
    floating: {
      x: 0,
      y: 0,
      width: floatingDimensions.width,
      height: floatingDimensions.height
    }
  };
};
function isRTL(element) {
  return getComputedStyle2(element).direction === "rtl";
}
var platform = {
  convertOffsetParentRelativeRectToViewportRelativeRect,
  getDocumentElement,
  getClippingRect,
  getOffsetParent,
  getElementRects,
  getClientRects,
  getDimensions,
  getScale,
  isElement,
  isRTL
};
function rectsAreEqual(a, b) {
  return a.x === b.x && a.y === b.y && a.width === b.width && a.height === b.height;
}
function observeMove(element, onMove) {
  let io = null;
  let timeoutId;
  const root = getDocumentElement(element);
  function cleanup() {
    var _io;
    clearTimeout(timeoutId);
    (_io = io) == null || _io.disconnect();
    io = null;
  }
  function refresh(skip, threshold) {
    if (skip === void 0) {
      skip = false;
    }
    if (threshold === void 0) {
      threshold = 1;
    }
    cleanup();
    const elementRectForRootMargin = element.getBoundingClientRect();
    const {
      left,
      top,
      width,
      height
    } = elementRectForRootMargin;
    if (!skip) {
      onMove();
    }
    if (!width || !height) {
      return;
    }
    const insetTop = floor(top);
    const insetRight = floor(root.clientWidth - (left + width));
    const insetBottom = floor(root.clientHeight - (top + height));
    const insetLeft = floor(left);
    const rootMargin = -insetTop + "px " + -insetRight + "px " + -insetBottom + "px " + -insetLeft + "px";
    const options = {
      rootMargin,
      threshold: max(0, min(1, threshold)) || 1
    };
    let isFirstUpdate = true;
    function handleObserve(entries) {
      const ratio = entries[0].intersectionRatio;
      if (ratio !== threshold) {
        if (!isFirstUpdate) {
          return refresh();
        }
        if (!ratio) {
          timeoutId = setTimeout(() => {
            refresh(false, 1e-7);
          }, 1e3);
        } else {
          refresh(false, ratio);
        }
      }
      if (ratio === 1 && !rectsAreEqual(elementRectForRootMargin, element.getBoundingClientRect())) {
        refresh();
      }
      isFirstUpdate = false;
    }
    try {
      io = new IntersectionObserver(handleObserve, __spreadProps(__spreadValues({}, options), {
        // Handle <iframe>s
        root: root.ownerDocument
      }));
    } catch (_e) {
      io = new IntersectionObserver(handleObserve, options);
    }
    io.observe(element);
  }
  refresh(true);
  return cleanup;
}
function autoUpdate(reference, floating, update, options) {
  if (options === void 0) {
    options = {};
  }
  const {
    ancestorScroll = true,
    ancestorResize = true,
    elementResize = typeof ResizeObserver === "function",
    layoutShift = typeof IntersectionObserver === "function",
    animationFrame = false
  } = options;
  const referenceEl = unwrapElement(reference);
  const ancestors = ancestorScroll || ancestorResize ? [...referenceEl ? getOverflowAncestors(referenceEl) : [], ...getOverflowAncestors(floating)] : [];
  ancestors.forEach((ancestor) => {
    ancestorScroll && ancestor.addEventListener("scroll", update, {
      passive: true
    });
    ancestorResize && ancestor.addEventListener("resize", update);
  });
  const cleanupIo = referenceEl && layoutShift ? observeMove(referenceEl, update) : null;
  let reobserveFrame = -1;
  let resizeObserver = null;
  if (elementResize) {
    resizeObserver = new ResizeObserver((_ref) => {
      let [firstEntry] = _ref;
      if (firstEntry && firstEntry.target === referenceEl && resizeObserver) {
        resizeObserver.unobserve(floating);
        cancelAnimationFrame(reobserveFrame);
        reobserveFrame = requestAnimationFrame(() => {
          var _resizeObserver;
          (_resizeObserver = resizeObserver) == null || _resizeObserver.observe(floating);
        });
      }
      update();
    });
    if (referenceEl && !animationFrame) {
      resizeObserver.observe(referenceEl);
    }
    resizeObserver.observe(floating);
  }
  let frameId;
  let prevRefRect = animationFrame ? getBoundingClientRect(reference) : null;
  if (animationFrame) {
    frameLoop();
  }
  function frameLoop() {
    const nextRefRect = getBoundingClientRect(reference);
    if (prevRefRect && !rectsAreEqual(prevRefRect, nextRefRect)) {
      update();
    }
    prevRefRect = nextRefRect;
    frameId = requestAnimationFrame(frameLoop);
  }
  update();
  return () => {
    var _resizeObserver2;
    ancestors.forEach((ancestor) => {
      ancestorScroll && ancestor.removeEventListener("scroll", update);
      ancestorResize && ancestor.removeEventListener("resize", update);
    });
    cleanupIo == null || cleanupIo();
    (_resizeObserver2 = resizeObserver) == null || _resizeObserver2.disconnect();
    resizeObserver = null;
    if (animationFrame) {
      cancelAnimationFrame(frameId);
    }
  };
}
var offset2 = offset;
var flip2 = flip;
var computePosition2 = (reference, floating, options) => {
  const cache = /* @__PURE__ */ new Map();
  const mergedOptions = __spreadValues({
    platform
  }, options);
  const platformWithCache = __spreadProps(__spreadValues({}, mergedOptions.platform), {
    _c: cache
  });
  return computePosition(reference, floating, __spreadProps(__spreadValues({}, mergedOptions), {
    platform: platformWithCache
  }));
};

// js/hooks/dropdown.js
var KEYS = {
  ARROW_UP: "ArrowUp",
  ARROW_DOWN: "ArrowDown",
  ESCAPE: "Escape",
  ENTER: "Enter",
  SPACE: " ",
  HOME: "Home",
  END: "End",
  PAGE_UP: "PageUp",
  PAGE_DOWN: "PageDown"
};
var SELECTORS = {
  BUTTON: '[aria-haspopup="menu"]',
  MENU_WRAPPER: '[data-prima-ref="menu-wrapper"]',
  MENU: '[role="menu"]',
  MENUITEM: '[role="menuitem"]',
  ENABLED_MENUITEM: '[role="menuitem"]:not([aria-disabled="true"])',
  FOCUSED_MENUITEM: '[role="menuitem"][data-focus]'
};
var dropdown_default = {
  mounted() {
    this.initialize();
  },
  updated() {
    this.initialize();
  },
  reconnected() {
    this.initialize();
  },
  destroyed() {
    this.cleanup();
  },
  initialize() {
    this.cleanup();
    this.setupElements();
    this.setupEventListeners();
    this.el.setAttribute("data-prima-ready", "true");
  },
  setupElements() {
    const button = this.el.querySelector(SELECTORS.BUTTON);
    const menuWrapper = this.el.querySelector(SELECTORS.MENU_WRAPPER);
    const menu = this.el.querySelector(SELECTORS.MENU);
    const items = this.el.querySelectorAll(SELECTORS.MENUITEM);
    const referenceSelector = menuWrapper == null ? void 0 : menuWrapper.getAttribute("data-reference");
    const referenceElement = referenceSelector ? document.querySelector(referenceSelector) : button;
    this.setupAriaRelationships(button, menu);
    this.refs = { button, menuWrapper, menu, items, referenceElement };
  },
  setupEventListeners() {
    this.listeners = [
      [this.refs.button, "click", this.handleToggle.bind(this)],
      [this.refs.menu, "mouseover", this.handleMouseOver.bind(this)],
      [this.refs.menu, "click", this.handleMenuClick.bind(this)],
      [this.el, "keydown", this.handleKeydown.bind(this)],
      [this.el, "prima:close", this.handleClose.bind(this)],
      [this.refs.menu, "phx:show-start", this.handleShowStart.bind(this)],
      [this.refs.menu, "phx:hide-end", this.handleHideEnd.bind(this)]
    ];
    this.listeners.forEach(([element, event, handler]) => {
      element.addEventListener(event, handler);
    });
  },
  cleanup() {
    this.cleanupAutoUpdate();
    if (this.listeners) {
      this.listeners.forEach(([element, event, handler]) => {
        element.removeEventListener(event, handler);
      });
      this.listeners = [];
    }
  },
  cleanupAutoUpdate() {
    if (this.autoUpdateCleanup) {
      this.autoUpdateCleanup();
      this.autoUpdateCleanup = null;
    }
  },
  handleKeydown(e) {
    const keyHandlers = {
      [KEYS.ARROW_UP]: () => this.navigateUp(e),
      [KEYS.ARROW_DOWN]: () => this.navigateDown(e),
      [KEYS.ESCAPE]: () => this.handleEscape(),
      [KEYS.ENTER]: () => this.handleEnterOrSpace(e),
      [KEYS.SPACE]: () => this.handleEnterOrSpace(e),
      [KEYS.HOME]: () => this.handleHome(e),
      [KEYS.END]: () => this.handleEnd(e),
      [KEYS.PAGE_UP]: () => this.handleHome(e),
      [KEYS.PAGE_DOWN]: () => this.handleEnd(e)
    };
    const handler = keyHandlers[e.key];
    if (handler) {
      handler();
    } else {
      this.handleTypeahead(e);
    }
  },
  navigateUp(e) {
    e.preventDefault();
    if (!this.isMenuVisible() && document.activeElement === this.refs.button) {
      this.showMenuAndFocusLast();
      return;
    }
    const items = this.getEnabledMenuItems();
    if (items.length === 0)
      return;
    const currentIndex = this.getCurrentFocusIndex(items);
    const targetIndex = currentIndex === 0 ? items.length - 1 : currentIndex - 1;
    this.setFocus(items[targetIndex]);
  },
  navigateDown(e) {
    e.preventDefault();
    if (!this.isMenuVisible() && document.activeElement === this.refs.button) {
      this.showMenuAndFocusFirst();
      return;
    }
    const items = this.getEnabledMenuItems();
    if (items.length === 0)
      return;
    const currentIndex = this.getCurrentFocusIndex(items);
    const targetIndex = currentIndex === items.length - 1 ? 0 : currentIndex + 1;
    this.setFocus(items[targetIndex]);
  },
  handleEscape() {
    this.hideMenu();
    this.refs.button.focus();
  },
  handleEnterOrSpace(e) {
    const focusedItem = this.el.querySelector(SELECTORS.FOCUSED_MENUITEM);
    if (focusedItem && focusedItem.getAttribute("aria-disabled") !== "true") {
      e.preventDefault();
      focusedItem.click();
    } else if (document.activeElement === this.refs.button) {
      e.preventDefault();
      this.showMenuAndFocusFirst();
    }
  },
  handleHome(e) {
    if (this.isMenuVisible()) {
      e.preventDefault();
      const items = this.getEnabledMenuItems();
      if (items.length > 0) {
        this.setFocus(items[0]);
      }
    }
  },
  handleEnd(e) {
    if (this.isMenuVisible()) {
      e.preventDefault();
      const items = this.getEnabledMenuItems();
      if (items.length > 0) {
        this.setFocus(items[items.length - 1]);
      }
    }
  },
  handleTypeahead(e) {
    if (!this.isMenuVisible() || e.key.length !== 1 || !/[a-zA-Z0-9]/.test(e.key))
      return;
    e.preventDefault();
    const searchChar = e.key.toLowerCase();
    const items = this.getEnabledMenuItems();
    const matchingItems = Array.from(items).filter(
      (item) => item.textContent.trim().toLowerCase().startsWith(searchChar)
    );
    if (matchingItems.length === 0)
      return;
    const currentFocused = this.el.querySelector(SELECTORS.FOCUSED_MENUITEM);
    const currentIndex = currentFocused && matchingItems.includes(currentFocused) ? matchingItems.indexOf(currentFocused) : -1;
    const nextIndex = currentIndex >= 0 && currentIndex < matchingItems.length - 1 ? currentIndex + 1 : 0;
    this.setFocus(matchingItems[nextIndex]);
  },
  handleClose() {
    this.hideMenu();
  },
  handleToggle() {
    this.toggleMenu();
  },
  handleMouseOver(e) {
    if (e.target.getAttribute("role") === "menuitem" && e.target.getAttribute("aria-disabled") !== "true") {
      this.setFocus(e.target);
    }
  },
  handleMenuClick(e) {
    if (e.target.getAttribute("role") === "menuitem" && e.target.getAttribute("aria-disabled") !== "true") {
      this.hideMenu();
      this.refs.button.focus();
    }
  },
  handleShowStart() {
    this.refs.button.setAttribute("aria-expanded", "true");
    this.autoUpdateCleanup = autoUpdate(this.refs.referenceElement, this.refs.menuWrapper, () => {
      this.positionMenu();
    });
  },
  handleHideEnd() {
    this.clearFocus();
    this.refs.menu.removeAttribute("aria-activedescendant");
    this.refs.button.setAttribute("aria-expanded", "false");
    this.refs.menuWrapper.style.display = "none";
    this.cleanupAutoUpdate();
  },
  getAllMenuItems() {
    return this.el.querySelectorAll(SELECTORS.MENUITEM);
  },
  getEnabledMenuItems() {
    return this.el.querySelectorAll(SELECTORS.ENABLED_MENUITEM);
  },
  isMenuVisible() {
    const wrapper = this.refs.menuWrapper;
    return wrapper && wrapper.style.display !== "none" && wrapper.offsetParent !== null;
  },
  getCurrentFocusIndex(items) {
    return Array.prototype.findIndex.call(items, (item) => item.hasAttribute("data-focus"));
  },
  setFocus(el) {
    this.clearFocus();
    if (el && el.getAttribute("aria-disabled") !== "true") {
      el.setAttribute("data-focus", "");
      this.refs.menu.setAttribute("aria-activedescendant", el.id);
    } else {
      this.refs.menu.removeAttribute("aria-activedescendant");
    }
  },
  clearFocus() {
    var _a;
    (_a = this.el.querySelector(SELECTORS.FOCUSED_MENUITEM)) == null ? void 0 : _a.removeAttribute("data-focus");
  },
  hideMenu() {
    liveSocket.execJS(this.refs.menu, this.refs.menu.getAttribute("js-hide"));
    this.refs.menuWrapper.style.display = "none";
  },
  toggleMenu() {
    if (this.isMenuVisible()) {
      liveSocket.execJS(this.refs.menu, this.refs.menu.getAttribute("js-hide"));
      this.refs.menuWrapper.style.display = "none";
    } else {
      this.refs.menuWrapper.style.display = "block";
      this.positionMenu();
      liveSocket.execJS(this.refs.menu, this.refs.menu.getAttribute("js-show"));
    }
  },
  showMenuAndFocusFirst() {
    this.refs.menuWrapper.style.display = "block";
    this.positionMenu();
    liveSocket.execJS(this.refs.menu, this.refs.menu.getAttribute("js-show"));
    const items = this.getEnabledMenuItems();
    if (items.length > 0) {
      this.setFocus(items[0]);
    }
  },
  showMenuAndFocusLast() {
    this.refs.menuWrapper.style.display = "block";
    this.positionMenu();
    liveSocket.execJS(this.refs.menu, this.refs.menu.getAttribute("js-show"));
    const items = this.getEnabledMenuItems();
    if (items.length > 0) {
      this.setFocus(items[items.length - 1]);
    }
  },
  setupAriaRelationships(button, menu) {
    const dropdownId = this.el.id;
    const triggerId = button.id || `${dropdownId}-trigger`;
    const menuId = menu.id || `${dropdownId}-menu`;
    if (!button.id)
      button.id = triggerId;
    button.setAttribute("aria-controls", menuId);
    if (!menu.id)
      menu.id = menuId;
    menu.setAttribute("aria-labelledby", triggerId);
    this.setupMenuitemIds();
    this.setupSectionLabels();
  },
  setupMenuitemIds() {
    const dropdownId = this.el.id;
    const items = this.el.querySelectorAll(SELECTORS.MENUITEM);
    items.forEach((item, index) => {
      if (!item.id) {
        item.id = `${dropdownId}-item-${index}`;
      }
    });
  },
  setupSectionLabels() {
    const dropdownId = this.el.id;
    const sections = this.el.querySelectorAll('[role="group"]');
    sections.forEach((section, sectionIndex) => {
      const firstChild = section.firstElementChild;
      if (firstChild && firstChild.getAttribute("role") === "presentation") {
        if (!firstChild.id) {
          firstChild.id = `${dropdownId}-section-${sectionIndex}-heading`;
        }
        section.setAttribute("aria-labelledby", firstChild.id);
      }
    });
  },
  positionMenu() {
    if (!this.refs.menuWrapper)
      return;
    const placement = this.refs.menuWrapper.getAttribute("data-placement") || "bottom-start";
    const shouldFlip = this.refs.menuWrapper.getAttribute("data-flip") !== "false";
    const offsetValue = this.refs.menuWrapper.getAttribute("data-offset");
    const middleware = [];
    if (offsetValue && !isNaN(parseInt(offsetValue))) {
      middleware.push(offset2(parseInt(offsetValue)));
    }
    if (shouldFlip) {
      middleware.push(flip2());
    }
    computePosition2(this.refs.referenceElement, this.refs.menuWrapper, {
      placement,
      middleware
    }).then(({ x, y }) => {
      Object.assign(this.refs.menuWrapper.style, {
        top: `${y}px`,
        left: `${x}px`
      });
    }).catch((error) => {
      console.error("[Prima Dropdown] Failed to position menu:", error);
    });
  }
};

// js/hooks/modal.js
var modal_default = {
  mounted() {
    this.initialize();
  },
  updated() {
    this.initialize();
  },
  reconnected() {
    this.initialize();
  },
  destroyed() {
    this.cleanup();
  },
  initialize() {
    this.cleanup();
    this.setupElements();
    this.setupDOMEventListeners();
    this.setupPushEventListeners();
    this.checkInitialShow();
    this.el.setAttribute("data-prima-ready", "true");
  },
  setupPushEventListeners() {
    this.pushEventRefs = [
      this.handleEvent("prima:modal:open", (payload) => {
        if (!payload.id || payload.id === this.el.id) {
          this.handleModalOpen();
        }
      }),
      this.handleEvent("prima:modal:close", (payload) => {
        if (!payload.id || payload.id === this.el.id) {
          this.handleModalClose();
        }
      })
    ];
  },
  setupElements() {
    this.autoClose = Object.hasOwn(this.el.dataset, "primaAutoClose");
    if (!this.ref("modal-panel")) {
      this.async = true;
    }
    this.setupAriaRelationships();
  },
  setupDOMEventListeners() {
    this.listeners = [
      [this.el, "prima:modal:open", this.handleModalOpen.bind(this)],
      [this.el, "prima:modal:close", this.handleModalClose.bind(this)],
      [this.ref("modal-overlay"), "phx:hide-end", this.handleOverlayHideEnd.bind(this)]
    ];
    if (this.async) {
      this.listeners.push(
        [this.el, "prima:modal:panel-mounted", this.handlePanelMounted.bind(this)],
        [this.el, "prima:modal:panel-removed", this.handlePanelRemoved.bind(this)]
      );
    }
    if (this.ref("modal-panel")) {
      this.listeners.push(
        [this.ref("modal-panel"), "phx:show-end", this.handlePanelShowEnd.bind(this)]
      );
    }
    this.listeners.forEach(([element, event, handler]) => {
      if (element) {
        element.addEventListener(event, handler);
      }
    });
  },
  cleanup() {
    if (this.listeners) {
      this.listeners.forEach(([element, event, handler]) => {
        element.removeEventListener(event, handler);
      });
      this.listeners = [];
    }
    if (this.pushEventRefs) {
      this.pushEventRefs.forEach((ref) => {
        if (ref)
          this.removeHandleEvent(ref);
      });
      this.pushEventRefs = [];
    }
  },
  checkInitialShow() {
    if (Object.hasOwn(this.el.dataset, "primaShow")) {
      this.el.dispatchEvent(new Event("prima:modal:open"));
    }
  },
  handleModalOpen() {
    this.storeFocusedElement();
    this.preventBodyScroll();
    this.el.removeAttribute("aria-hidden");
    this.maybeExecJS(this.el, "js-show");
    this.maybeExecJS(this.ref("modal-overlay"), "js-show");
    if (this.async) {
      this.maybeExecJS(this.ref("modal-loader"), "js-show");
    } else {
      this.maybeExecJS(this.ref("modal-panel"), "js-show");
    }
  },
  handlePanelMounted() {
    this.maybeExecJS(this.ref("modal-loader"), "js-hide");
    this.maybeExecJS(this.ref("modal-panel"), "js-show");
    this.setupAriaRelationships();
    this.el.removeAttribute("aria-hidden");
    const panelShowEndHandler = this.handlePanelShowEnd.bind(this);
    this.ref("modal-panel").addEventListener("phx:show-end", panelShowEndHandler);
    this.listeners.push([this.ref("modal-panel"), "phx:show-end", panelShowEndHandler]);
  },
  handlePanelRemoved() {
    if (!this.panelIsDirty()) {
      this.el.dispatchEvent(new Event("prima:modal:close"));
    }
  },
  handleModalClose(e) {
    if (this.autoClose || !e) {
      this.restoreBodyScroll();
      this.maybeExecJS(this.ref("modal-overlay"), "js-hide");
      this.maybeExecJS(this.ref("modal-panel"), "js-hide");
      this.maybeExecJS(this.ref("modal-loader"), "js-hide");
      if (this.async) {
        this.ref("modal-panel").dataset.primaDirty = true;
      }
    } else {
      this.maybeExecJS(this.el, "js-hide");
    }
  },
  handleOverlayHideEnd() {
    this.maybeExecJS(this.el, "js-hide");
    this.js().hide(this.el);
    this.el.setAttribute("aria-hidden", "true");
    this.restoreFocusedElement();
  },
  handlePanelShowEnd() {
    this.focusFirstElement();
  },
  maybeExecJS(el, attribute) {
    if (el && el.getAttribute(attribute)) {
      this.liveSocket.execJS(el, el.getAttribute(attribute));
    }
  },
  panelIsDirty() {
    return this.ref("modal-panel") && this.ref("modal-panel").dataset.primaDirty;
  },
  ref(ref) {
    return this.el.querySelector(`[data-prima-ref="${ref}"]`);
  },
  preventBodyScroll() {
    this.originalBodyOverflow = document.body.style.overflow;
    this.originalBodyPaddingRight = document.body.style.paddingRight;
    const scrollBarWidth = window.innerWidth - document.documentElement.clientWidth;
    document.body.style.overflow = "hidden";
    document.body.style.paddingRight = scrollBarWidth + "px";
  },
  restoreBodyScroll() {
    document.body.style.overflow = this.originalBodyOverflow || "";
    document.body.style.paddingRight = this.originalBodyPaddingRight || "";
  },
  setupAriaRelationships() {
    const modalId = this.el.id;
    const titleElement = this.ref("modal-title");
    if (titleElement) {
      if (!titleElement.id) {
        titleElement.id = `${modalId}-title`;
      }
      this.el.setAttribute("aria-labelledby", titleElement.id);
    }
  },
  storeFocusedElement() {
    this.previouslyFocusedElement = document.activeElement;
  },
  restoreFocusedElement() {
    if (this.previouslyFocusedElement && this.previouslyFocusedElement.focus) {
      this.previouslyFocusedElement.focus();
    }
  },
  focusFirstElement() {
    const panel = this.ref("modal-panel");
    const autofocusElement = panel.querySelector("[data-autofocus]");
    if (autofocusElement) {
      autofocusElement.focus();
    } else {
      this.maybeExecJS(panel, "js-focus-first");
    }
  }
};

// js/hooks/combobox.js
var KEYS2 = {
  ARROW_UP: "ArrowUp",
  ARROW_DOWN: "ArrowDown",
  ESCAPE: "Escape",
  ENTER: "Enter",
  TAB: "Tab",
  BACKSPACE: "Backspace",
  HOME: "Home",
  END: "End",
  PAGE_UP: "PageUp",
  PAGE_DOWN: "PageDown"
};
var SELECTORS2 = {
  SEARCH_INPUT: "input[data-prima-ref=search_input]",
  SUBMIT_CONTAINER: "[data-prima-ref=submit_container]",
  OPTIONS_WRAPPER: '[data-prima-ref="options-wrapper"]',
  OPTIONS: '[data-prima-ref="options"]',
  OPTION: "[role=option]",
  CREATE_OPTION: "[data-prima-ref=create-option]",
  SELECTIONS: "[data-prima-ref=selections]",
  SELECTION_TEMPLATE: "[data-prima-ref=selection-template]",
  SELECTION_ITEM: '[data-prima-ref="selection-item"]',
  REMOVE_SELECTION: '[data-prima-ref="remove-selection"]',
  VISIBLE_OPTION: "[role=option]:not([data-hidden])",
  FOCUSED_OPTION: "[role=option][data-focus=true]",
  REGULAR_OPTION: "[role=option]:not([data-prima-ref=create-option])"
};
var combobox_default = {
  mounted() {
    this.initialize();
  },
  reconnected() {
    this.initialize();
  },
  destroyed() {
    this.cleanup();
  },
  initialize() {
    this.cleanup();
    this.setupElements();
    this.setupEventListeners();
    this.initializeCreateOption();
    this.syncSelectedAttributes();
    this.setupAriaAttributes();
    if (this.mode === "async") {
      this.refs.searchInput.dispatchEvent(new Event("input", { bubbles: true }));
    }
    this.el.setAttribute("data-prima-ready", "true");
  },
  setupElements() {
    var _a, _b, _c;
    this.refs = {
      searchInput: this.el.querySelector(SELECTORS2.SEARCH_INPUT),
      submitContainer: this.el.querySelector(SELECTORS2.SUBMIT_CONTAINER),
      optionsWrapper: this.el.querySelector(SELECTORS2.OPTIONS_WRAPPER),
      optionsContainer: this.el.querySelector(SELECTORS2.OPTIONS),
      selectionsContainer: this.el.querySelector(SELECTORS2.SELECTIONS)
    };
    this.refs.createOption = (_a = this.refs.optionsContainer) == null ? void 0 : _a.querySelector(SELECTORS2.CREATE_OPTION);
    this.refs.selectionTemplate = (_b = this.refs.selectionsContainer) == null ? void 0 : _b.querySelector(SELECTORS2.SELECTION_TEMPLATE);
    const referenceSelector = (_c = this.refs.optionsWrapper) == null ? void 0 : _c.getAttribute("data-reference");
    this.refs.referenceElement = referenceSelector ? document.querySelector(referenceSelector) : this.refs.searchInput;
    this.mode = this.getMode();
    this.isMultiple = this.el.hasAttribute("data-multiple");
    this.hasCreateOption = !!this.refs.createOption;
  },
  setupEventListeners() {
    this.listeners = [
      [this.el, "keydown", this.handleKeydown.bind(this)],
      [this.el, "click", this.handleClick.bind(this)],
      [this.refs.searchInput, "focus", this.handleSearchFocus.bind(this)],
      [this.refs.searchInput, "click", this.handleSearchClick.bind(this)],
      [this.refs.searchInput, "change", (e) => e.stopPropagation()],
      [this.refs.searchInput, "input", this.handleInput.bind(this)]
    ];
    if (this.refs.optionsContainer) {
      this.listeners.push(
        [this.refs.optionsContainer, "click", this.handleClick.bind(this)],
        [this.refs.optionsContainer, "mouseover", this.handleHover.bind(this)],
        [this.refs.optionsContainer, "phx:show-start", this.handleShowStart.bind(this)],
        [this.refs.optionsContainer, "phx:hide-end", this.handleHideEnd.bind(this)]
      );
    }
    this.listeners.forEach(([element, event, handler]) => {
      if (element) {
        element.addEventListener(event, handler);
      }
    });
  },
  setupAriaAttributes() {
    if (this.refs.optionsContainer && this.refs.searchInput) {
      const optionsId = this.refs.optionsContainer.getAttribute("id");
      if (optionsId) {
        this.refs.searchInput.setAttribute("aria-controls", optionsId);
      }
    }
    this.ensureOptionIds();
  },
  ensureOptionIds() {
    if (!this.refs.optionsContainer)
      return;
    const options = this.refs.optionsContainer.querySelectorAll(SELECTORS2.OPTION);
    options.forEach((option, index) => {
      if (!option.id) {
        const comboboxId = this.el.id || "combobox";
        option.id = `${comboboxId}-option-${index}`;
      }
    });
  },
  cleanup() {
    this.cleanupAutoUpdate();
    if (this.listeners) {
      this.listeners.forEach(([element, event, handler]) => {
        if (element) {
          element.removeEventListener(event, handler);
        }
      });
      this.listeners = [];
    }
  },
  updated() {
    var _a;
    this.ensureOptionIds();
    this.positionOptions();
    const focusedDomNode = (_a = this.refs.optionsContainer) == null ? void 0 : _a.querySelector(`${SELECTORS2.OPTION}[data-value="${this.focusedOptionBeforeUpdate}"]`);
    if (this.focusedOptionBeforeUpdate && focusedDomNode) {
      this.setFocus(focusedDomNode);
    } else {
      this.focusFirstOption();
    }
    this.syncSelectedAttributes();
  },
  getMode() {
    return this.refs.searchInput.hasAttribute("phx-change") ? "async" : "frontend";
  },
  getVisibleOptions() {
    var _a;
    return Array.from(((_a = this.refs.optionsContainer) == null ? void 0 : _a.querySelectorAll(SELECTORS2.VISIBLE_OPTION)) || []);
  },
  getRegularOptions() {
    var _a;
    return ((_a = this.refs.optionsContainer) == null ? void 0 : _a.querySelectorAll(SELECTORS2.REGULAR_OPTION)) || [];
  },
  isOptionsVisible() {
    if (!this.refs.optionsContainer)
      return false;
    return this.refs.optionsContainer.style.display !== "none";
  },
  getSelectedValues() {
    var _a;
    const inputs = ((_a = this.refs.submitContainer) == null ? void 0 : _a.querySelectorAll('input[type="hidden"]')) || [];
    return Array.from(inputs).map((input) => input.value);
  },
  findOptionByValue(value) {
    if (!value)
      return null;
    const allOptions = this.getRegularOptions();
    return Array.from(allOptions).find(
      (option) => option.getAttribute("data-value") === value
    );
  },
  getSelectedOption() {
    const selectedValues = this.getSelectedValues();
    return this.findOptionByValue(selectedValues[0]);
  },
  restoreSelectedDisplayValue() {
    const selectedOption = this.getSelectedOption();
    if (selectedOption) {
      this.refs.searchInput.value = selectedOption.getAttribute("data-display");
    } else {
      this.refs.searchInput.value = "";
    }
  },
  getInputName() {
    if (!this.refs.submitContainer)
      return "";
    const baseName = this.refs.submitContainer.getAttribute("data-input-name");
    return this.isMultiple ? baseName + "[]" : baseName;
  },
  addSelection(value) {
    if (!this.refs.submitContainer)
      return;
    const selectedValues = this.getSelectedValues();
    if (selectedValues.includes(value))
      return;
    if (!this.isMultiple) {
      this.refs.submitContainer.innerHTML = "";
    }
    const input = document.createElement("input");
    input.type = "hidden";
    input.name = this.getInputName();
    input.value = value;
    this.refs.submitContainer.appendChild(input);
    if (this.isMultiple) {
      this.appendSelectionPill(value);
    }
    this.syncSelectedAttributes();
    this.notifyFormChange(input);
  },
  removeSelection(value) {
    var _a;
    const inputs = Array.from(this.refs.submitContainer.querySelectorAll('input[type="hidden"]'));
    const input = inputs.find((input2) => input2.value === value);
    if (this.isMultiple) {
      const pill = (_a = this.refs.selectionsContainer) == null ? void 0 : _a.querySelector(
        `${SELECTORS2.SELECTION_ITEM}[data-value="${value}"]`
      );
      pill == null ? void 0 : pill.remove();
    }
    input.value = "";
    this.notifyFormChange(input);
    input.remove();
    this.syncSelectedAttributes();
  },
  setFocus(el) {
    var _a, _b;
    (_b = (_a = this.refs.optionsContainer) == null ? void 0 : _a.querySelector(SELECTORS2.FOCUSED_OPTION)) == null ? void 0 : _b.removeAttribute("data-focus");
    el.setAttribute("data-focus", "true");
    if (el.id) {
      this.refs.searchInput.setAttribute("aria-activedescendant", el.id);
    }
    el.scrollIntoView({ block: "nearest", inline: "nearest" });
  },
  focusFirstOption() {
    var _a;
    const firstOption = (_a = this.refs.optionsContainer) == null ? void 0 : _a.querySelector(SELECTORS2.VISIBLE_OPTION);
    if (firstOption) {
      this.setFocus(firstOption);
    }
  },
  getCurrentFocusedOption() {
    var _a;
    return (_a = this.refs.optionsContainer) == null ? void 0 : _a.querySelector(SELECTORS2.FOCUSED_OPTION);
  },
  navigateUp(e) {
    e.preventDefault();
    const visibleOptions = this.getVisibleOptions();
    if (visibleOptions.length === 0)
      return;
    const currentFocusIndex = visibleOptions.findIndex((option) => option.getAttribute("data-focus") === "true");
    const targetIndex = currentFocusIndex <= 0 ? visibleOptions.length - 1 : currentFocusIndex - 1;
    this.setFocus(visibleOptions[targetIndex]);
  },
  navigateDown(e) {
    e.preventDefault();
    const visibleOptions = this.getVisibleOptions();
    if (visibleOptions.length === 0)
      return;
    const currentFocusIndex = visibleOptions.findIndex((option) => option.getAttribute("data-focus") === "true");
    const targetIndex = currentFocusIndex === visibleOptions.length - 1 ? 0 : currentFocusIndex + 1;
    this.setFocus(visibleOptions[targetIndex]);
  },
  navigateToFirst(e) {
    e.preventDefault();
    const visibleOptions = this.getVisibleOptions();
    if (visibleOptions.length === 0)
      return;
    this.setFocus(visibleOptions[0]);
  },
  navigateToLast(e) {
    e.preventDefault();
    const visibleOptions = this.getVisibleOptions();
    if (visibleOptions.length === 0)
      return;
    this.setFocus(visibleOptions[visibleOptions.length - 1]);
  },
  selectOption(el) {
    if (!el)
      return;
    let value = el.getAttribute("data-value");
    let displayValue = el.getAttribute("data-display");
    if (value === "__CREATE__") {
      value = this.refs.searchInput.value;
      displayValue = value;
    }
    this.addSelection(value);
    if (this.isMultiple) {
      this.refs.searchInput.value = "";
      this.refs.searchInput.focus();
    } else {
      this.refs.searchInput.value = displayValue;
    }
    this.hideOptions();
  },
  syncSelectedAttributes() {
    if (!this.refs.optionsContainer)
      return;
    const allOptions = this.getRegularOptions();
    const selectedValues = this.getSelectedValues();
    for (const option of allOptions) {
      const value = option.getAttribute("data-value");
      if (selectedValues.includes(value)) {
        option.setAttribute("data-selected", "true");
      } else {
        option.removeAttribute("data-selected");
      }
    }
  },
  appendSelectionPill(value) {
    if (!this.refs.selectionsContainer || !this.refs.selectionTemplate)
      return;
    const option = this.findOptionByValue(value);
    const displayValue = option ? option.getAttribute("data-display") : value;
    const pill = this.refs.selectionTemplate.content.cloneNode(true);
    const item = pill.querySelector(SELECTORS2.SELECTION_ITEM);
    item.dataset.value = value;
    item.innerHTML = item.innerHTML.replaceAll("__VALUE__", displayValue);
    this.refs.selectionsContainer.appendChild(pill);
  },
  handleClick(e) {
    const removeButton = e.target.closest(SELECTORS2.REMOVE_SELECTION);
    if (removeButton) {
      const value = removeButton.getAttribute("data-value");
      this.removeSelection(value);
      this.refs.searchInput.focus();
      return;
    }
    const optionElement = e.target.closest(SELECTORS2.OPTION);
    if (optionElement) {
      this.selectOption(optionElement);
    }
  },
  handleKeydown(e) {
    const arrowKeys = [KEYS2.ARROW_UP, KEYS2.ARROW_DOWN];
    const otherNavigationKeys = [KEYS2.HOME, KEYS2.END, KEYS2.PAGE_UP, KEYS2.PAGE_DOWN];
    if (arrowKeys.includes(e.key) && !this.isOptionsVisible()) {
      e.preventDefault();
      this.showOptions();
      return;
    }
    if (otherNavigationKeys.includes(e.key) && !this.isOptionsVisible()) {
      return;
    }
    const keyHandlers = {
      [KEYS2.ARROW_UP]: () => this.navigateUp(e),
      [KEYS2.ARROW_DOWN]: () => this.navigateDown(e),
      [KEYS2.HOME]: () => this.navigateToFirst(e),
      [KEYS2.PAGE_UP]: () => this.navigateToFirst(e),
      [KEYS2.END]: () => this.navigateToLast(e),
      [KEYS2.PAGE_DOWN]: () => this.navigateToLast(e),
      [KEYS2.ESCAPE]: () => this.handleEscape(e),
      [KEYS2.ENTER]: () => this.handleEnterOrTab(e),
      [KEYS2.TAB]: () => this.handleEnterOrTab(e),
      [KEYS2.BACKSPACE]: () => this.handleBackspace(e)
    };
    const handler = keyHandlers[e.key];
    if (handler) {
      handler();
    }
  },
  handleEscape(e) {
    e.preventDefault();
    if (!this.isMultiple) {
      this.restoreSelectedDisplayValue();
    } else {
      this.refs.searchInput.value = "";
    }
    this.hideOptions();
  },
  handleEnterOrTab(e) {
    if (!this.isOptionsVisible()) {
      return;
    }
    e.preventDefault();
    this.selectOption(this.getCurrentFocusedOption());
  },
  handleBackspace(e) {
    if (this.isMultiple && this.refs.searchInput.value === "") {
      e.preventDefault();
      const values = this.getSelectedValues();
      if (values.length > 0) {
        this.removeSelection(values[values.length - 1]);
      }
    }
  },
  handleHover(e) {
    const optionElement = e.target.closest(SELECTORS2.OPTION);
    if (optionElement) {
      this.setFocus(optionElement);
    }
  },
  handleSearchFocus() {
    this.refs.searchInput.select();
  },
  handleSearchClick() {
    if (this.isOptionsVisible()) {
      this.hideOptions();
    } else {
      this.showOptions();
    }
  },
  handleInput(e) {
    const searchValue = e.target.value;
    if (!this.isMultiple && searchValue === "" && this.getSelectedValues().length > 0) {
      this.removeSelection(this.getSelectedValues()[0]);
    }
    if (this.hasCreateOption) {
      this.updateCreateOption(searchValue);
    }
    if (this.mode === "async") {
      this.handleAsyncMode();
    } else {
      e.stopPropagation();
      this.handleFrontendMode(searchValue);
    }
  },
  handleAsyncMode() {
    var _a;
    if (this.refs.searchInput.value.length > 0) {
      this.showOptions();
    }
    this.focusedOptionBeforeUpdate = (_a = this.getCurrentFocusedOption()) == null ? void 0 : _a.dataset.value;
  },
  handleFrontendMode(searchValue) {
    if (searchValue.length > 0) {
      this.showOptions();
    }
    this.filterOptions(searchValue);
  },
  filterOptions(searchValue) {
    const q = searchValue.toLowerCase();
    const allOptions = this.getRegularOptions();
    let previouslyFocusedOptionIsHidden = false;
    for (const option of allOptions) {
      const optionVal = option.getAttribute("data-display").toLowerCase();
      if (optionVal.includes(q)) {
        this.showOption(option);
      } else {
        this.hideOption(option);
        if (option.getAttribute("data-focus") === "true") {
          previouslyFocusedOptionIsHidden = true;
        }
      }
    }
    if (this.hasCreateOption) {
      this.updateCreateOptionVisibility(searchValue);
    }
    if (previouslyFocusedOptionIsHidden) {
      this.focusFirstOption();
    }
  },
  showOption(option) {
    option.style.display = "block";
    option.removeAttribute("data-hidden");
  },
  hideOption(option) {
    option.style.display = "none";
    option.setAttribute("data-hidden", "true");
  },
  positionOptions() {
    if (!this.refs.optionsWrapper)
      return;
    const placement = this.refs.optionsWrapper.getAttribute("data-placement") || "bottom-start";
    const shouldFlip = this.refs.optionsWrapper.getAttribute("data-flip") !== "false";
    const offsetValue = this.refs.optionsWrapper.getAttribute("data-offset");
    const middleware = [];
    if (offsetValue && !isNaN(parseInt(offsetValue))) {
      middleware.push(offset2(parseInt(offsetValue)));
    }
    if (shouldFlip) {
      middleware.push(flip2());
    }
    computePosition2(this.refs.referenceElement, this.refs.optionsWrapper, {
      placement,
      middleware
    }).then(({ x, y }) => {
      Object.assign(this.refs.optionsWrapper.style, {
        top: `${y}px`,
        left: `${x}px`
      });
    }).catch((error) => {
      console.error("[Prima Combobox] Failed to position options:", error);
    });
  },
  cleanupAutoUpdate() {
    if (this.autoUpdateCleanup) {
      this.autoUpdateCleanup();
      this.autoUpdateCleanup = null;
    }
  },
  showOptions() {
    this.refs.optionsWrapper.style.display = "block";
    this.positionOptions();
    this.liveSocket.execJS(this.refs.optionsContainer, this.refs.optionsContainer.getAttribute("js-show"));
    this.refs.optionsContainer.addEventListener("phx:show-end", () => {
      this.focusFirstOption();
    }, { once: true });
    this.setupClickOutsideHandler();
  },
  handleShowStart() {
    this.refs.searchInput.setAttribute("aria-expanded", "true");
    this.autoUpdateCleanup = autoUpdate(this.refs.referenceElement, this.refs.optionsWrapper, () => {
      this.positionOptions();
    });
  },
  handleHideEnd() {
    this.refs.optionsWrapper.style.display = "none";
    this.cleanupAutoUpdate();
  },
  hideOptions() {
    if (!this.refs.optionsContainer)
      return;
    this.liveSocket.execJS(this.refs.optionsContainer, this.refs.optionsContainer.getAttribute("js-hide"));
    this.refs.searchInput.setAttribute("aria-expanded", "false");
    this.refs.searchInput.removeAttribute("aria-activedescendant");
    this.refs.optionsContainer.addEventListener("phx:hide-end", () => {
      const regularOptions = this.getRegularOptions();
      for (const option of regularOptions) {
        this.showOption(option);
      }
    }, { once: true });
  },
  setupClickOutsideHandler() {
    const handleClickOutside = (event) => {
      if (!this.refs.optionsContainer.contains(event.target) && !this.refs.searchInput.contains(event.target)) {
        this.handleBlur();
        document.removeEventListener("click", handleClickOutside);
      }
    };
    document.addEventListener("click", handleClickOutside);
  },
  handleBlur() {
    const hasSelection = this.getSelectedValues().length > 0;
    const hasSearchText = this.refs.searchInput.value.length > 0;
    if (hasSelection && hasSearchText) {
      this.restoreSelectedDisplayValue();
    } else if (hasSearchText) {
      this.refs.searchInput.value = "";
      this.refs.searchInput.dispatchEvent(new Event("input", { bubbles: true }));
      this.refs.submitContainer.innerHTML = "";
    }
    this.hideOptions();
  },
  initializeCreateOption() {
    if (!this.hasCreateOption)
      return;
    this.hideOption(this.refs.createOption);
  },
  updateCreateOption(searchValue) {
    if (!this.refs.createOption)
      return;
    this.refs.createOption.textContent = `Create "${searchValue}"`;
  },
  updateCreateOptionVisibility(searchValue) {
    if (!this.refs.createOption)
      return;
    if (searchValue.length > 0 && !this.hasExactMatch(searchValue)) {
      this.showOption(this.refs.createOption);
    } else {
      const createOptionHasFocus = this.refs.createOption.getAttribute("data-focus") === "true";
      this.hideOption(this.refs.createOption);
      if (createOptionHasFocus) {
        this.focusFirstOption();
      }
    }
  },
  hasExactMatch(searchValue) {
    const regularOptions = this.getRegularOptions();
    const hasStaticMatch = Array.from(regularOptions).some(
      (option) => option.getAttribute("data-value") === searchValue
    );
    const selectedValues = this.getSelectedValues();
    const hasSelectedMatch = selectedValues.includes(searchValue);
    return hasStaticMatch || hasSelectedMatch;
  },
  notifyFormChange(input) {
    input.dispatchEvent(new Event("input", { bubbles: true }));
  }
};
export {
  combobox_default as Combobox,
  dropdown_default as Dropdown,
  modal_default as Modal
};
