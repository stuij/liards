(in-package :liards)

;; got from symbolics code somewhere (hope they don't sue)
(defmethod instance-slot-names ((instance standard-object))
  "Given an INSTANCE, returns a list of the slots in the instance's class."
  (mapcar #'mopp:slot-definition-name
          (mopp:class-direct-slots (class-of instance))))

(defun class-slot-names (class-name)
  "Given a CLASS-NAME, returns a list of the slots in the class."
  (mapcar #'mopp:slot-definition-name
          (mopp:class-direct-slots (find-class class-name))))
