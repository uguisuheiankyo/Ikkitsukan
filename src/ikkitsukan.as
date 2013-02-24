// ActionScript file
import flash.events.NativeProcessExitEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

import mx.controls.Alert;
import mx.events.AIREvent;

import tools.CommandLineProcess;
import tools.Indexing;
private var process:CommandLineProcess;
protected function windowedapplication1_windowCompleteHandler(event:AIREvent):void
{
	var indexing:Indexing = new Indexing();
	indexing.run();
}