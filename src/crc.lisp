(in-package :liards)

(defvar *crc16-table*
  (make-array  256 :initial-contents
               '(#x0000 #xC0C1 #xC181 #x0140 #xC301 #x03C0 #x0280 #xC241
                 #xC601 #x06C0 #x0780 #xC741 #x0500 #xC5C1 #xC481 #x0440
                 #xCC01 #x0CC0 #x0D80 #xCD41 #x0F00 #xCFC1 #xCE81 #x0E40
                 #x0A00 #xCAC1 #xCB81 #x0B40 #xC901 #x09C0 #x0880 #xC841
                 #xD801 #x18C0 #x1980 #xD941 #x1B00 #xDBC1 #xDA81 #x1A40
                 #x1E00 #xDEC1 #xDF81 #x1F40 #xDD01 #x1DC0 #x1C80 #xDC41
                 #x1400 #xD4C1 #xD581 #x1540 #xD701 #x17C0 #x1680 #xD641
                 #xD201 #x12C0 #x1380 #xD341 #x1100 #xD1C1 #xD081 #x1040
                 #xF001 #x30C0 #x3180 #xF141 #x3300 #xF3C1 #xF281 #x3240
                 #x3600 #xF6C1 #xF781 #x3740 #xF501 #x35C0 #x3480 #xF441
                 #x3C00 #xFCC1 #xFD81 #x3D40 #xFF01 #x3FC0 #x3E80 #xFE41
                 #xFA01 #x3AC0 #x3B80 #xFB41 #x3900 #xF9C1 #xF881 #x3840
                 #x2800 #xE8C1 #xE981 #x2940 #xEB01 #x2BC0 #x2A80 #xEA41
                 #xEE01 #x2EC0 #x2F80 #xEF41 #x2D00 #xEDC1 #xEC81 #x2C40
                 #xE401 #x24C0 #x2580 #xE541 #x2700 #xE7C1 #xE681 #x2640
                 #x2200 #xE2C1 #xE381 #x2340 #xE101 #x21C0 #x2080 #xE041
                 #xA001 #x60C0 #x6180 #xA141 #x6300 #xA3C1 #xA281 #x6240
                 #x6600 #xA6C1 #xA781 #x6740 #xA501 #x65C0 #x6480 #xA441
                 #x6C00 #xACC1 #xAD81 #x6D40 #xAF01 #x6FC0 #x6E80 #xAE41
                 #xAA01 #x6AC0 #x6B80 #xAB41 #x6900 #xA9C1 #xA881 #x6840
                 #x7800 #xB8C1 #xB981 #x7940 #xBB01 #x7BC0 #x7A80 #xBA41
                 #xBE01 #x7EC0 #x7F80 #xBF41 #x7D00 #xBDC1 #xBC81 #x7C40
                 #xB401 #x74C0 #x7580 #xB541 #x7700 #xB7C1 #xB681 #x7640
                 #x7200 #xB2C1 #xB381 #x7340 #xB101 #x71C0 #x7080 #xB041
                 #x5000 #x90C1 #x9181 #x5140 #x9301 #x53C0 #x5280 #x9241
                 #x9601 #x56C0 #x5780 #x9741 #x5500 #x95C1 #x9481 #x5440
                 #x9C01 #x5CC0 #x5D80 #x9D41 #x5F00 #x9FC1 #x9E81 #x5E40
                 #x5A00 #x9AC1 #x9B81 #x5B40 #x9901 #x59C0 #x5880 #x9841
                 #x8801 #x48C0 #x4980 #x8941 #x4B00 #x8BC1 #x8A81 #x4A40
                 #x4E00 #x8EC1 #x8F81 #x4F40 #x8D01 #x4DC0 #x4C80 #x8C41
                 #x4400 #x84C1 #x8581 #x4540 #x8701 #x47C0 #x4680 #x8641
                 #x8201 #x42C0 #x4380 #x8341 #x4100 #x81C1 #x8081 #x4040)))

(defun crc16 (data)
  (let ((crc #xFFFF))
    (dotimes (byte-nr (length data) (make-array 2 :initial-contents `(,(logand crc #xff) ,(ash crc -8))))
      (setf crc (logxor (logand (ash crc -8) #xFFFF)
                        (aref *crc16-table*
                              (logand (logxor crc
                                              (nth byte-nr data))
                                      #xFF)))))))