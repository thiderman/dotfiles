(use-package filenotify)

(use-package compile
  :init
  (add-to-list 'comint-output-filter-functions 'ansi-color-process-output)

  (ignore-errors
    (require 'ansi-color)
    (defun colorize-compilation-buffer ()
      (when (eq major-mode 'compilation-mode)
        (ansi-color-apply-on-region compilation-filter-start (point-max))))
    (add-hook 'compilation-filter-hook 'colorize-compilation-buffer))

  ;; We usually want to see all of it
  (add-hook 'compilation-mode-hook (lambda () (toggle-truncate-lines -1)))
  (add-hook 'grep-mode-hook (lambda () (toggle-truncate-lines 1)))

  (setq compilation-always-kill t)
  (setq compilation-ask-about-save nil)
  (setq compilation-auto-jump-to-first-error nil)
  (setq compilation-scroll-output t)
  (setq compilation-read-command nil))

(use-package make-mode
  :bind (:map makefile-mode-map
              ("C-c C-p" . makefile-toggle-phony))
  :hook (makefile-mode . whitespace-mode))

(use-package makefile-executor
  :straight (makefile-executor :type git
                               :host github
                               :repo "thiderman/makefile-executor.el"
                               :branch "magefile")
  :commands (makefile-executor-execute-target
             makefile-executor-execute-project-target
             magefile-executor-execute-target
             magefile-executor-execute-project-target)
  :hook
  (makefile-mode . makefile-executor-mode)
  :mode
  ("mage\\.go" . magefile-executor-mode))

(use-package firestarter
  :config
  (firestarter-mode 1)
  (add-hook 'go-mode-hook
            (lambda () (setq firestarter '(recompile)))))

(defhydra th/makefile-hydra (:exit t)
  "Makefile"
  ("c" makefile-executor-execute-last "last target")
  ("f" makefile-executor-goto-makefile "visit file")
  ("g" magefile-executor-execute-project-target "magefile execute")
  ("C-m" makefile-executor-execute-project-target "project execute")
  ("m" makefile-executor-execute-project-target "project execute"))

(global-set-key (kbd "C-x C-m") 'th/makefile-hydra/body)


(setq go-tc/kwds
      '(("RUN" . font-lock-function-name-face)
        ("FROM" . font-lock-function-name-face)
        ("ENV" . font-lock-function-name-face)
        ("WORKDIR" . font-lock-function-name-face)
        ("ADD" . font-lock-function-name-face)
        ("COPY" . font-lock-function-name-face)
        ("EXPOSE" . font-lock-function-name-face)
        ("ENTRYPOINT" . font-lock-function-name-face)
        ("CMD" . font-lock-function-name-face)
        ("PASS" . font-lock-type-face)
        ("FAIL" . font-lock-warning-face)
        ("===\\|---" . font-lock-comment-face)
        ("^WARN .*" . font-lock-warning-face)
        ("20..-..-..T..:..:..Z" . font-lock-comment-face)
        ("20..-..-..T..:..:......\\+...." . font-lock-comment-face)))

(define-minor-mode golang-test-compile-mode
  "Doc string."
  nil "☯" nil
  (font-lock-add-keywords nil go-tc/kwds)

  (if (fboundp 'font-lock-flush)
      (font-lock-flush)
    (when font-lock-mode
      (with-no-warnings (font-lock-fontify-buffer)))))

(add-hook 'compilation-mode-hook 'golang-test-compile-mode)

(defun th/compile-current-makefile ()
  (save-excursion
    (beginning-of-buffer)
    (forward-line 3)
    (search-forward "/")
    (thing-at-point 'filename)))

(defun th/compile-current-target ()
  (save-excursion
    (beginning-of-buffer)
    (forward-line 3)
    (end-of-line)
    (substring-no-properties (thing-at-point 'symbol))))

(defun th/compile-goto-makefile ()
  "Edit the Makefile related to the current compilation buffer"
  (interactive)
  (save-excursion
    (let* ((target (th/compile-current-target)))
      (find-file-other-window (th/compile-current-makefile))
      (search-forward-regexp (format "^%s" target) nil t))))

(define-key compilation-mode-map (kbd "e") 'th/compile-goto-makefile)

(defun th/compile-execute-target ()
  "Choose a new target in the current makefile"
  (interactive)
  (makefile-executor-execute-target
   (th/compile-current-makefile)))

(define-key compilation-mode-map (kbd "c") 'th/compile-execute-target)

(defun th/compile-execute-dedicated ()
  "Choose a new target in the current makefile and run it in a dedicated buffer."
  (interactive)
  (makefile-executor-execute-dedicated-buffer
   (th/compile-current-makefile)))

(define-key compilation-mode-map (kbd "d") 'th/compile-execute-dedicated)

;;;###autoload
(defun makefile-toggle-phony ()
  "Toggle .PHONY on the current rule"
  (interactive)
  (save-excursion
    (backward-sentence)
    (if (looking-at ".PHONY")
        (kill-line 1)
      (insert (format ".PHONY: %s\n" (symbol-at-point))))))

(provide 'th-compile)
