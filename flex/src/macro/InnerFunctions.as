package macro {
    import mx.containers.Canvas;
    import mx.core.Application;
    
    public dynamic class InnerFunctions {
		private var clisp:Interpriter;
		private var api:Object = {
		    "+":$(function(args:Array, env:Array):Atom{ return calc(args, function(x:int, y:int):int{return x + y}) }),
		    "-":$(function(args:Array, env:Array):Atom{ return calc(args, function(x:int, y:int):int{return x - y}) }),
		    "*":$(function(args:Array, env:Array):Atom{ return calc(args, function(x:int, y:int):int{return x * y}) }),
		    "/":$(function(args:Array, env:Array):Atom{ return calc(args, function(x:int, y:int):int{return x / y}) }),
		    "%":$(function(args:Array, env:Array):Atom{ return calc(args, function(x:int, y:int):int{return x % y}) }),
		    "=":$(function(args:Array, env:Array):Atom{ return relation(args, "=", function(x:*, y:*):Boolean{return x == y}) }),
		    "and":$(function(args:Array, env:Array):Atom{return calcRel(args, env, function(x:*):Boolean{return x=="#f"}) }),
		    "or":$(function(args:Array, env:Array):Atom{ return calcRel(args, env, function(x:*):Boolean{return x!="#f"}) }),
		    "begin":$(function(args:Array, env:Array):Atom{ return args.pop() }),
		    "define":$(function(args:Array, env:Array):Atom{
			    checkArguments("define", 2, args);
			    var name:Atom = args[0];
			    var exp:Atom = args[1];
			    env[0][name.value] = exp;									
			    return name; 
			}),
		    "set!":$(function(args:Array, env:Array):Atom{
			    checkArguments("set!", 2, args);
			    
			    var name:Atom = args[0];
			    var exp:Atom = args[1];
			    clisp.refEnv(name, env).value = exp.value;
			    return exp; 
			}),	    
		    "lambda":$(function(args:Array, env:Array):Atom{ 
			    var xargs:Array = args[0].value;
			    var exp:Atom = $([$("begin")].concat(args.tail()));
			    return $((function(args:Array, dummyEnv:Array):Atom{
					checkArguments("<function>", xargs.length, args);
					var e:Object = {};
					for(var i:int = 0; i<args.length; i++) e[xargs[i].value] = args[i];
					return clisp.eval(exp, [e].concat(env) ) }));
			}),
		    "eval":$(function(args:Array, env:Array):Atom{
			    checkArguments("eval", 1, args);
	
			    var exp:Atom = args[0];
			    return clisp.eval(exp, env);		    
			}),	    
		    "if":$(function(args:Array, env:Array):Atom{ 
			    checkArguments("if", 3, args);
			    
			    var test:Atom = args[0];
			    var exp1:Atom = args[1];
			    var exp2:Atom = args[2];
			    var result:Atom = clisp.eval(test, env)
			    
			    return (result.value == "#f") ? clisp.eval(exp2, env) : clisp.eval(exp1, env);
			}),
		    "car":$(function(args:Array, env:Array):Atom{ 
			    checkArguments("car", 1, args);
			    
			    var list:Atom = args[0];
			    if(!list.isList()) throw new Error("list required, but got " + list.value);
			    
			    return list.value.take();
			}),
		    "cdr":$(function(args:Array, env:Array):Atom{ 
			    checkArguments("car", 1, args);
			    
			    var list:Atom = args[0];
			    if(!list.isList()) throw new Error("list required, but got " + list.value);
			    
			    return $(list.value.tail());
			}),
		    "quote":$(function(args:Array, env:Array):Atom{
			    checkArguments("quote", 1, args);
			    return args[0];
			}),	    
		    "list":$(function(args:Array, env:Array):Atom{
			    var list:Array = []; 
			    for(var i:int=0;i<args.length;i++) list.push(args[i]);
			    
			    return $(list);
			}),
		    "cons":$(function(args:Array, env:Array):Atom{
			    checkArguments("cons", 2, args)
	
			    var xs:Array = args[1].clone().value
			    xs.unshift(args[0]);
			    
			    return $(xs)
			}),
		    "null?":$(function(args:Array, env:Array):Atom{
			    checkArguments("null?", 1, args);
			    return $(args[0].isList() && args[0].value.length == 0)
			}),
			"generate-new-tab":$(function(args:Array, env:Array):Atom{
			    checkArguments("rgenerate-new-tab", 1, args);
			    var label:String = args[0].value
			    
			    var r:Canvas = Application.application.generateNewTab(label);
			    return $(r);
			}),
			"add-tab-item":$(function(args:Array, env:Array):Atom{
			    checkArguments("add-tab-item", 2, args);
			    var tab:Canvas = args[0].value
			    var item:Array = [args[1]]
			    
			    var tid:String =  clisp.apply_func($("get-status-twitter_id"), item, env).value.toString()
		    	var user_id:String = clisp.apply_func($("get-status-user_id"), item, env).value
				var screen_name:String = clisp.apply_func($("get-status-screen_name"), item, env).value
				var profile_icon:String = clisp.apply_func($("get-status-profile_icon"), item, env).value
				var text:String = clisp.apply_func($("get-status-text"), item, env).value
				var since:String = clisp.apply_func($("get-status-since"), item, env).value		    	
			    
			    var status:Status = new Status(tid, user_id, screen_name, profile_icon, since, text)
				var r:Canvas = Application.application.addItems(tab, [status])
			    return $(r);
			}),			
		    "reload":$(function(args:Array, env:Array):Atom{
			    checkArguments("reaload", 0, args);
			    
			    Application.application.update();
			    return $("nil");
			}),
		    "play":$(function(args:Array, env:Array):Atom{
			    checkArguments("play", 1, args);
			    Application.application.play(args[0].value);
			    return $("nil");
			})    
		    
		};
		
		
		public function InnerFunctions(clisp:Interpriter) {
		    this.clisp = clisp;
		}
		
		public function load():Object {
		    return api;
		}
	
		private function $(x:*):Atom{
		    return Atom.toAtom(x);
		}
		
		private function checkArguments(name:String, required:int, args:Array):void{
		    if (args.length != required){
			throw new Error("wrong number of arguments for #" + name + " (required " + required + ", got " + args.length + ")"); 
		    }		
		}
		private function relation(args:Array, name:String, callback:Function):Atom{
		    checkArguments(name, 2, args);
		    return (callback(args[0].value, args[1].value)) ? $("#t") : $("#f");
		}
		private function calcRel(args:Array, env:Array, callback:Function):Atom{
		    var x:Atom;
		    for (var i:int=0;i<args.length;i++){
			x = clisp.eval(args[i], env);
			if (callback(x.value)) return x;
		    } 
		    return x;			
		}
		private function calc(args:Array, callback:Function):Atom{
		    return args.reduce(function(x:Atom, y:Atom):Atom{return new Atom(Atom.NUM, callback(x.value, y.value))});
		}			
    }
}