package com.ball.dict
{
	import flash.display.Sprite;
	
	public class Map extends Sprite
	{
		public function Map()
		{
			super();
			
			createMapByObj();
			createMapByArray();
		}
		
		private function createMapByObj():void{
			var obj:Object = new Object();
			obj["first"] = "Hello";
			obj["second"] = "World";
			
			trace(obj["first"], obj["second"]);
			
			var obj2:Object = new Object();
			obj2[1000] = "Good";
			obj2[2000] = "Morning";
			trace(obj2.length);
			trace(obj2[1000], obj2[2000]);
			
			//以下两种遍历方式都可访问到存储的值
			for (var key:Object in obj2){
				trace(obj2[key]);
			}
			
			for each (var value:Object in obj2){
				trace(value);
			}
		}
		
		//结论:建立关联数组的时候最好不要用Array,用Object,避免异常的错误,关联数组无法适用Array类的任何方法
		private function createMapByArray():void{
			var a:Array = new Array();
			a["first"] = "Hello";
			a["second"] = "World";
			
			trace(a["first"], a["second"]);
			
			//看似关联数组,实际是个索引数组
			var b:Array = new Array();
			b["10"] = "Hello";
			b["20"] = "World";
			trace(b.length);
			
			trace(b[10], b[20]);
			
			var c:Array = new Array();
			c["third"] = "Good";
			c["fourth"] = "Morning";
			
			//关联数组不可concat,数组长度也无法得到,变量跟踪length为0
			var d:Array = a.concat(c);
			trace("end");
		}
	}
}