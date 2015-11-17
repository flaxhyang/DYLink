package net
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	import user.Param;
	
	import utils.Decode;
	import utils.Encode;
	import utils.EventCenter;
	import utils.TcpEvent;
	
	public class ClientBarrage extends EventDispatcher
	{
		public var _conn2:TcpClient;
		public var dispatcher:EventDispatcher;
		public var login_status:Boolean = false;
		public var my_uid:int;
		public var my_username:String;
		public var my_nickname:String;
		public var my_gid:int = -1;
		public var roomId:int;
		public var keep_online:int = 0;
		private var myTimer:Timer;
		private var joinGroupTimer:Timer;
		private var per_keep_live:int = 45;
		private var per_cachedata:int = 60;
		private var serialnum:int = 0;
		private var user_count:int = 0;
		public var serverArray:Array;
		private var firstConn:TcpClient;
		private var _checkOnlineSeed:uint;
		private var breakLine:uint;
		private var endTimeIndex:uint;
		private var endStr:String;
		
		
		public var OnChatMsg:Function;
		public var GiftMsg:Function;
		public var THWelcome:Function;
		public var dmLinkOk:Function;
		
		
		public function ClientBarrage(param1:TcpClient)
		{
			this.dispatcher = new EventDispatcher();
			this.serverArray = new Array();
			this.firstConn = param1;
			return;
		}
		
		public function ConnectNewServer() : void
		{
			var _loc_1:int;
			this.clean_conn_timer();
			this._conn2 = new TcpClient();
			if (this.serverArray.length > 0)
			{
				_loc_1 = int(Math.random() * 10000) % this.serverArray.length;
				this._conn2.connect(this.serverArray[_loc_1]["ip"], this.serverArray[_loc_1]["port"]);
				this._conn2.addEventListener(TcpEvent.Conneted, this.onConn);
				this._conn2.addEventListener(TcpEvent.RecvMsg, this.ParseMsg);
				//$.jscall("console.log", "dmnc");
			}
			return;
		}// end function
		
		public function onConn(param1:Event) : void
		{
			//$.jscall("console.log", "dmncr");
			this.UserLogin();
			if (this._checkOnlineSeed)
			{
				clearInterval(this._checkOnlineSeed);
			}
			this._checkOnlineSeed = setInterval(this.CheckOnline, 120000);
			return;
		}// end function
		
		private function breakOnline() : void
		{
			if (this._conn2 && this._conn2.is_connected)
			{
				this._conn2.close();
				//$.jscall("console.log", "cutdmcn");
			}
			return;
		}// end function
		
		private function CheckOnline() : void
		{
			if (this.firstConn && this.firstConn.is_connected)
			{
				if (!this._conn2 || !this._conn2.is_connected)
				{
					//$.jscall("console.log", "cnc");
					this.ConnectNewServer();
				}
			}
			return;
		}// end function
		
		public function UserLogin() : void
		{
			if (this._conn2 == null)
			{
				return;
			}
			var _loc_1:* = this.my_username;
			var _loc_2:String="";
			this.roomId = this.roomId;
			this._conn2.addEventListener(TcpEvent.RecvMsg, this.ParseMsg);
			var _loc_3:* = new Encode();
			_loc_3.AddItem("type", "loginreq");
			_loc_3.AddItem("username", _loc_1);
			_loc_3.AddItem("password", _loc_2);
			_loc_3.AddItem_int("roomid", this.roomId);
			var _loc_4:* = _loc_3.Get_SttString();
			//$.jscall("console.log", "  UserLogin [%s]", _loc_4);
			this._conn2.sendmsg(_loc_4);
			return;
		}// end function
		
		public function UserJoinGroup() : void
		{
			if (this.login_status == false)
			{
				return;
			}
			var _loc_1:* = new Encode();
			_loc_1.AddItem("type", "joingroup");
			_loc_1.AddItem_int("rid", this.roomId);
			_loc_1.AddItem_int("gid", this.my_gid);
			var _loc_2:* = _loc_1.Get_SttString();
			if (this._conn2 == null)
			{
				return;
			}
			this._conn2.sendmsg(_loc_2);
			return;
		}// end function
		
		public function UserLogout() : void
		{
			var _loc_1:Encode;
			var _loc_2:String;
			if (this._conn2 != null)
			{
				//$.jscall("console.log", "ulo");
				_loc_1 = new Encode();
				_loc_1.AddItem("type", "logout");
				_loc_2 = _loc_1.Get_SttString();
				this._conn2.sendmsg(_loc_2);
				if (this._checkOnlineSeed)
				{
					clearInterval(this._checkOnlineSeed);
				}
				this.clean_conn_timer();
			}
			return;
		}// end function
		
		public function KeepLive(param1:TimerEvent) : void
		{
			var _loc_2:Encode;
			var _loc_3:String;
			if (this._conn2 != null)
			{
				this._conn2.addEventListener(TcpEvent.RecvMsg, this.ParseMsg);
				_loc_2 = new Encode();
				_loc_2.AddItem("type", "keeplive");
				_loc_2.AddItem_int("tick", Math.round(Math.random() * 100));
				_loc_3 = _loc_2.Get_SttString();
				this._conn2.sendmsg(_loc_3);
				//$.jscall("console.log", "time1=" + getTimer());
			}
			return;
		}// end function
		
		public function CheckJoinGroup(param1:TimerEvent) : void
		{
			if (this._conn2 != null)
			{
				if (this.login_status == true && this.my_gid != -1)
				{
					this.joinGroupTimer.stop();
					this.joinGroupTimer = null;
					this.UserJoinGroup();
				}
			}
			return;
		}// end function
		
		private function ParseMsg(param1:TcpEvent) : void
		{
			var _loc_2:* = new Decode();
			_loc_2.Parse(param1._param as String);
			var _loc_3:* = _loc_2.GetItem("type");
			//trace("返回值"+_loc_3)
			if (_loc_3 != "keeplive" && _loc_3 != "chatmessage" && _loc_3 != "donateres" && _loc_3 != "dgn")
			{
				//$.jscall("console.log", "弹幕 网络数据 [%s]", param1._param as String);
			}
			if (_loc_3 == "loginres")
			{
				this.ServerLoginInfo(_loc_2);
				trace("ok")
			}
			else if (_loc_3 == "chatmessage")
			{
				this.ServerChatContent(_loc_2);
			}
			else if (_loc_3 == "keeplive")
			{
				this.ServerKeepLive(_loc_2);
			}
			else if (_loc_3 == "error")
			{
				this.ServerError(_loc_2);
				trace("error")
			}
			else if (_loc_3 == "donateres")
			{
				this.fishPresent(_loc_2);
			}
			else if (_loc_3 == "setadminres")
			{
				this.ServerSetAdmin(_loc_2);
			}
			else if (_loc_3 == "blackres")
			{
				this.ServerBlackUser(_loc_2);
			}
			else if (_loc_3 == "rss")
			{
				this.ServerShowStatus(_loc_2);
			}
			else if (_loc_3 == "rsm")
			{
				this.systemBroadcast(_loc_2);
			}
			else if (_loc_3 == "userenter")
			{
				//高级用户进入
				this.ServerUserEnter(_loc_2);
			}
			else if (_loc_3 == "bc_buy_deserve")
			{
				trace(param1._param)
				//酬勤
				this.buyDeserve(param1._param as String);
			}
			else if (_loc_3 == "common_call")
			{
				this.baoxueTime(_loc_2);
			}
			else if (_loc_3 == "ranklist")
			{
				this.rewardListResponse(_loc_2);
			}
			else if (_loc_3 == "filterblackad")
			{
				this.maskQrCodeNotify(_loc_2);
			}
			else if (_loc_3 == "hits_effect")
			{
				this.batterFxEffect(param1._param as String);
			}
			else if (_loc_3 == "onlinegift")
			{
				//领取 鱼丸
				this.onGiftNotify(_loc_2);
			}
			else
			{
				if (_loc_3 == "spbc")
				{
					return;
				}
				if (_loc_3 == "dgn")
				{
					this.currentRoomGiftBroadcast(param1._param as String);
				}
				else if (_loc_3 == "ssd")
				{
					this.superDanmuBroadcast(_loc_2);
				}
				else
				{
					if (_loc_3 == "gbbc")
					{
						return;
					}
					if (_loc_3 == "gbbr")
					{
						return;
					}
					if (_loc_3 == "ggbb")
					{
						return;
					}
					if (_loc_3 == "gbip")
					{
						return;
					}
				}
			}
			return;
		}// end function
		
		private function ServerLoginInfo(param1:Decode) : void
		{
			//$.jscall("console.log", "dmlgsuccess");
			if (this.myTimer == null)
			{
				this.myTimer = new Timer(this.per_keep_live * 1000, 0);
				this.myTimer.addEventListener(TimerEvent.TIMER, this.KeepLive);
				this.myTimer.start();
			}
			else
			{
				this.myTimer.reset();
				this.myTimer.start();
			}
			this.login_status = true;
			if (this.joinGroupTimer == null)
			{
				this.joinGroupTimer = new Timer(1 * 1000, 0);
				this.joinGroupTimer.addEventListener(TimerEvent.TIMER, this.CheckJoinGroup);
				this.joinGroupTimer.start();
			}
			else
			{
				this.joinGroupTimer.reset();
				this.joinGroupTimer.start();
			}
			
			
			dmLinkOk();
			return;
		}
		
		private function ServerChatContent(param1:Decode) : void
		{
			if (this.OnChatMsg != null)
			{
//				if (GlobalData.rg > 1 || GlobalData.pg > 1)
//				{
//					return;
//				}
				this.OnChatMsg(param1);
				//trace(param1.item);
			}
			return;
		}
		
		//-----------------------------------------------------------------
		// yzy gift
		//-----------------------------------------------------------------
		private function ServerGift(id:String,nick:String,num:int=100):void{
			trace(nick,num)
			this.GiftMsg(id,nick,num);
		}
		
		
		
		
		private function ServerKeepLive(param1:Decode) : void
		{
			var _loc_2:* = param1.GetItemAsInt("tick");
			var _loc_3:* = param1.GetItemAsInt("usernum");
			var _loc_4:* = new Encode();
			_loc_4.AddItem("type", "keeplive");
			_loc_4.AddItem_int("tick", _loc_2);
			_loc_4.AddItem_int("usernum", _loc_3);
			var _loc_5:* = _loc_4.Get_SttString();
			this.keep_online = this.keep_online + this.per_keep_live;
			return;
		}// end function
		
		private function ServerError(param1:Decode) : void
		{
			this.clean_conn_timer();
			var _loc_2:* = param1.GetItemAsInt("code");
			//$.jscall("console.log", "server_error1 [%d]", _loc_2);
			return;
		}// end function
		
		private function fishPresent(param1:Decode) : void
		{
			var _loc_2:* = param1.GetItemAsInt("r");
			var _loc_3:* = param1.GetItemAsInt("mg");
			var _loc_4:* = param1.GetItemAsInt("ms");
			var _loc_5:int = param1.GetItemAsInt("gb");//鱼丸数
			var _loc_6:* = param1.GetItemAsInt("sb");
			var _loc_7:* = param1.GetItemAsInt("hc");
			var _loc_8:* = param1.GetItem("sui");
			var _loc_9:* = param1.GetItemAsNumber("src_strength");
			var _loc_10:* = param1.GetItemAsNumber("dst_weight");
			var _loc_11:* = new Decode();
			_loc_11.Parse(_loc_8);
			var _loc_12:* = _loc_11.GetItem("nick");//nick
			var id:*=_loc_11.GetItem("id");
			//----------------------------------------------------------------------------yzy
			ServerGift(id,_loc_12,_loc_4);
			return;
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
//			ExternalInterface.call("return_setadmin", _loc_8);
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
		
		private function ServerShowStatus(param1:Decode) : void
		{
			var _loc_2:* = param1.GetItemAsInt("rid");
			var _loc_3:* = param1.GetItemAsInt("ss");
			var _loc_4:* = param1.GetItemAsInt("code");
			var _loc_5:* = param1.GetItemAsInt("notify");
			var _loc_6:* = param1.GetItemAsInt("endtime");
			var _loc_7:* = new Encode();
			_loc_7.AddItem_int("rid", _loc_2);
			_loc_7.AddItem_int("ss", _loc_3);
			_loc_7.AddItem_int("code", _loc_4);
			_loc_7.AddItem_int("notify", _loc_5);
			_loc_7.AddItem_int("endtime", _loc_6);
			this.endStr = _loc_7.Get_SttString();
			clearTimeout(this.endTimeIndex);
			var _loc_8:* = int(Math.random() * 30);
			//$.jscall("console.log", "ServerShowStatus2 =" + _loc_8);
			this.endTimeIndex = setTimeout(this.recommend, _loc_8 * 1000);
			return;
		}// end function
		
		private function recommend() : void
		{
			//$.jscall("console.log", "nsStatechange:", this.endStr);
			//$.jscall("super_close_room_tips", this.endStr);
			this.dispatcher.dispatchEvent(new Event("ServerShowStatus"));
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
		
		private function ServerUserEnter(param1:Decode) : void
		{
			var _loc_2:* = param1.GetItem("userinfo");
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
			var _loc_14:* = _loc_3.GetItemAsInt("m_deserve_lev");
			var _loc_15:* = _loc_3.GetItemAsInt("cq_cnt");
			var _loc_16:* = _loc_3.GetItemAsInt("best_dlev");
			var _loc_17:* = new Encode();
			_loc_17.AddItem_int("id", _loc_4);
			_loc_17.AddItem("name", _loc_5);
			_loc_17.AddItem("nick", _loc_6);
			_loc_17.AddItem_int("rg", _loc_7);
			_loc_17.AddItem_int("bg", _loc_8);
			_loc_17.AddItem_int("pg", _loc_9);
			_loc_17.AddItem_int("rt", _loc_10);
			_loc_17.AddItem_int("weight", _loc_11);
			_loc_17.AddItem_int("strength", _loc_12);
			_loc_17.AddItem_int("cps_id", _loc_13);
			_loc_17.AddItem_int("m_deserve_lev", _loc_14);
			_loc_17.AddItem_int("cq_cnt", _loc_15);
			_loc_17.AddItem_int("best_dlev", _loc_16);
			var _loc_18:* = _loc_17.Get_SttString();
			//$.jscall("console.log", "newuinfo： [%s]", _loc_18);
			//$.jscall("remind_obj.senior_remind", _loc_17.Get_SttString());
			
			//---------------------------------------------------------------------------------------------------------------------------------
			THWelcome(String(_loc_6));
			
			return;
		}// end function
		
		private function buyDeserve(param1:String) : void
		{
			//$.jscall("cq_obj.buy_msg", param1);
			try
			{
				var dec1:Decode = new Decode();
				dec1.Parse(param1);
				var level:String = dec1.GetItem("lev");
				var sui:String=dec1.GetItem("sui");
				var dec2:Decode=new Decode();
				dec2.Parse(sui);
				var nick:String=dec2.GetItem("nick");
				var id:String=dec2.GetItem("id");
				//trace(level)
				var yw:int;
				switch(level)
				{
					case "1":
					{
						yw=15000;
						break;
					}
					case "2":
					{
						yw=30000;
						break;
					}
					case "3":
					{
						yw=50000;
						break;
					}
						
					default:
					{
						break;
					}
				}
				ServerGift(id,nick,yw);
			} 
			catch(error:Error) 
			{
				
			}
			return;
		}// end function
		
		private function baoxueTime(param1:Decode) : void
		{
			var _loc_2:* = param1.GetItem("func");
			var _loc_3:* = param1.GetItem("param");
			var _loc_4:* = new Encode();
			_loc_4.AddItem("func", _loc_2);
			_loc_4.AddItem("param", _loc_3);
			//$.jscall("common_call", _loc_4.Get_SttString());
			//$.jscall("console.log", "common_call2:", _loc_4.Get_SttString());
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
		
		private function maskQrCodeNotify(param1:Decode) : void
		{
			var _loc_2:* = param1.GetItemAsNumber("x_s");
			var _loc_3:* = param1.GetItemAsNumber("y_s");
			var _loc_4:* = param1.GetItemAsNumber("w_s");
			var _loc_5:* = param1.GetItemAsNumber("h_s");
			var _loc_6:* = param1.GetItemAsInt("et");
			if (Param.maskObj == null)
			{
				Param.maskObj = new Object();
			}
			Param.maskObj.x_scale = _loc_2;
			Param.maskObj.y_scale = _loc_3;
			Param.maskObj.w_scale = _loc_4;
			Param.maskObj.h_scale = _loc_5;
			Param.maskObj.endtime = _loc_6;
			EventCenter.dispatch("maskNotify", null);
			return;
		}// end function
		
		private function batterFxEffect(param1:String) : void
		{
			//$.jscall("roomBatterFxRender", param1);
			//$.jscall("console.log", "roomBatterFxRender：", param1);
			return;
		}// end function
		
		private function onGiftNotify(param1:Decode) : void
		{
			var _loc_2:* = param1.GetItemAsInt("rid");
			var _loc_3:* = param1.GetItem("nn");//mizi
			var _loc_4:* = param1.GetItemAsInt("uid");
			var _loc_5:* = param1.GetItemAsInt("gid");
			var _loc_6:* = param1.GetItemAsInt("sil");//yuwan shu
			var _loc_7:* = param1.GetItemAsInt("if");
			var _loc_8:* = param1.GetItemAsInt("ct");
			
//			trace("ling yw:"+_loc_3)
			var _loc_9:* = new Encode();
			_loc_9.AddItem_int("rid", _loc_2);
			_loc_9.AddItem_int("uid", _loc_4);
			_loc_9.AddItem_int("gid", _loc_5);
			_loc_9.AddItem_int("sil", _loc_6);
			_loc_9.AddItem_int("if", _loc_7);
			_loc_9.AddItem_int("ct", _loc_8);
			_loc_9.AddItem("nn", _loc_3);
			if (_loc_8 == 1)
			{
				EventCenter.dispatch("MobileRewardEvent", {nameStr:_loc_3});
			}
			//$.jscall("box_obj.Luck_Burst", _loc_9.Get_SttString());
			//$.jscall("console.log", "box_obj.Luck_Burst：", _loc_9.Get_SttString());
			return;
		}// end function
		
		private function giftBroadcast(param1:Decode) : void
		{
			var _loc_2:* = param1.GetItem("sn");
			var _loc_3:* = param1.GetItem("dn");
			var _loc_4:* = param1.GetItem("gn");
			var _loc_5:* = param1.GetItemAsInt("gc");
			var _loc_6:* = param1.GetItemAsInt("drid");
			var _loc_7:* = param1.GetItemAsInt("gs");
			var _loc_8:* = param1.GetItemAsInt("rid");
			var _loc_9:* = param1.GetItemAsInt("gid");
			var _loc_10:* = new Encode();
			_loc_10.AddItem("sn", _loc_2);
			_loc_10.AddItem("dn", _loc_3);
			_loc_10.AddItem("gn", _loc_4);
			_loc_10.AddItem_int("gc", _loc_5);
			_loc_10.AddItem_int("drid", _loc_6);
			_loc_10.AddItem_int("gs", _loc_7);
			_loc_10.AddItem_int("rid", _loc_8);
			_loc_10.AddItem_int("gid", _loc_9);
			EventCenter.dispatch("GiftBroadcastEvent", {send:_loc_2, receive:_loc_3, gift:_loc_4, num:_loc_5, rid:_loc_6, giftStyle:_loc_7, type:2, time:getTimer()});
			//$.jscall("live_gift_batter", _loc_10.Get_SttString());
			//$.jscall("console.log", "live_gift_batter：", _loc_10.Get_SttString());
			return;
		}// end function
		
		private function currentRoomGiftBroadcast(param1:String) : void
		{
			//$.jscall("live_gift_batter", param1);
			trace(param1)
			//type@=dgn/gfid@=50/gs@=1/gfcnt@=1/hits@=1/lhits@=0/sid@=10762874/src_ncnm@=lin5996889/rid@=4809/
			//gid@=162/lev@=0/cnt@=0/sth@=4420/bdl@=0/dw@=334458827/rpid@=0/slt@=0/elt@=0/
			//type@=dgn/gfid@=53/gs@=2/gfcnt@=1/hits@=415/lhits@=414/sid@=24325281/src_ncnm@=Cute丶公子
			//寒/rid@=863/gid@=35/lev@=3/cnt@=100/sth@=330200/bdl@=3/dw@=103245917/rpid@=0/slt@=0/elt@=0/"
			var _loc_2:Decode = new Decode();
			_loc_2.Parse(param1);
			var id:String = _loc_2.GetItem("sid");
			var nick:String=_loc_2.GetItem("src_ncnm");
			var type:String=_loc_2.GetItem("gs");
			var num:int;
			if(type=="1"){
				//trace("100:"+nick);
				num=100;
				ServerGift(id,nick,num);
			}else if(type=="2"){
				//trace("520:"+nick)
				num=520;
				ServerGift(id,nick,num);
			}else if(type=="3"){
				num=100;
				ServerGift(id,nick,num);
			}else if(type=="4"){
				num=6000;
				ServerGift(id,nick,num);
			}else if(type=="5"){
				num=100000;
				ServerGift(id,nick,num);
			}else if(type=="6"){
				num=500000;
				ServerGift(id,nick,num);
			}
			
			//-------------------------------------------------------------------------------------------------yzy
			return;
		}// end function
		
		private function hbNotify(param1:String) : void
		{
			//$.jscall("live_gift_batter", param1);
			//$.jscall("console.log", "live_gift_batter3：", param1);
			return;
		}// end function
		
		private function hbGetResponse(param1:String) : void
		{
			//$.jscall("live_gift_batter", param1);
			//$.jscall("console.log", "live_gift_batter4：", param1);
			return;
		}// end function
		
		private function hbGetNotify(param1:String) : void
		{
			//$.jscall("live_gift_batter", param1);
			//$.jscall("console.log", "live_gift_batter5：", param1);
			return;
		}// end function
		
		private function hbForNewuserNotify(param1:String) : void
		{
			//$.jscall("live_gift_batter", param1);
			//$.jscall("console.log", "live_gift_batter6：", param1);
			return;
		}// end function
		
		private function superDanmuBroadcast(param1:Decode) : void
		{
			var _loc_2:* = param1.GetItemAsInt("sdid");
			var _loc_3:* = param1.GetItemAsInt("trid");
			var _loc_4:* = param1.GetItem("content");
			var _loc_5:* = param1.GetItemAsInt("rid");
			var _loc_6:* = param1.GetItemAsInt("gid");
			var _loc_7:* = new Encode();
			_loc_7.AddItem_int("sdid", _loc_2);
			_loc_7.AddItem_int("trid", _loc_3);
			_loc_7.AddItem("content", _loc_4);
			_loc_7.AddItem_int("rid", _loc_5);
			_loc_7.AddItem_int("gid", _loc_6);
			EventCenter.dispatch("GiftBroadcastEvent", {did:_loc_2, nrid:_loc_3, supercontent:_loc_4, crid:_loc_5, cgid:_loc_6, type:3, time:getTimer()});
			//$.jscall("console.log", "superdm");
			//$.jscall("superBarrage.addHtml", _loc_7.Get_SttString());
			return;
		}// end function
		
		public function clean_conn_timer() : void
		{
			if (this.myTimer != null)
			{
				this.myTimer.stop();
				this.myTimer.removeEventListener(TimerEvent.TIMER, this.KeepLive);
				this.myTimer = null;
			}
			if (this._conn2 != null)
			{
				this._conn2.close();
				this._conn2.removeEventListener(TcpEvent.Conneted, this.onConn);
				this._conn2.removeEventListener(TcpEvent.RecvMsg, this.ParseMsg);
				this._conn2 = null;
			}
			return;
		}// end function
		
	}
}