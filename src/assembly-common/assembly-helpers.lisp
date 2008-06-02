(in-package :liards)

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

(defun add-jr-reachables (new-reachables)
  (setf *jr-reachables*
        (append *jr-reachables* (convert-to-intern new-reachables :liards))))

(defun get-jr-offset (thing)
  "reference offset address reachable from *jr*"
  (let ((internal-thing (intern (format nil "~a" thing) :liards)))
    (aif (gethash internal-thing *jr-hash*)
         it
         (error "jr offset request has hit upon uninitialized value ~A. please correct. thank you."
                internal-thing))))

(defun set-jr (thing val)
  (let ((internal-thing (intern (format nil "~a" thing) :liards)))
    (if (position internal-thing *jr-reachables*)
        (setf (gethash internal-thing *jr-hash*) val)
        (error "~A is not reachable through jr" internal-thing))))

(defun check-jr-reachables ()
  (loop for reachable in *jr-reachables*
     do (if (not (gethash reachable *jr-hash*))
            (error "jr-reachable ~A hasn't been set" reachable))))
