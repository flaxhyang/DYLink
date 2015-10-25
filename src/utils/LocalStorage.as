package utils
{
	import flash.net.SharedObject;

	public class LocalStorage
	{
		public static const VOLUME_NUMBER:String = "volumeNumber";
		private static var _so:SharedObject = SharedObject.getLocal("acDouyu", "/");
		
		public function LocalStorage()
		{
			return;
		}// end function
		
		public static function getValue(param1:String, param2:String = null):String
		{
			if (_so.data[param1] != null)
			{
				return _so.data[param1];
			}
			return param2;
		}// end function
		
		public static function setValue(param1:String, param2) : void
		{
			if (_so.data[param1] != param2)
			{
				_so.data[param1] = param2;
				_so.flush();
			}
			return;
		}// end function
	}
}