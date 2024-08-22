;; Initialize package sources
(require 'package)

;; Add MELPA to the list of package archives if it's not already there
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;; Initialize the package system
(package-initialize)

;; Refresh package contents if the archives are empty
(unless package-archive-contents
  (package-refresh-contents))

;; Install use-package if it's not already installed
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

;; Ensure use-package is always installed
(require 'use-package)
(setq use-package-always-ensure t)

;; Install and configure Magit using use-package
(use-package magit
  :bind (("C-x g" . magit-status)))

;; Install and configure color-theme-sanityinc-tomorrow using use-package
(use-package color-theme-sanityinc-tomorrow
  :config
  (load-theme 'sanityinc-tomorrow-night t))

;; Enable line numbers globally
(global-display-line-numbers-mode t)
