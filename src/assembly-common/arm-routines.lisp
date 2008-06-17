(in-package :liards)

(in-block liards-common)

;; general macros
(def-asm-macro push-rs (reg &key cond)
  ;; todo: needs bounds checking but can't be bothered with error handling right now
  (let ((store (if cond
                   (concat-symbol 'str cond)
                   'str)))
    `((,store ,reg (rp -4)!))))

(def-asm-macro pop-rs (reg &key cond)
  ;; todo: needs bounds checking but can't be bothered with error handling right now
  (let ((load (if cond
                  (concat-symbol 'ldr cond)
                  'ldr)))
    `((,load ,reg (rp) 4))))

(def-asm-macro push-ps (reg &key cond)
  ;; todo: needs bounds checking but can't be bothered with error handling right now
  (let ((store (if cond
                   (concat-symbol 'str cond)
                   'str)))
    `((,store ,reg (sp -4)!))))

(def-asm-macro pop-ps (reg &key cond)
  ;; todo: needs bounds checking but can't be bothered with error handling right now
  (let ((load (if cond
                  (concat-symbol 'ldr cond)
                  'ldr)))
    `((,load ,reg (sp) 4))))

;; to circumvent no$gba problems
(def-asm-macro b-and-l (label &key cond)
  (let ((branch (if cond
                    (concat-symbol 'b cond)
                    'b)))
    `((mov lr pc)
      (,branch ,label))))


;; general fns
(def-asm-fn eternal-loop
  (b :eternal-loop))

;; ds fns
(def-asm-fn init-system
  ;; for now, this basically means set up screens for writing
  (ldr r6 #x04000000)   ; hardware-registers offset and address of reg-disp-ctrl
  (mov r1 #x3)                             ; both screens on bits
  (ldr r2 #x00020000)                      ; framebuffer mode bits
  (mov r3 #x80)                            ; vram bank a enabled, lcd bits
  (ldr r4 #x04000304)                      ; reg-power-ctrl
  (mov r5 r4)                              ; see below
  (sub r5 r5 #xC4)                         ; 0x04000240 == reg-vram-ctrl-a

  (str r1 (r4 0))
  (str r2 (r6 0))
  (str r3 (r5 0))

  (mov r11 lr)
  (b-and-l :write-screen)
  (mov pc r11)
  pool)

(def-asm-fn write-screen
  (ldr r3 +bank-a+) ;; base of bank a
  (load-jr r1 text-bg-color)
  (ldr r2 #xC000) ;; nr of screen pixels

  :write-screen-loop
  (strh r1 (r3) 2)
  (subs r2 r2 #x1)
  (bne :write-screen-loop)

  (mov pc lr)
  pool)

(def-asm-fn error-handling
  (b :write-screen))


;; divide routines signed and unsigned integer
;; for arm7m and above
;; taken from ARM System Developers Guide

(let ((d 'r1)                           ; input denominator d, output quotient 
      (r 'r2)                           ; input numerator n, output remainder 
      (tmp 'r3)                         ; scratch register 
      (q 'r4)                           ; current quotient 
      (sign 'r5))
                                        ; __value_in_regs struct { unsigned q, r; } 
                                        ; udiv_32by32_arm7m(unsigned d, unsigned n) 
  (def-asm-fn udiv-32by32-arm7m

    (mov q 0)                              ; zero quotient 
    (rsbs tmp d r :lsr 3)                  ; if ((r >> 3)>=d) C=1; else C=0; 
    (bcc :div-3bits)                       ; quotient fits in 3 bits 
    (rsbs tmp d r :lsr 8)                  ; if ((r >> 8)>=d) C=1; else C=0; 
    (bcc :div-8bits)                       ; quotient fits in 8 bits 
    (mov d d :lsl 8)                       ; d = d*256 
    (orr q q #xFF000000)                   ; make div_loop iterate twice 
    (rsbs tmp d r :lsr 4)                  ; if ((r >> 4)>=d) C=1; else C=0; 
    (bcc :div-4bits)                       ; quotient fits in 12 bits 
    (rsbs tmp d r :lsr 8)                  ; if ((r >> 8)>=d) C=1; else C=0; 
    (bcc :div-8bits)                       ; quotient fits in 16 bits 
    (mov d d :lsl 8)                       ; d = d*256 
    (orr q q #x00FF0000)                   ; make div_loop iterate 3 times 
    (rsbs tmp d r :lsr 8)                  ; if ((r >> 8)>=d) 
    (movcs d d :lsl 8)                     ; { d = d*256; 
    (orrcs q q #x0000FF00)                 ; make div_loop iterate 4 times} 
    (rsbs tmp d r :lsr 4)                  ; if ((r >> 4)<d) 
    (bcc :div-4bits)                       ; r/d quotient fits in 4 bits 
    (rsbs tmp d 0)                         ; if (0 >= d) 
    (bcs :div-by-0)                        ; goto divide by zero trap 
                                        ; fall through to the loop with c=0 
    :div-loop 
    (movcs d d :lsr 8)                  ; if (next loop) d = d/256 

    :div-8bits                            ; calculate 8 quotient bits 
    (rsbs tmp d r :lsr 7)                 ; if ((r >> 7)>=d) c=1; else c=0; 
    (subcs r r d :lsl 7)                  ; if (c) r -= d << 7; 
    (adc q q q)                           ; q=(q << 1)+c; 
    (rsbs tmp d r :lsr 6)                 ; if ((r >> 6)>=d) c=1; else c=0; 
    (subcs r r d :lsl 6)                  ; if (c) r -= d << 6; 
    (adc q q q)                           ; q=(q << 1)+c; 
    (rsbs tmp d r :lsr 5)                 ; if ((r >> 5)>=d) c=1; else c=0; 
    (subcs r r d :lsl 5)                  ; if (c) r -= d << 5; 
    (adc q q q)                           ; q=(q << 1)+c; 
    (rsbs tmp d r :lsr 4)                 ; if ((r >> 4)>=d) c=1; else c=0; 
    (subcs r r d :lsl 4)                  ; if (c) r -= d << 4; 
    (adc q q q)                           ; q=(q << 1)+c; 

    :div-4bits                            ; calculate 4 quotient bits 
    (rsbs tmp d r :lsr 3)                 ; if ((r >> 3)>=d) c=1; else c=0; 
    (subcs r r d :lsl 3)                  ; if (c) r -= d << 3; 
    (adc q q q)                           ; q=(q << 1)+c; 

    :div-3bits                            ; calculate 3 quotient bits 
    (rsbs tmp d r :lsr 2)                 ; if ((r >> 2)>=d) c=1; else c=0; 
    (subcs r r d :lsl 2)                  ; if (c) r -= d << 2;
    (adc q q q)                           ; q=(q << 1)+c; 
    (rsbs tmp d r :lsr 1)                 ; if ((r >> 1)>=d) c=1; else c=0; 
    (subcs r r d :lsl 1)                  ; if (c) r -= d << 1; 
    (adc q q q)                           ; q=(q << 1)+c; 
    (rsbs tmp d r)                        ; if (r>=d) c=1; else c=0; 
    (subcs r r d)                         ; if (c) r -= d; 
    (adcs q q q)                          ; q=(q << 1)+c; c=old q bit 31; 

    :div-next 
    (bcs :div-loop)                     ; loop if more quotient bits 
    (mov d q)                           ; r0 = quotient; r1=remainder; 
    (mov pc lr)                         ; return { r0, r1 } structure; 

    :div-by-0 
    (b-and-l :divide-error)             ; to be implemented by client 
    (mov pc lr))
  
  (def-asm-fn sdiv-32by32-arm7m        ; __value_in_regs struct { signed q, r; }
                                        ; udiv_32by32_arm7m(signed d, signed n)
    (stmfd sp! (lr))
    (mov sign 0)
    
    (teq r 0) ;; if r=0 result is 0,0
    (moveq d 0)
    (beq :sdiv-return)

    (push-ps d)
    (ands tmp d (ea (ash 1 31)))          ; sign=(d<0 ? 1 << 31 : 0); 
    (rsbmi d d 0)                         ; if (d<0) d=-d;
    (eormi sign sign 1)
    (ands tmp r (ea (ash 1 31)))          ; if (r<0) sign= ∼sign 
    (rsbmi r r 0)                         ; if (r<0) r=-r;
    (eormi sign sign 2)
    (b-and-l :udiv-32by32-arm7m)        ; (d,r)=(r/d,r%d)
    (pop-ps tmp)
    
    ;; d = plus, r = plus
    (eors q sign 0)
    (beq :sdiv-return)                  ; do nothing. standard case

    ;; d = min, r = pos
    (eors q sign 1)
    (bne :sdiv-correct-pos-min)
    (rsb d d 0)
    (teq r 0)
    (beq :sdiv-return)
    (sub d d 1)
    (add r tmp r)
    (b :sdiv-return)
    
    ;; d = pos, r = min
    :sdiv-correct-pos-min
    (eors q sign 2)
    (bne :sdiv-correct-min-min)
    (rsb d d 0)
    (teq r 0)
    (beq :sdiv-return)
    (sub d d 1)
    (sub r tmp r)
    (b :sdiv-return)

    :sdiv-correct-min-min
    ;; d = min, r = min
    (rsb r r 0)
    
    :sdiv-return
    (ldmfd sp! (pc))))