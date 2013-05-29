package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import spark.effects.AddAction;
	
	public class Tracker extends Sprite
	{		
		public static var USER_ENTER:String = "enter";
		public static var USER_STOP:String = "stop";
		public static var USER_LEAVE:String = "leave";
		
		public function Tracker()
		{
			super();
			emulate();
		}
		
		private function emulate():void
		{
			addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void {
				stage.addEventListener(KeyboardEvent.KEY_DOWN, emulateByKey);
			});		
		}	
		
		private function emulateByKey(e:KeyboardEvent):void
		{
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
				
		public function getHeight():Number {
			return Math.round(20 + Math.random()*5);
		}
		
		public function getWeight():Number {
			return Math.round(200 + Math.random()*100);
		}
	}
}