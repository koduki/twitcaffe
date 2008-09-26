package macro {
	import mx.containers.Canvas;
	
    public class Atom {
		public static const LIST:String = "LIST";		
		public static const SYMBOL:String = "Symbol";
		public static const NULL:String = "Null";		
		public static const NUM:String = "Num";
		public static const STR:String = "Str";
		public static const BOOL:String = "Bool";		
		public static const FUNCTION:String = "Function";
		public static const TAB:String = "Tab";	
			
		public var type:String;
		public var value:*;
		
		public static function toAtom(x:*):Atom{
		    return (x is Function) ? new Atom(FUNCTION, x)
			:(x is Array) ? new Atom(LIST, x)
			:(x is Boolean) ? new Atom(BOOL, (x) ? "#t" : "#f")
		    :(x is Canvas) ? new Atom(TAB, x)					
			:(x.match(/".*"/)) ? new Atom(STR, x.substring(1, x.length - 1))
			:(x.match(/\d/)) ? new Atom(NUM, parseInt(x))
			:(x == "#t") ? new Atom(BOOL, x)
			:(x == "#f") ? new Atom(BOOL, x)
			:(x == "nil") ? new Atom(NULL, x)
			: new Atom(SYMBOL, x);			
		}		
		
		public function Atom(type:String, value:*){
		    this.type = type;
		    this.value = value;
		}
	
		public function clone():Atom {
		    return (this.isList) ? new Atom(LIST, this.value.map(function(x:Atom, i:int, a:Array):Atom{ return x }))
		    					:new Atom(this.type, this.value);
		}
		
		public function isSymbol():Boolean{
		    return this.type == SYMBOL;
		}
		
		public function isList():Boolean{
		    return this.type == LIST;
		}
		
		public function isFunction():Boolean{
		    return this.type == FUNCTION;
		}
		
		public function isNil():Boolean{
		    return this.type == NULL;
		}
		
		public function isTab():Boolean{
		    return this.type == TAB
		}					
    }
}