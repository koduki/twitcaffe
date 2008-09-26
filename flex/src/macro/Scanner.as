package macro {
    public class Scanner {
		private var tokens:Array;
		private var index:int;
		
		public function Scanner(src:String){
		    this.index = 0;
		    this.tokens = splite(src);
		}
		
		public function next():String{
		    return tokens[index++];
		}
		
		public function hasNext():Boolean{
		    return tokens.length > index;
		}
		
		public function splite(src:String):Array{
			src = src.replace(/;.*/g, "")
					.replace(/\(/g, " ( ")
					.replace(/\)/g, " ) ");
			return src.match(/".*?"|\(|\)|\S+/gm)
		}
	}
}