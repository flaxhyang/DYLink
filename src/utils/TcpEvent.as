package utils
{
	import flash.events.Event;
	
	public class TcpEvent extends Event
	{
		public var _param:Object;
		public static var Conneted:String = "STT_TcpClient_Connected";
		public static var Error:String = "STT_TcpClient_Error";
		public static var Closed:String = "STT_TcpClient_Closed";
		public static var RecvMsg:String = "STT_TcpClient_RecvMsg";
		
		public function TcpEvent(param1:String, param2:Object = null, param3:Boolean = false, param4:Boolean = false)
		{
			this._param = param2;
			super(param1, param3, param4);
			return;
		}
	}
}