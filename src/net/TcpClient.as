package net
{
		import flash.errors.IOError;
		import flash.events.Event;
		import flash.events.EventDispatcher;
		import flash.events.IOErrorEvent;
		import flash.events.ProgressEvent;
		import flash.events.SecurityErrorEvent;
		import flash.net.Socket;
		import flash.utils.ByteArray;
		
		import utils.TcpEvent;
		
		public class TcpClient extends EventDispatcher
		{
			public var is_connected:Boolean;
			private var _socket:Socket;
			private var read_len:int;
			private var packet_len:int;
			private var read_bytes:ByteArray;
			
			public function TcpClient()
			{
				this.is_connected = false;
				this.read_len = 0;
				return;
			}// end function
			
			public function connect(param1:String = null, param2:uint = 0) : void
			{
				this.close();
				this._socket = new Socket();
				this._socket.endian = "littleEndian";
				this._socket.addEventListener(Event.CLOSE, this.closeHandler);
				this._socket.addEventListener(Event.CONNECT, this.connectHandler);
				this._socket.addEventListener(IOErrorEvent.IO_ERROR, this.ioErrorHandler);
				this._socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.securityErrorHandler);
				this._socket.addEventListener(ProgressEvent.SOCKET_DATA, this.socketDataHandler);
				this._socket.connect(param1, param2);
				return;
			}// end function
			
			public function close() : void
			{
				if (this._socket != null)
				{
					this._socket.removeEventListener(Event.CLOSE, this.closeHandler);
					this._socket.removeEventListener(Event.CONNECT, this.connectHandler);
					this._socket.removeEventListener(IOErrorEvent.IO_ERROR, this.ioErrorHandler);
					this._socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.securityErrorHandler);
					this._socket.removeEventListener(ProgressEvent.SOCKET_DATA, this.socketDataHandler);
					this._socket.close();
					this._socket = null;
				}
				this.is_connected = false;
				return;
			}// end function
			
			public function sendmsg(param1:String) : Boolean
			{
				var str_byte:ByteArray;
				var pack_len:int;
				var head_byte:ByteArray;
				var str:* = param1;
				try
				{
					str_byte = new ByteArray();
					str_byte.endian = "littleEndian";
					str_byte.writeUTFBytes(str);
					str_byte.writeByte(0);
					pack_len = 8 + str_byte.length;
					head_byte = new ByteArray();
					head_byte.endian = "littleEndian";
					head_byte.writeUnsignedInt(pack_len);
					head_byte.writeShort(689);
					head_byte.writeByte(0);
					head_byte.writeByte(0);
					if (this._socket != null)
					{
						this._socket.writeUnsignedInt(pack_len);
						this._socket.writeBytes(head_byte);
						this._socket.writeBytes(str_byte);
						this._socket.flush();
					}
				}
				catch (e:IOError)
				{
					this.close();
					return false;
				}
				return true;
			}// end function
			
			private function parseNetData() : void
			{
				var _loc_1:int;
				var _loc_2:int;
				var _loc_3:String;
				if (this._socket != null)
				{
					if (this.read_len == 0)
					{
						if (this._socket.bytesAvailable < 4)
						{
							return;
						}
						this.packet_len = this._socket.readInt();
						this.read_len = this.read_len + 4;
					}
					if (this.read_len == 4)
					{
						if (this._socket.bytesAvailable < this.packet_len)
						{
							return;
						}
						this.read_bytes = new ByteArray();
						this.read_bytes.endian = "littleEndian";
						this._socket.readBytes(this.read_bytes, 0, this.packet_len);
						this.read_len = 0;
						_loc_1 = this.read_bytes.readInt();
						_loc_2 = this.read_bytes.readUnsignedShort();
						this.read_bytes.readByte();
						this.read_bytes.readByte();
						_loc_3 = this.read_bytes.readUTFBytes(this.read_bytes.length - 8);
						this.dispatchEvent(new TcpEvent(TcpEvent.RecvMsg, _loc_3));
					}
					if (this._socket != null)
					{
						if (this._socket.bytesAvailable > 0)
						{
							this.parseNetData();
						}
					}
				}
				return;
			}// end function
			
			private function closeHandler(param1:Event) : void
			{
				trace("console.log", "Tcp Close [%s]", param1.toString());
				this.dispatchEvent(new TcpEvent(TcpEvent.Closed));
				this.close();
				return;
			}// end function
			
			private function connectHandler(param1:Event) : void
			{
				trace("console.log", "Tcp Connected [%s]", param1.toString());
				this.is_connected = true;
				this.dispatchEvent(new TcpEvent(TcpEvent.Conneted));
				return;
			}// end function
			
			private function ioErrorHandler(param1:IOErrorEvent) : void
			{
				trace("console.log", "Tcp Error IO [%s]", param1.toString());
				this.dispatchEvent(new TcpEvent(TcpEvent.Error));
				this.close();
				return;
			}// end function
			
			private function securityErrorHandler(param1:SecurityErrorEvent) : void
			{
				trace("console.log", "Tcp Error Security [%s]", param1.toString());
				this.dispatchEvent(new TcpEvent(TcpEvent.Error));
				this.close();
				return;
			}// end function
			
			private function socketDataHandler(param1:ProgressEvent) : void
			{
				this.parseNetData();
				return;
			}// end function
		
	}
}