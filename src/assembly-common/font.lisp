(in-package :mandel)

;;;; globals

(defvar *text-color*)
(defvar *text-bg-color*)

;; char data to be layed out and referenced in assembly
(defvar *char-x-data*)
(defvar *char-y-data*)
(defvar *char-sizes*)
(defvar *char-offsets*)
(defvar *char-widths*)
(defvar *max-font-height*)

;; some configurables
(defvar *space-length*)
(defvar *letter-spacing*)
(defvar *line-spacing*)

;; todo: redo the char layout so as we have a uft-16 layout
(defvar *font-info*
  '((32
     'space 2)

    (33
     (0 0 0 0 0 0 0 0)
     (1 2 3 4 5 6 7 9))

    (34
     (0 0 0 3 3 3)
     (0 1 2 0 1 2))

    (35
     (0 1 1 1 1 2 2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5 5 6 6 6 6 7)
     (7 4 7 8 9 3 4 5 6 7 1 2 4 7 4 7 8 9 3 4 5 6 7 1 2 4 7 4))

    (36
     (0 0 0 1 1 1 2 2 2 2 2 2 2 2 2 2  2  2 3 3 3 4 4 4 5 5 5)
     (3 4 9 2 5 9 0 1 2 3 4 5 6 7 8 9 10 11 2 6 9 2 6 9 2 7 8))

    (37
     (0 0 0 1 1 2 2 3 3 3 3 4 4 5 5 5 6 6 7 7 7 7 8 8 9 9 10 10 10)
     (2 3 4 1 5 1 5 2 3 4 9 7 8 4 5 6 2 3 1 6 7 8 5 9 5 9  6  7  8))

    (38
     (0 0 0 0 0 0 1 1 1 2 2 2 3 3 3 4 4 4 4 4 5 5 6 6 6 7)
     (2 3 4 6 7 8 1 5 9 1 5 9 1 5 9 2 3 4 6 9 7 8 5 6 8 9))

    (39
     (0 0 0)
     (1 2 3))

    (40
     (0 0 0 0 0 0 1 1 1  1 2  2)
     (3 4 5 6 7 8 1 2 9 10 0 11))

    (41
     (0  0  1 1 1 1 2 2 2 2 2 2)
     (11 0 10 9 2 1 8 7 6 5 4 3))

    (42
     (0 0 1 2 2 2 2 2 3 4 4)
     (1 3 2 0 1 2 3 4 2 1 3))

    (43
     (0 1 2 3 3 3 3 3 3 3 4 5 6)
     (6 6 6 3 4 5 6 7 8 9 6 6 6))

    (44
     ( 0 1 1  1)
     (11 8 9 10))

    (45
     (0 1 2 3 4 5 6)
     (6 6 6 6 6 6 6))

    (46
     (0 0)
     (8 9))

    (47
     ( 0  1 1 1 2 2 2 3 3 3 4 4)
     (11 10 9 8 7 6 5 4 3 2 1 0))

    (48
     (0 0 0 0 0 0 0 1 1 2 2 3 3 4 4 5 5 5 5 5 5 5)
     (2 3 4 5 6 7 8 1 9 1 9 1 9 1 9 2 3 4 5 6 7 8))

    (49
     (0 0 1 1 2 2 2 2 2 2 2 2 2 3 4)
     (2 9 2 9 1 2 3 4 5 6 7 8 9 9 9))

    (50
     (0 0 0 0 1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 5)
     (2 3 8 9 1 7 9 1 6 9 1 6 9 1 5 9 2 3 4 9))

    (51
     (0 0 1 1 2 2 2 3 3 3 4 4 4 5 5 5 5 5 5)
     (2 8 1 9 1 5 9 1 5 9 1 5 9 2 3 4 6 7 8))

    (52
     (0 0 1 1 2 2 3 3 4 4 4 4 4 4 4 4 4 5 6)
     (5 6 4 6 3 6 2 6 1 2 3 4 5 6 7 8 9 6 6))

    (53
     (0 0 0 0 0 1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 5 5)
     (1 2 3 4 8 1 4 9 1 4 9 1 4 9 1 4 9 1 5 6 7 8))

    (54
     (0 0 0 0 0 0 1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 5)
     (3 4 5 6 7 8 2 4 9 1 4 9 1 4 9 1 4 9 5 6 7 8))

    (55
     (0 1 1 2 2 2 3 3 3 4 4 4 5 5)
     (1 1 9 1 7 8 1 5 6 1 3 4 1 2))

    (56
     (0 0 0 0 0 0 1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 5 5 5)
     (2 3 4 6 7 8 1 5 9 1 5 9 1 5 9 1 5 9 2 3 4 6 7 8))

    (57
     (0 0 0 0 1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 5 5 5)
     (2 3 4 5 1 6 9 1 6 9 1 6 9 1 6 8 2 3 4 5 6 7))

    (58
     (0 0 0 0)
     (3 4 8 9))

    (59
     ( 0  1 1 1 1 1)
     (11 10 9 8 4 3))

    (60
     (0 1 1 2 2 3 3 4 4 5 5 6 6)
     (6 5 7 5 7 4 8 4 8 3 9 3 9))

    (61
     (0 0 1 1 2 2 3 3 4 4 5 5 6 6)
     (4 6 4 6 4 6 4 6 4 6 4 6 4 6))

    (62
     (0 0 1 1 2 2 3 3 4 4 5 5 6)
     (3 9 3 9 4 8 4 8 5 7 5 7 6))

    (63
     (0 1 2 2 2 2 3 3 4 4 4)
     (2 1 1 6 7 9 1 5 2 3 4))

    (64
     (0 0 0 0 1 1 1 1 2 2 3 3 3 3 3  3 4 4  4 4 5 5 5  5 6 6 6 6 6 6 6  6 7 7 8 8 8 9 9 9 9)
     (4 5 6 7 2 3 8 9 2 9 1 4 5 6 7 10 1 3 8 10 1 3 8 10 1 3 4 5 6 7 8 10 2 8 2 3 8 4 5 6 7))

    (65
     (0 0 1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 6 6 6 7 7)
     (8 9 5 6 7 3 4 7 1 2 7 1 2 7 3 4 7 5 6 7 8 9))

    (66
     (0 0 0 0 0 0 0 0 0 1 1 1 2 2 2 3 3 3 4 4 4 4 4 5 5 5)
     (1 2 3 4 5 6 7 8 9 1 5 9 1 5 9 1 5 9 2 3 4 5 9 6 7 8))

    (67
     (0 0 0 0 0 1 1 2 2 3 3 4 4 5 5 6 6)
     (3 4 5 6 7 2 8 1 9 1 9 1 9 1 9 2 8))

    (68
     (0 0 0 0 0 0 0 0 0 1 1 2 2 3 3 4 4 5 5 6 6 6 6 6)
     (1 2 3 4 5 6 7 8 9 1 9 1 9 1 9 1 9 2 8 3 4 5 6 7))

    (69
     (0 0 0 0 0 0 0 0 0 1 1 1 2 2 2 3 3 3 4 4 4 5 5 5)
     (1 2 3 4 5 6 7 8 9 1 5 9 1 5 9 1 5 9 1 5 9 1 5 9))

    (70
     (0 0 0 0 0 0 0 0 0 1 1 2 2 3 3 4 4 5)
     (1 2 3 4 5 6 7 8 9 1 5 1 5 1 5 1 5 1))

    (71
     (0 0 0 0 0 1 1 2 2 3 3 4 4 4 5 5 5 6 6 6 6 6)
     (3 4 5 6 7 2 8 1 9 1 9 1 5 9 1 5 9 2 5 6 7 8))

    (72
     (0 0 0 0 0 0 0 0 0 1 2 3 4 5 6 6 6 6 6 6 6 6 6)
     (1 2 3 4 5 6 7 8 9 5 5 5 5 5 1 2 3 4 5 6 7 8 9))

    (73
     (0 0 1 1 1 1 1 1 1 1 1 2 2)
     (1 9 1 2 3 4 5 6 7 8 9 1 9))

    (74
     (0 1 1 2 2 3 3 3 3 3 3 3 3)
     (9 1 9 1 9 1 2 3 4 5 6 7 8))

    (75
     (0 0 0 0 0 0 0 0 0 1 2 2 3 3 4 4 5 5)
     (1 2 3 4 5 6 7 8 9 5 4 6 3 7 2 8 1 9))

    (76
     (0 0 0 0 0 0 0 0 0 1 2 3 4 5)
     (1 2 3 4 5 6 7 8 9 9 9 9 9 9))

    (77
     (0 0 0 0 0 0 0 0 0 1 1 2 2 2 3 3 4 4 5 5 5 6 6 7 7 7 7 7 7 7 7 7)
     (1 2 3 4 5 6 7 8 9 1 2 3 4 5 6 7 6 7 3 4 5 1 2 1 2 3 4 5 6 7 8 9))

    (78
     (0 0 0 0 0 0 0 0 0 1 1 2 2 3 4 4 5 5 6 6 6 6 6 6 6 6 6)
     (1 2 3 4 5 6 7 8 9 1 2 3 4 5 6 7 8 9 1 2 3 4 5 6 7 8 9))

    (79
     (0 0 0 0 0 1 1 2 2 3 3 4 4 5 5 6 6 7 7 7 7 7)
     (3 4 5 6 7 2 8 1 9 1 9 1 9 1 9 2 8 3 4 5 6 7))

    (80
     (0 0 0 0 0 0 0 0 0 1 1 2 2 3 3 4 4 5 5 5 5)
     (1 2 3 4 5 6 7 8 9 1 6 1 6 1 6 1 6 2 3 4 5))

    (81
     (0 0 0 0 0 1 1 2 2 3 3 4 4 5  5 5 6 6  6 7 7 7 7 7  7)
     (3 4 5 6 7 2 8 1 9 1 9 1 9 1 9 10 2 8 11 3 4 5 6 7 11))

    (82
     (0 0 0 0 0 0 0 0 0 1 1 2 2 3 3 3 4 4 4 5 5 5 5 6)
     (1 2 3 4 5 6 7 8 9 1 5 1 5 1 5 6 1 5 7 2 3 4 8 9))

    (83
     (0 0 0 0 1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 5)
     (2 3 4 8 1 5 9 1 5 9 1 5 9 1 5 9 2 6 7 8))

    (84
     (0 1 2 3 3 3 3 3 3 3 3 3 4 5 6)
     (1 1 1 1 2 3 4 5 6 7 8 9 1 1 1))

    (85
     (0 0 0 0 0 0 0 1 2 3 4 5 6 6 6 6 6 6 6 6)
     (1 2 3 4 5 6 7 8 9 9 9 8 1 2 3 4 5 6 7 8))

    (86
     (0 0 1 1 1 2 2 3 3 4 4 5 5 6 6 6 7 7)
     (1 2 3 4 5 6 7 8 9 9 8 7 6 5 4 3 2 1))

    (87
     (0 0 0 0 1 1 1 2 2 3 3 4 4 4 5 5 6 6 6 7 7 8 8 9 9 9 10 10 10 10)
     (1 2 3 4 5 6 7 8 9 7 6 5 4 3 2 1 3 4 5 6 7 8 9 7 6 5  4  3  2  1))

    (88
     (0 0 0 0 1 1 2 2 2 3 3 3 4 4 5 5 5 5)
     (1 2 8 9 3 7 4 5 6 6 5 4 3 7 1 2 8 9))

    (89
     (0 1 1 2 3 3 3 3 3 4 5 5 6)
     (1 2 3 4 5 6 7 8 9 4 3 2 1))

    (90
     (0 0 0 1 1 1 2 2 2 2 3 3 3 4 4 4 5 5 5)
     (1 8 9 1 7 9 1 6 5 9 1 4 9 1 3 9 1 2 9))

    (91
     (0 0 0 0 0 0 0 0 0 0  0  0 1  1 2  2)
     (0 1 2 3 4 5 6 7 8 9 10 11 0 11 1 11))

    (92
     (0 0 1 1 1 2 2 3 3 3  4  4)
     (0 1 2 3 4 5 6 7 8 9 10 11))

    (93
     (0  0 1  1 2 2 2 2 2 2 2 2 2 2  2  2)
     (0 11 0 11 0 1 2 3 4 5 6 7 8 9 10 11))

    (94
     (0 1 2 3 4 5 6 7)
     (4 3 2 1 1 2 3 4))

    (95
     ( 0  1  2  3  4  5  6  7)
     (11 11 11 11 11 11 11 11))

    (96
     (0 1)
     (0 1))

    (97
     (0 0 1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 5 5 5)
     (7 8 3 6 9 3 6 9 3 6 9 3 6 9 4 5 6 7 8 9))

    (98
     (0 0 0 0 0 0 0 0 0 0 1 1 2 2 3 3 4 4 5 5 5 5 5)
     (0 1 2 3 4 5 6 7 8 9 4 9 3 9 3 9 3 9 4 5 6 7 8))

    (99
     (0 0 0 0 0 1 1 2 2 3 3 4 4)
     (4 5 6 7 8 3 9 3 9 3 9 4 8))

    (100
     (0 0 0 0 0 1 1 2 2 3 3 4 4 5 5 5 5 5 5 5 5 5 5)
     (4 5 6 7 8 3 9 3 9 3 9 3 8 0 1 2 3 4 5 6 7 8 9))

    (101
     (0 0 0 0 0 1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 5)
     (4 5 6 7 8 3 6 9 3 6 9 3 6 9 3 6 9 4 5 6 8))

    (102
     (0 1 1 1 1 1 1 1 1 1 2 2 3 3)
     (3 1 2 3 4 5 6 7 8 9 0 3 0 3))

    (103
     (0 0 0 0 0 1 1  1 2 2  2 3 3  3 4 4  4 5 5 5 5 5 5 5  5)
     (4 5 6 7 8 3 9 11 3 9 11 3 9 11 3 8 11 3 4 5 6 7 8 9 10))

    (104
     (0 0 0 0 0 0 0 0 0 0 1 2 3 4 5 5 5 5 5 5)
     (0 1 2 3 4 5 6 7 8 9 4 3 3 3 4 5 6 7 8 9))

    (105
     (0 0 0 0 0 0 0 0)
     (0 3 4 5 6 7 8 9))

    (106
     ( 0 1  1 2 2 2 2 2 2 2 2  2)
     (11 3 11 0 3 4 5 6 7 8 9 10))

    (107
     (0 0 0 0 0 0 0 0 0 0 1 2 2 3 3 4 4)
     (0 1 2 3 4 5 6 7 8 9 6 5 7 4 8 3 9))

    (108
     (0 0 0 0 0 0 0 0 0 0)
     (0 1 2 3 4 5 6 7 8 9))

    (109
     (0 0 0 0 0 0 0 1 2 3 4 4 4 4 4 4 5 6 7 8 8 8 8 8 8)
     (3 4 5 6 7 8 9 3 3 3 4 5 6 7 8 9 3 3 3 4 5 6 7 8 9))

    (110
     (0 0 0 0 0 0 0 1 2 3 4 5 5 5 5 5 5)
     (3 4 5 6 7 8 9 4 3 3 3 4 5 6 7 8 9))

    (111
     (0 0 0 0 0 1 1 2 2 3 3 4 4 5 5 5 5 5)
     (4 5 6 7 8 3 9 3 9 3 9 3 9 4 5 6 7 8))

    (112
     (0 0 0 0 0 0 0  0  0 1 1 2 2 3 3 4 4 5 5 5 5 5)
     (3 4 5 6 7 8 9 10 11 4 9 3 9 3 9 3 9 4 5 6 7 8))

    (113
     (0 0 0 0 0 1 1 2 2 3 3 4 4 5 5 5 5 5 5 5  5  5)
     (4 5 6 7 8 3 9 3 9 3 9 3 8 3 4 5 6 7 8 9 10 11))

    (114
     (0 0 0 0 0 0 0 1 2 3)
     (3 4 5 6 7 8 9 4 3 3))

    (115
     (0 0 0 1 1 1 2 2 2 3 3 3 4 4 4)
     (4 5 9 3 6 9 3 6 9 3 6 9 3 7 8))

    (116
     (0 1 1 1 1 1 1 1 1 2 2 3 3 4 4)
     (3 1 2 3 4 5 6 7 8 3 9 3 9 3 9))

    (117
     (0 0 0 0 0 0 1 2 3 4 5 5 5 5 5 5 5)
     (3 4 5 6 7 8 9 9 9 8 3 4 5 6 7 8 9))

    (118
     (0 0 1 1 1 2 2 3 3 3 4 4)
     (3 4 5 6 7 8 9 7 6 5 4 3))

    (119
     (0 0 1 1 1 2 2 3 3 3 4 4 5 5 5 6 6 7 7 7 8 8)
     (3 4 5 6 7 8 9 7 6 5 4 3 5 6 7 8 9 7 6 5 4 3))

    (120
     (0 0 0 0 1 1 2 3 3 4 4 4 4)
     (3 4 8 9 5 7 6 5 7 3 4 8 9))

    (121
     (0 0 1 1 1  1 2 2  2 3 3 3 4 4)
     (3 4 5 6 7 11 8 9 10 7 6 5 4 3))

    (122
     (0 0 0 1 1 1 2 2 2 3 3 3 4 4 4)
     (3 8 9 3 7 9 3 6 9 3 5 9 3 4 9))

    (123
     (0 1 2 2 2 2 2 2 2 2  2 3  3 4  4)
     (5 5 1 2 3 4 6 7 8 9 10 0 11 0 11))

    (124
     (0 0 0 0 0 0 0 0 0 0  0  0)
     (0 1 2 3 4 5 6 7 8 9 10 11))

    (125
     (0  0 1  1 2 2 2 2 2 2 2 2  2 3 4)
     (0 11 0 11 1 2 3 4 6 7 8 9 10 5 5))

    (126
     (0 0 1 2 3 4 5 6 7 7)
     (6 7 5 5 6 6 7 7 5 6))

    (161
     (0 0 0 0 0 0 0 0)
     (1 3 4 5 6 7 8 9))

    (162
     (0 0 0 0 0 1 1 2 2 3 3 3 3 3 3 3 3 3  3  3 4 4 5 5)
     (4 5 6 7 8 3 9 3 9 1 2 3 4 5 6 7 8 9 10 11 3 9 3 9))

    (163
     (0 0 0 1 1 1 1 1 1 1 2 2 2 3 3 3 4 4 4 5 5)
     (6 8 9 2 3 4 5 6 7 9 1 6 9 1 6 9 1 6 9 1 9))

    (164
     (0 0 1 1 1 1 2 2 3 3 4 4 4 4 5 5)
     (3 8 4 5 6 7 4 7 4 7 4 5 6 7 3 8))

    (165
     (0 1 1 1 2 2 3 3 3 3 3 4 4 5 5 5 6)
     (1 2 3 7 4 7 5 6 7 8 9 4 7 2 3 7 1))

    (166
     (0 0 0 0 0 0 0 0  0  0)
     (0 1 2 3 4 7 8 9 10 11))

    (167
     (0 0 0 0  0 1 1 1  1 2 2 2  2 3 3 3  3 4 4 4  4 5 5 5 5  5)
     (2 3 5 6 11 1 4 7 11 1 4 8 11 1 4 8 11 1 5 8 11 1 6 7 9 10))

    (168
     (0 2)
     (1 1))

    (169
     (0 0 0 0 1 1 1 1 2 2 2 2 2 2 3 3 3  3 4 4 4  4 5 5 5  5 6 6 6  6 7 7 8 8 8 8 9 9 9 9)
     (4 5 6 7 2 3 8 9 2 4 5 6 7 9 1 3 8 10 1 3 8 10 1 3 8 10 1 4 7 10 2 9 2 3 8 9 4 5 6 7))

    (170
     (0 0 1 1 1 2 2 2 3 3 3 4 4 4 4 4)
     (4 5 1 3 6 1 3 6 1 3 6 2 3 4 5 6))

    (171
     (0 0 1 1 2 2 3 3 4 4 5 5)
     (5 6 4 7 3 8 5 6 4 7 3 8))

    (172
     (0 1 2 3 4 5 6 6 6 6)
     (6 6 6 6 6 6 6 7 8 9))

    (173
     (0 1 2 3)
     (6 6 6 6))

    (174
     (0 0 0 0 1 1 1 1 2 2 3 3 3 3 3 3 3  3 4 4 4  4 5 5 5  5 6 6 6 6  6 7 7 7 8 8 8 8 9 9 9 9)
     (4 5 6 7 2 3 8 9 2 9 1 3 4 5 6 7 8 10 1 3 6 10 1 3 6 10 1 3 4 6 10 2 8 9 2 3 8 9 4 5 6 7))

    (175
     (0 1 2 3 4 5 6 7)
     (0 0 0 0 0 0 0 0))

    (176
     (0 0 0 1 1 2 2 3 3 4 4 4)
     (2 3 4 1 5 1 5 1 5 2 3 4))

    (177
     (0 0 1 1 2 2 3 3 3 3 3 3 3 4 4 5 5 6 6)
     (5 8 5 8 5 8 2 3 4 5 6 7 8 5 8 5 8 5 8))

    (178
     (0 0 1 1 1 2 2 2 3 3)
     (1 5 1 4 5 1 3 5 2 5))

    (179
     (0 0 1 1 1 2 2 2 3 3)
     (1 5 1 3 5 1 3 5 2 4))

    (180
     (0 1)
     (1 0))

    (181
     (0 0 0 0 0 0 0  0  0 1 2 3 4 5 5 5 5 5 5 5)
     (3 4 5 6 7 8 9 10 11 9 9 9 9 3 4 5 6 7 8 9))

    (182
     (0 0 0 1 1 1 1 1 2 2 2 2 2 3 3 3 3 3 3 3 3 3  3  3 4 5 5 5 5 5 5 5 5 5  5  5)
     (2 3 4 1 2 3 4 5 1 2 3 4 5 1 2 3 4 5 6 7 8 9 10 11 1 1 2 3 4 5 6 7 8 9 10 11))

    (183
     (0 0)
     (5 6))

    (184
     ( 0  1  2)
     (11 11 10))

    (185
     (0 0 1 1 1 1 1 2)
     (2 5 1 2 3 4 5 5))

    (186
     (0 0 1 1 1 2 2)
     (6 3 6 4 2 6 3))

    (187
     (0 0 1 1 2 2 3 3 4 4 5 5)
     (3 8 4 7 5 6 3 8 4 7 5 6))

    (188
     (0 0 0 0 0 0 1 1 2 3 3 4 4 4 4 5 5 5 6 6 7 7 7 7 8)
     (1 2 3 4 5 9 7 8 6 4 5 2 3 7 8 1 6 8 5 8 5 6 7 8 9))

    (189
     (0 1 1 1 1 1 1 2 2 3 4 4 5 5 6 6 6 7 7 7 8 8 8 9 9)
     (2 1 2 3 4 5 9 8 7 6 5 4 3 2 1 5 9 5 8 9 5 7 9 6 9))

    (190
     (0 0 1 1 1 2 2 2 2 2 3 3 3 3 4 5 5 5 5 6 6 6 6 7 7 8 8 8 8 8 9)
     (1 5 1 3 5 1 3 5 8 9 2 4 6 7 5 3 4 7 8 1 2 6 8 5 8 5 6 7 8 9 8))

    (191
     (0 0 0 1 1 2 2 2 2 3 4)
     (6 7 8 5 9 1 3 4 9 9 8))

    (192
     (0 0 1 1 1 2 2 2  3 3 3 3  4 4 4 4 5 5 5 6 6 6 7 7)
     (8 9 5 6 7 3 4 7 -2 1 2 7 -1 1 2 7 3 4 7 5 6 7 8 9))

    (193
     (0 0 1 1 1 2 2 2 3 3 3  4 4 4 4  5 5 5 5 6 6 6 7 7)
     (8 9 5 6 7 3 4 7 1 2 7 -1 1 2 7 -2 3 4 7 5 6 7 8 9))

    (194
     (0 0 1 1 1  2 2 2 2  3 3 3 3  4 4 4 4  5 5 5 5 6 6 6 7 7)
     (8 9 5 6 7 -1 3 4 7 -2 1 2 7 -2 1 2 7 -1 3 4 7 5 6 7 8 9))

    (195
     (0 0 1 1 1  2 2 2 2  3 3 3 3  4  4 4 4 4  5 5 5 5  6 6 6 6 7 7)
     (8 9 5 6 7 -1 3 4 7 -2 1 2 7 -2 -1 1 2 7 -1 3 4 7 -2 5 6 7 8 9))

    (196
     (0 0 1 1 1  2 2 2 2 3 3 3 4 4 4  5 5 5 5 6 6 6 7 7)
     (8 9 5 6 7 -1 3 4 7 1 2 7 1 2 7 -1 3 4 7 5 6 7 8 9))

    (197
     (0 0 1 1  2 2 2 2 2 2  3 3 3 3  4 4 4 4  5 5 5 5 5 5 6 6 7 7)
     (8 9 6 7 -1 0 3 4 5 7 -2 1 2 7 -2 1 2 7 -1 0 3 4 5 7 6 7 8 9))

    (198
     (0 0 1 1 1 2 2 2 3 3 4 4 5 5 5 5 5 5 5 5 5 6 6 6 7 7 7 8 8 8 9 9 9)
     (7 8 4 5 6 2 3 6 1 6 1 6 1 2 3 4 5 6 7 8 9 1 5 9 1 5 9 1 5 9 1 5 9))

    (199
     (0 0 0 0 0 1 1 2 2 3 3  3 4 4  4 5 5  5 6 6)
     (3 4 5 6 7 2 8 1 9 1 9 11 1 9 11 1 9 10 2 8))

    (200
     (0 0 0 0 0 0 0 0 0  1 1 1 2  2 2 2 3 3 3 3 4 4 4 5 5 5)
     (1 2 3 4 5 6 7 8 9 -2 1 5 9 -1 1 5 9 1 5 9 1 5 9 1 5 9))

    (201
     (0 0 0 0 0 0 0 0 0 1 1 1 2 2 2  3 3 3 3  4 4 4 4 5 5 5)
     (1 2 3 4 5 6 7 8 9 1 5 9 1 5 9 -1 1 5 9 -2 1 5 9 1 5 9))

    (202
     (0 0 0 0 0 0 0 0 0  1 1 1 1  2 2 2 2  3 3 3 3  4 4 4 4 5 5 5)
     (1 2 3 4 5 6 7 8 9 -1 1 5 9 -2 1 5 9 -2 1 5 9 -1 1 5 9 1 5 9))

    (203
     (0 0 0 0 0 0 0 0 0 1 1 1  2 2 2 2 3 3 3  4 4 4 4 5 5 5)
     (1 2 3 4 5 6 7 8 9 1 5 9 -1 1 5 9 1 5 9 -1 1 5 9 1 5 9))

    (204
     ( 0 0 0  1 1 1 1 1 1 1 1 1 1 2 2)
     (-2 1 9 -1 1 2 3 4 5 6 7 8 9 1 9))

    (205
     (0 0  1 1 1 1 1 1 1 1 1 1  2 2)
     (1 9 -1 1 2 3 4 5 6 7 8 9 -2 9))

    (206
     ( 0 0 0  1 1 1 1 1 1 1 1 1 1  2 2 2  3)
     (-1 1 9 -2 1 2 3 4 5 6 7 8 9 -2 1 9 -1))

    (207
     ( 0 0 0 1 1 1 1 1 1 1 1 1  2 2 2)
     (-1 1 9 1 2 3 4 5 6 7 8 9 -1 1 9))

    (208
     (0 1 1 1 1 1 1 1 1 1 2 2 2 3 3 3 4 4 5 5 6 6 7 7 7 7 7)
     (5 1 2 3 4 5 6 7 8 9 1 5 9 1 5 9 1 9 1 9 2 8 3 4 5 6 7))

    (209
     (0 0 0 0 0 0 0 0 0  1 1 1  2 2 2  3  3 3  4 4 4  5 5 5 6 6 6 6 6 6 6 6 6)
     (1 2 3 4 5 6 7 8 9 -1 1 2 -2 3 4 -2 -1 5 -1 6 7 -2 8 9 1 2 3 4 5 6 7 8 9))

    (210
     (0 0 0 0 0 1 1 2 2  3 3 3  4 4 4 5 5 6 6 7 7 7 7 7)
     (3 4 5 6 7 2 8 1 9 -2 1 9 -1 1 9 1 9 2 8 3 4 5 6 7))

    (211
     (0 0 0 0 0 1 1 2 2 3 3  4 4 4  5 5 5 6 6 7 7 7 7 7)
     (3 4 5 6 7 2 8 1 9 1 9 -1 1 9 -2 1 9 2 8 3 4 5 6 7))

    (212
     (0 0 0 0 0 1 1  2 2 2  3 3 3  4 4 4  5 5 5 6 6 7 7 7 7 7)
     (3 4 5 6 7 2 8 -1 1 9 -2 1 9 -2 1 9 -1 1 9 2 8 3 4 5 6 7))

    (213
     (0 0 0 0 0 1 1  2 2 2  3 3 3  4  4 4 4  5 5 5  6 6 6 7 7 7 7 7)
     (3 4 5 6 7 2 8 -1 1 9 -2 1 9 -2 -1 1 9 -1 1 9 -2 2 8 3 4 5 6 7))

    (214
     (0 0 0 0 0 1 1  2 2 2 3 3 4 4  5 5 5 6 6 7 7 7 7 7)
     (3 4 5 6 7 2 8 -1 1 9 1 9 1 9 -1 1 9 2 8 3 4 5 6 7))

    (215
     (0 0 1 1 2 3 3 4 4)
     (4 8 5 7 6 7 5 8 4))

    (216
     (0 0 0 0 0  0 1 1 1 2 2 2 3 3 3 3 4 4 4 5 5 5 6 6 6 7 7 7 7 7 7)
     (3 4 5 6 7 10 2 8 9 1 7 9 1 5 6 9 1 4 9 1 3 9 1 2 8 0 3 4 5 6 7))

    (217
     (0 0 0 0 0 0 0 1  2 2  3 3 4 5 6 6 6 6 6 6 6)
     (1 2 3 4 5 6 7 8 -2 9 -1 9 9 8 7 6 5 4 3 2 1))

    (218
     (0 0 0 0 0 0 0 1 2  3 3  4 4 5 6 6 6 6 6 6 6)
     (1 2 3 4 5 6 7 8 9 -1 9 -2 9 8 7 6 5 4 3 2 1))

    (219
     (0 0 0 0 0 0 0 1  2 2  3 3  4 4  5 5 6 6 6 6 6 6 6)
     (1 2 3 4 5 6 7 8 -1 9 -2 9 -2 9 -1 8 7 6 5 4 3 2 1))

    (220
     (0 0 0 0 0 0 0 1  2 2 3  4 4 5 6 6 6 6 6 6 6)
     (1 2 3 4 5 6 7 8 -1 9 9 -1 9 8 7 6 5 4 3 2 1))

    (221
     (0 1 1 2 3 3 3 3 3 4 5 5 6)
     (1 2 3 4 9 8 7 6 5 4 3 2 1))

    (222
     (0 0 0 0 0 0 0 0 0 1 1 2 2 3 3 4 4 5 5 5)
     (1 2 3 4 5 6 7 8 9 3 7 3 7 3 7 3 7 4 5 6))

    (223
     (0 0 0 0 0 0 0 0 0 1 2 2 2 3 3 3 4 4 4 4 4 4 4)
     (1 2 3 4 5 6 7 8 9 0 0 4 9 0 4 9 1 2 3 5 6 7 8))

    (224
     (0 0 1 1 1 2 2 2 2 3 3 3 3 4 4 4 5 5 5 5 5 5)
     (7 8 3 6 9 0 3 6 9 1 3 6 9 3 6 9 4 5 6 7 8 9))

    (225
     (0 0 1 1 1 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5 5 5)
     (7 8 3 6 9 3 6 9 1 3 6 9 0 3 6 9 4 5 6 7 8 9))

    (226
     (0 0 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5 5 5 5)
     (7 8 3 6 9 1 3 6 9 0 3 6 9 0 3 6 9 1 4 5 6 7 8 9))

    (227
     (0 0 1 1 1 1 2 2 2 2 3 3 3 3 3 4 4 4 4 5 5 5 5 5 5 5)
     (7 8 1 3 6 9 0 3 6 9 0 1 3 6 9 1 3 6 9 0 4 5 6 7 8 9))

    (228
     (0 0 1 1 1 2 2 2 2 3 3 3 4 4 4 4 5 5 5 5 5 5)
     (7 8 3 6 9 1 3 6 9 3 6 9 1 3 6 9 4 5 6 7 8 9))

    (229
     (0 0 1 1 1  2 2 2 2 2  3 3 3 3 3  4 4 4 4 4  5 5 5 5 5 5 5 5)
     (7 8 3 6 9 -1 0 3 6 9 -2 1 3 6 9 -2 1 3 6 9 -1 0 4 5 6 7 8 9))

    (230
     (0 0 1 1 1 2 2 2 3 3 3 4 4 4 4 4 5 5 5 6 6 6 7 7 7 8 8 8 8)
     (7 8 3 6 9 3 6 9 3 6 9 4 5 6 7 8 3 6 9 3 6 9 3 6 9 4 5 6 8))

    (231
     (0 0 0 0 0 1 1  1 2 2  2 3 3  3 4 4)
     (4 5 6 7 8 3 9 11 3 9 11 3 9 10 4 8))

    (232
     (0 0 0 0 0 1 1 1 2 2 2 2 3 3 3 3 4 4 4 5 5 5 5)
     (4 5 6 7 8 3 6 9 0 3 6 9 1 3 6 9 3 6 9 4 5 6 8))

    (233
     (0 0 0 0 0 1 1 1 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5)
     (4 5 6 7 8 3 6 9 3 6 9 1 3 6 9 0 3 6 9 4 5 6 8))

    (234
     (0 0 0 0 0 1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5)
     (4 5 6 7 8 1 3 6 9 0 3 6 9 0 3 6 9 1 3 6 9 4 5 6 8))

    (235
     (0 0 0 0 0 1 1 1 1 2 2 2 3 3 3 4 4 4 4 5 5 5 5)
     (4 5 6 7 8 1 3 6 9 3 6 9 3 6 9 1 3 6 9 4 5 6 8))

    (236
     (0 1 1 1 1 1 1 1 1)
     (0 1 3 4 5 6 7 8 9))

    (237
     (0 0 0 0 0 0 0 0 1)
     (1 3 4 5 6 7 8 9 0))

    (238
     (0 1 1 1 1 1 1 1 1 2)
     (1 0 3 4 5 6 7 8 9 1))

    (239
     (0 1 1 1 1 1 1 1 2)
     (1 3 4 5 6 7 8 9 1))

    (240
     (0 0 0 0 1 1 1 1 2 2 2 2 3 3 3 4 4 4 4 4 5 5 5 5 5)
     (5 6 7 8 0 2 4 9 0 1 4 9 1 4 9 0 2 3 4 9 4 5 6 7 8))

    (241
     (0 0 0 0 0 0 0 1 1 2 2 3 3 3 4 4 5 5 5 5 5 5 5)
     (3 4 5 6 7 8 9 1 4 0 3 0 1 3 1 3 0 4 5 6 7 8 9))

    (242
     (0 0 0 0 0 1 1 2 2 2 3 3 3 4 4 5 5 5 5 5)
     (4 5 6 7 8 3 9 0 3 9 1 3 9 3 9 4 5 6 7 8))

    (243
     (0 0 0 0 0 1 1 2 2 3 3 3 4 4 4 5 5 5 5 5)
     (4 5 6 7 8 3 9 3 9 1 3 9 0 3 9 4 5 6 7 8))

    (244
     (0 0 0 0 0 1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 5 5)
     (4 5 6 7 8 1 3 9 0 3 9 0 3 9 1 3 9 4 5 6 7 8))

    (245
     (0 0 0 0 0 1 1 1 2 2 2 3 3 3 3 4 4 4 5 5 5 5 5 5)
     (4 5 6 7 8 1 3 9 0 3 9 0 1 3 9 1 3 9 0 4 5 6 7 8))

    (246
     (0 0 0 0 0 1 1 1 2 2 3 3 4 4 4 5 5 5 5 5)
     (4 5 6 7 8 1 3 9 3 9 3 9 1 3 9 4 5 6 7 8))

    (247
     (0 1 2 3 3 3 3 3 4 5 6)
     (6 6 6 6 3 4 8 9 6 6 6))

    (248
     (0 0 0 0 0  0 1 1 1 2 2 2 2 3 3 3 4 4 4 5 5 5 5 5 5)
     (4 5 6 7 8 10 3 8 9 3 6 7 9 3 5 9 3 4 9 2 4 5 6 7 8))

    (249
     (0 0 0 0 0 0 1 2 2 3 3 4 5 5 5 5 5 5 5)
     (3 4 5 6 7 8 9 0 9 1 9 8 3 4 5 6 7 8 9))

    (250
     (0 0 0 0 0 0 1 2 3 3 4 4 5 5 5 5 5 5 5)
     (3 4 5 6 7 8 9 9 1 9 0 8 3 4 5 6 7 8 9))

    (251
     (0 0 0 0 0 0 1 1 2 2 3 3 4 4 5 5 5 5 5 5 5)
     (3 4 5 6 7 8 1 9 0 9 0 9 1 8 3 4 5 6 7 8 9))

    (252
     (0 0 0 0 0 0 1 1 2 3 4 4 5 5 5 5 5 5 5)
     (3 4 5 6 7 8 1 9 9 9 1 8 3 4 5 6 7 8 9))

    (253
     (0 0 1 1 1  1 2 2 2  2 3 3 3 3 4 4)
     (3 4 5 6 7 11 1 8 9 10 0 5 6 7 3 4))

    (254
     (0 0 0 0 0 0 0 0 0 0  0  0 1 1 2 2 3 3 4 4 5 5 5 5 5)
     (0 1 2 3 4 5 6 7 8 9 10 11 4 9 3 9 3 9 3 9 4 5 6 7 8))

    (255
     (0 0 1 1 1 1  1 2 2  2 3 3 3 3 4 4)
     (3 4 1 5 6 7 11 8 9 10 1 5 6 7 3 4))))

