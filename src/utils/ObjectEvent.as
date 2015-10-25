package utils
{
	import flash.events.*;
	
	public class ObjectEvent extends Event
	{
		private var _data:Object;
		
		public function ObjectEvent(param1:String, param2:Object = null, param3:Boolean = false, param4:Boolean = false)
		{
			super(param1, param3, param4);
			this._data = param2;
			return;
		}// end function
		
		public function get data() : Object
		{
			return this._data;
		}// end function
		
	}
}