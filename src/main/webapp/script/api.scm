(define global-event (list))
(define add-event (lambda (obj name fn)
		    (set! global-event (cons (list obj name fn) global-event))
		    ))

(define dispach-event (lambda (obj event xs)
			(define result (filter (lambda (x) (match x obj event)) global-event))
                        (if (null? result)
                            (list)
			    (for-each (lambda (x) ( (car (cdr (cdr x)))  xs)) result)
			    )))

(define match (lambda (target obj event)                                  
		(and (= obj (car target))                             
		     (= event (car (cdr target)))                     
		     )))

(define find-property (lambda (name item)
			(if (null? item) 
			    (list)
			    (if (equal? (car (car item)) name) 
				(car item)
				(find-property name (cdr item))
				)
			    )
			))
(define get-status-twitter_id (lambda (item) (car (cdr (find-property "twitter_id" item)))))
(define get-status-user_id (lambda (item) (car (cdr (find-property "user_id" item)))))
(define get-status-screen_name (lambda (item) (car (cdr (find-property "screen_name" item)))))
(define get-status-profile_icon (lambda (item) (car (cdr (find-property "profile_icon" item)))))
(define get-status-text (lambda (item) (car (cdr (find-property "text" item)))))
(define get-status-since (lambda (item) (car (cdr (find-property "since" item)))))

(define grouping-items (lambda (screen_names tab items)
			 (define result (filter (lambda (item) 
						  (fold (lambda (name init)
							  (or (= (get-status-screen_name item) name) init))
							#f
							screen_names))
						items))
			 (for-each (lambda (item) (add-tab-item tab item)) result) ))