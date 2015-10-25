package utils
{
	
	public class Encode extends Object
	{
		public var SttString:String = "";
		
		public function Encode()
		{
			return;
		}// end function
		
		public function AddItem(param1:String, param2:String) : void
		{
			var _loc_3:String="";
			_loc_3 = param1 != null ? (this.scan_str(param1) + "@=") : ("");
			this.SttString = this.SttString + (_loc_3 + this.scan_str(param2) + "/");
			return;
		}// end function
		
		public function AddItem_int(param1:String, param2:Number) : void
		{
			var _loc_3:String="";
			_loc_3 = param1 != null ? (this.scan_str(param1) + "@=") : ("");
			this.SttString = this.SttString + (_loc_3 + this.scan_str(param2.toString()) + "/");
			return;
		}// end function
		
		public function Get_SttString() : String
		{
			return this.SttString;
		}// end function
		
		private function scan_str(param1:String) : String
		{
			var _loc_2:String="";
			var _loc_3:int;
			while (_loc_3 < param1.length)
			{
				
				if (param1.charAt(_loc_3) == "/")
				{
					_loc_2 = _loc_2 + "@S";
				}
				else if (param1.charAt(_loc_3) == "@")
				{
					_loc_2 = _loc_2 + "@A";
				}
				else
				{
					_loc_2 = _loc_2 + param1.charAt(_loc_3);
				}
				_loc_3++;
			}
			return _loc_2;
		}// end function
		
	}
}
