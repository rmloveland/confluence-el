;;; confluence-markup.el --- Emacs mode for highlighting Confluence markup.

;; Copyright (C) 2008  Free Software Foundation, Inc.
;; Copyright (C) 2013, 2014, 2015, 2016 Richard Loveland <r@rmloveland.com>

;; Author: James Ahlborn
;; Author: Kyle Burton <kyle.burton@gmail.com>
;; Author: Richard Loveland <r@rmloveland.com>
;; Keywords: Confluence, Wiki, Wikis, WikiText, Markup

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; This file began its life as 'confluence.el', a full-featured
;; package with the ability to edit Confluence wiki pages over the
;; network.  It's now a simple syntax highlighter.  All network-facing
;; functionality has been removed.

;;; Code:

(defgroup confluence-markup nil
  "Highlighter for text files using Confluence wiki syntax."
  :prefix "confluence-markup"
  :group 'wp)

(defvar confluence-markup-code-face 'confluence-markup-code-face)

(defface confluence-markup-code-face
  '((((class color) (background dark))
     (:foreground "dim gray" :bold t))
    (((class color) (background light))
     (:foreground "dim gray"))
    (t (:bold t)))
  "Font Lock Mode face used for code in Confluence wiki syntax.")

(defvar confluence-markup-panel-face 'confluence-markup-panel-face)

(defface confluence-markup-panel-face
  '((((class color) (background dark))
     (:background "LightGray"))
    (((class color) (background light))
     (:background "LightGray"))
    (t nil))
  "Font Lock Mode face used for panel in Confluence wiki syntax.")

