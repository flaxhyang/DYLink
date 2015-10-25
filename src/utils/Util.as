package utils
{
	
	import flash.system.Capabilities;

	public class Util
	{
		private static var counter:Number = 0;
		public function Util()
		{
		}
		
		public static function getLoginValidationStr(param1:String, param2:String) : String
		{
			var _loc_3:Array=["1AoZhAnGKao216Yu","dOu2YuchUn3tIan1"];
			//			var _loc_3:Array=["dOu2YuchUn3tIan1"];
			var _loc_4:String= param1 + "" + _loc_3[int(_loc_3.length * Math.random())] + param2;
			//			var _loc_4:String= param1 + "" + _loc_3[0] + param2;
			trace("_loc_4="+_loc_4);
			var _loc_5:* = MD5.hash(_loc_4);
			//			var _loc_5:* =com.adobe.crypto.MD5.hash(_loc_4);
			return _loc_5;
		}// end function
		
		public static function getSecretStr(param1:String,param2:String=null):String{
			var _loc_3:Array=new Array();
			var _loc_4:* = param1 + "" + _loc_3[int(_loc_3.length * Math.random())] + param2;
			var _loc_5:* = MD5.hash(_loc_4);
			return _loc_5;
		}
		
		public static function createGuid() : String
		{
			var _loc_1:* = new Date();
			var _loc_2:* = _loc_1.getTime();
			var _loc_3:* = Math.random() * Number.MAX_VALUE;
			var _loc_4:* = Capabilities.serverString;
			var _loc_5:* = calculate(_loc_2 + _loc_4 + _loc_3 + counter++).toUpperCase();
			var _loc_6:* = _loc_5.substring(0, 8) + "" + _loc_5.substring(8, 12) + "" + _loc_5.substring(12, 16) + "" + _loc_5.substring(16, 20) + "" + _loc_5.substring(20, 32);
			return _loc_6;
		}
		
		
		
		private static function calculate(param1:String) : String
		{
			return hex_sha1(param1);
		}// end function
		
		private static function hex_sha1(param1:String) : String
		{
			return binb2hex(core_sha1(str2binb(param1), param1.length * 8));
		}// end function
		
		private static function core_sha1(param1:Array, param2:Number) : Array
		{
			var _loc_10:Number;
			var _loc_11:Number;
			var _loc_12:Number;
			var _loc_13:Number;
			var _loc_14:Number;
			var _loc_15:Number;
			var _loc_16:Number;
			param1[param2 >> 5] = param1[param2 >> 5] | 128 << 24 - param2 % 32;
			param1[(param2 + 64 >> 9 << 4) + 15] = param2;
			var _loc_3:* = new Array(80);
			var _loc_4:Number;
			var _loc_5:Number;
			var _loc_6:Number;
			var _loc_7:Number;
			var _loc_8:Number;
			var _loc_9:Number;
			while (_loc_9 < param1.length)
			{
				
				_loc_10 = _loc_4;
				_loc_11 = _loc_5;
				_loc_12 = _loc_6;
				_loc_13 = _loc_7;
				_loc_14 = _loc_8;
				_loc_15 = 0;
				while (_loc_15++ < 80)
				{
					
					if (_loc_15 < 16)
					{
						_loc_3[_loc_15] = param1[_loc_9 + _loc_15];
					}
					else
					{
						_loc_3[_loc_15] = rol(_loc_3[_loc_15 - 3] ^ _loc_3[_loc_15 - 8] ^ _loc_3[_loc_15 - 14] ^ _loc_3[_loc_15 - 16], 1);
					}
					_loc_16 = safe_add(safe_add(rol(_loc_4, 5), sha1_ft(_loc_15, _loc_5, _loc_6, _loc_7)), safe_add(safe_add(_loc_8, _loc_3[_loc_15]), sha1_kt(_loc_15)));
					_loc_8 = _loc_7;
					_loc_7 = _loc_6;
					_loc_6 = rol(_loc_5, 30);
					_loc_5 = _loc_4;
					_loc_4 = _loc_16;
				}
				_loc_4 = safe_add(_loc_4, _loc_10);
				_loc_5 = safe_add(_loc_5, _loc_11);
				_loc_6 = safe_add(_loc_6, _loc_12);
				_loc_7 = safe_add(_loc_7, _loc_13);
				_loc_8 = safe_add(_loc_8, _loc_14);
				_loc_9 = _loc_9 + 16;
			}
			return new Array(_loc_4, _loc_5, _loc_6, _loc_7, _loc_8);
		}// end function
		
		private static function sha1_ft(param1:Number, param2:Number, param3:Number, param4:Number) : Number
		{
			if (param1 < 20)
			{
				return param2 & param3 | ~param2 & param4;
			}
			if (param1 < 40)
			{
				return param2 ^ param3 ^ param4;
			}
			if (param1 < 60)
			{
				return param2 & param3 | param2 & param4 | param3 & param4;
			}
			return param2 ^ param3 ^ param4;
		}// end function
		
		private static function sha1_kt(param1:Number) : Number
		{
			return param1 < 20 ? (1518500249) : (param1 < 40 ? (1859775393) : (param1 < 60 ? (-1894007588) : (-899497514)));
		}// end function
		
		private static function safe_add(param1:Number, param2:Number) : Number
		{
			var _loc_3:* = (param1 & 65535) + (param2 & 65535);
			var _loc_4:* = (param1 >> 16) + (param2 >> 16) + (_loc_3 >> 16);
			return _loc_4 << 16 | _loc_3 & 65535;
		}// end function
		
		private static function rol(param1:Number, param2:Number) : Number
		{
			return param1 << param2 | param1 >>> 32 - param2;
		}// end function
		
		private static function str2binb(param1:String) : Array
		{
			var _loc_2:* = new Array();
			var _loc_4:Number;
			while (_loc_4 < param1.length * 8)
			{
				
				_loc_2[_loc_4 >> 5] = _loc_2[_loc_4 >> 5] | (param1.charCodeAt(_loc_4 / 8) & (1 << 8)-1) << 24 - _loc_4 % 32;
				_loc_4 = _loc_4 + 8;
			}
			return _loc_2;
		}// end function
		
		private static function binb2hex(param1:Array) : String
		{
			var _loc_2:* = new String("");
			var _loc_3:* = new String("0123456789abcdef");
			var _loc_4:Number;
			while (_loc_4++ < param1.length * 4)
			{
				
				_loc_2 = _loc_2 + (_loc_3.charAt(param1[_loc_4 >> 2] >> (3 - _loc_4 % 4) * 8 + 4 & 15) + _loc_3.charAt(param1[_loc_4 >> 2] >> (3 - _loc_4 % 4) * 8 & 15));
			}
			return _loc_2;
		}// end function
		
		public static function facereplace(param1:String) : String
		{
			var _loc_5:String;
			var _loc_2:* = new Array("good", "kiss", "drop", "fil", "grief", "badluck", "indecent", "kiss", "laugh", "lovely", "rage", "scare", "sleep", "trick", "awesome", "snicker", "doubt", "guise", "sorry", "nosebleed", "moving", "grimace", "laughing", "revel", "excited", "dizzy", "bye", "up", "a", "dzt", "js", "kx", "uccu", "wy", "dyfn", "dyw", "dyhp", "dycy", "dylb", "dyjj", "dydoge", "dylyl", "dyhc", "dytk", "dysyw");
			var _loc_3:* = _loc_2.length;
			var _loc_4:int;
			while (_loc_4 < _loc_3)
			{
				
				_loc_5 = "\\[emot:" + _loc_2[_loc_4] + "\\]";
				param1 = param1.replace(new RegExp(_loc_5, "g"), "");
				_loc_4++;
			}
			param1 = param1.replace(new RegExp("\\s", "g"), " ");
			return param1;
		}// end function
		
		
	}
}