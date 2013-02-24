package tools
{
	import events.NotificationEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.NativeProcessExitEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;

	public class Automator extends EventDispatcher
	{
		private var process:CommandLineProcess;
		private var stream:FileStream;
		
		public function Automator()
		{
			process = new CommandLineProcess();
			stream = new FileStream();
		}
		
		// search PPTX file with Spotlight
		// the result is written into pptx_paths file in the storage directory
		// return pptx_paths in List<String>
		public function searchPPTX():void {
			var installDirPath:String = File.applicationDirectory.resolvePath("automators").nativePath;
			process.appName = "automator";
			process.arguments = installDirPath + "/FindPPTXwithSpotlight.workflow";
			process.addEventListener(NativeProcessExitEvent.EXIT, finSearchPPTX);
			process.run();
		}
		
		public function createPDFandImages(filepath:String):void {
			
		}
		
		private function finSearchPPTX(event:NativeProcessExitEvent):void {
			var notificationEvent:NotificationEvent = new NotificationEvent("notificationEvent","FoundPPTX", null);
			this.dispatchEvent(notificationEvent);
		}
		
		private function finCreatePDFandImages(event:NativeProcessExitEvent):void {
			var notificationEvent:NotificationEvent = new NotificationEvent("notificationEvent","CreatedPDFandImages", null);
			this.dispatchEvent(notificationEvent);
		}
		
		
	}
}