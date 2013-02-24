package events
{
	import flash.events.Event;

	public class NotificationEvent extends Event
	{
		public var notification:String;
		public var value:Object;
		
		public function NotificationEvent(type:String, notification:String, value:Object)
		{
			super(type);
			this.notification = notification;
			this.value = value;
		}
	}
}