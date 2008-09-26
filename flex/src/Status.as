package{
    public class Status {
		[Bindable] public var twiter_id:String;
		[Bindable] public var text:String;
		[Bindable] public var user_id:String;
		[Bindable] public var screen_name:String;
		[Bindable] public var profile_icon:String;
		[Bindable] public var since:Date;
		
		public function Status(id:String, user_id:String, screen_name:String, profile_icon:String, since:String, text:String){
			function toDate(date:String):Date{
				var month:Object = {"Jan":1, "Feb":2, "Mar":3, "Apr":4,	 "May":5,  "Jun":6,
									"Jul":7, "Aug":8, "Sep":9, "Oct":10, "Nov":11, "Dec":12}	
				
				var xs:Array = date.split(/ /)
				var y:int = parseInt(xs[5])
				var M:int = month[xs[1]]
				var d:int = parseInt(xs[2])
				var time:Array = xs[3].toString().split(/:/)
				var h:int = parseInt(time[0]) + 9
				var m:int = parseInt(time[1])
				var s:int = parseInt(time[2])
				
				return new Date(y, M, d, h, m, s)
			}
			
		    this.twiter_id = id;
		    this.text = text;
		    this.user_id = user_id;
		    this.screen_name = screen_name;
		    this.profile_icon = profile_icon;
		    this.since = toDate(since);
		}
		
		public function toSExpression():String {
			return '((twitter_id ' + this.twiter_id + ') '+
			    '(user_id "' + this.user_id + '") '+
			    '(screen_name "' + this.screen_name + '") '+
			    '(profile_icon "' + this.profile_icon + '") '+
			    '(text "' + this.text + '") '+
			    '(since "' + this.since + '")) '
		}
	}
}