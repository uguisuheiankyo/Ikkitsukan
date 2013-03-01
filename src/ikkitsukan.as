// ActionScript file
import flash.events.NativeProcessExitEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.html.*;
import flash.net.URLRequest;

import mx.controls.Alert;
import mx.events.AIREvent;

import tools.Automator;
import tools.CommandLineProcess;
import tools.Indexing;
import tools.PPTXInfo;

private var process:CommandLineProcess;

protected function windowedapplication1_windowCompleteHandler(event:AIREvent):void
{
	var pptx_info:PPTXInfo = new PPTXInfo();
	pptx_info.md5 = "AAAA";
	pptx_info.filepath = "/Users/Hiroyuki/Desktop/プレゼンテーション2.pptx";
	pptx_info.filename = "プレゼンテーション2";
	pptx_info.date = new Date();
	var slidenums:Vector.<Number> = new Vector.<Number>;
	slidenums.push(1);
	slidenums.push(3);
	slidenums.reverse();
	new Automator().selectSlides(pptx_info, slidenums);
	
	
//	var indexing:Indexing = new Indexing();
//	indexing.run();
}

private function loadPDF():void {
	 
	    // check that the client is able to open PDFs 
	 
	    if (HTMLLoader.pdfCapability == HTMLPDFCapability.STATUS_OK) {
			//trace(File.applicationStorageDirectory.resolvePath("presentations/presentation.pdf").exists);
			trace(File.applicationStorageDirectory.resolvePath("presentations/presentation.pdf").url);
			var request:URLRequest = new URLRequest(File.applicationStorageDirectory.resolvePath("presentations/presentation.pdf").url); 
	        var pdf:HTMLLoader = new HTMLLoader(); 
	        pdf.height = myHTML.height - 10; 
	        pdf.width = myHTML.width - 10; 
	        pdf.load(request); 
	        myHTML.location = pdf.location;
//			myHTML1.location = pdf.location;
//			myHTML2.location = pdf.location;
//			myHTML3.location = pdf.location;
//			myHTML4.location = pdf.location;
	    } 
	    else { 
		        trace("Unable to open PDF docs!"); 
	    } 
}