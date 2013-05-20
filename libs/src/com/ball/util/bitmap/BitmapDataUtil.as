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

	}
}