(defun font-char-p (val)
  (numberp (car (second val))))

(defun space-p (val)
  (eql (second val) 'space))

(defun extract-x-char-data (val)
  (second val))

(defun extract-y-char-data (val)
  (third val))

(defun x-data (val)
  (second val))

(defun make-font ()
  (loop for i from 0 to 255
     for val = (assoc i *font-info*)
     with x-data = () 
     and y-data = ()
     and char-sizes = ()
     and last-offset = -1
     and char-offsets = '(0)
     and char-widths = ()
     do (cond
          ((font-char-p val)
           (let ((char-size (length (x-data val))))
             (setf x-data (append x-data (extract-x-char-data val)))
             (setf y-data (append y-data (extract-y-char-data val)))
             (setf char-sizes (append char-sizes (list char-size)))
             (setf last-offset (+ last-offset char-size))
             (setf char-offsets (append char-offsets (list last-offset)))
             (setf char-widths (append char-widths (list (apply #'max (x-data val)))))))
          ((space-p val)
           (setf char-sizes (append char-sizes '(0)))
           (setf char-offsets (append char-offsets *space-length*))
           (setf char-widths (append char-widths '(0))))
          (t
           (setf char-sizes (append char-sizes '(0)))
           (setf char-offsets (append char-offsets (list (negate *letter-spacing*))))
           (setf char-widths (append char-widths '(0)))))
     finally (progn
               (setf *char-x-data* x-data)
               (setf *char-y-data* y-data)
               (setf *max-font-height* (apply #'max *char-y-data*))
               (setf *char-sizes* char-sizes)
               (setf *char-offsets* char-offsets)
               (setf *char-widths* char-widths))))