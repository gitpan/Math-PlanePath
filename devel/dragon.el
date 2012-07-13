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

;; left +90    -Y,X
;; right -90   Y,-X

(progn
  (defun bit-above-lowest-1bit (n)
    (logand n (lsh (1+ (logxor n (1- n))) 0)))
  (defun dragon-turn-right-p (n)
    (zerop (bit-above-lowest-1bit n)))

  (defun dragon-picture-insert (ch step)
    (dotimes (i step)
      (if (= (current-column) 0) ;; in first column
          (save-excursion (goto-char (point-min)) (replace-regexp "^" " ")))
      (if (= (point-min) (line-beginning-position)) ;; on first line
          (save-excursion (goto-char (point-min)) (insert "\n")))
      (picture-update-desired-column t)
      (picture-insert ?* 1)
      (sit-for .005)))

  (defun dragon-picture (depth step)
    (interactive (list (read-number "Replication levels (default 8) " 8)
                       (read-number "Each step size (default 3) " 3)))
    (switch-to-buffer "*dragon*")
    (erase-buffer)
    (picture-mode)

    (dotimes (n (lsh 1 depth))  ;; 0 to 2**depth-1
      (dragon-picture-insert ?* step)
      ;; then turn right or left
      (let ((right (dragon-turn-right-p n)))
        (picture-set-motion (* picture-horizontal-step (if right -1 1))
                            (* picture-vertical-step   (if right 1 -1)))))

    (picture-mode-exit)
    (goto-char (point-min)))

  (dragon-picture 12 1))

(shell-command "math-image --expression='i<32?i:0' --path=DragonCurve --scale=20")

    ;; (picture-forward-column 40)
    ;; (picture-move-down 40)

    (if (= 0 (current-column))
        (save-excursion (rect

# find which side to turn based on the iteration
$angle +=

my ($dx, $dy) = ($x + $len * $angle.sin, $y - $len * $angle.cos);
say "<line x1='$x' y1='$y' x2='$dx' y2='$dy' style='stroke:rgb(0,0,0);stroke-width:1'/>";
($x, $y) = ($dx, $dy);
}


(dotimes (i (1- (lsh 1 5)))
  (let ((right (zerop (logand i (lsh (1+ (logxor i (1+ i))) 0)))))
    (insert (if right "1" "0"))))

;; (insert (format "%S\n" (1+ (logxor i (1+ i))))))


110110011100100111011000
