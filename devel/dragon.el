;; Copyright 2012 Kevin Ryde
;;
;; This file is part of Math-PlanePath.
;;
;; Math-PlanePath is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by the Free
;; Software Foundation; either version 3, or (at your option) any later
;; version.
;;
;; Math-PlanePath is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
;; or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
;; for more details.
;;
;; You should have received a copy of the GNU General Public License along
;; with Math-PlanePath.  If not, see <http://www.gnu.org/licenses/>.

;;-----------------------------------------------------------------------------
;; by turns
;;

(require 'cl) ;; for `ignore-errors' in Emacs 22 and earlier

(defun dragon-ensure-line-above ()
  "If point is in the first line of the buffer then insert a new line above."
  (when (= (line-beginning-position) (point-min))
    (save-excursion
      (goto-char (point-min))
      (insert "\n"))))

(defun dragon-ensure-column-left ()
  "If point is in the first column then insert a new column to the left.
This is designed for use in `picture-mode'."
  (when (zerop (current-column))
    (save-excursion
      (goto-char (point-min))
      (insert " ")
      (while (= 0 (forward-line 1))
        (insert " ")))
    (picture-forward-column 1)))

(defun dragon-insert-char (char len)
  "Insert CHAR repeated LEN many times.
After each CHAR, point is moved in the current `picture-mode'
direction, as set by `picture-set-motion' etc.

This is the same as `picture-insert' except that when in column 0
or row 0 a new row or column is inserted so that there's room to
move up or left, with existing buffer contents shifted down or
right."

  (dotimes (i len)
    (dragon-ensure-line-above)
    (dragon-ensure-column-left)
    (picture-insert char 1)))

(defun dragon-bit-above-lowest-0bit (n)
  "Return the bit above the lowest 0-bit in N.
For example N=43 binary \"101011\" has lowest 0-bit at \"...0..\"
and the bit above that is a \"..1...\" so the return is 8 which
is that bit."
  (logand n (1+ (logxor n (1+ n)))))

(defun dragon-next-turn-right-p (n)
  "Return non-nil if the dragon curve should turn right after segment N.
Segments are numbered from N=0 for the first, so calling with N=0
is the turn to make after drawing that first segment."
  (zerop (dragon-bit-above-lowest-0bit n)))

(defun dragon-picture (len step)
  "Draw the dragon curve in a *dragon* buffer.
LEN is the number of segments of the curve to draw.  STEP is the
length of each segment.

If LEN is a power-of-2 it shows self-similar nature of the curve,
but any length can be given.  If STEP >= 2 then the segments have
lines with \"|\" or \"-\" characters.  If STEP=1 then only \"+\"
corners.

There's a `sit-for' delay in the drawing loop to draw
progressively on screen."

  (interactive (list (read-number "Length of curve " 256)
                     (read-number "Each step size " 3)))
  (unless (>= step 1)
    (error "Step length must be >= 1"))

  (switch-to-buffer "*dragon*")
  (erase-buffer)
  (ignore-errors (picture-mode))

  (dotimes (n len)  ;; n=0 to len-1, inclusive
    (dragon-insert-char ?+ 1)  ;; corner char
    (dragon-insert-char (if (zerop picture-vertical-step)
                                    picture-rectangle-h picture-rectangle-v)
                                (1- step))  ;; line chars

    (if (dragon-next-turn-right-p n)
        ;; turn right
        (picture-set-motion (- picture-horizontal-step) picture-vertical-step)
      ;; turn left
      (picture-set-motion picture-horizontal-step (- picture-vertical-step)))

    ;; delay to display the drawing progressively
    (sit-for .01))

  (picture-insert ?+ 1) ;; endpoint
  (picture-mode-exit)
  (goto-char (point-min)))

(dragon-picture 256 3)




;; ;;-----------------------------------------------------------------------------
;; ;; by direction
;; 
;; 
;; (defun count-1bits (n)
;;   "Return the number of 1-bits in N.
;; For example N=22 returns 3, since 22 in binary is \"10110\" which
;; has 3 1-bits."
;;   (let ((count 0))
;;     (while (not (zerop n))
;;       ;; (setq n (logxor n (1- n))
;;       (setq count (+ count (logand n 1)))
;;       (setq n (lsh n -1)))
;;     count))
;; 
;; (defun count-bit-runs (n)
;;   "Return the number of runs of the same bits in N.
;; For example N=27 is binary \"11011\" has three runs \"11\", \"0\", \"11\".
;; N=0 has 0 runs."
;;   ;; xor with bits shifted to the right leaves a 1 at each transition
;;   (count-1bits (logxor n (lsh n -1))))
;; 
;; (defun dragon-direction (n)
;;   "Return the direction 0,1,2,3 of the dragon curve at point N.
;; The return is 0=east, 1=north, 2=west, 3=south."
;;   (logand 3 (count-bit-runs n)))
;; 
;; (defun dragon-direction-vh (n)
;;   "Return a list (vert horiz) of the dragon curve step at N.
;; vert and horiz are +1, -1 or 0, in the style of
;; `pointer-set-motion', which means vert=-1 is up the page, vert=+1
;; down the page.  N=0 is the first point of the curve, which is to
;; the left so vert=0 horiz=+1 there."
;;   (aref [(0 1) (-1 0) (0 -1) (1 0)] (dragon-direction n)))
;; 
;; (defun dragon-picture (len step)
;;   (interactive (list (read-number "Length of curve (default 256) " 256)
;;                      (read-number "Each step size (default 3 chars) " 3)))
;;   (unless (>= step 1)
;;     (error "Step length must be >= 1"))
;; 
;;   (switch-to-buffer "*dragon*")
;;   (erase-buffer)
;;   (ignore-errors (picture-mode))
;;   (dotimes (n len)  ;; 0 to len-1, inclusive
;;     ;; direction of the curve at n
;;     (apply 'picture-set-motion (dragon-direction-vh n))
;; 
;;     ;; draw corner "+" and if step>=2 then line "|" or "-" chars too
;;     (dragon-insert-char ?+ 1)
;;     (dragon-insert-char (if (zerop picture-vertical-step)
;;                                     picture-rectangle-h
;;                                   picture-rectangle-v)
;;                                 (1- step))
;; 
;;     ;; delay to make the drawing visible as it progresses
;;     (sit-for .01))
;; 
;;   (dragon-insert-char ?+ 1) ;; endpoint
;;   (picture-mode-exit)
;;   (goto-char (point-min)))
;; 
;; ;; `M-x dragon-picture' to make a buffer with the dragon curve
;; 
;; 
;; 
;; 
;; ;;-----------------------------------------------------------------------------
;; 
;; 
;; 
;; 
;; (mapcar 'dragon-direction (number-sequence 0 16))
;; 
;; (defmacro dragon-with-picture-mode (&rest body)
;;   "Evaluate BODY with `picture-mode' enabled."
;;   `(progn
;;      (picture-mode)
;;      (unwind-protect
;;          (progn ,@body)
;;        (picture-mode-exit))))
;; 
;; (defconst dir-to-dx [1 0 -1 0]
;;     "Vector of +1,-1,0 for X step in direction 0,1,2,3.")
;; (defconst dir-to-dy [0 -1 0 1]
;;     "Vector of +1,-1,0 for Y step in direction 0,1,2,3.")
;; 
;; 
;; ;;-----------------------------------------------------------------------------
;; 
;; 
;; (progn
;;   (defun dragon-insert-char (char step)
;;     (dotimes (i step)
;;       (if (= (current-column) 0) ;; in first column
;;           (save-excursion (goto-char (point-min)) (replace-regexp "^" " ")))
;;       (if (= (point-min) (line-beginning-position)) ;; on first line
;;           (save-excursion (goto-char (point-min)) (insert "\n")))
;;       ;; (picture-update-desired-column t)
;;       (picture-insert char 1)
;;       (sit-for .005)))
;; 
;;   (dragon-picture 8 3))
;; 
;; (shell-command "math-image --expression='i<32?i:0' --path=DragonCurve --scale=20")
;; 
;;     ;; (picture-forward-column 40)
;;     ;; (picture-move-down 40)
;; 
;;     (if (= 0 (current-column))
;;         (save-excursion (rect
;; 
;; # find which side to turn based on the iteration
;; $angle +=
;; 
;; my ($dx, $dy) = ($x + $len * $angle.sin, $y - $len * $angle.cos);
;; say "<line x1='$x' y1='$y' x2='$dx' y2='$dy' style='stroke:rgb(0,0,0);stroke-width:1'/>";
;; ($x, $y) = ($dx, $dy);
;; }
;; 
;; 
;; (dotimes (i (1- (lsh 1 5)))
;;   (let ((right (zerop (logand i (lsh (1+ (logxor i (1+ i))) 0)))))
;;     (insert (if right "1" "0"))))
;; 
;; ;; (insert (format "%S\n" (1+ (logxor i (1+ i))))))
;; 
;; 
;; 110110011100100111011000
;; 
