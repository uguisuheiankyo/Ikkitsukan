package tools
/* A Sample to use this class
 * var pptx:File = new File("/Users/Hiroyuki/Desktop/example.pptx");
 * var str:String = crypto.cryptoMD5(pptx);
 * Copyright (c) 2010 Nick <BlooDHounD> Ryzhy / blooddy@tut.by / www.blooddy.by ( MIT LISENCE )
 */
{
	import by.blooddy.crypto.MD5;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public class Crypto
	{
		public function Crypto() { }
		
		
		// MD5
		public function cryptoMD5(file:File):String {
			var bytes:ByteArray = getByteArray(file);
			var md5:String = MD5.hashBytes(bytes);
			return md5;
		}
				
		// Get the byteArray from the File Instance
		public function getByteArray(file:File):ByteArray {
			var stream:FileStream = new FileStream();
			stream.open(file,FileMode.READ);
			var bytes:ByteArray = new ByteArray();
			stream.readBytes(bytes); // this is the equivalent to stream.getByteArray():ByteArray
			stream.close();
			return bytes;
		}
	}
}