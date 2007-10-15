(in-package :cl-user)

(defpackage :liards
  (:use :common-lisp
        :armish
        :umpa-lumpa
        :it.bese.arnesi
        :split-sequence)
  (:shadowing-import-from :it.bese.arnesi :partition)
  (:export
   
   ;; file stitch
   :nds-compile

   ;; hardware-layout
   :+main-ram+
   :+protection+
   :+shared-wram-bank-0+
   :+shared-wram-bank-1+
   :+gba-rom+
   :+gba-sram+
           
   :+bank-a+
   :+bank-b+
   :+bank-c+
   :+bank-d+
   :+bank-e+
   :+bank-f+
   :+bank-g+
   :+bank-h+
   :+bank-i+
           
   :+main-background+
   :+sub-background+
   :+main-sprite+
   :+sub-sprite+
           
   :+arm7-bios+
   :+arm7-iwram+
   :+wifi-mac-mem+
           
   :+bios+
   :+itcm+
   :+dtcm+
   :+palette-ram+
   :+sub-palette-ram+
   :+oam-main+))