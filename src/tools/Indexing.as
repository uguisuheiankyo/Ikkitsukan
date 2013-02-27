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
		private var tmp_pptx_info:Vector.<PPTXInfo>;
		
		// flags for first indexing
	    private var flag_initialize:Boolean = false;
		private var flag_findPPTX:Boolean = false;
		private var flag_getPPTXPaths:Boolean = false;
		private var flag_renovatePPTXInfo:Boolean = false;
		private var flag_loadExistingPPTXInfo:Boolean = false;
		
		private const PPTX_INFO_FILE:String = "pptx_info.txt";
		
		// Constructor
		public function Indexing()
		{
			automator = new Automator();
			tmp_pptx_info = new Vector.<PPTXInfo>;
		}
		
		// getter and setter
		public function get allPPTXPaths():Array { return _allPPTXPaths; }
		public function get pptx_infos():Vector.<PPTXInfo> { return _pptx_infos; }

		public function run():void {
			
			// Check the state in StorageDirectory
			if(!flag_initialize)  initialize();
			
		    // Find all pptx files in this machine
			else if(!flag_findPPTX) findPPTX();
			
			// Get all paths of all pptx files
			else if(!flag_getPPTXPaths) getPPTXPaths();
			
			// Load the existing pptx_info file
			else if(!flag_loadExistingPPTXInfo) loadExistingPPTXInfo();
			
			// Renovate pptx_info file
			else if(!flag_renovatePPTXInfo) renovatePPTXInfo();
		}
		
		
		private function notificationEventHandler(event:NotificationEvent):void {
			trace(event.notification);
			switch(event.notification) {
				case "Initialized":
					flag_initialize = true; run(); break;
				case "FoundPPTX":
					flag_findPPTX = true; run(); break;
				case "GotPPTXPaths":
					flag_getPPTXPaths = true; run(); break;
				case "LoadedExistingPPTXInfo":
					flag_loadExistingPPTXInfo = true; run(); break;
				case "RenovatedPPTXInfo":
					flag_renovatePPTXInfo = true; run(); break;
				case "CreatedPDFandImages":
					trace(this.tmp_pptx_info.length);
					if(this.tmp_pptx_info.length != 0) { automator.createPDFandImages(tmp_pptx_info.pop()); }
					break;
			}
		}
		
		// Check the state in StorageDirectory
		public function initialize():void {
						
			// Create .sd_path file which has the path of presDir in user directory
			var sd_path:File = File.userDirectory.resolvePath(".sd_path");
			if(!sd_path.exists) {
				writeText(sd_path,presDir.nativePath);
			}
			
			// Check "presentations" directory exists in sdDirectory
			presDir = File.applicationStorageDirectory.resolvePath("presentations");
			if(!presDir.exists) {
				presDir.createDirectory();
			}
			
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
			trace("Find " + _allPPTXPaths.length + " files");
			notificationEventHandler(new NotificationEvent("notificationEvent", "GotPPTXPaths", null));
		}
		
		// Check pptx_infos with old pptx_infos
		private function loadExistingPPTXInfo():void {
			trace("Loading... pptx_info file");
			var pptx_info_txt:File = presDir.resolvePath(PPTX_INFO_FILE);
			var pptx_info_array:Array = readLines(pptx_info_txt);
			_pptx_infos = this.readPPTXInfos(pptx_info_array);
			notificationEventHandler(new NotificationEvent("notificationEvent", "LoadedExistingPPTXInfo", null));
		}
		
		// Renovate md5, filepath, name, date informations in pptx_info
		public function renovatePPTXInfo():void {
			
			// If the pptx_info file is empty,
			// all pptx files will be registered into pptx_info
			var pptx_path:String;
			if(_pptx_infos == null) {
				_pptx_infos = new Vector.<PPTXInfo>;
				for each( pptx_path in _allPPTXPaths) {
					trace("Adding... " + pptx_path);
					_pptx_infos.push(getPPTXInfo(pptx_path));
					//automator.createPDFandImages(pptx_info);
					this.tmp_pptx_info.push(pptx_info);
				}
			}
			
			else {
				var pptx_info:PPTXInfo;
				var indexOfSameMD5:int;
				var indexOfSameFilepath:int;
				for each(pptx_path in _allPPTXPaths) {
					pptx_info = getPPTXInfo(pptx_path);
					indexOfSameMD5 = hasSameMD5(pptx_info.md5);
					indexOfSameFilepath = hasSameFilepath(pptx_info.filepath);
					
					if( indexOfSameMD5 >= 0) {
						if( pptx_info.filepath == _pptx_infos[indexOfSameMD5].filepath ) {
							// old pptx_info file already has this pptx informations.
							trace("Don't need to renovate: " + pptx_info.filepath);
						}
						else {
							// old pptx_info file already has the same md5 value as to this pptx.
							// need to renovate file path.
							// If there are duplicated files, this system will choice only one pptx file.
							trace("Change " + _pptx_infos[indexOfSameMD5].filepath + " to " + pptx_info.filepath);
							_pptx_infos[indexOfSameMD5].filepath = pptx_info.filepath;
						}
					}
					else if( indexOfSameFilepath >= 0 ) {
						// old pptx_info file already has has the same filepath.
						// need to delete pptx_infos[i] and create anew one
						// because the previous file had the same filepath was edited or deleted.
						_pptx_infos.splice(indexOfSameFilepath,indexOfSameFilepath);
						_pptx_infos.push(pptx_info);
						//automator.createPDFandImages(pptx_info);
						this.tmp_pptx_info.push(pptx_info);
						trace("Adding... " + pptx_info.filepath);
					}
					else {
						// old pptx_info file doesn't have this pptx_info.
						// need to add all pptx_info and create the pdf and images.
						_pptx_infos.push(pptx_info);
						//automator.createPDFandImages(pptx_info);
						this.tmp_pptx_info.push(pptx_info);
						trace("Adding... " + pptx_info.filepath);
					}
				}
			}
			
			// 2013-02-28
			automator.createPDFandImages(tmp_pptx_info.pop());
			this.flag_renovatePPTXInfo = true;
			
			// Write pptx_infos into the pptx_info file
			writePPTXInfos(_pptx_infos);
			trace("Writing... " + PPTX_INFO_FILE);
		}
		
		// Register pptx_info
		private function getPPTXInfo(pptx_path:String):PPTXInfo {
			var crypto:Crypto = new Crypto();
			var pptx:File = new File(pptx_path);
			var pptx_info:PPTXInfo = new PPTXInfo();
			pptx_info.filename = pptx.name;
			pptx_info.filepath = pptx.nativePath;
			pptx_info.md5 = crypto.cryptoMD5(pptx);
			pptx_info.date = new Date();
			return pptx_info;
		}
		
		// Read existing pptx informations from pptx_info
		private function readPPTXInfos(pptx_info_array:Array):Vector.<PPTXInfo> {
			var pptx_infos:Vector.<PPTXInfo> = new Vector.<PPTXInfo>;
			
			// There is no informations in pptx_info file
			if(pptx_info_array[0] == "") {
				pptx_infos = null;
			}
			
			else {
				for each(var pptx_info_raw:String in pptx_info_array) {
					var pptx_info:PPTXInfo = new PPTXInfo();
					var array:Array = pptx_info_raw.split(",");
					pptx_info.md5 = array[0];
					pptx_info.filepath = array[1];
					pptx_info.filename = array[2];
					pptx_info.date = new Date(array[3]);
					pptx_infos.push(pptx_info);
				}
			}
			
			return pptx_infos;
		}
		
		// Write pptx_infos to the pptx_info file
		private function writePPTXInfos(pptx_infos:Vector.<PPTXInfo>):void {
			var str:String = "";
			for each(var pptx_info:PPTXInfo in _pptx_infos) {
				str += pptx_info.md5 + "," + pptx_info.filepath + "," + pptx_info.filename + "," + pptx_info.date.toString() + "\n";
			}
			writeText(presDir.resolvePath(PPTX_INFO_FILE),str.substr(0,str.length-2)); // delete the last of "\n"
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
		
		//////////////////////////////////
		// pptx_infosのクラス化の必要あり
		//////////////////////////////////
		private function hasSameMD5(md5:String):int {
			for( var i:int = _pptx_infos.length-1; i >= 0; i--) {
				if( md5 == _pptx_infos[i].md5 ) {
					return i;
				}
			}
			return -1;
		}
		
		private function hasSameFilepath(filepath:String):int {
			for( var i:int = _pptx_infos.length-1; i >= 0; i--) {
				if( filepath == _pptx_infos[i].filepath ) {
					return i;
				}
			}
			return -1;
		}
		
	}
}