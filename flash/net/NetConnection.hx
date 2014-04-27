package flash.net;


import flash.events.EventDispatcher;
import flash.events.NetStatusEvent;


class NetConnection extends EventDispatcher {
	
	
	public static inline var CONNECT_SUCCESS:String = "connectSuccess";
	
	
	public function new ():Void {
		
		super ();
		
	}
	
	
	public function connect (command:String, ?_, ?_, ?_, ?_, ?_):Void {
		
		if (command != null) {
			
			throw "Error: Can only connect in \"HTTP streaming\" mode";
			
		}
		
		this.dispatchEvent (new NetStatusEvent (NetStatusEvent.NET_STATUS, false, true, { code:NetConnection.CONNECT_SUCCESS }));
		
	}
	
	
}