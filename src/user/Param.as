package user 
{
	
	public class Param extends Object
	{
		public static var LiveID:String;
		public static var RtmpUrl:String;
		public static var Servers:String;
		public static var Serversinfo:Array;
		public static var ServerIp:String;
		public static var ServerPort:int;
		public static var RoomId:String;
		public static var cateId:String;
		public static var Status:Boolean;
		public static var DomainName:String;
		public static var closeFMS:String;
		public static var IsIndex:Boolean;
		public static var ASSET_URL:String;
		public static var PASS_VERIFY:String = "";
		public static var IS_HOSTLIVE:int;
		public static var HAS_PASS:int;
		public static var currentNum:int;
		public static var userId:String;
		public static var ownerId:String;
		public static var usergroupid:String;
		public static var CDN:String = "";
		public static var DOTATALK:String;
		public static var P2P:int = 0;
		public static var isPs:int = 0;
		public static var isLoginUser:Number;
		public static var delayTime:int;
		public static var currentStreamType:int = 0;
		public static var maskObj:Object = null;
		public static var roomLink:String = null;
		public static var isFifteen:Boolean = false;
		public static var swfVersion:String = "";
		public static var adUrl:String;
		public static var plugId:int;
		public static var adServerUrl:String;
		public static var cdnType:int;
		public static var pos:int;
		public static var adState:int;
		public static var liveType:int;
		
		public function Param()
		{
			return;
		}// end function
		
		public static function init(param1:Object) : void
		{
			var _loc_2:int;
			var _loc_3:Object;
			LiveID = param1["LiveID"];
			RtmpUrl = param1["RtmpUrl"];
			Servers = param1["Servers"];
			if (Servers)
			{
				Serversinfo =JSON.parse(Servers).Servers as Array;
				if (Servers && Servers.length != 0)
				{
					_loc_2 = int(Math.random() * 10000) % Serversinfo.length;
					_loc_3 = Serversinfo[_loc_2];
					ServerIp = _loc_3.ip;
					ServerPort = _loc_3.port;
				}
				else
				{
					ServerIp = param1["ServerIp"];
					ServerPort = param1["ServerPort"];
				}
			}
			isLoginUser = param1["uid"];
			RoomId = param1["RoomId"];
			cateId = param1["cate_id"];
			roomLink = param1["room_link"];
			if (!param1["Status"])
			{
			}
			Status = "".toString().toLowerCase() == "true";
			DomainName = param1["DomainName"];
			closeFMS = param1["closeFMS"];
			if (!param1["IsIndex"])
			{
			}
			IsIndex = "".toString().toLowerCase() == "true";
			ASSET_URL = param1["asset_url"];
			CDN = param1["cdn"];
			if (CDN == null)
			{
				CDN = "";
			}
			DOTATALK = param1["show_talk"];
			HAS_PASS = param1.roompass;
			IS_HOSTLIVE = param1.checkowne;
			ownerId = param1.OwnerId;
			usergroupid = param1.usergroupid;
			return;
		}// end function
		
	}
}
