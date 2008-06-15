(in-package :liards)

(def-space-n-clusters-n-blocks liards
    ()
  (liards-common liards-writer))

;; general lookup-table functionality reachable from register
(defparameter *jr* 'r0) ;; like in Dallas, the reg with the contacts

(defparameter *jr-reachables*
  '((text-color #xFFFF)        ;; white
    (text-bg-color #xF)        ;; dark red
    (text-line-nr 0)
    (text-line-pos 0)

    (char-x-data (address :char-x-data))
    (char-y-data (address :char-y-data))
    (char-sizes (address :char-sizes))
    (char-offsets (address :char-offsets))
    (char-widths (address :char-widths))))

(defun add-jr-reachables (new-reachables)
  (let ((clean-new-reachables (mapcar (lambda (r)
                                        `(,(convert-to-intern (car r) :liards)
                                           ,(cadr r)))
                                      new-reachables)))
    (loop for r in clean-new-reachables
       do (aif (position r *jr-reachables* :test (lambda (r1 r2)
                                                   (eql (car r1) (car r2))))
        
               (setf (nth it *jr-reachables*) r)
               (setf *jr-reachables* (append *jr-reachables* (list r)))))))

(defun add-jr-reachable (new-reachable)
  (add-jr-reachables (list new-reachable)))

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

(defparameter *jr-suffix* "-177JR")

(def-asm-macro dump-jr-data ()
  `(:jr-base
    ,@(loop for item in *jr-reachables*
         append `,(list (intern (symbol-name (concat-symbol (car item) *jr-suffix*)) :keyword)
                        `(word ,(cadr item))))))

(def-asm-macro load-jr-address (dest-reg identifier)
  `((ldr ,dest-reg (address ,(intern (symbol-name (concat-symbol identifier *jr-suffix*)) :keyword)))))