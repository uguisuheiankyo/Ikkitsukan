package tools
{
	import events.NotificationEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class Automator extends EventDispatcher
	{
		private var process:CommandLineProcess;
		private var stream:FileStream;
		
		private var tmp_pinfo:PPTXInfo;
		private var tmp_slidenums:Vector.<Number>;
		private var automatorDirPath:String = File.applicationDirectory.resolvePath("automators").nativePath;
		
		public function Automator()
		{
			process = new CommandLineProcess();
			stream = new FileStream();
		}
		
		
		////////////////////////////////////////////////////////////////////////////
		// Public Functions
		////////////////////////////////////////////////////////////////////////////
		
		// Search pptxes with Spotlight
		// The result is written into pptx_paths file in the storage directory
		public function searchPPTX():void {
			var args:Vector.<String> = new Vector.<String>;
			args.push(automatorDirPath + "/FindPPTXwithSpotlight.workflow");
			process.appName = "automator";
			process.arguments = args;
			process.addEventListener(NativeProcessExitEvent.EXIT, finSearchPPTX);
			process.run();
		}
		
		// Create a pdf and Images from a pptx
		public function createPDFandImages(pptx_info:PPTXInfo):void {
			var args:Vector.<String> = new Vector.<String>;
			args.push("-i");
			args.push(pptx_info.filepath);
			args.push(automatorDirPath + "/CreatePDFandImages.workflow");
			process.appName = "automator";
			process.arguments = args;
			process.addEventListener(NativeProcessExitEvent.EXIT, finCreatePDFandImages);
			process.run();
			this.tmp_pinfo = pptx_info;
		}
		
		// Draw a specified number of slide from pptx
		public function selectSlides(pptx_info:PPTXInfo, slidenums:Vector.<Number>):void {
			var workflow:File = new File(automatorDirPath + "/SelectSlides.workflow/Contents/document.wflow");
			
			// Load the source code of the workflow
			var array:Array = readLines(workflow);
			
			// The line number will be revise to the specified number of the slide in pptx
			var slidenum:Number = slidenums.pop();
			array[274] = "					<real>"+slidenum+"</real>";
			array[278] = "					<real>"+slidenum+"</real>";
			
			// Write the revised source code to original workflow file
			var str:String = "";
			for each(var line:String in array) {
				str += line + "\n";
			}
			writeText(workflow, str);
			
			// Execute Automator
			var args:Vector.<String> = new Vector.<String>;
			args.push("-i");
			args.push(pptx_info.filepath);
			args.push(automatorDirPath + "/SelectSlides.workflow");
			process.appName = "automator";
			process.arguments = args;
			process.addEventListener(NativeProcessExitEvent.EXIT, extractSlides);
			process.run();
			this.tmp_pinfo = pptx_info;
			this.tmp_slidenums = slidenums;
		}

		// Draw several slides from pptx
		public function extractSlides(event:NativeProcessExitEvent):void {
			if(tmp_slidenums.length != 0) {
				selectSlides(this.tmp_pinfo, this.tmp_slidenums);
			}
			else {
				process.removeEventListener(NativeProcessExitEvent.EXIT, extractSlides);
				exitPowerPoint();
			}
		}
		
		// Exit PowerPoint Application
		public function exitPowerPoint():void {
			var args:Vector.<String> = new Vector.<String>;
			args.push(automatorDirPath + "/ExitPowerPoint.workflow");
			process.appName = "automator";
			process.arguments = args;
			process.addEventListener(NativeProcessExitEvent.EXIT, finExitPowerPoint);
			process.run();
		}
		
		////////////////////////////////////////////////////////////////////////////
		// Private Functions
		////////////////////////////////////////////////////////////////////////////
		
		// Divide up PDF and Images into each unique folder
		private function divideUpPDFandImages(pptx_info:PPTXInfo):void {
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
			moveIn2Directory(presDir.resolvePath("tmp_pdf").nativePath +"/" + pptx_info.filename, pdfDir.nativePath + "/" + pptx_info.filename);
		}
		
		// Move pdf and images file into each unique folder from tmp folder
		private function moveIn2Directory(orgpath:String, destpath:String):void {
			orgpath += ".pdf"; // Add "pdf" extension on the filepaths
			destpath += ".pdf";
			var original:File = new File(orgpath);
			var destination:File = new File(destpath);
			trace(orgpath);
			trace(destpath);
			trace("original: " + original.exists);
			trace("destination: " + destination.exists);
			if(!original.exists) { return; }
			original.addEventListener(Event.COMPLETE, fileMoveCompleteHandler); 
			original.addEventListener(IOErrorEvent.IO_ERROR, fileMoveIOErrorEventHandler); 
			original.moveTo(destination,true);
		}
		
		// Read lines
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
		
		
		////////////////////////////////////////////////////////////////////////////
		// Event Handlers
		////////////////////////////////////////////////////////////////////////////

		private function finSearchPPTX(event:NativeProcessExitEvent):void {
			process.removeEventListener(NativeProcessExitEvent.EXIT, finSearchPPTX);
			var notificationEvent:NotificationEvent = new NotificationEvent("notificationEvent","FoundPPTX", null);
			this.dispatchEvent(notificationEvent);
		}
		
		private function finCreatePDFandImages(event:NativeProcessExitEvent):void {
			process.removeEventListener(NativeProcessExitEvent.EXIT, finCreatePDFandImages);
			var notificationEvent:NotificationEvent = new NotificationEvent("notificationEvent","CreatedPDFandImages", null); // For debug
			this.divideUpPDFandImages(this.tmp_pinfo);
			this.dispatchEvent(notificationEvent);
		}
		
		private function finMoveIn2Directory(event:NativeProcessExitEvent):void {
			process.removeEventListener(NativeProcessExitEvent.EXIT, finMoveIn2Directory);
			var notificationEvent:NotificationEvent = new NotificationEvent("notificationEvent","MovedIn2Direcotry", null);
			this.dispatchEvent(notificationEvent);
		}
		
		private function finExitPowerPoint(event:NativeProcessExitEvent):void {
			process.removeEventListener(NativeProcessExitEvent.EXIT, finExitPowerPoint);
			var notificationEvent:NotificationEvent = new NotificationEvent("notificationEvent","ExitedPowerPoint", null);
			this.dispatchEvent(notificationEvent);
		}
		
		private function fileMoveCompleteHandler(event:Event):void { 
			trace("Complete to move " + event.target);
		} 
		private function fileMoveIOErrorEventHandler(event:IOErrorEvent):void { 
			trace("I/O Error.");  
		} 
	}
}