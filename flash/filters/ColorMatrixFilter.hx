package flash.filters;


import flash.geom.Point;
import flash.geom.Rectangle;
import js.html.ImageData;



class ColorMatrixFilter extends BitmapFilter {
	
	
	public var matrix:Array<Float>;
	
	
	public function new (matrix:Array<Float> = null) {
		
		super ();
		
		this.matrix = matrix;
		
	}
	
	
	public override function clone ():BitmapFilter {
		
		return new ColorMatrixFilter ();
		
	}
	
	
	public override function __applyFilter (sourceData:ImageData, targetData:ImageData, sourceRect:Rectangle, destPoint:Point):Void {
		
		var source = sourceData.data;
		var target = targetData.data;
		
		var offsetX = Std.int (destPoint.x - sourceRect.x);
		var offsetY = Std.int (destPoint.y - sourceRect.y);
		var sourceStride = sourceData.width * 4;
		var targetStride = targetData.width * 4;
		
		var sourceOffset:Int;
		var targetOffset:Int;
		
		for (row in Std.int (sourceRect.y)...Std.int (sourceRect.height)) {
			
			for (column in Std.int (sourceRect.x)...Std.int (sourceRect.width)) {
				
				sourceOffset = (row * sourceStride) + (column * 4);
				targetOffset = ((row + offsetX) * targetStride) + ((column + offsetY) * 4);
				
				var srcR = source[sourceOffset];
				var srcG = source[sourceOffset + 1];
				var srcB = source[sourceOffset + 2];
				var srcA = source[sourceOffset + 3];
				
				target[targetOffset] = Std.int ((matrix[0]  * srcR) + (matrix[1]  * srcG) + (matrix[2]  * srcB) + (matrix[3]  * srcA) + matrix[4]);
				target[targetOffset + 1] = Std.int ((matrix[5]  * srcR) + (matrix[6]  * srcG) + (matrix[7]  * srcB) + (matrix[8]  * srcA) + matrix[9]);
				target[targetOffset + 2] = Std.int ((matrix[10] * srcR) + (matrix[11] * srcG) + (matrix[12] * srcB) + (matrix[13] * srcA) + matrix[14]);
				target[targetOffset + 3] = Std.int ((matrix[15] * srcR) + (matrix[16] * srcG) + (matrix[17] * srcB) + (matrix[18] * srcA) + matrix[19]);
				
			}
			
		}
		
	}
	
	
}