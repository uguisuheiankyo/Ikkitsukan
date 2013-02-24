package tools
{
	import flash.events.NativeProcessExitEvent;
	import flash.filesystem.FileStream;
	import flash.filesystem.File;

	public class Automator
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
			process.run();
		}
	}
}