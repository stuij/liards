(in-package :liards)

(def-space-n-clusters-n-blocks liards
  ()
  (liards-common liards-writer))

;; general lookup-table functionality reachable from register
(defparameter *jr* 'r0) ;; like in Dallas, the reg with the contacts

(defparameter *jr-reachables*
  '((text-color (word #xFFFF))
    (text-bg-color (word #x0))
    (text-line-nr (word 0))
    (text-line-pos (word 0))

    (char-x-data (word (address :char-x-data)))
    (char-y-data (word (address :char-y-data)))
    (char-sizes (word (address :char-sizes)))
    (char-offsets (word (address :char-offsets)))
    (char-widths (word (address :char-widths)))))

(defun add-jr-reachables (new-reachables)
  (let ((clean-new-reachables (convert-to-intern (ensure-list new-reachables) :liards)))
    (if (intersection *jr-reachables* clean-new-reachables :test (lambda (r1 r2)
                                                                   (eql (car r1) (car r2))))
        
        (error "jr reachables ~a and new reachables ~a share identifiers"
               *jr-reachables* clean-new-reachables)
        (setf *jr-reachables* (append *jr-reachables* clean-new-reachables)))))

(defun get-jr-offset (thing)
  "reference offset address reachable from *jr*"
  (let ((internal-thing (intern (format nil "~a" thing) :liards)))
    (aif (position internal-thing *jr-reachables* :test (lambda (r1 r2)
                                                          (eql (car r2) r1)))
         it
         (error "jr offset request has hit upon unknown offset value ~A. please correct. thank you."
                internal-thing))))

(def-asm-macro load-jr (dest-reg identifier)
  `((ldr ,dest-reg (,*jr* ,(* 4 (get-jr-offset identifier))))))

(def-asm-macro store-jr (val-reg identifier)
  `((str ,val-reg (,*jr* ,(* 4 (get-jr-offset identifier))))))

(def-asm-macro dump-jr-data ()
  `(:jr-base
    ,@(loop for item in *jr-reachables*
         collect `,(cadr item))))

