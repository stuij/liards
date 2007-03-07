(in-package :liards)

(defvar *logo*
  '(200 96 79 226 1 112 143 226 23 255 47 225 18 79 17 72 18 76 32 96 100 96 124
    98 48 28 57 28 16 74 0 240 20 248 48 106 128 25 177 106 242 106 0 240 11 248
    48 107 128 25 177 107 242 107 0 240 8 248 112 106 119 107 7 76 96 96 56 71 7
    75 210 24 154 67 7 75 146 8 210 24 12 223 247 70 4 240 31 229 0 254 127 2 240
    255 127 2 240 1 0 0 255 1 0 0 0 0 0 4 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
  "seems to be startup code for one or the other `thing'. Damn you homebrew, and your hackerish ways")

(defmacro def-nds-header (slot-list)
  "Expects the layout of the nds header, so not much wiggle room here. it expects three or four values per header section.
  from left to right: the name of the section, the position of the section, the amount of bytes it wants to write and as a fourth an optional 
  standard value as a vector, fill in :nil to default to zero bits and flag that it doesn't need to be touched anymore.
  Def-nds-header builds a class with the names as slots. In those slots it builds appropriate classes with 
  the same name who's value slot (an array) shares it's structure with it's rightfull place on the *header* array, so we won't have to write
  that stuff in explicitely all the time. The sections that actually have to do some specialized stuff, mostly determine the position for this
  and that in the actual nds file, do so when they are called with header-item-handler. def-nds-header and header-item-handler should 
  together cover the creation of a correct header (== *header*). After which two crc checks will really finish it off with icecream on top."
  `(progn
     ,@(mapcar #'make-header-slot-class slot-list)
     (defclass nds-header ()
       ,(mapcar #'header-item-slot slot-list))))
 
(def-nds-header
    ((game-title            #x000  12 '(#x2E 00 00 #xEA 00 00 00 00 00 00 00 00))
     ;; yes well... this should be the the game title but according to the ndstool
     ;; c++ file this info is needed for "PassMe's that start @ 0x08000000"
     (game-code             #x00c   4 '(35 35 35 35)) ;; f\ndstool "####"
     (maker-code            #x010   2 :nil)
     (unit-code             #x012   1 :nil)
     (device-type           #x013   1 :nil)
     (device-cap            #x014   1)
     (reserved-1            #x015   8 :nil) ;; was cardinfo
     (rom-version           #x01e   1 :nil)
     (flags                 #x01f   1 '(#x04))    ;; flags c\autostart f\ndstool
     (arm9-rom-offset       #x020   4 '(0 2 0 0))
     (arm9-entry-addr       #x024   4 '(0 0 0 2))
     (arm9-ram-addr         #x028   4 '(0 0 0 2))
     (arm9-code-size        #x02c   4)
     (arm7-rom-offset       #x030   4)
     (arm7-entry-addr       #x034   4 '(0 0 128 3))
     (arm7-ram-addr         #x038   4 '(0 0 128 3))
     (arm7-code-size        #x03c   4)
     (filename-table-offset #x040   4)
     (filename-table-size   #x044   4 '(9 0 0 0)) ;; ? idem
     (fat-offset            #x048   4)
     (fat-size              #x04c   4 :nil)
     (arm9-overlay-offset   #x050   4 :nil)
     (arm9-overlay-size     #x054   4 :nil)
     (arm7-overlay-offset   #x058   4 :nil)
     (arm7-overlay-size     #x05c   4 :nil)
     (rom-ctrl-info-1       #x060   4 '(#x00 #x60 #x58 #x00))   ;; ctrl-reg-flags-read f\ndstool used in modes 1/3 \f libnds
     (rom-ctrl-info-2       #x064   4 '(#xF8 #x08 #x18 #x00))   ;; ctrl-reg-flags-init f\ndstool used in mode 2 \f libnds
     (banner-offset         #x068   4 :nil)                     ;; icon/title-offs
     (secure-area-crc16     #x06c   2 :nil)
     (rom-ctrl-info-3       #x06e   2 '(30 5)) ;; rom-timeout. most have it on 30 5, but why?
     (arm-9-?               #x070   4 :nil)
     (arm-7-?               #x074   4 :nil)
     (magic                 #x078   8 :nil)
     (application-end-offset #x080   4) ;; rom-size
     (rom-header-size       #x084   4 '(0 2 0 0))
     (unknown-5             #x088  24 :nil) ;; was 56, is still kinda... in total... bit useless this entry; just for bw-compatibility
     (sram-backup           #x0a0   9 (string-to-octets "SRAM_V110" :utf-8))
     (auto-flashme-start    #x0ac   7 (concatenate 'vector (string-to-octets "PASS01" :utf-8) '(#x96)))
     ;; f\ndstool "automatically start with FlashMe, make it look more like a GBA rom"
     (logo                  #x0c0 156 *logo*)
     (logo-crc16            #x15c   2)
     (header-crc16          #x15e   2)
     (reserved              #x160 160 :nil)))


;; phased out:
#-(and) (defgeneric header-item-handler (header-item-base)
          (:documentation "handles non-constant header items")
          ;; game-title - just make sure there's a name in *game-title* if you want to change the default
          ;; commented out right now because appearantly the info that the name info is stepping on is needed for passme devices
          #-(and)(:method ((title game-title))
                   (let ((array (make-array (no-bytes title))))
                     ;; there's a bit to much array replacing going on between this function and write-header-item,
                     ;; but somehow i think it's more elegant
                     (if (write-header-item (value title) (replace array (string-to-octets *game-title* :utf-8)))
                         (setf (setp title) t)
                         (error "stuff went wrong writing game title")))))
#-(and) (defun process-leftover-headers (h)
  "makes sure the non-constant header items are processed correctly so we have a fully filled out and correct nds header...
   except for the crcs"
  (dolist (item (instance-slot-names h))
    (let ((item-class (slot-value h item)))
      (if (not (or (setp item-class) (eq item 'logo-crc16 ) (eq item 'header-crc16)))
          (header-item-handler item-class)))))
