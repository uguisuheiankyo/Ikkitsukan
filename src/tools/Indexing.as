package tools
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;

	public class Indexing
	{
		private var presDir:File;
		private var pptx_info:File;
		private var crypto:Crypto;
		private var automator:Automator;
		
		public function Indexing()
		{
			crypto = new Crypto();
			automator = new Automator();
		}
		
		public function run():void {
		    // 
			
		}
		
		// Check the state in StorageDirectory
		public function initialize():void {
						
			// Check "presentations" directory exists in sdDirectory
			presDir = File.applicationStorageDirectory.resolvePath("presentations");
			if(!presDir.exists) {
				presDir.createDirectory();
			}
			
			// Create .sd_path file which has the path of presDir in user directory
			var sd_path:File = File.userDirectory.resolvePath(".sd_path");
			writeText(sd_path,presDir.nativePath);
			
			// Check "pptx_info" file exists in presDirectory
			pptx_info = presDir.resolvePath("pptx_info");
			if(!pptx_info.exists) {
				writeText(pptx_info,"");
			}
		}
		
		// Check md5 value of pptx and compare with other md5 in pptx_info
		public function checkMD5():void {
			automator.searchPPTX();
			//var pptx:File = new File("/Users/Hiroyuki/Desktop/example.pptx");
			//crypto.cryptoMD5(pptx);		
		}
		
		// Renovate md5, name, date informations in pptx_info
		public function renovatePPTXInfo():void {
			
		}
		
		// If add md5 value anew,
		// Create a pdf file and extract images in ppt,pptx.
		
		
		private function writeText(file:File, str:String):void {
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeUTFBytes(str);
			stream.close();
		}
	}
}