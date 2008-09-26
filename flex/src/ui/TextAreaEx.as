package ui
{
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	
	import mx.controls.TextArea;

	public class TextAreaEx extends TextArea {
		private var preventable:Boolean = false;
		private var inputHistory:Array = [];
		private var inputHistoryIndex:int = 0;
				
	    public function addKeybind(hotkey:String, fn:Function):void {
	    	// C-? が来るのが前提。後でちゃんと直す
			var keys:Array = hotkey.split("-");
			var ctrl:Boolean = keys[0] == "C";
			var key:int = keys[1].charCodeAt();
			this.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void {
				trace("press char : "+e.charCode)
				log("press char : "+e.charCode)
				if (e.ctrlKey == ctrl && e.charCode == key){
				    preventable = true;
				    fn();
				}
			});
	    }
		
		public function TextAreaEx(){
			super();
		    this.addEventListener(TextEvent.TEXT_INPUT, function(e:TextEvent):void{ 
			    if(preventable){
					e.preventDefault();
					preventable = false;
			    }
			});	
			
		    this.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void{
			    // LinuxでC-a, C-v等を押すと何故かe.charCodeが0になるのでそれを回避するコード.
			    if (e.keyCode == 4294967295) {
					log("press C-a");
					var keyevent:KeyboardEvent = (KeyboardEvent)(e.clone());
					keyevent.ctrlKey = true;
					keyevent.keyCode = 65;
					keyevent.charCode = 97;
					dispatchEvent(keyevent);
			    }
			});							
		}
		
		public function addHistory(input:String):void{
			inputHistory.push(input);
    		inputHistoryIndex = inputHistory.length;
		}
		
		public function goHome():void{ setSelection(0, 0) }
		public function goEnd():void{ setSelection(length, length) }
		public function goNextChar():void{ setSelection(selectionBeginIndex+1, selectionBeginIndex+1) }
		public function goPrevChar():void{ setSelection(selectionEndIndex-1, selectionEndIndex-1) }	
		public function deleteBack():void{  
		    var idx:int = this.selectionBeginIndex;
		    text = text.substring(0, idx - 1) + text.substring(idx, text.length);
		    this.setSelection(selectionEndIndex-1, selectionEndIndex-1);
	    }
	    public function deleteChar():void{
	    	var idx:int = this.selectionBeginIndex;
	    	text = text.substring(0, idx) + text.substring(idx+1, text.length);
	    }
	    public function linecut():void{
		    var idx:int = this.selectionBeginIndex;
	    	text = text.substring(0, idx) + text.substring(idx+1, text.length);
	    }
	    public function prevHistory():void{
	  	    if(inputHistoryIndex > 0) inputHistoryIndex -= 1;
		    text = inputHistory[inputHistoryIndex];
	    }
	    public function nextHistory():void {
		    if(inputHistoryIndex < inputHistory.length) inputHistoryIndex += 1;
	    	text = inputHistory[inputHistoryIndex];
	    }
	}
}