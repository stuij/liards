(in-package :liards)

(defmacro def-registers (list)
  (let ((const-list '(progn)))
    (dolist (const-pair list const-list)
      (if (typep const-pair 'list)
          (setf const-list (append const-list `((defconstant ,(car const-pair) ,(cadr const-pair)))))))))

(def-registers
    ("define registers and their bit mnemonics"
     "setup/general"

     (reg-ex-mem-ctrl #x04000204
                      ((ram-region-access-cycle-ctrl :arm9 0 1)
                       (rom-1st-access-cycle-ctrl    :arm9 2 3)
                       (rom-2nd-access-cycle-ctrl    :arm9 4)
                       (phi-terminal-output-ctrl     :arm9 5 6)
                       (cartridge-access-right       :arm9 7)
                       (card-access-right            :arm9 11)
                       (main-mem-iface-priority      :arm9 14)
                       (main-mem-priority            :arm9 15)))

     (reg-pow-ctrl #x04000304
                   ((snd-speakers-pwr :arm7 0)
                    (wifi-pwr         :arm7 1)
                    (lcd-screens-pow      :arm9  0)
                    (2d-core-a-pow        :arm9  1)
                    (3d-render-core-pow   :arm9  2)
                    (3d-geometry-core-pow :arm9  3)
                    (2d-core-b-pow        :arm9  4)
                    (lcd-swap             :arm9 15)))

     (reg-halt-ctrl #x04000300
                    ((check :both 0)
                     (pause-mode :both 14 15)))
     
     "display"
     (reg-disp-ctrl #x4000000
                    ((bg-mode               :both 0 2)
                     (reserved-for-bios     :none   3)
                     (disp-frame-select     :both   4)
                     (h-blank-interval-free :both   5)
                     (obj-char-disp-mapping :both   6)
                     (forced-blank          :both   7)
                     (screen-disp-bg-0      :both   8)
                     (screen-disp-bg-1      :both   9)
                     (screen-disp-bg-2      :both  10)
                     (screen-disp-bg-3      :both  11)
                     (screen-disp-obj       :both  12)
                     (window-0-disp-flag    :both  13)
                     (window-1-disp-flag    :both  14)
                     (obj-window-disp-flag  :both  15)))
     
     (reg-disp-stat #x4000004
                    ((disp-in-vblank :both 0)
                     (disp-in-hblank :both 1)
                     (disp-vcount-flag :both 2)
                     (disp-vblank-irq :both 3)
                     (disp-hblank-irq :both 4)
                     (disp-vcount-irq :both 5)
                     (disp-vcount-match :both 7 15)))
     
     (reg-vcount #x4000006
                 ((curr-scanline :both 0 9)))

     (reg-vram-ctrl-a #x04000240
                      ((alloc-options :arm9 0 1)
                       (offset        :arm9 3 4)
                       (enable        :arm9 7)))

     (reg-vram-ctrl-b #x04000241
                      reg-vram-ctrl-a)

     (reg-vram-ctrl-c #x04000242
                      ((alloc-options :arm9 0 2)
                       (offset        :arm9 3 4)
                       (enable        :arm9 7)))

     (reg-vram-ctrl-d #x04000243
                      reg-vram-ctrl-b)

     (reg-vram-ctrl-e #x04000244
                      reg-vram-ctrl-b)
     
     (reg-vram-ctrl-f #x04000245
                      reg-vram-ctrl-b)

     (reg-vram-ctrl-g #x04000246
                      reg-vram-ctrl-b)

     (reg-vram-ctrl-h #x04000248
                      reg-vram-ctrl-b)

     (reg-vram-ctrl-i #x04000249
                      ((alloc-options :arm9 0 1)
                       (enable        :arm9 7)))
     
     (reg-wram-ctrl  #x04000247
                     ((bank-specification :arm9 0 1)))

     (reg-wvram-stat #x04000240
                     ((vram-c-setting :arm7 0)
                      (vram-d-setting :arm7 1)
                      (wram-0-setting :arm7 8)
                      (wram-1-setting :arm7 9)))

     "dma"
     (reg-dma-0-source-addr #x040000B0)
     (reg-dma-1-source-addr #x040000BC)
     (reg-dma-2-source-addr #x040000C8)
     (reg-dma-3-source-addr #x040000D4)

     (reg-dma-0-dest-addr #x040000B4)
     (reg-dma-1-dest-addr #x040000C0)
     (reg-dma-2-dest-addr #x040000CC)
     (reg-dma-3-dest-addr #x040000D8)

     (reg-dma-0-ctrl #x040000B8
                     ((size-count                :arm7 0 15)
                      (dest-addr-ctrl            :arm7 21 22)
                      (source-addr-ctrl          :arm7 23 24)
                      (dma-repeat                :arm7 25)
                      (dma-transfer-type         :arm7 26)
                      (dma-start-timing          :arm7 28 29)
                      (dma-irq-on-size-count-end :arm7 30)
                      (dma-enable                :arm7 31)))

     (reg-dma-1-ctrl #x040000C4
                     reg-dma-0-ctrl)

     (reg-dma-2-ctrl #x040000D0
                     reg-dma-0-ctrl)

     (reg-dma-3-ctrl #x040000DC
                     reg-dma-0-ctrl)

     "keys"
     (reg-key-status #x04000130
                     ((button-a :both 0)
                      (button-b :both 1)
                      (select   :both 2)
                      (start    :both 3)
                      (right    :both 4)
                      (left     :both 5)
                      (up       :both 6)
                      (down     :both 7)
                      (button-r :both 8)
                      (button-l :both 9)))

     (reg-key-xy #x04000136
                 ((button-x      :arm7 0)
                  (button-y      :arm7 1)
                  (touchpad      :arm7 6)
                  (screen-status :arm7 7)))

     "interprocessor communication"
     (reg-ipc-sync #x04000180
                   ((ipc-remote-status :both 0 3)
                    (ipc-local-status  :both 8 11)
                    (ipc-irq-req       :both 13)
                    (ipc-irq-enable    :both 14)))

     (reg-ipc-recieve-fifo #x04100000)
     (reg-ipc-send-fifo    #x04000188)

     (reg-ipc-fifo-ctrl #x04000184
                        ((send-fifo-empty-status  :both  0)
                         (send-fifo-full-status   :both  1)
                         (send-fifo-irq-enable    :both  2)
                         (send-fifo-clear         :both  3)
                         (receive-fifo-empty      :both  8)
                         (recieve-fifo-full       :both  9)
                         (recieve-fifo-irq-enable :both 10)
                         (fifo-error              :both 14)
                         (enable-fifo             :both 15)))))