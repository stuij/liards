(in-package :mandel)

(defun gather-code (&rest args)
  (gather args))

(defmacro def-arm (name args &rest body)
  "fn that outputs arm code"
  `(defun ,name ,args
     (emit-asm ,@body)))

(defun emit-arm-fns ()
  (loop for init being the hash-value in *arm-fns*
     append (funcall init)))

(defmacro def-asm-fn (name args &body body)
  `(setf (gethash ',name *arm-fns*)
         (lambda ,args
           (progn ,@body))))

;; general lookup-table functionality reachable from register

(defvar *jr*) ;; like in Dallas, the reg with the contacts

(defvar *jr-hash*)
(defvar *jr-address*)

(defparameter *jr-reachables*
  '(text-color
    text-bg-color
    text-line-nr
    text-line-pos

    char-x-data
    char-y-data
    char-sizes
    char-offsets
    char-widths))

(defun get-jr-offset (thing)
  "reference offset address reachable from *jr*"
  (aif (gethash thing *jr-hash*)
       it
       (error "jr offset request has hit upon uninitialized value ~A. please correct. thank you."
              thing)))

(defun set-jr (thing val)
  (if (position thing *jr-reachables*)
      (setf (gethash thing *jr-hash*) val)
      (error "~A is not reachable through jr" thing)))

(defun check-jr-reachables ()
  (loop for reachable in *jr-reachables*
     do (if (not (gethash reachable *jr-hash*))
            (error "jr-reachable ~A hasn't been set" reachable))))
