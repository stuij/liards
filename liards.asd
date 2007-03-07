(defpackage :liards.system
  (:use :cl :asdf))

(in-package :liards.system)

(defsystem liards
  :version "0.0.1"
  :author "Ties Stuij"
  :depends-on (:arnesi :split-sequence :armish)
  :components ((:file "packages")
               (:file "helpers"         :depends-on ("packages"))
               (:file "registers"       :depends-on ("helpers"))
               (:file "hardware-layout" :depends-on ("helpers"))
               (:file "crc"             :depends-on ("helpers"))
               (:file "header-helpers"  :depends-on ("helpers"))
               (:file "header"          :depends-on ("header-helpers"))
               (:file "file-stitch"     :depends-on ("registers" "hardware-layout" "crc" "header"))
               (:file "test"            :depends-on ("file-stitch"))))