package com.ball.util.bitmap {
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class BitmapDataUtil {
		public function BitmapDataUtil() {
		}

		/**
		 * scale BitmapData
		 * @param sourceBmd	source bmd
		 * @param width		the width of scaled bmd
		 * @param height	the height of scaled bmd
		 * @return 			scaled bmd
		 *
		 */
		public static function scaleBmd(sourceBmd:BitmapData, width:int, height:int):BitmapData {
			var scaleW:Number = width/sourceBmd.width;
			var scaleH:Number = height/sourceBmd.height;
			
			var minScale:Number = scaleW < scaleH ? scaleW : scaleH;
			
			var matrix:Matrix = new Matrix();
			matrix.scale(minScale, minScale);

			var targetBmd:BitmapData = new BitmapData(sourceBmd.width*minScale, sourceBmd.height*minScale, true, 0x000000);
			targetBmd.draw(sourceBmd, matrix, null, null, null, true);

			return targetBmd;
		}
		
		/**
		 * Rotate bitmapdata with center point
		 * @param source	source bmd
		 * @param value		rotate angle
		 * @return 			rotated bmd
		 * 
		 */
		public static function rotateBmd(source:BitmapData, value:Number):BitmapData{
			var width:Number = source.width;
			var height:Number = source.height;
			
			var wh:Number = Math.sqrt(width * width + height * height);
			var bmd:BitmapData = new BitmapData(wh, wh);
			var matrix:Matrix = new Matrix();
			
			setMatrix(matrix, (wh - width) * 0.5, (wh - height) * 0.5, value * Math.PI/180, wh);
			bmd.draw(source, matrix, null, null, null, true);
			
			return bmd;
		}
		
		private static function setMatrix(matrix:Matrix, xpos:Number, ypos:Number, angle:Number, wh:Number):void{
			var sin:Number = Math.sin(angle);
			var cos:Number = Math.cos(angle);
			var x1:Number = xpos - wh / 2; 
			var y1:Number = ypos - wh / 2; 
			var x2:Number = cos * x1 - sin * y1;
			var y2:Number = cos * y1 + sin * x1; 
			xpos = wh / 2 + x2; 
			ypos = wh / 2 + y2;
			matrix.tx = xpos;
			matrix.ty = ypos;
			matrix.a = cos;
			matrix.b = sin;
			matrix.c = -sin;
			matrix.d = cos;
		}

	}
}
