package macro{
    import utils.CoreEx;
    
    public class Interpriter {
		private var sc:Scanner;
		private var global_env:Object;
		
		public function Interpriter(){ 
		    CoreEx.load();
		    
		    global_env = (new InnerFunctions(this)).load();
		}
		
		public function invoke(src:String):String{
		    this.sc = new Scanner(src);
		    
		    var result:String = "";
		    
		    try{
				var tree:Atom = parse( Atom.toAtom([Atom.toAtom("begin")]) );
				var r:Atom = eval(tree, [global_env])
			    result = print(r); 
		    }catch(e:Error){
				result = "*** ERROR: " + e.message;
				trace(result);
		    }finally{
				return result;
		    }		
		}
		
		function print(x:Atom):String {
		    return   (x.isFunction())? "<function>"
		    :(x.isTab())? "<tab>"
			:(x.isList()) ? "(" +x.value.reduce(function(x:String, y:Atom):String{return x += print(y) + " "}, "") + ")"
			: x.value.toString()
			}
			
		function parse(xs:Atom):Atom{
		    while(sc.hasNext()){
			var x:String = sc.next();
			if(x == "("){
			    xs.value.push( parse(Atom.toAtom([])) );
			}else if(x == ")"){
			    break;
			}else {
			    xs.value.push(Atom.toAtom(x));
			}					
		    }
		    return xs;
		}
	
		function refEnv(name:Atom, env:Array):Atom{
		    for each (var e:Object in env){
			    if (e.hasOwnProperty(name.value)) return e[name.value];
			}	
		    throw new Error("unbound variable: " + name.value);		
		    return null;
		}
			
		function apply(name:Atom, args:Array, env:Array):Atom{
		    if (name.isList()) name = eval(name, env);
		    
		    switch (name.value){
		    case "define" :
				args[1] = eval(args[1], env);
				break;
		    case "set!" :
				args[1] = eval(args[1], env);
				break;
		    case "lambda" :
				break;
			case "quote" :
				break;
		    case "if" :
				args[0] = eval(args[0], env);		
				break;
		    case "and" :
				break;
		    case "or" :
				break;		
		    default :
				args = args.map(function(x:Atom, index:int, arr:Array):Atom{ return eval(x, env) });
		    }
			
			return apply_func(name, args, env)
		}
		
		function apply_val(name:Atom, env:Array):Atom{
		    return refEnv(name, env);
		}
		
		public function apply_func(name:Atom, args:Array, env:Array):Atom{
		    var fn:Function = (name.isFunction()) ? name.value : refEnv(name, env).value;
		    return fn(args, env);			
		}
		
		function eval(exp:Atom, env:Array):Atom{
		    return   (exp.isList()) ? apply(exp.value.take(), exp.value.tail(), env) 
			    :(exp.isSymbol()) ? apply_val(exp, env)
	   		    :(exp.isFunction()) ? exp.value([], env)
			    : exp;
		}	
    }
}