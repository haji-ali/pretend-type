;;; pretend-type.el --- Reveal buffer as you pretend to type -*- lexical-binding: t -*-
;;
;; Author: Al Haji-Ali <abdo.haji.ali@gmail.com>
;; URL: https://github.com/haji-ali/pretend-type
;; Version: 0.1.0
;; Package-Requires: ((emacs "24.3"))
;; Keywords: hide show invisible learning games
;;
;; This file is not part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;
;;; Commentary:
;; This package implements a mode which hide a buffer content and then reveals
;; it as one pretend to type.

;;; Code:

(defvar pretend-type-mode-map
  (let ((map (make-sparse-keymap)))
    ;; Printable ASCII characters (space through ~)
    (dotimes (i 127)
      (when (and (>= i 32) (<= i 126))
        (define-key map (char-to-string i) #'pretend-type--reveal-char)))
    ;; Newline keys
    (define-key map [remap newline] #'pretend-type--reveal-to-next-line)
    ;; TAB reveals next word
    (define-key map [remap indent-for-tab-command] #'pretend-type--reveal-next-word)
    ;; Backspace hides one character
    (define-key map [remap delete-backward-char] #'pretend-type--hide-char)
    ;; M-Backspace hides previous word
    (define-key map [remap backward-kill-word] #'pretend-type--hide-word)
    map)
  "Keymap for `pretend-type-mode`.
Only text-revealing keys, TAB, newline, and hide keys are bound.")

(defvar-local pretend-type--overlay nil
  "Overlay covering the hidden portion of the buffer.")

(defun pretend-type--init ()
  "Initialize `pretend-type-mode` by hiding all buffer content with an overlay."
  (setq pretend-type--overlay (make-overlay (point-min) (point-max)))
  (overlay-put pretend-type--overlay 'display " ") ;; hide all content
  (read-only-mode 1)
  (goto-char (overlay-start pretend-type--overlay)))

(defun pretend-type--maybe-disable ()
  "Disable `pretend-type-mode` if the entire buffer is revealed."
  (when (>= (overlay-start pretend-type--overlay) (point-max))
    (pretend-type-mode -1)))

(defun pretend-type--reveal-char ()
  "Reveal the next character or all consecutive whitespace in the buffer."
  (interactive)
  (let ((inhibit-read-only t)
        (start (overlay-start pretend-type--overlay))
        end)
    (when (< start (point-max))
      (setq end start)
      ;; Reveal consecutive whitespace or a single character
      (while (and (< end (point-max))
                  (memq (char-after end) '(?\  ?\t ?\n ?\r)))
        (setq end (1+ end)))
      (when (= end start)
        (setq end (1+ start)))
      (move-overlay pretend-type--overlay end (overlay-end pretend-type--overlay))
      (goto-char end)))
  (pretend-type--maybe-disable))

(defun pretend-type--reveal-to-next-line ()
  "Reveal all characters up to and including the next newline, skipping leading whitespace."
  (interactive)
  (let ((inhibit-read-only t)
        (start (overlay-start pretend-type--overlay))
        end)
    (when (< start (point-max))
      ;; Find the position of the next newline or end of buffer
      (setq end (or (save-excursion
                      (goto-char start)
                      (search-forward "\n" nil t))
                    (point-max)))
      ;; Expand end forward to include all whitespace up to the next non-whitespace character
      (while (and (< end (point-max))
                  (memq (char-after end) '(?\  ?\t ?\n ?\r)))
        (setq end (1+ end)))
      ;; Move the overlay and point
      (move-overlay pretend-type--overlay end (overlay-end pretend-type--overlay))
      (goto-char end)))
  (pretend-type--maybe-disable))

(defun pretend-type--reveal-next-word ()
  "Reveal characters up to the end of the next word, including leading whitespace."
  (interactive)
  (let ((inhibit-read-only t)
        (start (overlay-start pretend-type--overlay))
        next-word)
    (when (< start (point-max))
      (setq next-word (save-excursion
                        (goto-char start)
                        ;; Skip leading whitespace
                        (while (and (< (point) (point-max))
                                    (memq (char-after (point)) '(?\  ?\t ?\n ?\r)))
                          (forward-char 1))
                        ;; Move to end of word
                        (forward-word 1)
                        (point)))
      (move-overlay pretend-type--overlay next-word (overlay-end pretend-type--overlay))
      (goto-char next-word)))
  (pretend-type--maybe-disable))

(defun pretend-type--hide-char ()
  "Hide the previous character."
  (interactive)
  (let ((inhibit-read-only t)
        (start (overlay-start pretend-type--overlay)))
    (when (> start (point-min))
      (move-overlay pretend-type--overlay (1- start) (overlay-end pretend-type--overlay))
      (goto-char (1- start)))))

(defun pretend-type--hide-word ()
  "Hide the previous word."
  (interactive)
  (let ((inhibit-read-only t)
        (start (overlay-start pretend-type--overlay))
        prev-word)
    (when (> start (point-min))
      (setq prev-word (save-excursion
                        (goto-char start)
                        (backward-word 1)
                        (point)))
      (move-overlay pretend-type--overlay prev-word (overlay-end pretend-type--overlay))
      (goto-char prev-word))))

;;;###autoload
(define-minor-mode pretend-type-mode
  "Minor mode to hide buffer content and reveal it as you pretend to type."
  :lighter " Pretend"
  :keymap pretend-type-mode-map
  (if pretend-type-mode
      (pretend-type--init)
    ;; Disable mode
    (when (overlayp pretend-type--overlay)
      (delete-overlay pretend-type--overlay))
    (read-only-mode -1)))

(provide 'pretend-type)

;;; pretend-type.el ends here
