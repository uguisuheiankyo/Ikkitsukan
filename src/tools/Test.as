package tools
{
	import flash.events.NativeProcessExitEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class Test
	{
		private var process:CommandLineProcess;
		private var automator:Automator;
		
		public var slideNums:Vector.<Number>; 
		
		public function Test()
		{
			process = new CommandLineProcess();
			automator = new Automator();
		}
		
		public function extractSlides(event:NativeProcessExitEvent):void {
			if(slideNums.length != 0) {
				selectSlideNumber(slideNums.pop());
			}
		}
		
		public function selectSlideNumber(pageNum:Number):void {
			var workflow:File = File.userDirectory.resolvePath("SelectSlides.workflow/Contents/document.wflow");
			trace(workflow.nativePath);
			trace(workflow.exists);
			
			var array:Array = readLines(workflow);
			
			// 163,167
			// 165,169
			// 273,277
			array[274] = "					<real>"+pageNum+"</real>";
			array[278] = "					<real>"+pageNum+"</real>";
			
			var str:String = "";
			for each(var line:String in array) {
				str += line + "\n";
			}
			writeText(workflow, str);
			
			process.appName = "automator";
			
			var args:Vector.<String> = new Vector.<String>;
			args.push("-i");
			args.push("/Users/Hiroyuki/Desktop/presentation.pptx");
			args.push("/Users/Hiroyuki/SelectSlides.workflow");
			process.arguments = args;
			process.addEventListener(NativeProcessExitEvent.EXIT, extractSlides);
			process.run();
			
		}
		
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
	}
}