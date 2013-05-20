package com.ball.compress {
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;

	/**
	 * Quicklz implement of actionscript
	 * @author Jerry
	 *
	 */
	public class Quicklz {
		private static const HASH_VALUES:int            = 4096;
		private static const DEFAULT_HEADERLEN:int      = 9;
		private static const UNCONDITIONAL_MATCHLEN:int = 6;
		private static const UNCOMPRESSED_END:int       = 4;
		private static const CWORD_LEN:int              = 4;
		private static const MINOFFSET:int              = 2;
		private static const QLZ_POINTERS_1:int         = 1;
		private static const QLZ_POINTERS_3:int         = 16;
		private static const NUM:Number                 = 0x80000000;

		private static var maxMemory:int;

		public function Quicklz() {

		}

		/**
		 * compress method
		 * @param source	target ByteArray
		 * @param level		compress level, fastest compress speed with level 1, fastest uncompress speed with level 3
		 * @return 			compressed ByteArray
		 *
		 */
		public static function compress(source:ByteArray, level:int):ByteArray {

			var src:int               = 0;
			var dst:int               = DEFAULT_HEADERLEN + CWORD_LEN;
			var cword_val:Number      = 0x80000000;
			var cword_ptr:int         = DEFAULT_HEADERLEN;
			var destination:ByteArray = new ByteArray();
			destination.length = source.length + 400;
			var hashtable:Array     = [];
			var cachetable:Array    = new Array(HASH_VALUES);
			var hash_counter:Array  = new Array(HASH_VALUES);
			var d2:ByteArray        = new ByteArray();
			var fetch:int           = 0;
			var last_matchstart:int = source.length - UNCONDITIONAL_MATCHLEN - UNCOMPRESSED_END - 1;
			var lits:int            = 0;

			for (var z:int = 0; z < cachetable.length; z++) {
				cachetable[z] = 0;
			}

			for (var y:int = 0; y < hash_counter.length; y++) {
				hash_counter[y] = 0;
			}

			if (level != 1 && level != 3) {
				throw new Error("Actionscript version only supports level 1 and 3");
			}

			if (level == 1) {
				for (var i:int = 0; i < HASH_VALUES; i++) {
					if (hashtable[i] == null) {
						hashtable[i] = new Array();
					}
					for (var j:int = 0; j < QLZ_POINTERS_1; j++) {
						hashtable[i][j] = 0;
					}
				}
			} else {
				for (var m:int = 0; m < HASH_VALUES; m++) {
					if (hashtable[m] == null) {
						hashtable[m] = new Array();
					}
					for (var n:int = 0; n < QLZ_POINTERS_3; n++) {
						hashtable[m][n] = 0;
					}
				}
			}

			if (source.length == 0) {
				return new ByteArray();
			}

			if (src <= last_matchstart) {
				fetch = fastRead(source, src, 3);
			}

			while (src <= last_matchstart) {
				if(src % 100000 == 0){
					trace("src is " + src + " last match start is " + last_matchstart);
				}

				if ((cword_val & 1) == 1) {
					if (src > 3 * (source.length >> 2) && dst > src - (src >> 5)) {
						//can not compress big file, return original file
						d2.length = source.length + DEFAULT_HEADERLEN;
						writeHeader(d2, level, false, source.length, source.length + DEFAULT_HEADERLEN);
						source.position = 0;
						source.readBytes(d2, DEFAULT_HEADERLEN, source.length);
						return d2;
					}

					fastWrite(destination, cword_ptr, ((cword_val >>> 1) | NUM), 4);
					cword_ptr = dst;
					dst += CWORD_LEN;
					cword_val = NUM;
				}

				if (level == 1) {
					var hash:int  = ((fetch >>> 12) ^ fetch) & (HASH_VALUES - 1);
					var o:int     = hashtable[hash][0];
					var cache:int = cachetable[hash] ^ fetch;

					cachetable[hash] = fetch;
					hashtable[hash][0] = src;

					if ((cache == 0) && (hash_counter[hash] != 0) &&
						((src - o > MINOFFSET) ||
						(src == o + 1 && lits >= 3 && src > 3 && source[src] == source[src - 3] &&
						source[src] == source[src - 2] && source[src] == source[src - 1] &&
						source[src] == source[src + 1] && source[src] == source[src + 2]))) {
						cword_val = ((cword_val >>> 1) | NUM);
						if (source[o + 3] != source[src + 3]) {
							var f:int = 3 - 2 | (hash << 4);
							destination[dst + 0] = (f >>> 0 * 8);
							destination[dst + 1] = (f >>> 1 * 8);
							src += 3;
							dst += 2;
						} else {
							var old_src:int   = src;
							var remaining:int =
								(source.length - UNCOMPRESSED_END - src + 1 - 1) > 255 ? 255 : (source.length - UNCOMPRESSED_END - src + 1 - 1);

							src += 4;
							if (source[o + src - old_src] == source[src]) {
								src++;
								if (source[o + src - old_src] == source[src]) {
									src++;
									while (source[o + (src - old_src)] == source[src] && (src - old_src) < remaining) {
										src++;
									}
								}
							}

							var matchLen:int = src - old_src;

							hash <<= 4;
							if (matchLen < 18) {
								var f1:int = hash | (matchLen - 2);
								destination[dst + 0] = (f1 >>> 0 * 8);
								destination[dst + 1] = (f1 >>> 1 * 8);
								dst += 2;
							} else {
								var f2:int = hash | (matchLen << 16);
								fastWrite(destination, dst, f2, 3);
								dst += 3;
							}
						}
						lits = 0;
						fetch = fastRead(source, src, 3);
					} else {
						lits++;
						hash_counter[hash] = 1;
						destination[dst] = source[src];
						cword_val = (cword_val >>> 1);
						src++;
						dst++;
						fetch = ((fetch >>> 8) & 0xffff) | ((source[src + 2] & 0xff) << 16);
					}
				} else {
					fetch = fastRead(source, src, 3);

					var o2:int;
					var offset2:int;
					var matchLen2:int  = 0;
					var k:int          = 0;
					var m2:int         = 0;
					var best_k:int     = 0;
					var c:int;
					var remaining2:int =
						(source.length - UNCOMPRESSED_END - src + 1 - 1) > 255 ? 255 : (source.length - UNCOMPRESSED_END - src + 1 - 1);
					var hash2:int      = ((fetch >>> 12) ^ fetch) & (HASH_VALUES - 1);

					c = hash_counter[hash2];
					matchLen2 = 0;
					offset2 = 0;

					for (k = 0; k < QLZ_POINTERS_3 && (c > k || c < 0); k++) {
						o2 = hashtable[hash2][k];
						if (fetch == source[o2] && (fetch >>> 8) == source[o2 + 1] &&
							(fetch >>> 16) == source[o2 + 2] && o2 < src - MINOFFSET) {
							m2 = 3;
							while (source[o2 + m2] == source[src + m2] && m2 < remaining2) {
								m2++;
							}

							if (m2 > matchLen2 || (m2 == matchLen2 && o2 > offset2)) {
								offset2 = o2;
								matchLen2 = m2;
								best_k = k;
							}
						}
					}

					o2 = offset2;
					hashtable[hash2][c & (QLZ_POINTERS_3 - 1)] = src;
					c++;
					hash_counter[hash2] = c;

					if (matchLen2 >= 3 && src - o2 < 131071) {
						var offset:int = src - o2;
						for (var u:int = 1; u < matchLen2; u++) {
							fetch = fastRead(source, src + u, 3);
							hash2 = ((fetch >>> 12) ^ fetch) & (HASH_VALUES - 1);
							c = hash_counter[hash2]++;
							hashtable[hash2][c & (QLZ_POINTERS_3 - 1)] = src + u;
						}

						src += matchLen2;
						cword_val = ((cword_val >>> 1) | NUM);

						if (matchLen2 == 3 && offset <= 63) {
							fastWrite(destination, dst, offset << 2, 1);
							dst++;
						} else if (matchLen2 == 3 && offset <= 16383) {
							fastWrite(destination, dst, (offset << 2) | 1, 2);
							dst += 2;
						} else if (matchLen2 <= 18 && offset <= 1023) {
							fastWrite(destination, dst, ((matchLen2 - 3) << 2) | (offset << 6) | 2, 2);
							dst += 2;
						} else if (matchLen2 <= 33) {
							fastWrite(destination, dst, ((matchLen2 - 2) << 2) | (offset << 7) | 3, 3);
							dst += 3;
						} else {
							fastWrite(destination, dst, ((matchLen2 - 3) << 7) | (offset << 15) | 3, 4);
							dst += 4;
						}
					} else {
						destination[dst] = source[src];
						cword_val = (cword_val >>> 1);
						src++;
						dst++;
					}
				}
			}

			while (src <= source.length - 1) {
				if ((cword_val & 1) == 1) {
					fastWrite(destination, cword_ptr, ((cword_val >>> 1) | NUM), 4);
					cword_ptr = dst;
					dst += CWORD_LEN;
					cword_val = NUM;
				}

				destination[dst] = source[src];
				src++;
				dst++;
				cword_val = (cword_val >>> 1);
			}

			while ((cword_val & 1) != 1) {
				cword_val = (cword_val >>> 1);
			}

			fastWrite(destination, cword_ptr, ((cword_val >>> 1) | NUM), CWORD_LEN);
			writeHeader(destination, level, true, source.length, dst);

			destination.position = 0;
			destination.readBytes(d2, 0, dst);
			return d2;
		}

		/**
		 * uncompress method
		 * @param source	target ByteArray
		 * @return 			uncompressed ByteArray
		 *
		 */
		public static function decompress(source:ByteArray):ByteArray {

			var size:int              = sizeDecompressed(source);
			var src:int               = headerLen(source);
			var dst:int               = 0;
			var cword_val:int         = 1;
			var destination:ByteArray = new ByteArray();
			destination.length = size;
			var hashtable:Vector.<int>    = new Vector.<int>(4096);
			var hash_counter:Vector.<int> = new Vector.<int>(4096);
			var last_matchstart:int       = size - UNCONDITIONAL_MATCHLEN - UNCOMPRESSED_END - 1;
			var last_hashed:int           = -1;
			var hash:int;
			var fetch:int                 = 0;

			var level:int                 = (source[0] >>> 2) & 0x3;

			if (level != 1 && level != 3) {
				throw new Error("Actionscript version only supports level 1 and 3");
			}

			//uncompressed ByteArray, return original ByteArray
			if ((source[0] & 1) != 1) {
				var d2:ByteArray = new ByteArray();
				source.position += headerLen(source);
				source.readBytes(d2, 0, size);
				return d2;
			}

			while (true) {
				if (cword_val == 1) {
					cword_val = fastRead(source, src, 4);
					src += 4;
					if (dst <= last_matchstart) {
						if (level == 1) {
							fetch = fastRead(source, src, 3);
						} else {
							fetch = fastRead(source, src, 4);
						}
					}
				}

				if ((cword_val & 1) == 1) {
					var matchLen:int;
					var offset2:int;

					cword_val = cword_val >>> 1;

					if (level == 1) {
						hash = (fetch >>> 4) & 0xFFF;
						offset2 = hashtable[hash];

						if ((fetch & 0xF) != 0) {
							matchLen = (fetch & 0xF) + 2;
							src += 2;
						} else {
							matchLen = source[src + 2] & 0xFF;
							src += 3;
						}
					} else {
						var offset:int;

						if ((fetch & 3) == 0) {
							offset = (fetch & 0xFF) >>> 2;
							matchLen = 3;
							src++;
						} else if ((fetch & 2) == 0) {
							offset = (fetch & 0xFFFF) >>> 2;
							matchLen = 3;
							src += 2;
						} else if ((fetch & 1) == 0) {
							offset = (fetch & 0xFFFF) >>> 6;
							matchLen = ((fetch >>> 2) & 15) + 3;
							src += 2;
						} else if ((fetch & 127) != 3) {
							offset = (fetch >>> 7) & 0x1FFFF;
							matchLen = ((fetch >>> 2) & 0x1F) + 2;
							src += 3;
						} else {
							offset = (fetch >>> 15);
							matchLen = ((fetch >>> 7) & 255) + 3;
							src += 4;
						}
						offset2 = dst - offset;
					}

					destination[dst + 0] = destination[offset2 + 0];
					destination[dst + 1] = destination[offset2 + 1];
					destination[dst + 2] = destination[offset2 + 2];

					for (var i:int = 3; i < matchLen; i++) {
						destination[dst + i] = destination[offset2 + i];
					}
					dst += matchLen;

					if (level == 1) {
						fetch = fastRead(destination, last_hashed + 1, 3);
						while (last_hashed < dst - matchLen) {
							last_hashed++;
							hash = ((fetch >>> 12) ^ fetch) & (HASH_VALUES - 1);
							hashtable[hash] = last_hashed;
							hash_counter[hash] = 1;
							fetch = fetch >>> 8 & 0xffff | (destination[last_hashed + 3] & 0xff) << 16;
						}
						fetch = fastRead(source, src, 3);
					} else {
						fetch = fastRead(source, src, 4);
					}
					last_hashed = dst - 1;
				} else {
					if (dst <= last_matchstart) {
						if (dst % 1000 == 0) {
							maxMemory = (System.totalMemory > maxMemory) ? System.totalMemory : maxMemory;
						}
						destination[dst] = source[src];
						dst++;
						src++;
						cword_val = cword_val >>> 1;

						if (level == 1) {
							while (last_hashed < dst - 3) {
								last_hashed++;
								var fetch2:int = fastRead(destination, last_hashed, 3);
								hash = ((fetch2 >>> 12) ^ fetch2) & (HASH_VALUES - 1);
								hashtable[hash] = last_hashed;
								hash_counter[hash] = 1;
							}
							fetch = fetch >> 8 & 0xffff | (source[src + 2] & 0xff) << 16;
						} else {
							fetch =
								fetch >> 8 & 0xffff | (source[src + 2] & 0xff) << 16 | (source[src + 3] & 0xff) << 24;
						}
					} else {
						while (dst <= size - 1) {
							if (cword_val == 1) {
								src += CWORD_LEN;
								cword_val = NUM;
							}

							destination[dst] = source[src];
							dst++;
							src++;
							cword_val = cword_val >>> 1;
						}
						return destination;
					}
				}
			}

			return destination;
		}

		public static function sizeDecompressed(source:ByteArray):int {
			if (headerLen(source) == 9) {
				return fastRead(source, 5, 4);
			} else {
				return fastRead(source, 2, 1);
			}
		}

		public static function headerLen(source:ByteArray):int {
			var i:int = source[0];
			return ((source[0] & 2) == 2) ? 9 : 3;
		}

		public static function fastRead(a:ByteArray, i:int, numBytes:int):int {
			var l:int = 0;
			for (var j:int = 0; j < numBytes; j++) {
				l |= (((int(a[i + j])) & 0xFF) << j * 8);
			}
			return l;
		}

		public static function writeHeader(dst:ByteArray, level:int, compressible:Boolean, size_compressed:int,
										   size_decompressed:int):void {
			dst[0] = (2 | (compressible ? 1 : 0));
			dst[0] |= (level << 2);
			dst[0] |= (1 << 6);
			dst[0] |= (0 << 4);
			var a:int = dst[0];
			fastWrite(dst, 1, size_decompressed, 4);
			fastWrite(dst, 5, size_compressed, 4);
		}

		public static function fastWrite(a:ByteArray, i:int, value:int, numBytes:int):void {
			for (var j:int = 0; j < numBytes; j++) {
				a[i + j] = (value >>> (j * 8));
			}
		}

	}
}
