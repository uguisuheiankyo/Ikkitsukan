package tools
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;

	public class Indexing
	{
		private var process:CommandLineProcess;
		private var stream:FileStream;
		private var sdDir:File;
		private var presDir:File;
		private var pptx_info:File;
		private var crypto:Crypto;
		
		public function Indexing()
		{
			process = new CommandLineProcess();
			stream = new FileStream();
			sdDir = File.applicationStorageDirectory;
			crypto = new Crypto();
		}
		
		public function run():void {
		    // 
			var pptx:File = new File("/Users/Hiroyuki/Desktop/example.pptx");
			crypto.cryptoMD5(pptx);
			
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