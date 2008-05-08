(in-package :mandel)

(def-asm-fn init-system ()
  (emit-asm
   :init-system
   ;; for now, this basically means set up screens for writing
   (ldr r0 #x04000000)  ; hardware-registers offset and address of reg-disp-ctrl
   (mov r1 #x3)                            ; both screens on bits
   (ldr r2 #x00020000)                     ; framebuffer mode bits
   (mov r3 #x80)                           ; vram bank a enabled, lcd bits
   (ldr r4 #x04000304)                     ; reg-power-ctrl
   (mov r5 r4)                             ; see below
   (sub r5 r5 #xC4)                        ; 0x04000240 == reg-vram-ctrl-a

   (str r1 (r4 0))
   (str r2 (r0 0))
   (str r3 (r5 0))

   (ldr r0 +bank-a+)
   (ldr r2 #xC000) ;; nr of screen pixels

   (b :write-test-string)))

(def-asm-fn red-screen ()
  (emit-asm

   :write-screen-red
   (strh r1 (r0 0))
   (add r0 r0 #x2)
   (sub r2 r2 #x1)
   (bne :write-screen-red)

   (b :eternal-loop)))

(def-asm-fn eternal-loop ()
  (emit-asm
   :eternal-loop
   (b :eternal-loop)))

(def-asm-fn error-handling ()
  (emit-asm
   (b :write-screen-red)))