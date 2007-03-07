(in-package :cl-user)

(defpackage :liards
  (:use :common-lisp
        :armish
        :it.bese.arnesi
        :split-sequence)
  (:shadowing-import-from :it.bese.arnesi :partition)
  (:export :nds-compile))