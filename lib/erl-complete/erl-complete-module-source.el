;; Copyright 2012 Thomas Järvstrand <tjarvstrand@gmail.com>
;;
;; This file is part of EDTS.
;;
;; EDTS is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; EDTS is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with EDTS. If not, see <http://www.gnu.org/licenses/>.
;;
;; auto-complete source for erlang modules.

(require 'auto-complete)
(require 'ferl)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Source

(defvar erl-complete-module-source
  '((candidates . erl-complete-module-candidates)
    (document   . nil)
    (symbol     . "m")
    (requires   . nil)
    (limit      . nil)
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Candidate functions

(defun erl-complete-module-candidates ()
  (case (erl-complete-point-inside-quotes)
    ('double-quoted  nil) ; Don't complete inside strings
    ('single-quoted (erl-complete-single-quoted-module-candidates))
    ('none          (erl-complete-normal-module-candidates))))

(defvar erl-complete-module-completions nil
  "The current completion for modules")

(defun erl-complete-normal-module-candidates ()
  "Produces the completion list for normal (unqoted) modules."
  (when (erl-complete-module-p)
    (let* ((resource (list "nodes" (symbol-name erl-nodename-cache) "modules"))
           (res      (edts-rest-get resource nil)))
      (if (equal (assoc 'result res) '(result "200" "OK"))
          (cdr (assoc 'body res))
          (message "Unexpected reply: %s" (cdr (assoc 'result res)))))))

(defun erl-complete-single-quoted-module-candidates ()
  "Produces the completion for single-qoted erlang modules, Same as normal
candidates, except we single-quote-terminate candidates."
  (mapcar
   #'erl-complete-single-quote-terminate
   erl-complete-normal-module-candidates))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Conditions
;;

(defun erl-complete-module-p ()
  "Returns non-nil if the current `ac-prefix' can be completed with a module."
  (let ((preceding (erl-complete-term-preceding-char)))
    (and
     (not (equal ?? preceding))
     (not (equal ?# preceding))
     (string-match erlang-atom-regexp ac-prefix))))

(provide 'erl-complete-module-source)