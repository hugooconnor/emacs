(split-window-right)
(split-window-vertically)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default bold shadow italic underline bold bold-italic bold])
 '(ansi-color-names-vector
   (vector "#657b83" "#dc322f" "#859900" "#b58900" "#268bd2" "#d33682" "#2aa198" "#073642"))
 '(custom-enabled-themes (quote (sanityinc-solarized-light)))
 '(custom-safe-themes
   (quote
    ("4cf3221feff536e2b3385209e9b9dc4c2e0818a69a1cdb4b522756bcdf4e00a4" "4aee8551b53a43a883cb0b7f3255d6859d766b6c5e14bcb01bed572fcbef4328" "9d91458c4ad7c74cf946bd97ad085c0f6a40c370ac0a1cbeb2e3879f15b40553" default)))
 '(fci-rule-color "#eee8d5")
 '(initial-frame-alist (quote ((fullscreen . maximized))))
 '(js2-basic-offset 2)
 '(vc-annotate-background nil)
 '(vc-annotate-color-map
   (quote
    ((20 . "#dc322f")
     (40 . "#cb4b16")
     (60 . "#b58900")
     (80 . "#859900")
     (100 . "#2aa198")
     (120 . "#268bd2")
     (140 . "#d33682")
     (160 . "#6c71c4")
     (180 . "#dc322f")
     (200 . "#cb4b16")
     (220 . "#b58900")
     (240 . "#859900")
     (260 . "#2aa198")
     (280 . "#268bd2")
     (300 . "#d33682")
     (320 . "#6c71c4")
     (340 . "#dc322f")
     (360 . "#cb4b16"))))
 '(vc-annotate-very-old-color nil))

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(package-initialize)
(global-git-gutter-mode +1)
(add-to-list 'auto-mode-alist (cons (rx ".js" eos) 'js2-mode))
(setq js2-strict-missing-semi-warning nil)
(setq js2-missing-semi-one-line-override t)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(when (fboundp 'windmove-default-keybindings)
  (windmove-default-keybindings))
(add-hook 'emacs-startup-hook 'eshell)
(add-hook 'js2-mode-hook 
  (lambda ()
    (linum-mode 1)))
;;set color theme
(color-theme-sanityinc-solarized-dark)

;; no startup msg  
(setq inhibit-startup-message t)        ; Disable startup message 
(global-set-key (kbd "C-x C-b") 'ibuffer)
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode 1)

;look customisations
(blink-cursor-mode 0)
(scroll-bar-mode 0)
(tool-bar-mode 0)
(menu-bar-mode 0)
(tool-bar-mode 0)

(load "~/.emacs.d/eshell/eshell-customisation.el")
:;(projectile-global-mode)
(require 'flycheck)
(add-hook 'after-init-hook #'global-flycheck-mode)
(setq-default flycheck-disabled-checkers
  (append flycheck-disabled-checkers
    '(javascript-jshint)))
(flycheck-add-mode 'javascript-eslint 'js2-mode)

;; use local eslint from node_modules before global
;; http://emacs.stackexchange.com/questions/21205/flycheck-with-file-relative-eslint-executable
(defun my/use-eslint-from-node-modules ()
  (let* ((root (locate-dominating-file
                (or (buffer-file-name) default-directory)
                "node_modules"))
         (eslint (and root
                      (expand-file-name "node_modules/eslint/bin/eslint.js"
                                        root))))
    (when (and eslint (file-executable-p eslint))
      (setq-local flycheck-javascript-eslint-executable eslint))))
(add-hook 'flycheck-mode-hook #'my/use-eslint-from-node-modules)

(defun toggle-comment-on-line ()
  "comment or uncomment current line"
  (interactive)
  (if (region-active-p)
      (comment-or-uncomment-region (region-beginning) (region-end))
    (comment-or-uncomment-region (line-beginning-position) (line-end-position))))
(global-set-key (kbd "C-;") 'toggle-comment-on-line)

(setq-default indent-tabs-mode nil)

;; put autosave files into temp directory

(setq backup-directory-alist
          `((".*" . ,temporary-file-directory)))
    (setq auto-save-file-name-transforms
          `((".*" ,temporary-file-directory t)))

(global-set-key (kbd "C-c g") 'magit-status)

(defun count-words (&optional begin end)
  "count words between BEGIN and END (region); if no region defined, count words in buffer"
  (interactive "r")
  (let ((b (if mark-active begin (point-min)))
      (e (if mark-active end (point-max))))
    (message "Word count: %s" (how-many "\\w+" b e))))

;; Make windmove work in org-mode:
(add-hook 'org-shiftup-final-hook 'windmove-up)
(add-hook 'org-shiftleft-final-hook 'windmove-left)
(add-hook 'org-shiftdown-final-hook 'windmove-down)
(add-hook 'org-shiftright-final-hook 'windmove-right)

;; Auto-complete
(ac-config-default)
(add-hook 'eshell-mode-hook 'auto-complete-mode)


;; TIDE
(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1)
  ;; company is an optional dependency. You have to
  ;; install it separately via package-install
  ;; `M-x package-install [ret] company`
  (company-mode +1))

;; aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)

;; formats the buffer before saving
(add-hook 'before-save-hook 'tide-format-before-save)

(add-hook 'typescript-mode-hook #'setup-tide-mode)

(defadvice terminal-init-screen
  ;; The advice is named `tmux', and is run before `terminal-init-screen' runs.
  (before tmux activate)
  ;; Docstring.  This describes the advice and is made available inside emacs;
  ;; for example when doing C-h f terminal-init-screen RET
  "Apply xterm keymap, allowing use of keys passed through tmux."
  ;; This is the elisp code that is run before `terminal-init-screen'.
  (if (getenv "TMUX")
    (let ((map (copy-keymap xterm-function-map)))
    (set-keymap-parent map (keymap-parent input-decode-map))
    (set-keymap-parent input-decode-map map))))

  (add-hook 'eshell-mode-hook 'eshell-load-bashrc-aliases)
    (defun re-n-matches ()
      (1- (/ (length (match-data)) 2)))
      
    (defun match-strings-all (&optional string)
      "Return the list of all expressions matched in last search.
      STRING is optionally what was given to `string-match'."
      (loop for i from 0 to (re-n-matches)
    	collect (match-string-no-properties i string)))
      
    (defun re-find-all (regexp string &optional groups yes-props)
      "like python's re.find_all"
      (let (
    	(groups (or groups (list (regexp-count-capture-groups regexp))))
    	(match-string-fun (if (not yes-props) 'match-string 'match-string-no-properties))
    	(start 0)
    	(matches nil )
    	)
        (while (setq start (and (string-match regexp string start) (match-end 0)))
    	(setq matches (cons (cdr (match-strings-all string)) matches))
    	)
        (setq matches (reverse matches))
        (if (not (cdar matches))
    	(mapcar 'car matches)
          matches
          )
        )
      )
    
    
    (defun apply-eshell-alias (alias &rest definition)
      "basically taken from eshell/alias function"
        (if (not definition)
    	(setq eshell-command-aliases-list
    	      (delq (assoc alias eshell-command-aliases-list)
    		    eshell-command-aliases-list))
          (and (stringp definition)
    	   (set-text-properties 0 (length definition) nil definition))
          (let ((def (assoc alias eshell-command-aliases-list))
    	    (alias-def (list alias
    			     (eshell-flatten-and-stringify definition))))
    	(if def
    	    (setq eshell-command-aliases-list
    		  (delq def eshell-command-aliases-list)))
    	(setq eshell-command-aliases-list
    	      (cons alias-def eshell-command-aliases-list))))
      )
    (defun eshell-load-bashrc-aliases ()
      (interactive)
      (mapc (lambda (alias-def) (apply 'eshell/alias alias-def))
    	(re-find-all "^alias \\([^=]+\\)='?\\(.+?\\)'?$"
    		     (get-string-from-file  (concat (getenv "HOME") "/" ".bash_aliases"))
    		     )
    	)
      )

(require 'solidity-mode)

;;; init.el ends here
