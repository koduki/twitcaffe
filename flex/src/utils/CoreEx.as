package utils{	
	public class CoreEx{
		public static function load():void{
			Array.prototype.reduce = function(callback:Function, initialValue:* = null):*{
				var result:* = initialValue;
				var startIndex:int = 0;
				if(initialValue == null){
					result = this[0];
					startIndex = 1;
				}
				
				for(var i:int = startIndex; i<this.length; i++){
					result = callback(result, this[i]);
				}
				return result;
			};
			
			Array.prototype.take = function():*{
				return this[0];
			}
			Array.prototype.tail = function():Array{
				return (this.length > 1) ? this.slice(1) : [];
			}			
		}
		
	}
}
