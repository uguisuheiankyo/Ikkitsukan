package tools
/* A Sample to use this class
 * var process:CommandLineProcess = new CommandLineProcess;
 * process.appName = "Say";
 * process.arguments = "Hello World.";
 * process.addEventListener(NativeProcessExitEvent.EXIT, exitHandler);
 * process.run();
 */
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;

	public class CommandLineProcess extends EventDispatcher
	{
		private var _appName:String;
		private var _arguments:Vector.<String>;
		private var process:NativeProcess;
		private var nativeProcessStartupInfo:NativeProcessStartupInfo;
		private var _outputData:String; // For Debug
		
		public function CommandLineProcess() {
			process = new NativeProcess();
			nativeProcessStartupInfo = new NativeProcessStartupInfo();
		}
		
		// getter and setter
		public function get arguments():Vector.<String> { return _arguments; }
		public function set arguments(value:Vector.<String>):void { _arguments = value; }
		public function get appName():String { return _appName; }
		public function set appName(value:String):void { _appName = value; }
		
		// execute process
		public function run():void{
			//アプリケーションのパスを取得
			var appPath:String = getAppPath(appName);
			
			if(appPath == null) {
				Alert.show(appName + " が通常の場所に存在しません。\n" + appName + ".appを選択してください");
				// ファイル選択ウィンドウを起動
			}
			
			var appFile:File = new File(appPath);
			if(!appFile.exists) {
				Alert.show(appFile.name + " app doesn't exist.");
				return;
			}
			
			// 引数指定
			var args:Vector.<String> = _arguments;
			
			// 実行情報の指定
			nativeProcessStartupInfo.executable = appFile;
			nativeProcessStartupInfo.arguments = args;
			
			// リスナー
			process.addEventListener(NativeProcessExitEvent.EXIT, relay);
			process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOutputData);
			process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onErrorData);
			process.addEventListener(NativeProcessExitEvent.EXIT, onExit);
			process.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onIOError);
			process.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, onIOError);
			
			// 実行
			process.start(nativeProcessStartupInfo);
		}
		
		// stop process
		public function stop():void {
			process.exit(true);
		}
		
		// Dispatch Events to the NativeApplication 
		public function relay(event:Event):void{
			this.dispatchEvent(event);
		}
		
		// Add application names and paths in a following function
		private function getAppPath(appName:String):String {
			switch(appName) {
				case "automator":
					return "/usr/bin/automator";
				case "open":
					return "/usr/bin/open";
				case "mv":
					return "/bin/mv";
				case "say":
					return "/usr/bin/say";
				case "pwd":
					return "/bin/pwd";
				default:
					return appName;
			}
		}
		
		//////////////
		// For Debug
		//////////////
		
		public function onOutputData(event:ProgressEvent):void {
			_outputData = process.standardOutput.readUTFBytes(process.standardOutput.bytesAvailable).toString();
			trace("Got: ", _outputData); 
		}
		public function onErrorData(event:ProgressEvent):void {
			_outputData = process.standardError.readUTFBytes(process.standardError.bytesAvailable).toString();
			trace("ERROR -", _outputData); 
		}
		public function onExit(event:NativeProcessExitEvent):void {
			_outputData = event.exitCode.toString();
			trace("Process exited with ", _outputData);
		}
		public function onIOError(event:IOErrorEvent):void {
			_outputData = event.toString();
			trace(_outputData);
		}
		public function get outputData():String {
			return _outputData;
		}
	}
}