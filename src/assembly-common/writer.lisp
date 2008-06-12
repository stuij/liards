(in-package :liards)

(in-block liards-writer)

(let* ( ;; regs
       (color 'r1)
       (string-end 'r1)
       (string-pos 'r2)
       (curr-char-countdown 'r3)
       (chars-left 'r4)
       (x-dat 'r5)
       (y-dat 'r6)
       (char-sizes 'r7)
       (char-widths 'r7)
       (char-offsets 'r8)
       (bench-1 'r9)
       (screen-pos-offset 'r10)
       (bench-2 'r11)
       (curr-char-offset 'r12)

       ;;used exclusively for line calculation
       (char-accumulator 'r11)
       (space-point 'r4)
       (string-tmp-offset 'r3)
       (line-nr 'r5)
       (curr-char-val 'r12)
       (curr-char-width 'r12)
       
         
       ;; letter/line calculation vars
       (screen-width #x100)
       (screen-width-min-some (- screen-width 4))

       ;;(string "It's been a strong release week, especially with plenty of great new Xbox360™ releases. Popular sellers for Microsoft's system have been Ace Combat 6: Fires of Liberation (Japanese), Tomb Raider: Anniversary, The Simpsons Game, Guitar Hero III: Legends of Rock (also available as Wireless Guitar Bundle), Conan and SEGA Rally Revo (all Asia releases).")
       ;;(string "bla")
       (string "\"And so you see, in each moment you must be catching up the distance between us, and yet I, at the same time, will be adding a new distance, however small, for you to catch up again.\"

\"Indeed, it must be so,\" said Achilles wearily.

\"And so you can never catch up,\" the Tortoise concluded sympathetically.

\"You are right, as always,\" said Achilles sadly, and conceded the race .")
       (string-length (length string))
       
       (screen-root 9) ; just lucky cause the ds screen width is 256 and so a power of two,
       ;; and so barrel rollable, times two because a pixel takes two bytes of memory 
       (screen-height #xC0)
       (line-height (+ *max-font-height* *line-spacing*))
       (max-lines (ceiling (/ screen-height line-height)))


       (copy-up-distance (* line-height 256))
       (copy-up-base (+ +bank-a+ copy-up-distance))
       (copy-up-amount (+ copy-up-base (* copy-up-distance 10))))


  (def-asm-fn write-test-string
    (stmfd sp! (r1 r2 r3 r4 r5 r6 r7 r8 r9 r11 r12 r14))
    (ldr string-pos (address :test-string))
    (ldr string-end string-length)
    
    (b-and-l :init-writer)
    (ldmfd sp! (r1 r2 r3 r4 r5 r6 r7 r8 r9 r11 r12 r15))
    
    :test-string
    (ea string)
    align
    pool)


  (def-asm-fn scroll-up-1-line

    (push-ps string-end)
    (push-ps string-pos)
    
    (ldr string-pos copy-up-base) ;; orig-address
    (ldr string-end +bank-a+)     ;; dest-address
    (ldr bench-1 copy-up-amount)  ;; countdown

    :scroll-up-1-line-loop
    (ldr bench-2 (string-pos) 4)
    (str bench-2 (string-end) 4)
    (subs bench-1 bench-1 4)
    (bpl :scroll-up-1-line-loop)

    (pop-ps string-pos)
    (pop-ps string-end)
    (mov pc lr)

    pool)

  
  (def-asm-fn init-writer   
    ;; entry-point of general assembly writing routines
    ;; they thrash register r0 through r12, so the calling whatever
    ;; better have some backup/restore around these if necessary
  
    ;; some put-current-regs-on-stack, set write arrays in relevant places routine
    ;; here we assume the string-pos and color registers are set by the calling function

    ;; load the relevant registers with addresses
    ;;(load-jr x-dat char-x-data) done by calc-line

    (add string-end string-pos string-end)
    
    (load-jr y-dat char-y-data)
    (load-jr char-offsets char-offsets)
    (load-jr char-widths char-widths)

    (ldr screen-pos-offset +bank-a+)
    (load-jr line-nr text-line-nr)
    
    (b :calc-line)
    pool)


  (def-asm-fn calc-line-after-write
    ;; check if the current val is a line break or carriage return
    ;; if so it has already been processed last time around. we just need to
    ;; tell the counter this fact
    (ldrb curr-char-val (string-pos))
    (teq curr-char-val #xA)
    (addeq string-pos string-pos #x1)
    (teq curr-char-val #xD)
    (addeq string-pos string-pos #x1)

    (load-jr line-nr text-line-nr)
       
    :calc-line
    (teq line-nr max-lines)
    (beq :write-return) ;; ideally we would want to scroll the screen in stead of
    ;; exiting but i don't want to go into fast bulk memory transport just now
       
    (mov char-accumulator 0)
    (mov space-point 0)
       
    (mov bench-1 screen-width-min-some)
    (sub bench-1 bench-1 4)
    (mov string-tmp-offset string-pos)

    (b :char-line-countdown)

    :add-one-and-countdown-char
    (add char-accumulator char-accumulator 1)
       
    :char-line-countdown
    (cmp string-end string-tmp-offset)
    (submi char-accumulator char-accumulator 1)
    (movmi space-point char-accumulator)
    (bmi :write-line-setup-skip-space)

    (ldrb curr-char-val (string-tmp-offset) #x1)

    (teq curr-char-val 32)
    (moveq space-point char-accumulator)
       
    (cmp curr-char-val 32)
    (bmi :resolve-non-printables)

    :non-printable-reentry-point       
    (ldrb curr-char-width (char-widths curr-char-val))
    (subs bench-1 bench-1 curr-char-width)
    (bmi :write-line-setup)
    (subs bench-1 bench-1 *space-length*)
    (bpl :add-one-and-countdown-char)
       
    :write-line-setup
    (add space-point space-point 1)

    :write-line-setup-skip-space
    (mov bench-1 line-height)
    (mov bench-1 bench-1 :lsl screen-root)
    (mul bench-1 line-nr bench-1)
    (ldr screen-pos-offset +bank-a+)
    (add screen-pos-offset screen-pos-offset bench-1)
       
    ;; put line nr back in jr and reinstate x-dat
    (add line-nr line-nr 1)
    (store-jr line-nr text-line-nr)
    ;; (re)set the missing/overwritten char fn constants
    (load-jr x-dat char-x-data)

       
    (b :write-line)
    pool)


  (def-asm-fn check-string-end
    (add string-pos string-pos #x1)
    (cmp string-end string-pos)
    
    (bmi :write-return)
    
    (b :calc-line-after-write))


  (def-asm-fn resolve-non-printables
    (teq curr-char-val 0)                ;; test for null value == eos
    (moveq space-point char-accumulator) ;; maybe move these three instructions
    ;; to their seperate procedure, in stead 
    (beq :write-line-setup-skip-space) ;; of them much more often than not not being executed?

    (teq curr-char-val 13) ;; carriage return
    (moveq space-point char-accumulator)
    (beq :write-line-setup-skip-space)       

    (teq curr-char-val 10) ;; line feed
    (moveq space-point char-accumulator)
       
    (beq :write-line-setup-skip-space)

    ;; TODO need still to handle the case (on win) where line feed and
    ;; carriage return come in packs. Use the color or x-char reg
    ;; which are still empty i believe with a predicate

    ;; handle other cases on the dots
    ;; ...

    (b :non-printable-reentry-point))
    

  (def-asm-fn-raw write-line ()
    (emit-asm
     :write-char-point
       
     (add bench-1 curr-char-offset curr-char-countdown)
       
     (ldrb bench-2 (y-dat bench-1))
     (ldrb bench-1 (x-dat bench-1))
       
     (add bench-1 screen-pos-offset bench-1 :lsl 1)
     (mov bench-2 bench-2 :lsl screen-root)
       
     (add bench-1 bench-1 bench-2)
     (strh color (bench-1 0))
     (subs curr-char-countdown curr-char-countdown 1)
     (bne :write-char-point)

     (pop-ps string-end)
     
     :set-next-char
     (subs chars-left chars-left 1)
     (beq :check-string-end)

     ;; add space to offset
     (add screen-pos-offset screen-pos-offset 4)
     ;; load the char again so we can add its width to
     ;; the current offset
     (ldrb bench-1 (string-pos))
       
     (ldrb bench-1 (char-widths bench-1))
     (add screen-pos-offset screen-pos-offset bench-1 :lsl 1)

     (add string-pos string-pos #x1)

     :write-line
     ;; first test if we perhaps haven't got anything to print
     (teq chars-left 0)
     (beq :check-string-end)

     :setup-char-and-write
     (ldrb bench-1 (string-pos)) ;; load char val to bench-1

     (teq bench-1 32) ;; it's a space
     (beq :handle-space-offset)

     ;; set char sizes reg, read it, and set that reg back to char-widths
     (load-jr char-sizes char-sizes)
     (ldrb curr-char-countdown (char-sizes bench-1))
     (load-jr char-widths char-widths)
     (push-ps string-end)
     (load-jr color text-color)
       
     (ldr curr-char-offset (char-offsets bench-1 :lsl 2))
 
     (b :write-char-point)

     :handle-space-offset
     (add screen-pos-offset screen-pos-offset *space-length*)
     (b :set-next-char)))

    
  (def-asm-fn write-return
    :write-return
    (mov pc lr)))