package
{
	import com.as3nui.nativeExtensions.air.kinect.Kinect;
	import com.as3nui.nativeExtensions.air.kinect.KinectSettings;
	import com.as3nui.nativeExtensions.air.kinect.constants.CameraResolution;
	import com.as3nui.nativeExtensions.air.kinect.events.PointCloudEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	public class Tracker extends Sprite
	{		
		public static var USER_ENTER:String = "enter";
		public static var USER_STOP:String = "stop";
		public static var USER_LEAVE:String = "leave";
		
		private var device:Kinect;
		private var renderData:BitmapData;
		private var render:Bitmap;
		private var wText:TextField;
		private var hText:TextField;
		private var prnt:DisplayObjectContainer;
		
		private var emulate:Boolean = false;
		
		private var hasUser:Boolean = false;
		private var hasUserTime:Date;
		
		private var camw:uint = 320;
		private var camh:uint = 240;		
		private var zmin:uint = 0;
		private var zmax:uint = 1100;
		private var gtop:Number = 0, gbot:Number = 0, gleft:Number = 0.2, gright:Number = 0.2;
		private var userHeight:uint = 0, userWeight:uint = 0;
		
		private var stopUserdelay:Number = 3000;
		private var logFunction:Function;
		
		public function Tracker(s:DisplayObjectContainer, f:Function = null)
		{
			super();			
			
			renderData = new BitmapData(camw, camh, false, 0xff000000);
			render = new Bitmap(renderData);
			render.y = 100;
			addChild(render);
			
			if (f != null) {
				logFunction = f;
			}
			s.addEventListener(KeyboardEvent.KEY_DOWN, control);
			
			if (Kinect.isSupported()) {
				log("Kinect supported");
				
				device = Kinect.getDevice();				
				
				device.addEventListener(PointCloudEvent.POINT_CLOUD_UPDATE, pointCloudUpdateHandler, false, 0, true);
				
				var settings:KinectSettings = new KinectSettings();				
				settings.pointCloudEnabled = true;
				settings.pointCloudResolution = CameraResolution.RESOLUTION_320_240;
				settings.pointCloudDensity = 5;
				device.start(settings);
								
				// info
				
				wText = new TextField();
				wText.textColor = 0xffffff;
				wText.y = 120;
				addChild(wText);
				
				hText = new TextField();
				hText.textColor = 0xffffff;
				hText.y = 140;
				addChild(hText);				
				
				log("Kinect inited");
				
			} else {
				log("No kinect, emulation mode");
				startEmulate();
			}				
		}
		
		private function pointCloudUpdateHandler(event:PointCloudEvent):void {
			
			renderData.fillRect(renderData.rect,0xff000000);
			renderData.fillRect(new Rectangle(camw*gleft, camh*gtop, camw*(1-gleft-gright), camh*(1-gtop-gbot)), 0xff222222);
			
			userHeight = 0; userWeight = 0;
			
			while (event.pointCloudData.bytesAvailable >= 6) {
				var x:Number = event.pointCloudData.readShort();
				var y:Number = event.pointCloudData.readShort();
				var z:Number = event.pointCloudData.readShort();
				
				if ((x > camw*gleft) && (x < camw*(1-gright)) && (y > camh*gtop) && (y < camh*(1 - gbot))) {
					if (z > zmin && z < zmax) {
						renderData.setPixel(x, y, 0xff0000);
						if (userHeight < (camh - y)) userHeight = camh - y;
						userWeight++; 
					}	
				} else {
					if (z > zmin && z < zmax) {
						renderData.setPixel(x, y, 0xffffff);
					}					
				}
			}	
			
			wText.text = "Weight: " + userWeight;
			hText.text = "Height: " + userHeight;
			
			if (userWeight > 5 && !hasUser) { 				
				dispatchEvent(new Event(Tracker.USER_ENTER));				
				addEventListener(Event.ENTER_FRAME, trackUser);				
				hasUserTime = new Date();
				hasUser = true;			
				log("User enter");
			} else if(userWeight < 5 && hasUser) {
				dispatchEvent(new Event(Tracker.USER_LEAVE));
				removeEventListener(Event.ENTER_FRAME, trackUser);
				hasUser = false;
				log("User leave");
			}
		}
		
		private function log(param:String):void
		{
			if (logFunction != null) {
				logFunction(param);
			} else {
				trace(param);
			}
			
		}
		
		private function trackUser(e:Event):void
		{
			if ((new Date().time) - hasUserTime.time > stopUserdelay) {
				dispatchEvent(new Event(Tracker.USER_STOP));
				removeEventListener(Event.ENTER_FRAME, trackUser);
				log("User stop");
			}
		}
		
		private function startEmulate():void
		{	
			emulate = true;				
		}	
		
		private function control(e:KeyboardEvent):void
		{
			// `
			if (emulate) {
				switch (e.keyCode) {
					case Keyboard.NUMBER_1:
						this.dispatchEvent(new Event(USER_ENTER));
						break;
					case Keyboard.NUMBER_2:
						this.dispatchEvent(new Event(USER_STOP));
						break;
					case Keyboard.NUMBER_3:
						this.dispatchEvent(new Event(USER_LEAVE));
						break;
				}
			}
		}
		
		public function getHeight():Number {
			if (emulate) {
				return Math.round(20 + Math.random()*5);
			} else {
				return userHeight;
			}
		}
		
		public function getWeight():Number {
			if (emulate) {
				return Math.round(200 + Math.random()*100);
			} else {
				return userWeight;
			}
		}
	}
}