package net
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import user.Param;
	import user.RoomUser;
	
	import utils.Decode;
	import utils.Encode;
	import utils.EventCenter;
	import utils.GlobalData;
	import utils.LocalStorage;
	import utils.TcpEvent;
	import utils.Util;
	
	public class Client extends Object
	{
		public var _conn:TcpClient;
		public var barrage_Conn:ClientBarrage;
		public var dispatcher:EventDispatcher;
		public var my_uid:int;
		public var my_username:String;
		public var my_nickname:String;
		public var my_roomgroup:int;
		public var roomId:int;
		public var keep_online:int = 0;
		private var myTimer:Timer;
		private var cacheTimer:Timer;
		private var per_keep_live:int = 45;
		private var per_cachedata:int = 60;
		private var serialnum:int = 0;
		private var user_count:int = 0;
		public var users:Vector.<RoomUser>;
		public var admins:Vector.<RoomUser>;
		public var users100_sort:Vector.<RoomUser>;
		public var admins_sort:Vector.<RoomUser>;
		public var serverArray:Array;
		public var myblacklist:Array;
		private var _OnConn:Function;
		private var endTimeIndex0:uint;
		private var endError:String;
		private var reloadTimeIndex:uint;
		private var endTimeIndex:uint;
		private var endStr:String;
		
		public var reserviceMsg:Function;
		public var giftMsg:Function;
		public var dmLinkOk:Function;
		public var welcomeFun:Function;
		
		public function Client()
		{
			this._conn = new TcpClient();
			this.dispatcher = new EventDispatcher();
			this.users = new Vector.<RoomUser>;
			this.admins = new Vector.<RoomUser>;
			this.users100_sort = new Vector.<RoomUser>;
			this.admins_sort = new Vector.<RoomUser>;
			this.serverArray = new Array();
			this.myblacklist = new Array();
			
			return;
		}
		
		public function ConnectServer(param1:String, param2:int, param3:Function) : void
		{
			////$.jscall("console.log", "string is [%s]", "ConnectServer");
			this._OnConn = param3;
			if (this._conn == null)
			{
				return;
			}
			this._conn.connect(param1, param2);
			this._conn.addEventListener(TcpEvent.Conneted, param3, false, 0, true);
			this._conn.addEventListener(TcpEvent.RecvMsg, this.ParseMsg, false, 0, true);
			return;
		}// end function
		
		
		public function UserLogin2() : void
		{
			//			猫小胖杂货
			var username:* ="auto_9eGzX1quua";
			var password:* ="76385d18e7b38e8f6b229ff14bddf4be";
			
			//var username:* ="auto_zo7QX4VmlX";
			//var password:* ="25f9e794323b453885f5181f1b624d0b";
			
//			var username:* ="";
//			var password:* ="";
			this.roomId =int(Param.RoomId);
			
			
			var _loc_6:* = new Encode();
			_loc_6.AddItem("type", "loginreq");
			_loc_6.AddItem("username", username);
			_loc_6.AddItem("password", password);
			_loc_6.AddItem("roompass", Param.PASS_VERIFY);
			_loc_6.AddItem_int("roomid",this.roomId);
			
			var _loc_7:String="";
			if (_loc_7 == "")
			{
				_loc_7 = Util.createGuid();
				
				LocalStorage.setValue("GUID",_loc_7);
			}
			_loc_6.AddItem("devid",_loc_7);
			var _loc_8:* = new Date();
			var _loc_9:int =int( _loc_8.time / 1000);
			var _loc_10:* = Util.getLoginValidationStr(String(_loc_9),_loc_7);
			
			_loc_6.AddItem("rt",_loc_9 +"");
			_loc_6.AddItem("vk",_loc_10);
			var _loc_11:* = _loc_6.Get_SttString();
			this._conn.sendmsg(_loc_11);
			return;
		}
		
		public function UserLogin(nun:int) : void
		{
			var _loc_2:* = new Decode();
			//var _loc_4:* = _loc_2.GetItem("username");
			//var _loc_5:* = _loc_2.GetItem("password");
			//this.roomId = _loc_2.GetItemAsInt("roomid");
			
			
			//var username:* ="auto_zo7QX4VmlX";
			//var password:* ="25f9e794323b453885f5181f1b624d0b";
			
			//猫小胖
			var username:* ="auto_9eGzX1quua";
			var password:* ="76385d18e7b38e8f6b229ff14bddf4be";
			
//			var username:* ="";
//			var password:* ="";
			this.roomId =int(Param.RoomId);
			
			var _loc_6:* = new Encode();
			_loc_6.AddItem("type", "loginreq");
			_loc_6.AddItem("username", username);
			_loc_6.AddItem("password", password);
			_loc_6.AddItem("roompass", Param.PASS_VERIFY);
			_loc_6.AddItem_int("roomid", this.roomId);
			var _loc_7:* = LocalStorage.getValue("GUID", "");
			if (_loc_7 == "")
			{
				_loc_7 = Util.createGuid();
//				LocalStorage.setValue("GUID", _loc_7+nun);
				LocalStorage.setValue("GUID", _loc_7+nun);
			}
			_loc_6.AddItem("devid", _loc_7);
			var _loc_8:* = new Date();
			var _loc_9:* = _loc_8.time / 1000;
			
			var _loc_10:* = Util.getSecretStr(_loc_9 + "&" + _loc_7);
			
			_loc_6.AddItem("rt", _loc_9 + "");
			_loc_6.AddItem("vk", _loc_10);
			_loc_6.AddItem("ver", GlobalData.VERSION);
			var _loc_11:* = _loc_6.Get_SttString();
			//$.jscall("console.log", "urlgreq is [%s]", _loc_11);
			var _loc_12:* = new Encode();
			_loc_12.AddItem("devid", _loc_7);
			_loc_12.AddItem("rt", _loc_8.time + "");
			//Util.getLoginValidationStr(this.roomId + "&" + _loc_7 + _loc_8.time, "1");
			var _loc_13:* = Util.getSecretStr(this.roomId + "&" + _loc_7 + _loc_8.time, "1");
			_loc_12.AddItem("adv", _loc_13);
			//$.jscall("ad_obj.get_device_id", _loc_12.Get_SttString());
			if (this._conn == null)
			{
				return;
			}
			this._conn.sendmsg(_loc_11);
			return;
		}// end function
		
		public function UserLogout() : void
		{
			//$.jscall("console.log", "urlo[%s]", 1111);
			var _loc_1:* = new Encode();
			_loc_1.AddItem("type", "logout");
			var _loc_2:* = _loc_1.Get_SttString();
			if (this._conn != null)
			{
				this._conn.sendmsg(_loc_2);
			}
			this.clean_conn_timer();
			return;
		}// end function
		
		public function SendChatContent(param1:String) : void
		{
			var s:String='content@='+param1+'/scope@=/col@=/receiver@=/sender@=13198534/';
			var _loc_9:Encode;
			var _loc_10:String;
			var _loc_11:Encode;
			var _loc_12:String;
			//$.jscall("console.log", "jscc[%s]", param1);
			var _loc_2:Array = new Array();
			var _loc_3:Decode = new Decode();
			_loc_2 = _loc_3.Parse(s);
			var _loc_4:* = _loc_3.GetItemAsInt("sender");
			var _loc_5:* = _loc_3.GetItemAsInt("receiver");
			var _loc_6:* = _loc_3.GetItem("content");
			var _loc_7:* = _loc_3.GetItem("scope");
			var _loc_8:* = _loc_3.GetItemAsInt("col");
			if (!this.black_word(_loc_6))
			{
				_loc_9 = new Encode();
				_loc_9.AddItem("type", "chatmessage");
				_loc_9.AddItem_int("receiver", _loc_5);
				_loc_9.AddItem("content", _loc_6);
				_loc_9.AddItem("scope", _loc_7);
				_loc_9.AddItem_int("col", _loc_8);
				_loc_10 = _loc_9.Get_SttString();
				//$.jscall("console.log", "scc[%s]", _loc_10);
				if (this._conn == null)
				{
					return;
				}
				this._conn.sendmsg(_loc_10);
			}
			else
			{
				_loc_11 = new Encode();
				_loc_11.AddItem("type", "error");
				_loc_11.AddItem_int("code", 60);
				_loc_12 = _loc_11.Get_SttString();
				//$.jscall("console.log", "server_error [%s]", _loc_12);
				//$.jscall("server_error", _loc_12);
			}
			return;
		}// end function
		
		public function KeepLive(param1:TimerEvent = null) : void
		{
			var _loc_2:Encode;
			var _loc_3:Date;
			var _loc_4:int;
			var _loc_5:String;
			var _loc_6:String;
			if (this._conn != null)
			{
				_loc_2 = new Encode();
				_loc_2.AddItem("type", "keeplive");
				_loc_3 = new Date();
				_loc_4 = _loc_3.time / 1000;
				_loc_5 = Util.getSecretStr(_loc_4 + "&" + GlobalData.byteCount, "3");
				_loc_2.AddItem_int("tick", _loc_4);
				_loc_2.AddItem_int("vbw", GlobalData.byteCount);
				_loc_2.AddItem_int("cdn", GlobalData.CDNType);
				_loc_2.AddItem("k", _loc_5);
				_loc_6 = _loc_2.Get_SttString();
				this._conn.sendmsg(_loc_6);
				//$.jscall("console.log", "time=" + getTimer());
			}
			return;
		}// end function
		
		public function RoomRefresh(param1:TimerEvent) : void
		{
			if (this._conn == null)
			{
				return;
			}
			var _loc_2:* = new Encode();
			_loc_2.AddItem("type", "roomrefresh");
			_loc_2.AddItem_int("serialnum", this.serialnum);
			var _loc_3:* = _loc_2.Get_SttString();
			this._conn.sendmsg(_loc_3);
			return;
		}// end function
		
		public function SetAdmin(param1:String) : void
		{
			if (this._conn == null)
			{
				return;
			}
			var _loc_2:* = new Array();
			var _loc_3:* = new Decode();
			_loc_2 = _loc_3.Parse(param1);
			var _loc_4:* = _loc_3.GetItemAsInt("userid");
			var _loc_5:* = _loc_3.GetItemAsInt("group");
			var _loc_6:* = new Encode();
			_loc_6.AddItem("type", "setadminreq");
			_loc_6.AddItem_int("userid", _loc_4);
			_loc_6.AddItem_int("group", _loc_5);
			var _loc_7:* = _loc_6.Get_SttString();
			this._conn.sendmsg(_loc_7);
			return;
		}// end function
		
		public function BlackUser(param1:String) : void
		{
			if (this._conn == null)
			{
				return;
			}
			//$.jscall("console.log", "js_BlackUser [%s]", param1);
			var _loc_2:* = new Array();
			var _loc_3:* = new Decode();
			_loc_2 = _loc_3.Parse(param1);
			var _loc_4:* = _loc_3.GetItemAsInt("userid");
			var _loc_5:* = _loc_3.GetItemAsInt("blacktype");
			var _loc_6:* = _loc_3.GetItemAsInt("limittime");
			var _loc_7:* = new Encode();
			_loc_7.AddItem("type", "blackreq");
			_loc_7.AddItem_int("userid", _loc_4);
			_loc_7.AddItem_int("blacktype", _loc_5);
			_loc_7.AddItem_int("limittime", _loc_6);
			var _loc_8:* = _loc_7.Get_SttString();
			this._conn.sendmsg(_loc_8);
			return;
		}// end function
		
		public function SendByteCount(param1:Number) : void
		{
			if (this._conn == null)
			{
				return;
			}
			var _loc_2:* = new Encode();
			_loc_2.AddItem("type", "vbwr");
			_loc_2.AddItem_int("vbw", param1);
			_loc_2.AddItem_int("rid", this.roomId);
			var _loc_3:* = _loc_2.Get_SttString();
			this._conn.sendmsg(_loc_3);
			return;
		}// end function
		
		public function SendEmptyOrFullCount(param1:int, param2:int, param3:String, param4:int) : void
		{
			if (this._conn == null)
			{
				return;
			}
			var _loc_5:* = new Encode();
			_loc_5.AddItem("type", "ssr");
			_loc_5.AddItem_int("ec", param1);
			_loc_5.AddItem_int("fc", param2);
			_loc_5.AddItem("surl", param3);
			_loc_5.AddItem("cdn", Param.CDN);
			_loc_5.AddItem_int("isp2p", param4);
			var _loc_6:* = _loc_5.Get_SttString();
			this._conn.sendmsg(_loc_6);
			return;
		}// end function
		
		public function MyBlackList(param1:String) : void
		{
			this.myblacklist = param1.split("|");
			//$.jscall("console.log", "handIn_blacklist [%s]", param1);
			return;
		}// end function
		
		public function givePresent(param1:String) : void
		{
			if (this._conn == null)
			{
				return;
			}
			var _loc_2:* = new Decode();
			_loc_2.Parse(param1);
			var _loc_3:* = _loc_2.GetItemAsInt("mg");
			var _loc_4:* = _loc_2.GetItemAsInt("ms");
			var _loc_5:* = new Encode();
			_loc_5.AddItem("type", "donatereq");
			_loc_5.AddItem_int("mg", _loc_3);
			_loc_5.AddItem_int("ms", _loc_4);
			var _loc_6:* = _loc_5.Get_SttString();
			this._conn.sendmsg(_loc_6);
			//$.jscall("console.log", "赠送鱼丸请求");
			return;
		}// end function
		
		public function giveGift(param1:String) : void
		{
			if (this._conn == null)
			{
				return;
			}
			var _loc_2:* = new Decode();
			_loc_2.Parse(param1);
			var _loc_3:* = _loc_2.GetItemAsInt("gfid");
			var _loc_4:* = _loc_2.GetItemAsInt("num");
			var _loc_5:* = new Encode();
			_loc_5.AddItem("type", "sgq");
			_loc_5.AddItem_int("gfid", _loc_3);
			_loc_5.AddItem_int("num", _loc_4);
			var _loc_6:* = _loc_5.Get_SttString();
			this._conn.sendmsg(_loc_6);
			//$.jscall("console.log", "zsgreq");
			return;
		}// end function
		
		public function queryTask() : void
		{
			if (this._conn == null)
			{
				return;
			}
			var _loc_1:* = new Encode();
			_loc_1.AddItem("type", "qtlq");
			var _loc_2:* = _loc_1.Get_SttString();
			this._conn.sendmsg(_loc_2);
			//$.jscall("console.log", "qtq2");
			return;
		}// end function
		
		public function queryTaskNum() : void
		{
			if (this._conn == null)
			{
				return;
			}
			var _loc_1:* = new Encode();
			_loc_1.AddItem("type", "qtlnq");
			var _loc_2:* = _loc_1.Get_SttString();
			this._conn.sendmsg(_loc_2);
			//$.jscall("console.log", "qtq1");
			return;
		}// end function
		
		public function obtainTask(param1:String) : void
		{
			if (this._conn == null)
			{
				return;
			}
			var _loc_2:* = new Decode();
			_loc_2.Parse(param1);
			var _loc_3:* = _loc_2.GetItemAsInt("tid");
			var _loc_4:* = new Encode();
			_loc_4.AddItem("type", "gftq");
			_loc_4.AddItem_int("tid", _loc_3);
			var _loc_5:* = _loc_4.Get_SttString();
			this._conn.sendmsg(_loc_5);
			//$.jscall("console.log", "领取任务请求");
			return;
		}// end function
		
		public function setKeytitles(param1:String) : void
		{
			if (this._conn == null)
			{
				return;
			}
			var _loc_2:* = new Decode();
			_loc_2.Parse(param1);
			var _loc_3:* = _loc_2.GetItemAsInt("userid");
			var _loc_4:* = _loc_2.GetItem("username");
			var _loc_5:* = _loc_2.GetItem("reason");
			var _loc_6:* = new Encode();
			_loc_6.AddItem("type", "gbm");
			_loc_6.AddItem_int("uid", _loc_3);
			_loc_6.AddItem("uname", _loc_4);
			_loc_6.AddItem("reason", _loc_5);
			var _loc_7:* = _loc_6.Get_SttString();
			this._conn.sendmsg(_loc_7);
			//$.jscall("console.log", "keytitle =userid" + _loc_3 + "   uname=" + _loc_4 + "  reason=" + _loc_5);
			return;
		}// end function
		
		public function setReportBarrage(param1:String) : void
		{
			if (this._conn == null)
			{
				return;
			}
			var _loc_2:* = new Decode();
			_loc_2.Parse(param1);
			var _loc_3:* = _loc_2.GetItemAsInt("suid");
			var _loc_4:* = _loc_2.GetItemAsInt("rid");
			var _loc_5:* = _loc_2.GetItem("chatmsgid");
			var _loc_6:* = new Encode();
			_loc_6.AddItem("type", "chatmsgrep");
			_loc_6.AddItem_int("suid", _loc_3);
			_loc_6.AddItem_int("rid", _loc_4);
			_loc_6.AddItem("chatmsgid", _loc_5);
			var _loc_7:* = _loc_6.Get_SttString();
			this._conn.sendmsg(_loc_7);
			return;
		}// end function
		
		public function requestRewardList() : void
		{
			if (this._conn == null)
			{
				return;
			}
			var _loc_1:* = new Encode();
			_loc_1.AddItem("type", "qrl");
			_loc_1.AddItem("rid", Param.RoomId);
			var _loc_2:* = _loc_1.Get_SttString();
			this._conn.sendmsg(_loc_2);
			//$.jscall("console.log", "酬勤榜单请求");
			return;
		}// end function
		
		public function emailNotifyResponse(param1:String) : void
		{
			if (this._conn == null)
			{
				return;
			}
			var _loc_2:* = new Decode();
			_loc_2.Parse(param1);
			var _loc_3:* = _loc_2.GetItem("mid");
			var _loc_4:* = new Encode();
			_loc_4.AddItem("type", "mailnewres");
			_loc_4.AddItem("mid", _loc_3);
			var _loc_5:* = _loc_4.Get_SttString();
			this._conn.sendmsg(_loc_5);
			//$.jscall("console.log", "私信回执 ");
			return;
		}// end function
		
		public function queryGiftPkg(param1:String) : void
		{
			if (this._conn == null)
			{
				return;
			}
			this._conn.sendmsg(param1);
			//$.jscall("console.log", "查询礼包信息 =" + param1);
			return;
		}// end function
		
		public function dmodelNotify(param1:int) : void
		{
			if (this._conn == null)
			{
				return;
			}
			var _loc_2:* = new Encode();
			_loc_2.AddItem("type", "jfdg");
			_loc_2.AddItem_int("op", param1);
			var _loc_3:* = _loc_2.Get_SttString();
			this._conn.sendmsg(_loc_3);
			//$.jscall("console.log", "dmcnotify");
			return;
		}// end function
		
		public function superDanmuClickReq(param1:Object) : void
		{
			if (this._conn == null)
			{
				return;
			}
			var _loc_2:* = new Encode();
			_loc_2.AddItem("type", "sdcr");
			_loc_2.AddItem_int("rid", param1.crid);
			_loc_2.AddItem_int("sdid", param1.did);
			_loc_2.AddItem_int("trid", param1.nrid);
			_loc_2.AddItem_int("uid", this.my_uid);
			_loc_2.AddItem("content", param1.supercontent);
			var _loc_3:* = LocalStorage.getValue("GUID", "");
			if (_loc_3 == "")
			{
				_loc_3 = Util.createGuid();
				LocalStorage.setValue("GUID", _loc_3);
			}
			_loc_2.AddItem("did", _loc_3);
			var _loc_4:* = _loc_2.Get_SttString();
			this._conn.sendmsg(_loc_4);
			//$.jscall("console.log", "sdmcount");
			return;
		}// end function
		
		public function jsSuperDanmuClickReq(param1:String) : void
		{
			if (this._conn == null)
			{
				return;
			}
			var _loc_2:* = new Decode();
			_loc_2.Parse(param1);
			var _loc_3:* = _loc_2.GetItemAsInt("sdid");
			var _loc_4:* = _loc_2.GetItemAsInt("trid");
			var _loc_5:* = _loc_2.GetItem("content");
			var _loc_6:* = _loc_2.GetItemAsInt("rid");
			var _loc_7:* = _loc_2.GetItemAsInt("uid");
			var _loc_8:* = new Encode();
			_loc_8.AddItem("type", "sdcr");
			_loc_8.AddItem_int("rid", _loc_6);
			_loc_8.AddItem_int("sdid", _loc_3);
			_loc_8.AddItem_int("trid", _loc_4);
			_loc_8.AddItem_int("uid", this.my_uid);
			_loc_8.AddItem("content", _loc_5);
			var _loc_9:* = LocalStorage.getValue("GUID", "");
			if (_loc_9 == "")
			{
				_loc_9 = Util.createGuid();
				LocalStorage.setValue("GUID", _loc_9);
			}
			_loc_8.AddItem("did", _loc_9);
			var _loc_10:* = _loc_8.Get_SttString();
			this._conn.sendmsg(_loc_10);
			//$.jscall("console.log", "sdmcount1");
			return;
		}// end function
		
		public function hbRequest(param1:String) : void
		{
			if (this._conn == null)
			{
				return;
			}
			var _loc_2:* = new Decode();
			_loc_2.Parse(param1);
			var _loc_3:* = _loc_2.GetItemAsInt("gid");
			var _loc_4:* = _loc_2.GetItemAsInt("uid");
			var _loc_5:* = _loc_2.GetItem("unk");
			var _loc_6:* = new Encode();
			_loc_6.AddItem("type", "ggbq");
			_loc_6.AddItem_int("gid", _loc_3);
			_loc_6.AddItem_int("uid", _loc_4);
			_loc_6.AddItem("content", _loc_5);
			var _loc_7:* = _loc_6.Get_SttString();
			this._conn.sendmsg(_loc_7);
			//$.jscall("console.log", "hbq");
			return;
		}// end function
		
		public function roomSignUp() : void
		{
			if (this._conn == null)
			{
				return;
			}
			var _loc_1:* = new Encode();
			_loc_1.AddItem("type", "signinq");
			var _loc_2:* = _loc_1.Get_SttString();
			this._conn.sendmsg(_loc_2);
			//$.jscall("console.log", "房间签到请求");
			return;
		}// end function
		
		private function ParseMsg(param1:TcpEvent) : void
		{
			var _loc_2:* = new Decode();
			_loc_2.Parse(param1._param as String);
			var _loc_3:* = _loc_2.GetItem("type");
			if (_loc_3 != "keeplive" && _loc_3 != "chatmessage")
			{
				//$.jscall("console.log", "网络数据 [%s]", param1._param as String);
			}
			if (_loc_3 == "loginres")
			{
				this.ServerLoginInfo(_loc_2);
				this.reqOnlineGift();
				this.KeepLive();
				EventCenter.dispatch("login", {code:0});
			}
			else if (_loc_3 == "sui")
			{
				this.ServerUserInfoContent(_loc_2);
			}
			else if (_loc_3 == "chatmessage")
			{
				this.ServerChatContent(_loc_2);
			}
			else if (_loc_3 == "keeplive")
			{
				this.ServerKeepLive(_loc_2);
			}
			else if (_loc_3 == "setadminres")
			{
				this.ServerSetAdmin(_loc_2);
			}
			else if (_loc_3 == "blackres")
			{
				this.ServerBlackUser(_loc_2);
			}
			else if (_loc_3 == "roomrefresh")
			{
				this.ServerRoomRefresh(_loc_2);
			}
			else if (_loc_3 == "error")
			{
				this.ServerError(_loc_2);
			}
			else if (_loc_3 == "rss")
			{
				this.ServerShowStatus(_loc_2);
			}
			else if (_loc_3 == "msgrepeaterlist")
			{
				this.ServerRepeaterlist(_loc_2);
			}
			else if (_loc_3 == "setmsggroup")
			{
				this.ServerSetGroup(_loc_2);
			}
			else if (_loc_3 == "joingroup")
			{
				this.ServerJoinGroup(_loc_2);
			}
			else if (_loc_3 == "rsm")
			{
				this.systemBroadcast(_loc_2);
			}
			else if (_loc_3 == "donateres")
			{
				this.fishPresent(_loc_2);
			}
			else if (_loc_3 == "qtlr")
			{
				this.taskList(_loc_2);
			}
			else if (_loc_3 == "qtlnr")
			{
				this.taskNum(_loc_2);
			}
			else if (_loc_3 == "gftr")
			{
				this.obtainTaskRes(_loc_2);
			}
			else if (_loc_3 == "signinr")
			{
				this.roomSignUpRes(_loc_2);
			}
			else if (_loc_3 == "online_gift_info_res")
			{
				this.onlineGiftRes(_loc_2);
			}
			else if (_loc_3 == "gbmres")
			{
				this.keyTitlesRes(_loc_2);
			}
			else if (_loc_3 == "rdr")
			{
			}
			else if (_loc_3 == "scl")
			{
			}
			else if (_loc_3 == "common_call")
			{
				this.baoXuetime(_loc_2);
			}
			else if (_loc_3 == "chatmsgrep")
			{
				this.reportBarrage(_loc_2);
			}
			else if (_loc_3 == "adminnotify")
			{
				this.identityChange(_loc_2);
			}
			else if (_loc_3 == "ranklist")
			{
				this.rewardListResponse(_loc_2);
			}
			else if (_loc_3 == "mailnewreq")
			{
				this.emailNotify(_loc_2);
			}
			else if (_loc_3 == "gb")
			{
				this.updateYC(_loc_2);
			}
			else if (_loc_3 == "memberinfores")
			{
				this.roomInfoRes(param1._param as String);
			}
			else if (_loc_3 == "qgpi_rsp")
			{
				this.giftPkgRes(param1._param as String);
			}
			else if (_loc_3 == "dsgr")
			{
				this.giveFishBallres(param1._param as String);
			}
			else if (_loc_3 == "refresh_flash")
			{
				return;
			}
			return;
		}// end function
		
		private function ServerLoginInfo(param1:Decode) : void
		{
			var _loc_2:* = param1.GetItemAsInt("userid");
			var _loc_3:* = param1.GetItem("username");
			var _loc_4:* = param1.GetItem("nickname");
			var _loc_5:* = param1.GetItemAsInt("roomgroup");
			var _loc_6:* = param1.GetItemAsInt("sessionid");
			var _loc_7:* = param1.GetItemAsInt("is_signined");
			var _loc_8:* = param1.GetItemAsInt("signin_count");
			var _loc_9:* = param1.GetItemAsInt("pg");
			var _loc_10:* = param1.GetItemAsInt("live_stat");
			var _loc_11:* = param1.GetItemAsInt("npv");
			var _loc_12:* = param1.GetItemAsInt("best_dlev");
			var _loc_13:* = param1.GetItemAsInt("cur_lev");
			Param.isPs = _loc_11;
			if (_loc_10 == 0 && Param.Status)
			{
				this.dispatcher.dispatchEvent(new Event("ServerShowStatus"));
				//$.jscall("remind_obj.clear_allwatch_show");
			}
			this.my_uid = _loc_2;
			Param.userId = this.my_uid.toString();
			this.my_username = _loc_3;
			this.my_nickname = _loc_4;
			this.my_roomgroup = _loc_5;
			GlobalData.isYouke = this.my_roomgroup;
			GlobalData.rg = _loc_5;
			GlobalData.pg = _loc_9;
			if (GlobalData.isYouke == 0)
			{
				Param.userId = "0";
			}
			var _loc_14:* = new Encode();
			_loc_14.AddItem_int("userid", _loc_2);
			_loc_14.AddItem("nickname", _loc_4);
			_loc_14.AddItem_int("is_signined", _loc_7);
			_loc_14.AddItem_int("signin_count", _loc_8);
			_loc_14.AddItem_int("roomgroup", this.my_roomgroup);
			_loc_14.AddItem_int("pg", _loc_9);
			_loc_14.AddItem_int("best_dlev", _loc_12);
			_loc_14.AddItem_int("cur_lev", _loc_13);
			var _loc_15:* = _loc_14.Get_SttString();
			//$.jscall("console.log", "isYouke =" + GlobalData.isYouke + "   live_stat =" + _loc_10 + "   roomgroup =" + _loc_5 + " npv =" + _loc_11 + "&& return_tourist", _loc_15);
			//$.jscall("return_tourist", _loc_15);
			var _loc_16:* = new Encode();
			_loc_16.AddItem_int("npv", _loc_11);
			//$.jscall("isshow_chat", _loc_16.Get_SttString());
			if (this.myTimer == null)
			{
				this.myTimer = new Timer(this.per_keep_live * 1000, 0);
				this.myTimer.addEventListener(TimerEvent.TIMER, this.KeepLive, false, 0, true);
				this.myTimer.start();
			}
			else
			{
				this.myTimer.reset();
				this.myTimer.start();
			}
			EventCenter.dispatch("userRGEvent", null);
			return;
		}// end function
		
		public function reqOnlineGift() : void
		{
			var _loc_1:Encode;
			var _loc_2:String;
			if (this._conn == null)
			{
				return;
			}
			if (GlobalData.isYouke != 0)
			{
				_loc_1 = new Encode();
				_loc_1.AddItem("type", "online_gift_info_req");
				_loc_1.AddItem_int("uid", this.my_uid);
				_loc_2 = _loc_1.Get_SttString();
				this._conn.sendmsg(_loc_2);
				//$.jscall("console.log", "在线宝箱请求 ");
			}
			return;
		}// end function
		
		private function presonalInfoReq() : void
		{
			if (this._conn == null)
			{
				return;
			}
			var _loc_1:* = new Encode();
			_loc_1.AddItem("type", "memberinforeq");
			_loc_1.AddItem("link", GlobalData.domainName);
			var _loc_2:* = _loc_1.Get_SttString();
			this._conn.sendmsg(_loc_2);
			//$.jscall("console.log", "ifrq ");
			return;
		}// end function
		
		private function ServerUserInfoContent(param1:Decode) : void
		{
			var _loc_2:* = param1.GetItem("sui");
			var _loc_3:* = new Decode();
			_loc_3.Parse(_loc_2);
			var _loc_4:* = _loc_3.GetItemAsInt("id");
			var _loc_5:* = _loc_3.GetItem("name");
			var _loc_6:* = _loc_3.GetItem("nick");
			var _loc_7:* = _loc_3.GetItemAsInt("rg");
			var _loc_8:* = _loc_3.GetItemAsInt("bg");
			var _loc_9:* = _loc_3.GetItemAsInt("pg");
			var _loc_10:* = _loc_3.GetItemAsInt("rt");
			var _loc_11:* = _loc_3.GetItemAsNumber("weight");
			var _loc_12:* = _loc_3.GetItemAsNumber("strength");
			var _loc_13:* = _loc_3.GetItemAsInt("cps_id");
			return;
		}
		
		private function ServerChatContent(param1:Decode) : void
		{
			var _loc_22:Encode;
			var _loc_23:String;
			var _loc_24:String;
			var _loc_25:String;
			var _loc_26:Boolean;
			var _loc_27:Encode;
//			var _loc_2:* = param1.GetItemAsInt("rescode");
//			var _loc_3:* = param1.GetItemAsInt("time");
			var _loc_4:* = param1.GetItemAsInt("sender");//id
//			var _loc_5:* = param1.GetItemAsInt("receiver");
			var _loc_6:* = param1.GetItem("content");//msg
//			var _loc_7:* = param1.GetItem("scope");
			var _loc_8:* = param1.GetItem("snick");//nick
			
			
			reserviceMsg(_loc_4,_loc_8,_loc_6);
			return;
			
//			var _loc_9:* = param1.GetItem("dnick");
//			var _loc_10:* = param1.GetItemAsInt("cd");
//			var _loc_11:* = param1.GetItem("sui");
//			var _loc_12:* = param1.GetItem("chatmsgid");
//			var _loc_13:* = param1.GetItemAsInt("maxl");
//			var _loc_14:* = param1.GetItemAsInt("col");
//			var _loc_15:* = param1.GetItemAsInt("ct");
//			GlobalData.chatMaxChars = _loc_13;
//			var _loc_16:* = new Decode();
//			_loc_16.Parse(_loc_11);
//			var _loc_17:* = _loc_16.GetItemAsInt("rg");
//			var _loc_18:* = _loc_16.GetItemAsInt("pg");
//			var _loc_19:* = _loc_16.GetItemAsInt("m_deserve_lev");
//			var _loc_20:* = _loc_16.GetItemAsInt("cq_cnt");
//			var _loc_21:* = _loc_16.GetItemAsInt("best_dlev");
//			if (_loc_2 == 0)
//			{
//				_loc_22 = new Encode();
//				_loc_22.AddItem("type", "chatmessage");
//				_loc_22.AddItem_int("rescode", _loc_2);
//				if (_loc_4)
//				{
//					_loc_22.AddItem("sender_nickname", _loc_8);
//					_loc_22.AddItem_int("sender", _loc_4);
//				}
//				else
//				{
//					_loc_22.AddItem_int("sender", _loc_4);
//				}
//				_loc_22.AddItem_int("receiver", _loc_5);
//				if (_loc_5 != 0)
//				{
//					_loc_22.AddItem("receiver_nickname", _loc_9);
//				}
//				else
//				{
//					_loc_22.AddItem("receiver_nickname", "");
//				}
//				_loc_22.AddItem("content", _loc_6);
//				_loc_22.AddItem_int("roomgroup", 1);
//				_loc_22.AddItem("level", "1");
//				_loc_22.AddItem_int("cd", _loc_10);
//				_loc_22.AddItem_int("sender_rg", _loc_17);
//				_loc_22.AddItem_int("sender_pg", _loc_18);
//				if (_loc_7 == "private")
//				{
//					_loc_22.AddItem("chatmsgid", _loc_12);
//					_loc_23 = _loc_22.Get_SttString();
//					//$.jscall("return_pravite_msg", _loc_23);
//				}
//				else
//				{
//					_loc_22.AddItem_int("time", _loc_3);
//					_loc_22.AddItem_int("maxl", _loc_13);
//					_loc_22.AddItem_int("m_deserve_lev", _loc_19);
//					_loc_22.AddItem("chatmsgid", _loc_12);
//					_loc_22.AddItem_int("cq_cnt", _loc_20);
//					_loc_22.AddItem_int("col", _loc_14);
//					_loc_22.AddItem_int("ct", _loc_15);
//					_loc_22.AddItem_int("best_dlev", _loc_21);
//					_loc_24 = _loc_22.Get_SttString();
//					//$.jscall("returnmsg", _loc_24);
//					if (this.myblacklist.indexOf(_loc_4) == -1)
//					{
//						_loc_25 = this.facereplace(_loc_6);
//						if (_loc_25 != "")
//						{
//							_loc_26 = _loc_4 == this.my_uid ? (true) : (false);
//							//CommentTime.instance.start(new SingleCommentData(_loc_25, Util.getColor(_loc_14), GlobalData.textSizeValue, getTimer(), _loc_26, GlobalData.danmuModel));
//						}
//					}
//				}
//			}
//			else if (_loc_2 == 289 || _loc_2 == 290 || _loc_2 == 294)
//			{
//				_loc_27 = new Encode();
//				_loc_27.AddItem("type", "chatmessage");
//				_loc_27.AddItem_int("rescode", _loc_2);
//				if (_loc_4)
//				{
//					_loc_27.AddItem("sender_nickname", _loc_8);
//					_loc_27.AddItem_int("sender", _loc_4);
//				}
//				else
//				{
//					_loc_27.AddItem_int("sender", _loc_4);
//				}
//				//$.jscall("returnmsg", _loc_27.Get_SttString());
//			}
//			else if (_loc_2 == 2)
//			{
//				//$.jscall("return_sys_msg", "您已被禁言");
//			}
//			else if (_loc_2 == 5)
//			{
//				//$.jscall("return_sys_msg", "全站禁言");
//			}
//			else if (_loc_2 == 208)
//			{
//				//$.jscall("return_sys_msg", "目标用户未找到");
//			}
//			else if (_loc_2 == 206)
//			{
//				//$.jscall("return_sys_pravite_msg", "平民5及以下等级用户禁止私聊，赶紧升级吧~");
//			}
			return;
		}// end function
		
		private function ServerKeepLive(param1:Decode) : void
		{
			var _loc_2:* = param1.GetItemAsInt("tick");
			var _loc_3:* = param1.GetItemAsInt("usernum");
			var _loc_4:* = new Encode();
			_loc_4.AddItem("type", "keeplive");
			_loc_4.AddItem_int("tick", _loc_2);
			var _loc_5:* = _loc_4.Get_SttString();
			this.keep_online = this.keep_online + this.per_keep_live;
			this.user_count = param1.GetItemAsInt("uc");
			Param.currentNum = this.user_count;
			//$.jscall("room_usercount", this.user_count);
			return;
		}// end function
		
		private function ServerSetAdmin(param1:Decode) : void
		{
			var _loc_2:* = param1.GetItemAsInt("rescode");
			var _loc_3:* = param1.GetItemAsInt("userid");
			var _loc_4:* = param1.GetItemAsInt("opuid");
			var _loc_5:* = param1.GetItemAsInt("group");
			var _loc_6:* = param1.GetItem("adnick");
			var _loc_7:* = new Encode();
			_loc_7.AddItem_int("rescode", _loc_2);
			if (_loc_2 == 0)
			{
				_loc_7.AddItem_int("userid", _loc_3);
				_loc_7.AddItem_int("group", _loc_5);
				_loc_7.AddItem_int("opuid", _loc_4);
				_loc_7.AddItem("adnick", _loc_6);
			}
			var _loc_8:* = _loc_7.Get_SttString();
			//$.jscall("console.log", "setadm： [%s]", _loc_8);
			ExternalInterface.call("return_setadmin", _loc_8);
			return;
		}// end function
		
		private function ServerBlackUser(param1:Decode) : void
		{
			var _loc_8:String;
			var _loc_9:String;
			var _loc_10:Encode;
			var _loc_11:String;
			var _loc_2:* = param1.GetItemAsInt("rescode");
			var _loc_3:* = param1.GetItemAsInt("userid");
			var _loc_4:* = param1.GetItemAsInt("blacktype");
			var _loc_5:* = param1.GetItemAsInt("limittime");
			var _loc_6:* = param1.GetItem("dnick");
			var _loc_7:* = param1.GetItem("snick");
			if (_loc_2 == 0)
			{
				if (_loc_4 == 1)
				{
					_loc_9 = _loc_6 + "被管理员" + _loc_7 + "封锁IP";
					_loc_8 = "您已被管理员" + _loc_7 + "封锁IP,封锁时间:" + _loc_5 + "秒";
				}
				else if (_loc_4 == 2 || _loc_4 == 4)
				{
					if (_loc_5 != 0)
					{
						_loc_9 = _loc_6 + "被管理员" + _loc_7 + "禁言";
						_loc_8 = "您已被管理员" + _loc_7 + "禁言,禁言时间:" + _loc_5 + "秒";
					}
					else
					{
						_loc_9 = _loc_6 + "被管理员解除禁言";
						_loc_8 = "您已被管理员解禁";
					}
				}
				else if (_loc_4 == 3)
				{
					_loc_9 = _loc_6 + "被管理员" + _loc_7 + "T出房间";
					_loc_8 = "您已被管理员" + _loc_7 + "封锁帐号,封锁时间:" + _loc_5 + "秒";
				}
				if (this.my_uid == _loc_3)
				{
					//$.jscall("console.log", "forbidTip:", _loc_8);
					//$.jscall("return_sys_pravite_msg", _loc_8);
					if (_loc_4 == 1 && _loc_4 == 3)
					{
						this.clean_conn_timer();
					}
				}
				//$.jscall("return_sys_msg", _loc_9);
			}
			else
			{
				_loc_10 = new Encode();
				_loc_10.AddItem_int("rescode", _loc_2);
				_loc_11 = _loc_10.Get_SttString();
				//$.jscall("black_admin", _loc_11);
			}
			return;
		}// end function
		
		private function ServerRoomRefresh(param1:Decode) : void
		{
			this.serialnum = param1.GetItemAsInt("serialnum");
			this.user_count = param1.GetItemAsInt("c");
			Param.currentNum = this.user_count;
			//$.jscall("room_usercount", this.user_count);
			return;
		}// end function
		
		private function ServerError(param1:Decode) : void
		{
			var randTime:int;
			var _strdecode:* = param1;
			this.clean_conn_timer();
			var code:* = _strdecode.GetItemAsInt("code");
			var _strencode:* = new Encode();
			_strencode.AddItem("type", "error");
			_strencode.AddItem_int("code", code);
			var server_error_str:* = _strencode.Get_SttString();
			//$.jscall("console.log", "server_error [%s]", server_error_str);
			if (code == 205)
			{
				//$.jscall("server_error", server_error_str);
				this.dispatcher("login", {code:1});
			}
			if (code == 52)
			{
				this.endError = server_error_str;
				clearTimeout(this.endTimeIndex0);
				randTime = int(Math.random() * 30);
				//$.jscall("console.log", "ServerShowStatus0 =" + randTime);
				this.endTimeIndex0 = setTimeout(function () : void
				{
					//$.jscall("server_error", endError);
					dispatcher.dispatchEvent(new Event("ServerShowStatus"));
					return;
				}// end function
					, randTime * 1000);
			}
			return;
		}// end function
		
		private function ServerRepeaterlist(param1:Decode) : void
		{
			var _loc_4:Decode;
			var _loc_5:int;
			var _loc_6:String;
			var _loc_7:Decode;
			var _loc_2:* = param1.GetItemAsInt("rid");
			var _loc_3:* = param1.GetItem("list");
			if (_loc_3 != "")
			{
				_loc_4 = new Decode();
				_loc_4.Parse(_loc_3);
				_loc_5 = 0;
				while (_loc_5 < _loc_4.sItemArray.length)
				{
					
					_loc_6 = _loc_4.GetItemByIndex(_loc_5);
					_loc_7 = new Decode();
					_loc_7.Parse(_loc_6);
					this.serverArray[_loc_5] = new Array();
					this.serverArray[_loc_5]["nr"] = _loc_7.GetItemAsInt("nr");
					this.serverArray[_loc_5]["ip"] = _loc_7.GetItem("ip");
					this.serverArray[_loc_5]["port"] = _loc_7.GetItemAsInt("port");
					_loc_5++;
				}
				if (this.barrage_Conn != null)
				{
					this.barrage_Conn.UserLogout();
					this.barrage_Conn.dispatcher.removeEventListener("ServerShowStatus", this.__ShowStatus);
					this.barrage_Conn.clean_conn_timer();
					this.barrage_Conn = null;
				}
				this.barrage_Conn = new ClientBarrage(this._conn);
				this.barrage_Conn.dispatcher.addEventListener("ServerShowStatus", this.__ShowStatus);
				this.barrage_Conn.my_uid = this.my_uid;
				this.barrage_Conn.my_username = this.my_username;
				this.barrage_Conn.my_nickname = this.my_nickname;
				this.barrage_Conn.roomId = this.roomId;
				this.barrage_Conn.serverArray = this.serverArray;
				this.barrage_Conn.OnChatMsg = this.ServerChatContent;
				this.barrage_Conn.GiftMsg=this.giftMsg;
				this.barrage_Conn.dmLinkOk=this.dmLinkOk;
				this.barrage_Conn.THWelcome=this.welcomeFun;
				this.barrage_Conn.ConnectNewServer();
			}
			return;
		}// end function
		
		private function ServerSetGroup(param1:Decode) : void
		{
			var _loc_2:* = param1.GetItemAsInt("gid");
			this.barrage_Conn.my_gid = _loc_2;
			this.barrage_Conn.UserJoinGroup();
			return;
		}// end function
		
		private function ServerJoinGroup(param1:Decode) : void
		{
			return;
		}// end function
		
		private function systemBroadcast(param1:Decode) : void
		{
			var _loc_2:* = param1.GetItemAsInt("t");
			var _loc_3:* = param1.GetItemAsInt("bt");
			var _loc_4:* = param1.GetItemAsInt("vt");
			var _loc_5:* = param1.GetItem("sn");
			var _loc_6:* = param1.GetItem("c");
			var _loc_7:* = param1.GetItem("url");
			var _loc_8:* = new Encode();
			_loc_8.AddItem_int("bt", _loc_3);
			_loc_8.AddItem_int("vt", _loc_4);
			_loc_8.AddItem("sn", _loc_5);
			_loc_8.AddItem("c", _loc_6);
			_loc_8.AddItem("url", _loc_7);
			//$.jscall("console.log", "sysbroad:", _loc_8.Get_SttString());
			//$.jscall("broadcast_show", _loc_8.Get_SttString());
			return;
		}// end function
		
		private function fishPresent(param1:Decode) : void
		{
			var _loc_2:* = param1.GetItemAsInt("r");
			var _loc_3:* = param1.GetItemAsInt("mg");
			var _loc_4:* = param1.GetItemAsInt("ms");
			var _loc_5:* = param1.GetItemAsInt("gb");
			var _loc_6:* = param1.GetItemAsInt("sb");
			var _loc_7:* = param1.GetItemAsInt("hc");
			var _loc_8:* = param1.GetItem("sui");
			var _loc_9:* = param1.GetItemAsNumber("src_strength");
			var _loc_10:* = param1.GetItemAsNumber("dst_weight");
			var _loc_11:* = new Decode();
			_loc_11.Parse(_loc_8);
			var _loc_12:* = _loc_11.GetItem("nick");
			var _loc_13:* = new Encode();
			_loc_13.AddItem_int("r", _loc_2);
			_loc_13.AddItem_int("mg", _loc_3);
			_loc_13.AddItem_int("ms", _loc_4);
			_loc_13.AddItem_int("gb", _loc_5);
			_loc_13.AddItem_int("sb", _loc_6);
			_loc_13.AddItem("sui", _loc_8);
			_loc_13.AddItem_int("src_strength", _loc_9);
			_loc_13.AddItem_int("dst_weight", _loc_10);
			_loc_13.AddItem_int("hc", _loc_7);
			_loc_13.AddItem("type", "donateres");
			//$.jscall("gift_obj.retutn_gift", _loc_13.Get_SttString());
			return;
		}// end function
		
		private function taskList(param1:Decode) : void
		{
			var _loc_2:* = param1.GetItem("list");
			var _loc_3:* = new Encode();
			_loc_3.AddItem("list", _loc_2);
			//$.jscall("console.log", "tkss:", _loc_3.Get_SttString());
			//$.jscall("task_obj.return_task_list", _loc_3.Get_SttString());
			return;
		}// end function
		
		private function taskNum(param1:Decode) : void
		{
			var _loc_2:* = param1.GetItemAsInt("ps");
			var _loc_3:* = new Encode();
			_loc_3.AddItem_int("ps", _loc_2);
			//$.jscall("console.log", "tkn:", _loc_3.Get_SttString());
			//$.jscall("task_obj.return_task_num", _loc_3.Get_SttString());
			return;
		}// end function
		
		private function obtainTaskRes(param1:Decode) : void
		{
			var _loc_2:* = param1.GetItemAsInt("r");
			var _loc_3:* = param1.GetItemAsInt("tid");
			var _loc_4:* = param1.GetItemAsInt("mg");
			var _loc_5:* = param1.GetItemAsInt("ms");
			var _loc_6:* = param1.GetItemAsNumber("gb");
			var _loc_7:* = param1.GetItemAsNumber("sb");
			var _loc_8:* = new Encode();
			_loc_8.AddItem_int("r", _loc_2);
			_loc_8.AddItem_int("tid", _loc_3);
			_loc_8.AddItem_int("mg", _loc_4);
			_loc_8.AddItem_int("ms", _loc_5);
			_loc_8.AddItem_int("gb", _loc_6);
			_loc_8.AddItem_int("sb", _loc_7);
			//$.jscall("console.log", "rtkr:", _loc_8.Get_SttString());
			//$.jscall("task_obj.return_reward", _loc_8.Get_SttString());
			return;
		}// end function
		
		private function roomSignUpRes(param1:Decode) : void
		{
			var _loc_2:* = param1.GetItemAsInt("r");
			var _loc_3:* = param1.GetItemAsInt("sc");
			var _loc_4:* = new Encode();
			_loc_4.AddItem_int("r", _loc_2);
			_loc_4.AddItem_int("sc", _loc_3);
			//$.jscall("console.log", "rsignr:", _loc_4.Get_SttString());
			//$.jscall("task_obj.return_sign", _loc_4.Get_SttString());
			return;
		}// end function
		
		private function onlineGiftRes(param1:Decode) : void
		{
			var _loc_2:* = param1.GetItemAsInt("lev");
			var _loc_3:* = param1.GetItemAsInt("lack_time");
			var _loc_4:* = param1.GetItemAsInt("dl");
			var _loc_5:* = new Encode();
			_loc_5.AddItem_int("lev", _loc_2);
			_loc_5.AddItem_int("lack_time", _loc_3);
			_loc_5.AddItem_int("dl", _loc_4);
			//$.jscall("console.log", "onlineTreasurer:", _loc_5.Get_SttString());
			//$.jscall("box_obj.show_time", _loc_5.Get_SttString());
			return;
		}// end function
		
		private function keyTitlesRes(param1:Decode) : void
		{
			var _loc_2:* = param1.GetItem("uname");
			var _loc_3:* = param1.GetItemAsInt("ret");
			var _loc_4:* = new Encode();
			_loc_4.AddItem("uname", _loc_2);
			_loc_4.AddItem_int("ret", _loc_3);
			//$.jscall("console.log", "keytitler:", _loc_4.Get_SttString());
			//$.jscall("return_onekeyblack", _loc_4.Get_SttString());
			return;
		}// end function
		
		private function giveFishBall(param1:Decode) : void
		{
			var r:int;
			var ms:int;
			var sb:Number;
			var strength:Number;
			var _strencode:Encode;
			var _strdecode:* = param1;
			var _loc_4:int;
			var _loc_5:* = _strdecode;
			var _loc_3:* = new XMLList("");
			var _loc_6:Object;
			for each (_loc_6 in _loc_5)
			{
				
				var _loc_7:* = _loc_6;
				with (_loc_6)
				{
					if ("r")
					{
						_loc_3[_loc_4] = _loc_6;
					}
				}
			}
			r = _loc_3;
			ms = _strdecode.GetItemAsInt("ms");
			sb = _strdecode.GetItemAsNumber("sb");
			strength = _strdecode.GetItemAsNumber("strength");
			_strencode = new Encode();
			_strencode.AddItem_int("r", r);
			_strencode.AddItem_int("ms", ms);
			_strencode.AddItem_int("sb", sb);
			_strencode.AddItem_int("strength", strength);
			//$.jscall("gift_obj.balance", _strencode.Get_SttString());
			return;
		}// end function
		
		private function talkRestriction(param1:Decode) : void
		{
			var _loc_2:* = param1.GetItemAsInt("cd");
			var _loc_3:* = param1.GetItemAsInt("maxl");
			var _loc_4:* = new Encode();
			_loc_4.AddItem_int("cd", _loc_2);
			_loc_4.AddItem_int("maxl", _loc_3);
			//$.jscall("console.log", "limitchatr:", _loc_4.Get_SttString());
			//$.jscall("msg_obj.msg_cd", _loc_4.Get_SttString());
			return;
		}// end function
		
		private function baoXuetime(param1:Decode) : void
		{
			var _loc_2:* = param1.GetItem("func");
			var _loc_3:* = param1.GetItem("param");
			var _loc_4:* = new Encode();
			_loc_4.AddItem("func", _loc_2);
			_loc_4.AddItem("param", _loc_3);
			//$.jscall("common_call", _loc_4.Get_SttString());
			//$.jscall("console.log", "common_call1：", _loc_4.Get_SttString());
			return;
		}// end function
		
		private function reportBarrage(param1:Decode) : void
		{
			var _loc_2:* = param1.GetItemAsInt("state");
			var _loc_3:* = new Encode();
			_loc_3.AddItem_int("state", _loc_2);
			//$.jscall("return_chatreport", _loc_3.Get_SttString());
			//$.jscall("console.log", "return_chatreport：", _loc_3.Get_SttString());
			return;
		}// end function
		
		private function identityChange(param1:Decode) : void
		{
			var _loc_2:* = param1.GetItemAsInt("opuid");
			var _loc_3:* = param1.GetItemAsInt("rg");
			var _loc_4:* = param1.GetItemAsInt("rid");
			GlobalData.rg = _loc_3;
			this.dispatcher("userRGEvent", null);
			//$.jscall("console.log", "identityChange");
			return;
		}// end function
		
		private function rewardListResponse(param1:Decode) : void
		{
			var _loc_2:* = param1.GetItemAsInt("rid");
			var _loc_3:* = param1.GetItem("list");
			var _loc_4:* = new Encode();
			_loc_4.AddItem_int("rid", _loc_2);
			_loc_4.AddItem("list", _loc_3);
			//$.jscall("cq_obj.rank", _loc_4.Get_SttString());
			//$.jscall("console.log", "return_rewardList：", _loc_4.Get_SttString());
			return;
		}// end function
		
		private function emailNotify(param1:Decode) : void
		{
			var _loc_2:* = param1.GetItem("mid");
			var _loc_3:* = param1.GetItem("sender");
			var _loc_4:* = param1.GetItem("sub");
			var _loc_5:* = param1.GetItemAsInt("unread");
			var _loc_6:* = new Encode();
			_loc_6.AddItem("mid", _loc_2);
			_loc_6.AddItem("sender", _loc_3);
			_loc_6.AddItem("sub", _loc_4);
			_loc_6.AddItem_int("unread", _loc_5);
			//$.jscall("return_recevice_pm", _loc_6.Get_SttString());
			//$.jscall("console.log", "return_emailNotify：", _loc_6.Get_SttString());
			return;
		}// end function
		
		private function updateYC(param1:Decode) : void
		{
			var _loc_2:* = param1.GetItemAsInt("b");
			var _loc_3:* = new Encode();
			_loc_3.AddItem_int("b", _loc_2);
			//$.jscall("return_yc", _loc_3.Get_SttString());
			//$.jscall("console.log", "updateyc：", _loc_3.Get_SttString());
			return;
		}// end function
		
		private function roomInfoRes(param1:String) : void
		{
			//$.jscall("show_obj.info_show", param1);
			//$.jscall("console.log", "show_obj.info_showr：", param1);
			return;
		}// end function
		
		private function giftPkgRes(param1:String) : void
		{
			//$.jscall("query_gift_pkg_info", param1);
			//$.jscall("console.log", "query_gift_pkg_info：", param1);
			return;
		}// end function
		
		private function giveFishBallres(param1:String) : void
		{
			//$.jscall("live_gift_batter", param1);
			//$.jscall("console.log", "live_gift_batter1：", param1);
			return;
		}// end function
		
		private function reloadStreamNotify() : void
		{
			clearTimeout(this.reloadTimeIndex);
			var _loc_1:* = int(Math.random() * 30);
			this.reloadTimeIndex = setTimeout(this.reloadStream, _loc_1 * 1000);
			return;
		}// end function
		
		private function reloadStream() : void
		{
			this.dispatcher("ReloadStreamEvent", null);
			return;
		}// end function
		
		private function ServerShowStatus(param1:Decode) : void
		{
			var _strdecode:* = param1;
			var rid:* = _strdecode.GetItemAsInt("rid");
			var ss:* = _strdecode.GetItemAsInt("ss");
			var code:* = _strdecode.GetItemAsInt("code");
			var notify:* = _strdecode.GetItemAsInt("notify");
			var endtime:* = _strdecode.GetItemAsInt("endtime");
			var _strencode:* = new Encode();
			_strencode.AddItem_int("rid", rid);
			_strencode.AddItem_int("ss", ss);
			_strencode.AddItem_int("code", code);
			_strencode.AddItem_int("notify", notify);
			_strencode.AddItem_int("endtime", endtime);
			this.endStr = _strencode.Get_SttString();
			clearTimeout(this.endTimeIndex);
			var randTime:* = int(Math.random() * 30);
			//$.jscall("console.log", "ServerShowStatus1 =" + randTime);
			this.endTimeIndex = setTimeout(function () : void
			{
				//$.jscall("console.log", "nsStatechange:", endStr);
				//$.jscall("super_close_room_tips", endStr);
				dispatcher.dispatchEvent(new Event("ServerShowStatus"));
				return;
			}// end function
				, randTime * 1000);
			return;
		}// end function
		
		private function __ShowStatus(param1:Event) : void
		{
			this.dispatcher.dispatchEvent(new Event("ServerShowStatus"));
			return;
		}// end function
		
		private function findUserByUID(param1:int) : RoomUser
		{
			var _loc_2:int;
			_loc_2 = 0;
			while (_loc_2 < this.users.length)
			{
				
				if (this.users[_loc_2].uid == param1)
				{
					return this.users[_loc_2];
				}
				_loc_2++;
			}
			return null;
		}// end function
		
		private function findUserByUsername(param1:String) : RoomUser
		{
			var _loc_2:int;
			_loc_2 = 0;
			while (_loc_2 < this.users.length)
			{
				
				if (this.users[_loc_2].username == param1)
				{
					return this.users[_loc_2];
				}
				_loc_2++;
			}
			return null;
		}// end function
		
		private function findUserByNickname(param1:String) : RoomUser
		{
			var _loc_2:int;
			_loc_2 = 0;
			while (_loc_2 < this.users.length)
			{
				
				if (this.users[_loc_2].nickname == param1)
				{
					return this.users[_loc_2];
				}
				_loc_2++;
			}
			return null;
		}// end function
		
		private function removeUserByUID(param1:int) : void
		{
			var _loc_2:int;
			_loc_2 = 0;
			while (_loc_2 < this.users.length)
			{
				
				if (this.users[_loc_2].uid == param1)
				{
					this.users.splice(_loc_2, 1);
					return;
				}
				_loc_2++;
			}
			return;
		}// end function
		
		private function sortUsers(param1:RoomUser, param2:RoomUser) : int
		{
			var _loc_3:* = this.sortAtt(param1.roomgroup, param2.roomgroup);
			if (_loc_3 != 0)
			{
				return _loc_3;
			}
			return this.sortAtt(param1.score, param2.score);
		}// end function
		
		private function sortAtt(param1:int, param2:int) : int
		{
			if (param1 > param2)
			{
				return -1;
			}
			if (param1 < param2)
			{
				return 1;
			}
			return 0;
		}// end function
		
		public function black_word(param1:String) : Boolean
		{
			var _loc_3:String;
			var _loc_2:* = new Array("风云直播", "YY直播", "yy直播", "泽东", "泽民", "锦涛", "恩来", "大法", "法轮", "九评", "退党", "明慧", "办证", "我操", "毛主席", "近平", "薄熙来", "共产");
			for each (_loc_3 in _loc_2)
			{
				
				if (param1.indexOf(_loc_3) >= 0)
				{
					return true;
				}
			}
			return false;
		}// end function
		
		public function facereplace(param1:String) : String
		{
			var _loc_8:String;
			var _loc_9:String;
			var _loc_10:String;
			var _loc_2:* = new Array("good", "kiss", "drop", "fil", "grief", "badluck", "indecent", "kiss", "laugh", "lovely", "rage", "scare", "sleep", "trick", "awesome", "snicker", "doubt", "guise", "sorry", "nosebleed", "moving", "grimace", "laughing", "revel", "excited", "dizzy", "bye", "up", "a", "dzt", "js", "kx", "uccu", "wy", "dyfn", "dyw", "dyhp", "dycy", "dylb", "dyjj", "dydoge", "dylyl", "dyhc", "dytk", "dysyw", "dy001", "dy002", "dy003", "dy004", "dy005", "dy006", "dy007", "dy008", "dy009", "dy010", "dy011", "dy012", "dy013", "dy014", "dy015", "dy016", "dy017", "dy101", "dy102", "dy103", "dy104", "dy105", "dy106", "dy107", "dy108", "dy109", "dy110", "dy111", "dy112", "dy113", "dy114", "dy115", "dy116", "dy117", "dy118", "dy119", "dy120", "dy121", "dy122", "dy123", "dy124", "dy125", "dy126", "dy127", "dy128");
			var _loc_3:* = _loc_2.length;
			var _loc_4:int;
			while (_loc_4 < _loc_3)
			{
				
				_loc_8 = "\\[emot:" + _loc_2[_loc_4] + "\\]";
				param1 = param1.replace(new RegExp(_loc_8, "g"), "");
				_loc_4++;
			}
			param1 = param1.replace(new RegExp("\\s", "g"), " ");
			var _loc_5:* = new RegExp("\\[room=[a-zA-Z0-9]*\\]", "g");
			var _loc_6:* = param1.match(_loc_5);
			var _loc_7:int;
			while (_loc_7 < _loc_6.length)
			{
				
				_loc_9 = _loc_6[_loc_7];
				_loc_10 = _loc_9.toString().substring(_loc_9.toString().indexOf("=") + 1, _loc_9.toString().indexOf("]"));
				param1 = param1.replace(_loc_9.toString(), _loc_10);
				_loc_7++;
			}
			return param1;
		}// end function
		
		public function clean_conn_timer() : void
		{
			if (this.myTimer != null)
			{
				this.myTimer.stop();
				this.myTimer.removeEventListener(TimerEvent.TIMER, this.KeepLive);
				this.myTimer = null;
			}
			if (this.cacheTimer != null)
			{
				this.cacheTimer.stop();
				this.cacheTimer.removeEventListener(TimerEvent.TIMER, this.RoomRefresh);
				this.cacheTimer = null;
			}
			if (this._conn != null)
			{
				this._conn.close();
				this._conn.removeEventListener(TcpEvent.Conneted, this._OnConn);
				this._conn.removeEventListener(TcpEvent.RecvMsg, this.ParseMsg);
				this._conn = null;
			}
			if (this.barrage_Conn != null)
			{
				this.barrage_Conn.UserLogout();
				this.barrage_Conn = null;
			}
			return;
		}// end function
		
	}
}
