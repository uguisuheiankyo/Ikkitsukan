package tools
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class Indexing
	{
		private var process:CommandLineProcess;
		private var stream:FileStream;
		private var sdDir:File;
		private var presDir:File;
		private var pptx_info:File;
		
		public function Indexing()
		{
			process = new CommandLineProcess();
			stream = new FileStream();
			sdDir = File.applicationStorageDirectory;
		}
		
		public function run():void {
		    
		}
		
		// Check the state in StorageDirectory
		public function initialize():void {
			
			// Check "presentations" directory exists in sdDirectory
			presDir = sdDir.resolvePath("presentations");
			if(!presDir.exists) {
				presDir.createDirectory();
			}
			
			// Check "pptx_info" file exists in presDirectory
			pptx_info = presDir.resolvePath("pptx_info");
			if(!pptx_info.exists) {
				stream.open(pptx_info, FileMode.WRITE);
				stream.writeUTFBytes("");
				stream.close();
			}
		}
		
		
	}
}