package tools
{
	public class PPTXInfo
	{
		private var _md5:String;
		private var _filepath:String;
		private var _filename:String;
		private var _date:Date;
		
		public function PPTXInfo() {}

		// getter and setter
		public function get date():Date { return _date; }
		public function set date(value:Date):void { _date = value; }
		public function get filename():String { return _filename; }
		public function set filename(value:String):void { _filename = value; }
		public function get filepath():String { return _filepath; }
		public function set filepath(value:String):void { _filepath = value; }
		public function get md5():String { return _md5; }
		public function set md5(value:String):void { _md5 = value; }
		
		
		// public functions
		
		// Read existing pptx informations from pptx_info
		public function readPPTXInfos(pptx_info_array:Array):Vector.<PPTXInfo> {
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
		
		
		
		// private functions
		
		private function removeExtension(str:String):String {
			
			
			if(str.substr(str.length-4, str.length-1) == "pptx") {
				str = str.substr(0, str.length-6);
			}
			else if(str.substr(str.length-3, str.length-1) == "ppt") {
				str = str.substr(0, str.length-5);
			}
			else {
				trace("This file is not a Microsoft PowerPoint file: " + str);
			}
			
			return str;
		}
		
	}
}