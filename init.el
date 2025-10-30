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


;;; End of init.el