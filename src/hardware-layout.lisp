(in-package :liards)

(defmacro def-mem-layout (list)
  (let ((const-list '(progn)))
    (dolist (const-pair list const-list)
      (if (typep const-pair 'list)
          (setf const-list
                (append const-list
                        `((defconstant ,(car const-pair) ,(cadr const-pair)))))))))

;; expects name, start address, end adress and bus-width
;; just now just using name and start address
;; nuthin wrong with literary coding
(def-mem-layout
    ("mem-blocks"

     "- shared"
     "-- all-purpose"
     (+main-ram+            #x02000000 #x023FFFFF 16)
     (+protection+          #x04000308 #x0400030C :?) ;; got no clue what this does (write-once sadly) \f libnds
     (+shared-wram-bank-0+  #x03000000 #x03003FFF 32) ;; check it, ambigious info. this one from dovotos tutorial
     (+shared-wram-bank-1+  #x03004000 #x03007FFF 32) ;; idem
     (+gba-rom+             #x08000000 #x09FFFFFF 16)
     (+gba-sram+            #x0A000000 #x0A00FFFF  8)

     "-- video"
     "--- banks"
     (+bank-a+ #x06800000 #x0681FFFF 16)
     (+bank-b+ #x06820000 #x0683FFFF 16)
     (+bank-c+ #x06840000 #x0685FFFF 16)
     (+bank-d+ #x06860000 #x0687FFFF 16)
     (+bank-e+ #x06880000 #x0688FFFF 16)
     (+bank-f+ #x06890000 #x06983FFF 16)
     (+bank-g+ #x06894000 #x06897FFF 16)
     (+bank-h+ #x06898000 #x0689FFFF 16)
     (+bank-i+ #x068A0000 #x068A3FFF 16)

     "--- virtual"
     (+main-background+ #x06000000 #x0607FFFF 16)
     (+sub-background+  #x06200000 #x0621FFFF 16)
     (+main-sprite+     #x06400000 #x0643FFFF 16)
     (+sub-sprite+      #x06600000 #x0661FFFF 16)
     
     "- arm7 reachable"
     (+arm7-bios+           #x00000000 #x00003FFF :?)
     (+arm7-iwram+          #x03800000 #x0380FFFF 32)
     (+wifi-mac-mem+        #x04804000 #x04805FFF 16)

     
     "- arm9 reachable"
     (+bios+                #xFFFF0000 #xFFFF7FFF :?)

     "-- fast"
     (+itcm+                #x00000000 #x00007FFF 32)
     (+dtcm+                #x0B000000 #x0B003FFF 32)

     "-- graphics"
     (+palette-ram+         #x05000000 #x050003FF 16)
     (+sub-palette-ram+     #x05000400 #x050007FF 16)
     (+oam-main+            #x07000000 #x070003FF 32)
     (+oam-sub+             #x07000400 #x070007FF 32)))