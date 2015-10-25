package utils
{
	import flash.display.Sprite;

	public class GlobalData
	{
		public static var VIDEOLAYER:Sprite;
		public static var COMMENTLAYER:Sprite;
		public static var EFFECTLAYER:Sprite;
		public static var PALYLAYER:Sprite;
		public static var RECOMMENDLAYER:Sprite;
		public static var TIPLAYER:Sprite;
		public static var LOADLAYER:Sprite;
		public static var LOGINLAYER:Sprite;
		public static var AdLAYER:Sprite;
		public static var PLAYER_VERSION:String = "Douyu.tv_20150906.1";
		public static var VERSION:String = "20150906";
		public static var RECOMMEND_API:String = "/swf_api/recommend_live";
		public static var SHARE_API:String = "/swf_api/room";
		public static var FEEDBACK_API:String = "/api/network_stat_report/report";
		public static const MAX_FPS:int = 60;
//		public static var root:WebRoom;
		public static var isStageVideo:Boolean = false;
		public static var isYouke:int;
		public static var rg:int;
		public static var pg:int;
		public static var chatMaxChars:int = 50;
		public static var isChromeBrowser:Boolean = false;
		public static var textSizeValue:Number = 28;
		public static var textAlphaValue:Number = 0.85;
		public static var offsetUpHeight:int = 0;
		public static var offsetDownHeight:int = 0;
		public static var danmuModel:int = 1;
		public static var rateModel:int = 0;
		public static var hasMultirate:int = 0;
		public static var byteCount:Number = 0;
		public static var distanHeight:int = 42;
		public static var P2PStatus:Boolean = false;
		public static var CDNType:int = 0;
		public static var domainName:String;
		public static var isHSAdOK:Boolean = false;
		public static var isPlayOK:Boolean = false;
		public static var isDebug:Boolean = false;
		public function GlobalData()
		{
		}
	}
}