import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.TextEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

import macro.Interpriter;

import mx.collections.ArrayCollection;
import mx.containers.Canvas;
import mx.controls.List;
import mx.controls.TextArea;
import mx.core.ClassFactory;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;
import mx.rpc.http.mxml.HTTPService;

//private const HOST_URL:String = "http://localhost:2110/";
private const HOST_URL:String = "/";

[Bindable] private var TimelineStatuses:ArrayCollection = new ArrayCollection([]);
[Bindable] private var RepliesStautses:ArrayCollection =  new ArrayCollection([]);
[Bindable] private var FavoriteStatuses:ArrayCollection = new ArrayCollection([]);

private var login:Object = null;
private var timer:Timer;
private var interpriter:Interpriter = new Interpriter();

private function onLoad():void{
    loadScript("core.scm", function():void{
	    loadScript("api.scm", function():void{
		    loadScript("config.scm")})});

    registKeyBinds();
    popUpLoginWindow(function():void{
	    startTimer();
	    update(); 	
	});
}

private function onUpdateClick():void{
    var input:String = txtInput.text;

    txtInput.addHistory(input);

    if (input.charAt(0) == "(" || viewstack.selectedIndex == viewstack.getChildren().length - 1){
	callFunc(input);	
    }else{
	postStatus(input);
    }
    txtInput.text = "";
}

private function registKeyBinds():void{
    txtInput.addKeybind("C-j", function():void{ onUpdateClick() });
    txtInput.addKeybind("C-a", function():void{ txtInput.goHome() });
    txtInput.addKeybind("C-e", function():void{ txtInput.goEnd() });
    txtInput.addKeybind("C-f", function():void{ txtInput.goNextChar() });
    txtInput.addKeybind("C-b", function():void{ txtInput.goPrevChar() });
    txtInput.addKeybind("C-h", function():void{ txtInput.deleteBack() });
    txtInput.addKeybind("C-d", function():void{ txtInput.deleteChar() });	
    //txtInput.addKeybind("C-k", function():void{ txtInput.linecut() });	
    txtInput.addKeybind("C-p", function():void{ txtInput.prevHistory() });	
    txtInput.addKeybind("C-n", function():void{ txtInput.nextHistory() });		    					
}

public function generateNewTab(label:String):Canvas{
	var canvas:Canvas = new Canvas();
	canvas.label = label

	var list:List = new List()
	list.percentWidth = 100;
	list.percentHeight = 100;
	
		var panel:StatusPanel = new StatusPanel();
	list.itemRenderer = new ClassFactory(StatusPanel)
	list.dataProvider = new ArrayCollection()
	
	canvas.addChild(list);
	viewstack.addChildAt( canvas, viewstack.childDescriptors.length - 1 )
	
	return canvas;
}

public function addItems(tab:Canvas, statuses:Array):Canvas{
	var list:ArrayCollection = (List)(tab.getChildAt(0)).dataProvider as ArrayCollection
	statuses.forEach(function(status:Status, i:int, a:Array):void{ list.addItem(status) })
	return tab
}

private function onFavoriteClick():void{
    requestAPI("favorite", {"twitter_id":current_twitter});
}

private function popUpLoginWindow(callback:Function) : void{
    var window:LoginWindow = LoginWindow(PopUpManager.createPopUp(this, LoginWindow, true));
    window.addEventListener(CloseEvent.CLOSE, function(e:CloseEvent):void{
	    login = {"id":window.user_name, "passwd":window.password};
	    callback();
	});
    PopUpManager.centerPopUp(window);
}

private function startTimer():void {
    timer = new Timer(3 * 60 * 1000);
    timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void{ update(); });
    timer.start();
}

public function loadScript(name:String, fn:Function = null):void{
    request("script/" + name, {}, null, function(e:ResultEvent):void{
	    var src:String = e.result as String;
	    callFunc(src);
	    if (fn != null) fn();
	});
}

public function play(name:String):void{
    var sound:Sound = new Sound(new URLRequest(HOST_URL + name));
    log(HOST_URL + name);
    sound.play();
}

public function update():void{
    function updateTimeline():void{ updateStatuses(TimelineStatuses, "timeline")}
    function updateReplies():void{ updateStatuses(RepliesStautses, "replies")}
    function updateFavorites():void{ updateStatuses(FavoriteStatuses, "favorites")}

    function toLISP(statuses:Array):String{
		if (statuses.length == 0) return "(list)";
					      
		var items:String =  statuses.reduce(function(r:String, x:Status):String{
			return r + x.toSExpression(); 
		    }, "");
		return "(quote (" + items  + "))";
    }

    function updateStatuses(statuses:ArrayCollection, action:String):void{
		requestAPI(action, {}, null, function(e:ResultEvent):void{
			var xs:Array = e.result.Array.status.source.reverse()
					    .map(function(x:Object, index:int, arr:Array):*{
						    return new Status(x.id, x.name, x.screenname, x.image, x.createdat, x.text);
						})
					    .filter(function(status:Status, index:int, arr:Array):Boolean{
						    return !statuses.source.some(function(target:Status, i:int, a:Array):Boolean {
							    return target.twiter_id == status.twiter_id });
						});
			xs.forEach(function(x:Object, index:int, arr:Array):void{ statuses.addItemAt(x, 0) });
			callFunc("(dispach-event \"" + action + "\" \"reloaded\" "+ toLISP(xs) + ")");
	
		    });
    }
    updateReplies();
    updateFavorites();
    updateTimeline();	
}

private function callFunc(stdin:String):void{
    var stdout:TextArea = (TextArea)(console.getChildByName("textArea"));
    
    stdout.text += ">> " + stdin + "\n" + interpriter.invoke(stdin) + "\n";
    callLater(function():void{stdout.verticalScrollPosition = stdout.maxVerticalScrollPosition});
}

private function postStatus(status:String):void {
    requestAPI("update", {"status":status});
}

private function requestAPI(action:String, params:Object, method:String = null, callback:Function = null, format:String = "object"):void{
	request("api/" + action, params, method, callback, format)
}

private function request(action:String, params:Object, method:String = null, callback:Function = null, format:String = "object"):void{
    var srv:HTTPService = new HTTPService;
    srv.url = HOST_URL + action;
    srv.resultFormat = format
    if(login != null){
		params["id"] = login.id;
		params["passwd"] = login.passwd;
    }

    if (method != null) srv.method = method;
    if (callback != null) srv.addEventListener(ResultEvent.RESULT, callback); 
    srv.send(params);
    log("req : " + srv.url);
}
