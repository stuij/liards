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
   :+oam-main+

   ;; assembly-helpers
   :*jr*
   :*jr-hash*
   :*jr-address*
   :*jr-reachables*
   :add-jr-reachables
   :get-jr-offset
   :set-jr
   :check-jr-reachables

   ;; arm-routines
   :b-and-l
   :push-rs
   :pop-rs
   :push-ps
   :pop-ps

   ;; font
   :make-font
   :*text-color*
   :*text-bg-color*
   :*char-x-data*
   :*char-y-data*
   :*char-sizes*
   :*char-offsets*
   :*char-widths*
   :*max-font-height*
   :*space-length*
   :*letter-spacing*
   :*line-spacing*

   ;; writer
   :setup-writer-code))