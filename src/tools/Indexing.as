package tools
{
	import events.NotificationEvent;
	
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	import spark.components.List;

	public class Indexing
	{
		// private variables with getter and setter
		private var _allPPTXPaths:Array;
		private var _pptx_infos:Vector.<PPTXInfo>
		
		// private variables
		private var presDir:File;
		private var automator:Automator;
		
		// flags for first indexing
	    private var flag_initialize:Boolean = false;
		private var flag_findPPTX:Boolean = false;
		private var flag_getPPTXPaths:Boolean = false;
		private var flag_renovatePPTXInfo:Boolean = false;
		
		private const PPTX_INFO_FILE:String = "pptx_info.txt";
		
		// Constructor
		public function Indexing()
		{
			automator = new Automator();
		}
		
		// getter and setter
		public function get allPPTXPaths():Array { return _allPPTXPaths; }
		//public function set allPPTXPaths(value:Array):void { _allPPTXPaths = value; }
		public function get pptx_infos():Vector.<PPTXInfo> { return _pptx_infos; }
		//public function set pptx_infos(value:Vector.<PPTXInfo>):void { _pptx_infos = value; }

		public function run():void {
			
			// Check the state in StorageDirectory
			if(!flag_initialize)  initialize();
			
		    // Find all pptx files in this machine
			else if(!flag_findPPTX) findPPTX();
			
			// Get all paths of all pptx files
			else if(!flag_getPPTXPaths) getPPTXPaths();
			
			// Check md5 value of pptx and compare with other md5 in pptx_info
			else if(!flag_renovatePPTXInfo) renovatePPTXInfo();
		}
		
		
		private function notificationEventHandler(event:NotificationEvent):void {
			trace(event.notification);
			switch(event.notification) {
				case "Initialized":
					flag_initialize = true; run(); break;
				case "FoundPPTX":
					flag_findPPTX = true; run(); break;
					break;
				case "GotPPTXPaths":
					flag_getPPTXPaths = true; run(); break;
				case "RenovatedPPTXInfo":
					flag_renovatePPTXInfo = true; run(); break;
					break;
			}
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
			var pptx_info_txt:File = presDir.resolvePath("pptx_info.txt");
			if(!pptx_info_txt.exists) {
				writeText(pptx_info_txt,"");
			}
			
			//
			notificationEventHandler(new NotificationEvent("notificationEvent", "Initialized", null));
		}
		
		// Find all PPTX files in this machine
		public function findPPTX():void {
			automator.searchPPTX();
			automator.addEventListener("notificationEvent", notificationEventHandler);
		}
		
		// Get all paths of all pptx files;
		public function getPPTXPaths():void {
			var file:File = presDir.resolvePath("pptx_paths.txt");
			_allPPTXPaths = readLines(file);
			trace("Find " + _allPPTXPaths.length + "files");
			notificationEventHandler(new NotificationEvent("notificationEvent", "GotPPTXPaths", null));
		}
				
		// Renovate md5, name, date informations in pptx_info
		public function renovatePPTXInfo():void {
			var pptx_info_txt:File = presDir.resolvePath(PPTX_INFO_FILE);
			var pptx_info_raws:Array = readLines(pptx_info_txt);
			trace("\"" + pptx_info_raws.length + "\"");
			
			// If the pptx_info file is empty,
			// all pptx files will be registered into pptx_info
			_pptx_infos = new Vector.<PPTXInfo>;
			if(pptx_info_raws.length == 1 && pptx_info_raws[0] == "") {
				for each( var pptx_path:String in _allPPTXPaths) {
					trace("Indexing... " + pptx_path);
					_pptx_infos.push(registerPPTXInfo(pptx_path));
				}
				// Write pptx_infos into the pptx_info file
				writePPTXInfos(_pptx_infos);
			}
				
			else {
				
			}	
		}
		
		// If add md5 value anew,
		// Create a pdf file and extract images in ppt,pptx.
		
		
		
		// Register pptx_info
		private function registerPPTXInfo(pptx_path:String):PPTXInfo {
			var crypto:Crypto = new Crypto();
			var pptx:File = new File(pptx_path);
			var pptx_info:PPTXInfo = new PPTXInfo();
			pptx_info.filename = pptx.name;
			pptx_info.filepath = pptx.nativePath;
			pptx_info.md5 = crypto.cryptoMD5(pptx);
			pptx_info.date = new Date();
			return pptx_info;
		}
		
		// Store old pptx_infos
		private function readPPTXInfo(pptx_info_raws:Array):void {
			var old_pptx_infos:Vector.<PPTXInfo> = new Vector.<PPTXInfo>;
			for each(var pptx_info_raw:String in pptx_info_raws) {
				var old_pptx_info:PPTXInfo = new PPTXInfo();
				var array:Array = pptx_info_raw.split(",");
				old_pptx_info.md5 = array[0];
				old_pptx_info.filepath = array[1];
				old_pptx_info.filename = array[2];
				old_pptx_info.date = array[3];
				old_pptx_infos.push(old_pptx_info);
			}
		}
		
		// Write pptx_infos to the pptx_info file
		private function writePPTXInfos(pptx_infos:Vector.<PPTXInfo>):void {
			var str:String = "";
			for each(var pptx_info:PPTXInfo in pptx_infos) {
				trace("Recording... " + pptx_info.filepath);
				str += pptx_info.md5 + "," + pptx_info.filepath + "," + pptx_info.filename + "," + pptx_info.date.toString() + "\n";
			}
			writeText(presDir.resolvePath(PPTX_INFO_FILE),str);
		}
		
		// Read Lines from a text file and Store each line into an array
		private function readLines(file:File):Array {
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			var str:String = stream.readMultiByte(file.size, File.systemCharset);
			stream.close();
			return str.split(/\n/);
		}
		
		// Write str into the file.
		private function writeText(file:File, str:String):void {
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeUTFBytes(str);
			stream.close();
		}
		
		// pptx_infos has the same md5 as to an new pptx
		private function hasSameMD5(md5:String, pptx_infos:Vector.<PPTXInfo>):Boolean {
			for( var i:int = pptx_infos.length-1; i >= 0; i--) {
				if( md5 == pptx_infos[i].md5 ) return true;
			}
			return false;
		}
		
		// pptx_infos has the same filepath as to an new pptx
		private function hasSameFilepath(filepath:String, pptx_infos:Vector.<PPTXInfo>):Boolean {
			for( var i:int = pptx_infos.length-1; i >= 0; i--) {
				if( filepath == pptx_infos[i].filepath ) return true;
			}
			return false;
		}
	}
}