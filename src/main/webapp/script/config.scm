(add-event "timeline"  "reloaded" (lambda (xs) (if (null? xs) (list) (play "status.mp3" ))))
(add-event "replies"  "reloaded" (lambda (xs) (if (null? xs) (list) (play "reply.mp3" ))))

(define filter-tab (generate-new-tab "Filter"))
(define filter_users (list "pascalmk"))

(add-event "timeline" "reloaded" (lambda (xs) 
				   (if (null? xs) 
				       (list)
				       (grouping-items filter_users filter-tab xs))))
