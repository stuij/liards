(in-package :liards)

(defvar *rom-dir* (append (pathname-directory *load-truename*)
                          (list "roms")))

(defun rom-location (&optional (rom-name "my.nds") (rom-dir *rom-dir*))
  (concatenate 'string (namestring (make-pathname :directory rom-dir)) rom-name))

(defun write-rom (rom &key (file "my.nds") (dir *rom-dir*))
  (with-open-file (s (rom-location file dir) :direction :output :element-type '(unsigned-byte 8) :if-exists :supersede)
    (write-sequence rom s)))

(defun nds-compile (arm9-code arm7-code &optional (file "my.nds") (dir *rom-dir*))
  (let* ((header-class (make-instance 'nds-header))
         (header (make-list #x200 :initial-element 0))
         (arm9-code-size (length arm9-code))
         (arm9-aligned (align arm9-code))
         (arm7-code-size (length arm7-code))
         (arm7-rom-offset (+ (length arm9-aligned) (length header)))
         (filename-table-offset (+ arm7-rom-offset arm7-code-size))
         (filename-table-aligned (align (make-list 9 :initial-element 0)))
         (fat-offset (+ filename-table-offset (length filename-table-aligned)))
         (application-end-offset fat-offset)
         (logo-crc16 (crc16 *logo*)))
    ;; make a correct header
    (macrolet ((write-and-seal-headers (header-list)
                 (let ((res-list '(progn)))
                   (dolist (header-name header-list)
                     (setf res-list
                           (append res-list
                                   `((write-header-item-and-seal (,header-name header-class)
                                                                 (nr-to-big-endian-word-byte-list ,header-name))))))
                   res-list)))
      (write-and-seal-headers (arm9-code-size
                               arm7-code-size
                               arm7-rom-offset
                               filename-table-offset
                               fat-offset
                               application-end-offset)))
    (write-header-item-and-seal (logo-crc16 header-class) logo-crc16)
    (write-header-to-list header-class header)
    (write-header-item-and-seal (header-crc16 header-class) (crc16 (subseq header 0 #x15E)))
    (write-header-item-to-list (header-crc16 header-class) header)
    ;; append the lot
    (write-rom (append header arm9-aligned arm7-code filename-table-aligned) :file file :dir dir)))

#|
these should be calculated dynamically:
device-cap - not yet implemented
arm-9-code-size
arm7-rom-offset
arm7-code-size
filename-table-offset
fat-offset
application-end-offset
logo-crc16
header-crc16

It would be nice if a few more, like romsize and fat-size, are also calculated on the fly,
for elegance sake, but hey.
|#
