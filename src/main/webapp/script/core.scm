(define for-each (lambda (fn xs)
		   (if (null? xs)
		       xs
		       (begin
			 (fn (car xs))
			 (for-each fn (cdr xs))
		     ))
		   ))

(define map (lambda (fn xs)
	      (if (null? xs) 
		  (list)
		  (cons (fn (car xs)) (map fn (cdr xs))))
	      ))

(define filter (lambda (fn xs)
	     (if (null? xs)
		 (list)
		 (if (fn (car xs))
		     (cons (car xs) (filter fn (cdr xs)))
		     (filter fn (cdr xs)))
		 )
	     ))

(define reverse (lambda (xs)
		 (define result (list))
		 (for-each (lambda (x) ( (set! result (cons x result)))))
		 result
		 ))

(define fold (lambda (fn init xs)
		   (if (null? xs)
		       init
		       (fold fn (fn (car xs) init) (cdr xs))
		   )))

(define equal? (lambda (x y) (= x y)))