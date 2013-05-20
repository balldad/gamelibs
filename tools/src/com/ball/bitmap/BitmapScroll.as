package com.ball.bitmap
{
	import com.ball.debug.BasicInfo;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	import flash.ui.KeyboardType;
	
	[SWF(width="960", height="640", frameRate="120")]
	public class BitmapScroll extends Sprite
	{
		private var bmd:BitmapData = new BitmapData(4240, 1260);
		private var buffer:BitmapData = new BitmapData(4240, 1260);
		private var canvas:BitmapData = new BitmapData(960, 640);
		private var cutArray:Array = new Array();
//		private var row:int = 79;
//		private var col:int = 265;
//		private var beginRow:int = 0;
//		private var beginCol:int = 0;
		private var offX:int = 0;
		private var offY:int = 0;
		private var diff:int = 1;
		private var loadComplete:Boolean = false;
		
		public function BitmapScroll()
		{
			super();
			
			addChild(new BasicInfo());
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.load(new URLRequest("110001001.jpg"));
			
			this.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
//			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function onKeyDown(event:KeyboardEvent):void{
			switch(event.keyCode)
			{
				case Keyboard.LEFT:
				{
					offX -= diff;
					//					beginCol++;
					break;
				}
				case Keyboard.RIGHT:
				{
					offX += diff;
					//					beginCol--;
				}
				case Keyboard.UP:
				{
					offY -= diff;
					//					beginRow--;
				}
				case Keyboard.DOWN:
				{
					offY += diff;
					//					beginRow++;
				}
				default:
				{
					break;
				}
			}
		}
		
		private function onEnterFrame(event:Event):void{
			if(loadComplete){
				//				drawCanvas();
				offX += diff;
				render();
			}
		}
		
		private function drawCanvas():void{
			for(var i:int = 0; i < 40; i++){
				for(var j:int = 0; j < 60; j++){
					//					canvas.copyPixels(cutArray[i + beginRow][j + beginCol], new Rectangle(0, 0, 16, 16), new Point(j * 16, i * 16));
				}
			}
		}
		
		private function render():void{
			canvas.copyPixels(buffer, new Rectangle(offX, offY, 960, 640), new Point(0, 0));
			graphics.clear();
			graphics.beginBitmapFill(canvas);
			graphics.drawRect(0, 0, 960, 640);
			graphics.endFill();
		}
		
		private function onLoadComplete(event:Event):void{
			bmd = Bitmap(event.target.content).bitmapData;
			buffer.copyPixels(bmd, new Rectangle(0, 0, bmd.width, bmd.height), new Point(0, 0));
			//			for(var i:int = 0; i < row; i++){
			//				if(cutArray[i] == null){
			//					cutArray[i] = new Array();
			//				}
			//				
			//				for(var j:int = 0; j < col; j++){
			//					var cutBmd:BitmapData = new BitmapData(16, 16);
			//					cutBmd.copyPixels(bmd, new Rectangle(j * 16, i * 16, 16, 16), new Point(0, 0));
			//					cutArray[i][j] = cutBmd;
			//				}
			//			}
			//			
			loadComplete = true;
		}
	}
}