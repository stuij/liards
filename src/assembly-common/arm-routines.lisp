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
  (b :write-screen-red))