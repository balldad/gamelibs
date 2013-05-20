package com.ball.util.bitmap
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import mx.graphics.codec.JPEGEncoder;
	import mx.graphics.codec.PNGEncoder;
	
	/**
	 * 切图类,运行环境为AIR3.4以上版本 
	 * @author Jerry
	 * 
	 */
	public class BitmapCut extends Sprite
	{
		private var bmd:BitmapData; 
		private var cutWidth:int = 200;
		private var cutHeight:int = 168;
		
		public function BitmapCut()
		{
			super();
			
			var bytes:ByteArray = readFile("test.png");
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.loadBytes(bytes);
		}
		
		/**
		 * 读文件,适用于Air环境 
		 * @param uri
		 * @return 
		 * 
		 */
		private function readFile(uri:String):ByteArray{
			var bytes:ByteArray = new ByteArray();
			var file:File = File.applicationDirectory.resolvePath(uri);
			var fs:FileStream = new FileStream();
			
			fs.open(file, FileMode.READ);
			fs.readBytes(bytes);
			fs.close();
			
			return bytes;
		}
		
		/**
		 * 写文件,适用于Air环境 
		 * @param uri
		 * @param bytes
		 * 
		 */
		private function writeFile(uri:String, bytes:ByteArray):void{
			var file:File = new File(File.applicationDirectory.resolvePath(uri).nativePath);
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.WRITE);
			fs.writeBytes(bytes);
			fs.close();
		}
		
		private function onLoadComplete(event:Event):void{
			bmd = Bitmap(event.target.content).bitmapData;
			
			var row:int = Math.ceil(bmd.height/cutHeight);
			var col:int = Math.ceil(bmd.width/cutWidth);
			
			var cutBmd:BitmapData = new BitmapData(cutWidth, cutHeight);
			var encoder:PNGEncoder = new PNGEncoder();
			
			for(var i:int = 0; i < row; i++){
				for(var j:int = 0; j < col; j++){
					cutBmd.copyPixels(bmd, new Rectangle(cutWidth * j, cutHeight * i, cutWidth, cutHeight), new Point(0, 0));
					var out:ByteArray = encoder.encode(cutBmd);
					writeFile([i] + "_" + [j] + ".png", out);
				}
			}
		}
		
	}
}