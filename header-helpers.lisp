(in-package :liards)

(defclass  header-item-base ()
  ((no-bytes :accessor no-bytes :initarg :no-bytes)
   (header-pos :accessor header-pos :initarg :header-pos)
   (value :accessor value :initarg :value :type (array (unsigned-byte 8)))
   (setp :accessor setp :initarg :setp :initform nil)))

(defun make-header-slot-class (slot)
  `(defclass ,(first slot) (header-item-base) ()))

(defun header-item-slot (header-slot)
  (let ((slot-name (first header-slot))
        (header-pos (second header-slot))
        (no-bytes (third header-slot))
        (value (fourth header-slot)))
    `(,slot-name :accessor ,slot-name
                 :initform (make-instance ',slot-name
                                          :no-bytes   ,no-bytes
                                          :header-pos ,header-pos
                                          :value (value-handler ,no-bytes ,value)
                                          ,@(if value '(:setp t))))))


(defun value-handler (no-bytes value)
  (let ((value-arr (make-list no-bytes :initial-element 0)))
    (if (and value (not (eql value :nil)))
        (write-header-item value-arr value)
        value-arr)))


(defun write-header-item (dest-lst source-lst)
  (let ((src-lst-ln (length source-lst))
        (dst-lst-ln (length dest-lst)))
    (if (not (= src-lst-ln dst-lst-ln))
        (error "size of destination list (~D) doesnt match that of the source list (~D) ... scoundrel ..." dst-lst-ln src-lst-ln)
        (replace dest-lst source-lst))))

(defun write-header-item-and-seal (header-item source-lst)
  (write-header-item (value header-item) source-lst)
  (setf (setp header-item) t))

(defun write-header-item-to-list (header-item list)
  (let ((pos (header-pos header-item)))
    (setf (subseq list pos (+ pos (no-bytes header-item))) (value header-item))))

(defun write-header-to-list (header-class list)
  (dolist (item (instance-slot-names header-class))
    (write-header-item-to-list (slot-value header-class item) list)))
