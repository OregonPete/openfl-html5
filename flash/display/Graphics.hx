package flash.display;


import flash.geom.Matrix;
import flash.geom.Rectangle;
import js.html.CanvasElement;
import js.html.CanvasPattern;
import js.html.CanvasRenderingContext2D;
import js.Browser;
import openfl.display.Tilesheet;


@:access(flash.display.BitmapData)
class Graphics {
	
	
	public static inline var TILE_SCALE = 0x0001;
	public static inline var TILE_ROTATION = 0x0002;
	public static inline var TILE_RGB = 0x0004;
	public static inline var TILE_ALPHA = 0x0008;
	public static inline var TILE_TRANS_2x2 = 0x0010;
	public static inline var TILE_BLEND_NORMAL = 0x00000000;
	public static inline var TILE_BLEND_ADD = 0x00010000;
	
	private var __bounds:Rectangle;
	private var __canvas:CanvasElement;
	private var __commands:Array<DrawCommand>;
	private var __context:CanvasRenderingContext2D;
	private var __dirty:Bool;
	
	
	public function new () {
		
		__commands = new Array ();
		
	}
	
	
	public function beginBitmapFill (bitmap:BitmapData, matrix:Matrix = null, repeat:Bool = true, smooth:Bool = false):Void {
		
		__commands.push (BeginBitmapFill (bitmap, matrix, repeat, smooth));
			
	}
	
	
	public function beginFill (rgb:Int, alpha:Float = 1):Void {
		
		__commands.push (BeginFill (rgb & 0xFFFFFF, alpha));
		
	}
	
	
	public function clear ():Void {
		
		__commands = new Array ();
		
		if (__bounds != null) {
			
			__dirty = true;
			
		}
		
		__bounds = null;
		
	}
	
	
	public function drawCircle (x:Float, y:Float, radius:Float):Void {
		
		if (radius <= 0) return;
		
		__inflateBounds (x - radius, y - radius);
		__inflateBounds (x + radius, y + radius);
		
		__commands.push (DrawCircle (x, y, radius));
		
		__dirty = true;
		
	}
	
	
	public function drawEllipse (x:Float, y:Float, width:Float, height:Float):Void {
		
		if (width <= 0 || height <= 0) return;
		
		__inflateBounds (x, y);
		__inflateBounds (x + width, y + height);
		
		__commands.push (DrawEllipse (x, y, width, height));
		
		__dirty = true;
		
	}
	
	
	public function drawRect (x:Float, y:Float, width:Float, height:Float):Void {
		
		if (width <= 0 || height <= 0) return;
		
		__inflateBounds (x, y);
		__inflateBounds (x + width, y + height);
		
		__commands.push (DrawRect (x, y, width, height));
		
		__dirty = true;
		
	}
	
	
	public function drawRoundRect (x:Float, y:Float, width:Float, height:Float, rx:Float, ry:Float = -1):Void {
		
		// TODO
		
	}
	
	
	public function drawTiles (sheet:Tilesheet, tileData:Array<Float>, smooth:Bool = false, flags:Int = 0):Void {
		
		// Checking each tile for extents did not include rotation or scale, and could overflow the maximum canvas
		// size of some mobile browsers. Always use the full stage size for drawTiles instead?
		
		__inflateBounds (0, 0);
		__inflateBounds (Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
		
		__commands.push (DrawTiles (sheet, tileData, smooth, flags));
		
		__dirty = true;
		
		
	}
	
	
	public function endFill ():Void {
		
		
		
	}
	
	
	public function lineStyle (thickness:Null<Float> = null, color:Null<Int> = null, alpha:Null<Float> = null, pixelHinting:Null<Bool> = null, scaleMode:LineScaleMode = null, caps:CapsStyle = null, joints:JointStyle = null, miterLimit:Null<Float> = null):Void {
		
		__commands.push (LineStyle (thickness, color, alpha, pixelHinting, scaleMode, caps, joints, miterLimit));
		
	}
	
	
	public function lineTo (inX:Float, inY:Float):Void {
		
		// TODO
		
	}
	
	
	public function moveTo (inX:Float, inY:Float):Void {
		
		// TODO
		
	}
	
	
	private function __getBounds (rect:Rectangle, matrix:Matrix):Void {
		
		var bounds = __bounds.clone ().transform (matrix);
		rect.__expand (bounds.x, bounds.y, bounds.width, bounds.height);
		
	}
	
	
	private function __hitTest (x:Float, y:Float, shapeFlag:Bool, matrix:Matrix):Bool {
		
		if (__bounds == null) return false;
		
		var bounds = __bounds.clone ().transform (matrix);
		return (x > bounds.x && y > bounds.y && x <= bounds.right && y <= bounds.bottom);
		
	}
	
	
	private function __inflateBounds (x:Float, y:Float):Void {
		
		if (__bounds == null) {
			
			__bounds = new Rectangle (x, y, 0, 0);
			return;
			
		}
		
		if (x < __bounds.x) {
			
			__bounds.width += __bounds.x - x;
			__bounds.x = x;
			
		}
		
		if (y < __bounds.y) {
			
			__bounds.height += __bounds.y - y;
			__bounds.y = y;
			
		}
		
		if (x > __bounds.x + __bounds.width) {
			
			__bounds.width = x - __bounds.x;
			
		}
		
		if (y > __bounds.y + __bounds.height) {
			
			__bounds.height = y - __bounds.y;
			
		}
		
	}
	
	
	private function __render ():Void {
		
		if (__dirty) {
			
			if (__commands.length == 0) {
				
				__canvas = null;
				__context = null;
				
			} else {
				
				if (__canvas == null) {
					
					__canvas = cast Browser.document.createElement ("canvas");
					__context = __canvas.getContext ("2d");
					
				}
				
				__canvas.width = Math.round (__bounds.width);
				__canvas.height = Math.round (__bounds.height);
				
				var offsetX = __bounds.x;
				var offsetY = __bounds.y;
				
				var bitmapFill:BitmapData = null;
				var bitmapMatrix:Matrix = null;
				var bitmapRepeat = false;
				var pattern:CanvasPattern = null;
				var setFill = false;
				
				for (command in __commands) {
					
					switch (command) {
						
						case BeginBitmapFill (bitmap, matrix, repeat, smooth):
							
							if (bitmap != bitmapFill || repeat != bitmapRepeat) {
								
								bitmapFill = bitmap;
								bitmapRepeat = repeat;
								pattern = null;
								setFill = false;
								
							}
							
							bitmapMatrix = matrix;
						
						case BeginFill (rgb, alpha):
							
							if (alpha == 1) {
								
								__context.fillStyle = "#" + StringTools.hex (rgb, 6);
								
							} else {
								
								var r = (rgb & 0xFF0000) >>> 16;
								var g = (rgb & 0x00FF00) >>> 8;
								var b = (rgb & 0x0000FF);
								
								__context.fillStyle = "rgba(" + r + ", " + g + ", " + b + ", " + (alpha / 255) + ")";
								
							}
							
							bitmapFill = null;
							setFill = true;
						
						case LineStyle (thickness, color, alpha, pixelHinting, scaleMode, caps, joints, miterLimit):
							
							__context.lineWidth = thickness;
							__context.lineJoin = joints;
							__context.lineCap = caps;
							__context.miterLimit = miterLimit;
							
							/*if (lj.grad != null) {
								
								ctx.strokeStyle = createCanvasGradient (ctx, lj.grad);
								
							} else {
								
								ctx.strokeStyle = createCanvasColor (lj.colour, lj.alpha);
								
							}*/
						
						case DrawCircle (x, y, radius):
							
							if (!setFill && bitmapFill != null) {
								
								if (pattern == null) {
									
									if (bitmapFill.__sourceImage != null) {
										
										pattern = __context.createPattern (bitmapFill.__sourceImage, bitmapRepeat ? "repeat" : "no-repeat");
										
									} else {
										
										pattern = __context.createPattern (bitmapFill.__sourceCanvas, bitmapRepeat ? "repeat" : "no-repeat");
										
									}
									
								}
								
								__context.fillStyle = pattern;
								setFill = true;
								
							}
							
							__context.beginPath();
							__context.arc (x - offsetX, y - offsetY, radius, 0, Math.PI * 2, true);
							//__context.fillStyle = "#FF0000";
							__context.fill();
							__context.closePath();
						
						case DrawEllipse (x, y, width, height):
							
							if (!setFill && bitmapFill != null) {
								
								if (pattern == null) {
									
									if (bitmapFill.__sourceImage != null) {
										
										pattern = __context.createPattern (bitmapFill.__sourceImage, bitmapRepeat ? "repeat" : "no-repeat");
										
									} else {
										
										pattern = __context.createPattern (bitmapFill.__sourceCanvas, bitmapRepeat ? "repeat" : "no-repeat");
										
									}
									
								}
								
								__context.fillStyle = pattern;
								setFill = true;
								
							}
							
							var kappa = .5522848,
								ox = (width / 2) * kappa, // control point offset horizontal
								oy = (height / 2) * kappa, // control point offset vertical
								xe = x + width - offsetX,           // x-end
								ye = y + height - offsetY,           // y-end
								xm = x + width / 2 - offsetX,       // x-middle
								ym = y + height / 2 - offsetY;       // y-middle
							
							__context.beginPath();
							__context.moveTo(x, ym);
							__context.bezierCurveTo(x, ym - oy, xm - ox, y, xm, y);
							__context.bezierCurveTo(xm + ox, y, xe, ym - oy, xe, ym);
							__context.bezierCurveTo(xe, ym + oy, xm + ox, ye, xm, ye);
							__context.bezierCurveTo(xm - ox, ye, x, ym + oy, x, ym);
							__context.fill ();
							__context.closePath();
							//__context.stroke();
						
						case DrawRect (x, y, width, height):
							
							if (bitmapFill != null && width <= bitmapFill.width && height <= bitmapFill.height) {
								
								// TODO: Need to handle fill matrix
								
								if (bitmapFill.__sourceImage != null) {
									
									__context.drawImage (bitmapFill.__sourceImage, 0, 0, bitmapFill.width, bitmapFill.height, x, y, width, height);
									
								} else {
									
									__context.drawImage (bitmapFill.__sourceCanvas, 0, 0, bitmapFill.width, bitmapFill.height, x, y, width, height);
									
								}
								
							} else {
								
								if (!setFill && bitmapFill != null) {
									
									if (pattern == null) {
										
										if (bitmapFill.__sourceImage != null) {
											
											pattern = __context.createPattern (bitmapFill.__sourceImage, bitmapRepeat ? "repeat" : "no-repeat");
											
										} else {
											
											pattern = __context.createPattern (bitmapFill.__sourceCanvas, bitmapRepeat ? "repeat" : "no-repeat");
											
										}
										
									}
									
									__context.fillStyle = pattern;
									setFill = true;
									
								}
								
								__context.fillRect (x - offsetX, y - offsetY, width, height);
								//__context.stroke ();
								
							}
						
						case DrawTiles (sheet, tileData, smooth, flags):
							
							var useScale = (flags & TILE_SCALE) > 0;
							var useRotation = (flags & TILE_ROTATION) > 0;
							var useTransform = (flags & TILE_TRANS_2x2) > 0;
							var useRGB = (flags & TILE_RGB) > 0;
							var useAlpha = (flags & TILE_ALPHA) > 0;
							
							if (useTransform) { useScale = false; useRotation = false; }
							
							var scaleIndex = 0;
							var rotationIndex = 0;
							var rgbIndex = 0;
							var alphaIndex = 0;
							var transformIndex = 0;
							
							var numValues = 3;
							
							if (useScale) { scaleIndex = numValues; numValues ++; }
							if (useRotation) { rotationIndex = numValues; numValues ++; }
							if (useTransform) { transformIndex = numValues; numValues += 4; }
							if (useRGB) { rgbIndex = numValues; numValues += 3; }
							if (useAlpha) { alphaIndex = numValues; numValues ++; }
							
							var totalCount = tileData.length;
							var itemCount = Std.int(totalCount / numValues);
							var index = 0;
							
							var rect = null;
							var center = null;
							var previousTileID = -1;
							
							var surface:Dynamic;
							
							if (sheet.__bitmap.__sourceImage != null) {
								
								surface = sheet.__bitmap.__sourceImage;
								
							} else {
								
								surface = sheet.__bitmap.__sourceCanvas;
								
							}
							
							while (index < totalCount) {
								
								var tileID = Std.int (tileData[index + 2]);
								
								if (tileID != previousTileID) {
									
									rect = sheet.__tileRects[tileID];
									center = sheet.__centerPoints[tileID];
									
									previousTileID = tileID;
									
								}
								
								if (rect != null && center != null) {
									
									__context.save ();
									__context.translate (tileData[index], tileData[index + 1]);
									
									if (useRotation) {
										
										__context.rotate (tileData[index + rotationIndex]);
										
									}
									
									var scale = 1.0;
									
									if (useScale) {
										
										scale = tileData[index + scaleIndex];
										
									}
									
									if (useTransform) {
										
										__context.transform (tileData[index + transformIndex], tileData[index + transformIndex + 1], tileData[index + transformIndex + 2], tileData[index + transformIndex + 3], 0, 0);
										
									}
									
									if (useAlpha) {
										
										__context.globalAlpha = tileData[index + alphaIndex];
										
									}
									
									__context.drawImage (surface, rect.x, rect.y, rect.width, rect.height, -center.x * scale, -center.y * scale, rect.width * scale, rect.height * scale);
									__context.restore ();
									
								}
								
								index += numValues;
								
							}
						
					}
					
				}
				
			}
			
			__dirty = false;
			
		}
		
	}
	
	
}


enum DrawCommand {
	
	BeginBitmapFill (bitmap:BitmapData, matrix:Matrix, repeat:Bool, smooth:Bool);
	BeginFill (rgb:Int, alpha:Float);
	DrawCircle (x:Float, y:Float, radius:Float);
	DrawEllipse (x:Float, y:Float, width:Float, height:Float);
	DrawRect (x:Float, y:Float, width:Float, height:Float);
	DrawTiles (sheet:Tilesheet, tileData:Array<Float>, smooth:Bool, flags:Int);
	LineStyle (thickness:Null<Float>, color:Null<Int>, alpha:Null<Float>, pixelHinting:Null<Bool>, scaleMode:LineScaleMode, caps:CapsStyle, joints:JointStyle, miterLimit:Null<Float>);
	
}