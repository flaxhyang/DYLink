package utils
{
	
	public class Decode extends Object
	{
		public var item:Object;
		public var sItemArray:Array;
		
		public function Decode()
		{
			this.item = new Object();
			this.sItemArray = new Array();
			return;
		}// end function
		
		public function Parse(param1:String) : Array
		{
			if (param1.charAt(param1.length-1) != "/")
			{
				param1 = param1 + "/";
			}
			var _loc_2:String="";
			var _loc_3:String="";
			var _loc_4:int;
			var _loc_5:int;
			while (_loc_5 < param1.length)
			{
				
				if (param1.charAt(_loc_5) == "/")
				{
					this.item = {key:_loc_3, value:_loc_2};
					this.sItemArray[_loc_4] = this.item;
					var _loc_6:String;
					_loc_2 = "";
					_loc_3 = _loc_6;
					_loc_4++;
				}
				else if (param1.charAt(_loc_5) == "@")
				{
					_loc_5++;
					if (param1.charAt(_loc_5) == "A")
					{
						_loc_2 = _loc_2 + "@";
					}
					else if (param1.charAt(_loc_5) == "S")
					{
						_loc_2 = _loc_2 + "/";
					}
					else if (param1.charAt(_loc_5) == "=")
					{
						_loc_3 = _loc_2;
						_loc_2 = "";
					}
				}
				else
				{
					_loc_2 = _loc_2 + param1.charAt(_loc_5);
				}
				_loc_5++;
			}
			return this.sItemArray;
		}// end function
		
		public function GetItem(param1:String) : String
		{
			var _loc_2:String='';
			var _loc_3:int=0;
			while (_loc_3 < this.sItemArray.length)
			{
				
				if (this.sItemArray[_loc_3].key == param1)
				{
					_loc_2 = this.sItemArray[_loc_3].value;
					break;
				}
				_loc_3++;
			}
			return _loc_2;
		}// end function
		
		public function GetItemByIndex(param1:int) : String
		{
			if (param1 < this.sItemArray.length)
			{
				return this.sItemArray[param1].value;
			}
			return null;
		}// end function
		
		public function GetItemAsInt(param1:String) : int
		{
			var _loc_2:int;
			var _loc_3:int;
			while (_loc_3 < this.sItemArray.length)
			{
				
				if (this.sItemArray[_loc_3].key == param1)
				{
					_loc_2 = this.sItemArray[_loc_3].value;
					break;
				}
				_loc_3++;
			}
			return _loc_2;
		}// end function
		
		public function GetItemAsNumber(param1:String) : Number
		{
			var _loc_2:Number;
			var _loc_3:int;
			while (_loc_3 < this.sItemArray.length)
			{
				
				if (this.sItemArray[_loc_3].key == param1)
				{
					_loc_2 = this.sItemArray[_loc_3].value;
					break;
				}
				_loc_3++;
			}
			return _loc_2;
		}// end function
		
	}
}
