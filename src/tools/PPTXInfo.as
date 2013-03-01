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
		
	}
}