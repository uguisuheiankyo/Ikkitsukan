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
	import flash.events.EventDispatcher;
	import flash.events.NativeProcessExitEvent;
	import flash.filesystem.File;
	import flash.events.Event;	
	import mx.controls.Alert;

	public class CommandLineProcess extends EventDispatcher
	{
		private var _appName:String;
		private var _arguments:String;
		private var process:NativeProcess;
		private var nativeProcessStartupInfo:NativeProcessStartupInfo;
		
		public function CommandLineProcess() {
			process = new NativeProcess();
			nativeProcessStartupInfo = new NativeProcessStartupInfo();
		}
		
		// getter and setter
		public function get arguments():String { return _arguments; }
		public function set arguments(value:String):void { _arguments = value; }
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
			var args:Vector.<String> = new Vector.<String>();
			args.push(_arguments);
			
			// 実行情報の指定
			nativeProcessStartupInfo.executable = appFile;
			nativeProcessStartupInfo.arguments = args;
			
			// 実行
			process.start(nativeProcessStartupInfo);
			process.addEventListener(NativeProcessExitEvent.EXIT, relay);
		    
		}
		
		// Dispatch Events to the NativeApplication 
		public function relay(event:Event):void{
			this.dispatchEvent(event);
		}
		
		// Add application names and paths in a following function
		private function getAppPath(appName:String):String {
			switch(appName) {
				case "Automator":
					return "/usr/bin/automaor";
				case "Say":
					return "/usr/bin/say";
				default:
					return null;
			}
		}
	}
}