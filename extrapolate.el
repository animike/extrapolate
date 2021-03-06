;;; extrapolate.el --- Emacs library for live highlighting of text that matches with the marked region.  -*- lexical-binding: t; -*-

;; Copyright (C) 2016  Nicolas Richard

;; Author: Nicolas Richard <youngfrog@members.fsf.org>
;; Requires: ov
;; Keywords: context highlight region mark match live

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Dependencies:

;; ov.el in https://github.com/ShingoFukuyama/ov.el

;;; Comments:

;; Contextual live highlighting of text that matches with (i.e. is equal
;; to) the marked region.

;; See http://emacs.stackexchange.com/questions/22041/automatic-search-and-replace-of-the-marked-region

;; Recommended: use with selected.el to instantly bind isearch to cycle
;; across the highlighted matches with just one command when the marked
;; region is active.

;;; Code:

(defvar extrapolate--highlighted-text "")

(define-minor-mode extrapolate-mode
  "Contextual live highlighting of text that matches (i.e. is equal to) with the marked region."
  nil nil nil
  (remove-hook 'activate-mark-hook #'extrapolate--run t)
  (add-hook 'activate-mark-hook #'extrapolate--run nil t)
  (remove-hook 'deactivate-mark-hook #'extrapolate--run t)
  (add-hook 'deactivate-mark-hook #'extrapolate--run nil t)
  ;; as for GNU Emacs 25.0.93.1 (i686-pc-linux-gnu, X toolkit, Xaw scroll bars) of 2016-05-03
  ;; it seems that the following behaviour of activate-mark-hook described in its dosctring :
  ;; >> It is also run at the end of a command, if the mark is active and
  ;; >> it is possible that the region may have changed.
  ;; actually doesn't work. Thus let's add ourselves to post-command-hook...
  (remove-hook 'post-command-hook #'extrapolate--run t)
  (add-hook 'post-command-hook #'extrapolate--run nil t))

(defun extrapolate--run ()
  (run-at-time 0.01 nil 'extrapolate--run2))

(defun extrapolate--run2 nil
  (let ((str (if (use-region-p)
				 (buffer-substring-no-properties (region-beginning) (region-end))
			   "")))
	(if (string= str "")
		(extrapolate--unhighlight-matches str)
	  (progn
		(extrapolate--highlight-matches str))
	  nil)))

(defun extrapolate--highlight-matches (str)
  (if (string= str extrapolate--highlighted-text)
	  nil
	(progn
	  (ov-clear 'extrapolate)
	  (ov-set (regexp-quote str) 'face 'extrapolate 'extrapolate t)
	  (setq extrapolate--highlighted-text str))))

(defun extrapolate--unhighlight-matches (str)
  (if (string= str extrapolate--highlighted-text)
	  nil
	(progn
	  (ov-clear 'extrapolate)
	  (setq extrapolate--highlighted-text ""))))

(defface extrapolate
  '((t :inherit lazy-highlight))
  "Contextual highlighting from the Extrapolate library."
  :group 'faces)

(provide 'extrapolate)

;;; extrapolate.el ends here