(defconst confluence-markup-font-lock-keywords-1
  (list
  
   '("{\\([^{}:\n]+:?\\)[^{}\n]*}"
     (1 'font-lock-constant-face))
  
   '("{[^{}\n]+[:|]title=\\([^}|\n]+\\)[^{}\n]*}"
     (1 'bold append))
  
   '("{warning\\(?:[:][^}\n]*\\)?}\\(\\(.\\|[\n]\\)*?\\){warning}"
     (1 'font-lock-warning-face prepend))
   '("{note\\(?:[:][^}\n]*\\)?}\\(\\(.\\|[\n]\\)*?\\){note}"
     (1 'font-lock-minor-warning-face prepend))
   '("{info\\(?:[:][^}\n]*\\)?}\\(\\(.\\|[\n]\\)*?\\){info}"
     (1 'font-lock-doc-face prepend))
   '("{tip\\(?:[:][^}\n]*\\)?}\\(\\(.\\|[\n]\\)*?\\){tip}"
     (1 'font-lock-comment-face prepend))
  
   ;; bold
   '("[^[:word:]\\*][*]\\([^*\n]+\\)[*]\\W"
     (1 'bold))
   
   ;; code
   '("{{\\([^}\n]+\\)}}"
     (1 'confluence-markup-code-face t))
   
   ;; italics/emphasised
   '("[^[:word:]\\]_\\([^_\n]+\\)_\\W"
     (1 'italic prepend))
   '("[^[:word:]\\][?]\\{2\\}\\([^?\n]+\\)[?]\\{2\\}\\W"
     (1 'italic prepend))

   ;; underline
   '("[^[:word:]\\][+]\\([^+\n]+\\)[+]\\W"
     (1 'underline prepend))

   ;; strike-through
   '("[^[:word:]\\][-]\\([^-\n]+\\)[-]\\W"
     (1 '(:strike-through t) prepend))

   ;; headings
   '("^h1[.] \\(.*\\)$"
     (1 '(bold underline) prepend))
   '("^h2[.] \\(.*\\)$"
     (1 '(bold italic underline) prepend))
   '("^h3[.] \\(.*\\)$"
     (1 '(italic underline) prepend))
   '("^h[4-9][.] \\(.*\\)$"
     (1 'underline prepend))

   ;; ** outline headers

   ;; Generic, matches all headers
   '("^[\*]+ \\(.*\\)$"
	 (0 '(:height 1.0 :overline "#A7A7A7" :foreground "#005522" :background "#E5F4FB")
		nil
		t))

   ;; bullet points
   '("^\\([\+#]+\\)\\s-"
     (1 'font-lock-constant-face))
   
   ;; links
   '("\\(\\[\\)\\([^|\n]*\\)[|]\\([^]\n]+\\)\\(\\]\\)"
     (1 'font-lock-constant-face)
     (2 'font-lock-string-face)
     (3 'underline)
     (4 'font-lock-constant-face))
   '("\\(\\[\\)\\([^]|\n]+\\)\\(\\]\\)"
     (1 'font-lock-constant-face)
     (2 '(font-lock-string-face underline))
     (3 'font-lock-constant-face))
   '("{anchor:\\([^{}\n]+\\)}"
     (1 'font-lock-string-face))

   ;; images, embedded content
   '("\\([!]\\)\\([^|\n]+\\)[|]\\(?:[^!\n]*\\)\\([!]\\)"
     (1 'font-lock-constant-face)
     (2 '(font-lock-reference-face underline))
     (3 'font-lock-constant-face))
   '("\\([!]\\)\\([^!|\n]+\\)\\([!]\\)"
     (1 'font-lock-constant-face)
     (2 '(font-lock-reference-face underline))
     (3 'font-lock-constant-face))
   
   ;; tables
   '("[|]\\{2\\}\\([^|\n]+\\)"
     (1 'bold))
   '("\\([|]\\{1,2\\}\\)"
     (1 'font-lock-constant-face))
   )
  
  "Basic highlighting for Confluence Markup mode.")

(defconst confluence-markup-font-lock-keywords-2
  (append confluence-markup-font-lock-keywords-1
          (list
  
           ;; code/preformatted blocks
           '("{noformat\\(?:[:][^}\n]*\\)?}\\(\\(.\\|[\n]\\)*?\\){noformat}"
             (1 'confluence-markup-code-face t))
           '("{code\\(?:[:][^}\n]*\\)?}\\(\\(.\\|[\n]\\)*?\\){code}"
             (1 'confluence-markup-code-face t))

           ;; panels
           '("{panel\\(?:[:][^}\n]*\\)?}\\(?:\\s-*[\r]?[\n]\\)?\\(\\(.\\|[\n]\\)*?\\){panel}"
             (1 'confluence-markup-panel-face append))
           ))
  "Gaudy level highlighting for confluence mode.")

(defvar confluence-markup-font-lock-keywords confluence-markup-font-lock-keywords-1
  "Default expressions to highlight in Confluence modes.")

(defun confluence-markup-newline-and-indent ()
  "Inserts a newline and indents using the previous indentation.
Supports lists, tables, and headers."
  (interactive)
  (let ((indentation nil)
        (limit nil))
    ;; find the beginning of the previous line, skipping "soft" newlines if
    ;; "hard" newlines are being used (like in longlines mode)
    (save-excursion
      (while (and (search-backward "\n" nil 'silent)
                  use-hard-newlines
                  (not (get-text-property (match-beginning 0) 'hard))))
      (setq limit (point)))
    ;; find the indentation of the previous line
    (save-excursion
      (if (re-search-backward "^\\(?:\\(?:\\(?:[*#]+\\|h[0-9][.]\\)[ \t]+\\)\\|[|]+\\)" limit t)
          (setq indentation (match-string 0))))
    (newline)
    (if indentation
        (insert indentation))))

(defun confluence-markup-list-indent-dwim (&optional arg)
  "Increases the list indentationn on the current line by 1 bullet.  With ARG decreases by 1 bullet."
  (interactive "P")
  (let ((indent-arg (if arg -1 1)))
    (if (and mark-active transient-mark-mode)
        (let ((beg (min (point) (mark)))
              (end (max (point) (mark)))
              (tmp-point nil))
          (save-excursion
            (goto-char end)
            (if (bolp)
                (forward-line -1))
            (setq tmp-point (line-beginning-position))
            (confluence-markup-modify-list-indent indent-arg)
            (while (and (forward-line -1)
                        (not (equal (line-beginning-position) tmp-point))
                        (>= (line-end-position) beg))
              (setq tmp-point (line-beginning-position))
              (confluence-markup-modify-list-indent indent-arg))
          ))
    (confluence-markup-modify-list-indent indent-arg))))

(defun confluence-markup-modify-list-indent (depth)
  "Updates the list indentation on the current line, adding DEPTH bullets if DEPTH is positive or removing DEPTH
bullets if DEPTH is negative (does nothing if DEPTH is 0)."
  (interactive "nList Depth Change: ")
  (save-excursion
    (beginning-of-line)
    (cond
     ((> depth 0)
      (let ((indent-str (concat (make-string depth ?*) " ")))
        (if (re-search-forward "\\=\\([*#]+\\)" (line-end-position) t)
            (setq indent-str (make-string depth (elt (substring (match-string 1) -1) 0))))
        (insert-before-markers indent-str)))
     ((< depth 0)
      (let ((tmp-point (point))
            (indent-str ""))
        (if (re-search-forward "\\=\\([*#]+\\)" (line-end-position) t)
            (progn 
              (setq indent-str (match-string 1))
              (setq indent-str
                    (if (< (abs depth) (length indent-str))
                        (substring indent-str 0 depth)
                      ""))))
        (delete-region tmp-point (point))
        (insert-before-markers indent-str))))))

(define-derived-mode confluence-markup-mode text-mode "Confluence Markup"
  "Set major mode for editing Confluence Wiki pages."
  (turn-off-auto-fill)
  (make-local-variable 'words-include-escapes)
  (setq words-include-escapes t)
  (modify-syntax-entry ?\\ "\\")
  (set (make-local-variable 'font-lock-defaults)
	   '((confluence-markup-font-lock-keywords
		  confluence-markup-font-lock-keywords-1
		  confluence-markup-font-lock-keywords-2)
          nil nil nil nil (font-lock-multiline . t))))

(provide 'confluence-markup)

;;; confluence-markup.el ends here
