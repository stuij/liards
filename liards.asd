(defpackage :liards.system
  (:use :cl :asdf))

(in-package :liards.system)

(defsystem liards
    :author "Ties Stuij  <ties@stuij.se>"
    :depends-on (:arnesi :split-sequence :umpa-lumpa :armish)
    :components
    ((:module :src
              :components
              ((:file "packages")

               (:module :spec-related
                        :components
                        ((:file "registers")
                         (:file "hardware-layout"))
                        :depends-on ("packages"))

               (:module :rom-creation
                        :components
                        ((:file "crc")                        
                         (:file "header-helpers")
                         (:file "header"          :depends-on ("header-helpers"))
                         (:file "file-stitch"     :depends-on ("crc"
                                                               "header"))
                         (:file "test"            :depends-on ("file-stitch")))
                        :depends-on ("packages" :spec-related))

               (:module :assembly-common
                        :components
                        ((:file "assembly-helpers")
                         (:file "arm-routines"    :depends-on ("assembly-helpers"))
                         (:file "font")
                         (:file "writer"          :depends-on ("arm-routines" "font")))
                        :depends-on ("packages" :spec-related))))))