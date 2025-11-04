;;; init.el --- Emacs configuration file
;;; Commentary:
;;; This file is organized into sections for better readability and maintenance.

;;; 0. Package Management ---
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/")))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;;; 1. Appearance ---
(use-package doom-themes
  :ensure t
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-bluloco-dark t)
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

(use-package nerd-icons)

(use-package all-the-icons)

;;; 2. Completion ---
(use-package vertico
  :config
  (vertico-mode))

(use-package corfu
  :config
  (global-corfu-mode))

(use-package consult)

(use-package marginalia
  :config
  (marginalia-mode))

(use-package embark-consult
  :ensure t
  :after (consult embark))

(use-package embark
  :after consult)

;;; 3. Project Management ---
(use-package projectile
  :diminish projectile-mode
  :bind (("s-p" . projectile-command-map)
         ("C-c p" . projectile-command-map))
  :config
  (projectile-mode +1)
  (setq projectile-project-root-files
        (append '("CMakeLists.txt") projectile-project-root-files))
  (setq projectile-ignored-projects '("~/")))

(use-package treemacs
  :ensure t)

;;; 4. Language Support ---
;;; C++ Configuration
(use-package eglot
  :hook (c++-mode . eglot-ensure)
  :config
  (setq eglot-server-programs '((c++-mode . ("clangd")))))

(use-package c-ts-mode
  :mode "\.cpp\'" "\.h\'" "\.cc\'"
  :config
  (add-to-list 'major-mode-remap-alist '(c++-mode . c++-ts-mode))
  (add-to-list 'major-mode-remap-alist '(c-mode . c-ts-mode)))

(use-package apheleia
  :config
  (apheleia-global-mode +1)
  (setf (alist-get 'c++-ts-mode apheleia-formatters) '("clang-format"))
  (setf (alist-get 'c-ts-mode apheleia-formatters) '("clang-format")))

;;; 5. Debugging ---
(use-package dap-mode
  :after (treemacs)
  :config
  (require 'dap-cpptools)
  (require 'dap-ui)
  (dap-ui-mode 1)
  (require 'dap-variables)

  (dap-register-debug-template
   "My C++ Project"
   (list :type "cppdbg"
         :request "launch"
         :name "My C++ Project::Launch"
         :MIMode "gdb"
         :program "${workspaceFolder}/build/my_executable"
         :args '()
         :cwd "${workspaceFolder}")))

;;; 6. Version Control ---
(use-package magit
  :commands magit-status)

;;; 7. Utilities ---
(use-package default-text-scale
  :config
  (default-text-scale-mode))

;; Line numbers in all buffers
(setq display-line-numbers-type t)
(global-display-line-numbers-mode 1)

;; Optional: turn them off in terminals or shells
(dolist (mode '(term-mode eshell-mode shell-mode vterm-mode))
  (add-hook (intern (format "%s-hook" mode))
            (lambda () (display-line-numbers-mode 0))))

;;; 8. Frame Configuration ---
(defun maximize-frame ()
  "Maximize the frame."
  (modify-frame-parameters nil '((fullscreen . maximized))))

(add-hook 'after-make-frame-functions
          (lambda (frame)
            (with-selected-frame frame
              (maximize-frame))))

(add-hook 'emacs-startup-hook 'maximize-frame)


;;; 9. Startup Configuration ---
(setq inhibit-startup-screen t)

;;; 10. Modal Editing ---
(use-package evil
  :init
  (setq evil-want-integration t      ;; integrate with core Emacs features
        evil-want-keybinding nil     ;; let evil-collection handle bindings
        evil-want-C-u-scroll t       ;; C-u scrolls up
        evil-want-C-i-jump t)        ;; keep TAB jump behavior
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package evil-surround
  :after evil
  :config
  (global-evil-surround-mode 1))

(use-package evil-commentary
  :after evil
  :config
  (evil-commentary-mode 1))

;;; 11. Terminal mouse support ---
(defun my-enable-mouse-in-tty (frame)
  "Enable mouse support when FRAME is a terminal frame."
  (unless (display-graphic-p frame)
    (with-selected-frame frame
      (xterm-mouse-mode 1)     ;; basic mouse in terminal
      (mouse-wheel-mode 1))))  ;; enable wheel events if available

;; For daemon or new frames
(add-hook 'after-make-frame-functions #'my-enable-mouse-in-tty)

;; For the current frame when starting directly in a terminal
(unless (display-graphic-p)
  (xterm-mouse-mode 1)
  (mouse-wheel-mode 1))

;;; 12. Terminal: vterm ---
(use-package vterm
  :commands (vterm vterm-other-window)
  :custom
  (vterm-max-scrollback 10000)
  (vterm-always-compile-module t)
  (vterm-shell (or (getenv "SHELL") "/bin/bash"))
  :hook
  (vterm-mode . (lambda ()
                  (display-line-numbers-mode 0)
                  (setq-local global-hl-line-mode nil)))
  :bind
  (("C-c t" . vterm-bottom)))  ;; new keybind

;; Helper: find project root via Projectile, else project.el, else current dir
(defun my/project-root ()
  (or (and (fboundp 'projectile-project-root)
           (projectile-project-p)
           (projectile-project-root))
      (when-let ((proj (project-current)))
        (car (project-roots proj)))
      default-directory))

(defun vterm-bottom ()
  "Open vterm at the project root in a bottom split, about one third of the frame."
  (interactive)
  (let* ((root (my/project-root))
         (total (window-total-height))
         (height (max 10 (floor (* total 0.33))))
         (win (split-window (selected-window) (- total height))))
    (select-window win)
    (let ((default-directory root))
      ;; Optional pretty buffer name: *vterm project*
      (vterm (format "*vterm %s*"
                     (file-name-nondirectory (directory-file-name root)))))))

;;; 14. CMake highlighting with cmake-font-lock

;; Force classic cmake-mode for CMake files, since cmake-font-lock hooks into it
(use-package cmake-mode
  :mode ("CMakeLists\\.txt\\'" "\\.cmake\\'"))

;; Extra highlighting for commands, vars, properties, generator expressions
(use-package cmake-font-lock
  :after cmake-mode
  :hook (cmake-mode . cmake-font-lock-activate))

;;; End of init.el
