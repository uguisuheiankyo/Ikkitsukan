package tools
{
	import events.NotificationEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.NativeProcessExitEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;

	public class Automator extends EventDispatcher
	{
		private var process:CommandLineProcess;
		private var stream:FileStream;
		
		private var tmp_pptx_info:PPTXInfo; // need to delete this variable 
		private var installDirPath:String = File.applicationDirectory.resolvePath("automators").nativePath;
		
		public function Automator()
		{
			process = new CommandLineProcess();
			stream = new FileStream();
		}
		
		// search PPTX file with Spotlight
		// the result is written into pptx_paths file in the storage directory
		// return pptx_paths in List<String>
		public function searchPPTX():void {
			var args:Vector.<String> = new Vector.<String>;
			args.push(installDirPath + "/FindPPTXwithSpotlight.workflow");
			process.appName = "automator";
			process.arguments = args;
			process.addEventListener(NativeProcessExitEvent.EXIT, finSearchPPTX);
			process.run();
		}
		
		public function createPDFandImages(pptx_info:PPTXInfo):void {
			//var process:CommandLineProcess = new CommandLineProcess();
			var args:Vector.<String> = new Vector.<String>;
			args.push("-i");
//			args.push("/Users/Desktop//Users/Hiroyuki/Desktop/プレゼンテーション2.pptx");
//			args.push(installDirPath + "/CreatePDFandImages.workflow");
//			args.push("/usr/bin/automator");
//			args.push("-i");
//			args.push("/Users/Desktop//Users/Hiroyuki/Desktop/presentation.pptx");
//			args.push(installDirPath + "/CreatePDFandImages.workflow");
			args.push(pptx_info.filepath);
			args.push(installDirPath + "/CreatePDFandImages.workflow");
			process.appName = "automator";
			process.arguments = args;
			process.addEventListener(NativeProcessExitEvent.EXIT, finCreatePDFandImages);
			//process.addEventListener("notificationEvent", divideUpPDFandImages);
			this.tmp_pptx_info = pptx_info;
			process.run();
		}
		
		public function moveIn2Directory(orgpath:String, destpath:String):void {
			orgpath = orgpath.substr(0, orgpath.length - 4) + "pdf";
			trace(orgpath);
			trace(destpath);
			var original:File = new File(orgpath);
			var destination:File = new File(destpath);
			trace("original: " + original.exists);
			trace("destination: " + destination.exists);
			original.addEventListener(Event.COMPLETE, fileMoveCompleteHandler); 
			original.addEventListener(IOErrorEvent.IO_ERROR, fileMoveIOErrorEventHandler); 
			original.moveTo(destination);
//			var args:Vector.<String> = new Vector.<String>;
//			args.push(filepath);
//			args.push(dirpath);
//			process.appName = "mv";
//			process.arguments = args;
//			trace("filepath: " + filepath);
//			trace("mv " + process.arguments[0]);
//			process.addEventListener(NativeProcessExitEvent.EXIT, finMoveIn2Directory);
//			process.run();
		}
		
		
		// Event Handlers
		
		private function finSearchPPTX(event:NativeProcessExitEvent):void {
			var notificationEvent:NotificationEvent = new NotificationEvent("notificationEvent","FoundPPTX", null);
			this.dispatchEvent(notificationEvent);
		}
		
		private function finCreatePDFandImages(event:NativeProcessExitEvent):void {
			var notificationEvent:NotificationEvent = new NotificationEvent("notificationEvent","RenovatedPPTXInfo", null); // For debug
			this.divideUpPDFandImages(this.tmp_pptx_info);
			//var notificationEvent:NotificationEvent = new NotificationEvent("notificationEvent","CreatedPDFandImages", null);
			this.dispatchEvent(notificationEvent);
			//var notificationEvent2:NotificationEvent = new NotificationEvent("notificationEvent","CreatedPDFandImages",this.tmp_pptx_info);
			//process.dispatchEvent(notificationEvent2);
		}
		
		private function finMoveIn2Directory(event:NativeProcessExitEvent):void {
			var notificationEvent:NotificationEvent = new NotificationEvent("notificationEvent","MovedIn2Direcotry", null);
			this.dispatchEvent(notificationEvent);
		}
		
		private function fileMoveCompleteHandler(event:Event):void { 
			trace("Complete to move " + event.target); // [object File] 
		} 
		private function fileMoveIOErrorEventHandler(event:IOErrorEvent):void { 
			trace("I/O Error.");  
		} 
		
		
		
		private function divideUpPDFandImages(pptx_info:PPTXInfo):void {
			//var pptx_info:PPTXInfo = event.value as PPTXInfo;
			var presDir:File = File.applicationStorageDirectory.resolvePath("presentations");
			
			// Create a directory is named itseleves' md5.
			var indivisualDir:File = presDir.resolvePath(pptx_info.md5);
			if(!indivisualDir.exists) {
				indivisualDir.createDirectory();
			}
			
			// Create a pdf directory into the indivisual directory
			var pdfDir:File = indivisualDir.resolvePath("pdf");
			if(!pdfDir.exists) {
				pdfDir.createDirectory();
			}
			
			// Move the pdf file into the created pdf directory
			trace("MD5 direcotry is " + indivisualDir.exists);
			//trace(pdfDir.nativePath);
			moveIn2Directory(presDir.resolvePath("tmp_pdf").nativePath +"/" + pptx_info.filename, pdfDir.nativePath + "/" + pptx_info.filename);
			//moveIn2Directory(presDir.resolvePath("tmp_pdf").nativePath +"/" + pptx_info.filename, pdfDir.nativePath);
		}
		
		
	}
}