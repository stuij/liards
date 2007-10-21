(in-package :liards)

;;; make a queryable rom
;;  globals in abun' make the coders testing fun
(defvar *ref-rom-dir* (merge-pathnames #p"reference-roms" 
                                       (asdf:component-pathname (asdf:find-system :liards))))

(defvar *test-rom-dir* (merge-pathnames #p"test-roms" 
                                        (asdf:component-pathname (asdf:find-system :liards))))

(defvar *arm7-bin* '(#xFE #xFF #xFF #xEA)) ; sets core in eternal loop

(defvar *arm9-bin* '(#x01 #x03 #xA0 #xE3  #x03 #x10 #xA0 #xE3  #x02 #x28 #xA0 #xE3  #x80 #x30 #xA0 #xE3
                     #x04 #x13 #x80 #xE5  #x00 #x20 #x80 #xE5  #x40 #x32 #x80 #xE5  #x1A #x05 #xA0 #xE3
                     #x1F #x10 #xA0 #xE3  #x03 #x29 #xA0 #xE3  #xB2 #x10 #xC0 #xE0  #x01 #x20 #x52 #xE2
                     #xFC #xFF #xFF #x1A  #xFE #xFF #xFF #xEA)) ;; branch to thumb code and switch to thumb state

(defparameter *header-class* (make-instance 'nds-header))
(defparameter *header* (make-list #x200 :initial-element 0))
(defparameter *query-rom* '())

(defun nds-test-compile (arm9-bin arm7-bin &optional (file "test.nds") (dir *test-rom-dir*))
  (let* ((arm9-code-size (length arm9-bin))
         (arm9-aligned (align arm9-bin))
         (arm7-code-size (length arm7-bin))
         (arm7-rom-offset (+ (length arm9-aligned) (length *header*)))
         (filename-table-offset (+ arm7-rom-offset arm7-code-size))
         (filename-table-aligned (align (make-list 9 :initial-element 0)))
         (fat-offset (+ filename-table-offset (length filename-table-aligned)))
         (application-end-offset fat-offset)
         (logo-crc16 (crc16 *logo*)))
    ;; make a correct header
    (macrolet ((write-and-seal-headers (header-list)
                 (let ((res-list '(progn)))
                   (dolist (header-name header-list)
                     (setf res-list (append res-list
                                            `((write-header-item-and-seal (,header-name *header-class*)
                                                                          (nr-to-big-endian-word-byte-list ,header-name))))))
                   res-list)))
      (write-and-seal-headers (arm9-code-size arm7-code-size arm7-rom-offset filename-table-offset fat-offset application-end-offset)))
    (write-header-item-and-seal (logo-crc16 *header-class*) logo-crc16)
    (write-header-to-list *header-class* *header*)
    (write-header-item-and-seal (header-crc16 *header-class*) (crc16 (subseq *header* 0 #x15E)))
    (write-header-item-to-list (header-crc16 *header-class*) *header*)
    ;; append the lot
    (setf *query-rom* (append *header* arm9-aligned arm7-bin filename-table-aligned))
    (write-rom *query-rom* :file file :dir dir)))

;; test test-compiler
;; (nds-test-compile *arm9-bin* *arm7-bin*)
;; and load your favorite .nds sourcecode debugger. freeware-wise i think you're limited to dsemu

;;;; query a number of headers
;; the functions and macros that make it happen

(defmacro create-empty-headers (name-list)
  (let* ((header-list '()))
    `(progn ,@(dolist (name name-list header-list)
                      (setf header-list
                            (append header-list
                                    `((progn ,`(defparameter ,name
                                                 (list "name" (make-list #x200 :initial-element 0)))
                                             ,name))))))))

(defun read-headers (file-list headers)
  (mapc #'read-logo file-list headers))

(defun read-logo (filename sequence)
  (with-open-file (s (rom-location (cadr filename) *ref-rom-dir*) :element-type 'unsigned-byte)
    (read-sequence (second sequence) s)
    (setf (car sequence) (car filename))))

(defun header-info (slot-name header)
  (let ((slot (slot-value *header-class* slot-name)))
    (subseq header (header-pos slot) (+ (header-pos slot) (no-bytes slot)))))

(defun header-info-batch (slot-name headers)
  (let ((headers-plus (append `(("mine" ,*header*)) headers)))
    (format t "~%you asked for the bytes of ~d?:~%~%" slot-name)
    (map nil #'(lambda (header)
                 (format t "~d: ~d~%" (car header) (header-info slot-name (cadr header))))
         headers-plus)))

   
;; initialize
(create-empty-headers (*data1* *data2* *data3* *data4*))
(defparameter *header* (make-list #x200 :initial-element 0))
(defparameter *valid-headers* (list *data1* *data2* *data3* *data4*))

;; fill in a list of lists with in the front the name that you want to see printed and in the back the
;; real file-name under the test-roms dir. Get some DS homebrew from the net is my advice.
(read-headers '(("red" "red.nds")
                ("red" "red.nds")
                ("red" "red.nds")
                ("red" "red.nds"))
              *valid-headers*)

;; test headers
;; (header-info-batch 'rom-ctrl-info-1 *valid-headers*)


;;; testing the assembly facilities

(defun initialize-and-make-red ()
  (assemble 'arm9 'arm    
    (emit-asm
     (blx :main)
    
     code16

     :main
     (ldr r0 #x04000000) ; hardware-registers offset and address of reg-disp-ctrl
     (mov r1 #x3)                         ; both screens on bits
     (ldr r2 #x00020000)                  ; framebuffer mode bits
     (mov r3 #x80)                        ; vram bank a enabled, lcd bits
     (ldr r4 #x04000304)                  ; reg-power-ctrl
     (mov r5 r4)                          ; see below
     (sub r5 #xC4)                        ; 0x04000240 == reg-vram-ctrl-a

     (str r1 (r4 0))
     (str r2 (r0 0))
     (str r3 (r5 0))

     (ldr r0 #x06800000)
     (mov r1 #x31)
     (ldr r2 #xC000)

     :write-screen-red
     (strh r1 (r0 0))
     (add r0 #x2)
     (sub r2 r2 #x1)
     (bne :write-screen-red)

     :loop
     (b :loop))))

(defun arm7-loop ()
  (assemble 'arm7 'arm
    (emit-asm
     :loop
     (b :loop))))

(defun testerdetest ()
  (assemble 'arm9 'arm
    (emit-asm
     (adr r3 :main)
     (mov r3 r4)
     (mov r5 r6)
     :main)))

;; test - for testing
;; (nds-test-compile (initialize-and-make-red) (arm7-loop) "red-test.nds")
;; (nds-test-compile (testerdetest) (arm7-loop) "test.nds")

;; test - normal usage
;; (nds-compile (initialize-and-make-red) (arm7-loop) "red.nds")