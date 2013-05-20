package com.ball.util.byteArray
{
	import flash.utils.ByteArray;

	public class ByteArrayUtil
	{
		public function ByteArrayUtil()
		{
		}
		
		private static const HEX_CHARS:String = "0123456789ABCDEF";
		
		/**
		 * ByteArray to String 
		 * @param bytes		ByteArray
		 * @return 			String
		 * 
		 */
		public static function bytesToString(bytes:ByteArray):String {
			var result:String = "";
			var len:uint      = bytes.length;
			
			for (var i:uint = 0; i < len; i += 16) {
				var hex:String   = "";
				var chars:String = "";
				
				for (var j:uint = 0; j < 16 && i + j < len; j++) {
					var x:uint = bytes[i + j];
					
					hex += ' ';
					hex += HEX_CHARS.charAt(x >> 4);
					hex += HEX_CHARS.charAt(x & 0xF);
					chars += (x >= 32 && x <= 126) ? String.fromCharCode(x) : '\u2022';
				}
				
				while (hex.length < 48) {
					hex += ' ';
				}
				
				while (chars.length < 16) {
					chars += ' ';
				}
				
				result += HEX_CHARS.charAt((i >> 12) & 0xF);
				result += HEX_CHARS.charAt((i >> 8) & 0xF);
				result += HEX_CHARS.charAt((i >> 4) & 0xF)
				result += HEX_CHARS.charAt(i & 0xF) + ':  ' + hex + '    ' + chars + '\n';
			}
			
			return result;
		}
		
	}
}