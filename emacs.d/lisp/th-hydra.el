(defhydra th/util-hydra (:foreign-keys warn)
  "Util"
  ("e" th/load-env "Load 12FA env" :color blue)
  ("s" th/yas-hydra/body "yas" :color blue)
  ("a" auto-fill-mode "Auto fill")
  ("f" th/font-hydra/body "font-hydra" :color blue)
  ("M-f" fci-mode "Fill column")
  ("h" highlight-symbol-mode "Highlight symbol")
  ("j" text-scale-decrease "Font -")
  ("k" text-scale-increase "Font +")
  ("l" linum-mode "Line numbers")
  ("r" rainbow-identifiers-mode "Rainbow identifiers")
  ("t" toggle-truncate-lines "Truncate lines"))

(global-set-key (kbd "C-x c") 'th/util-hydra/body)

(defun th/iosevka (size)
  (set-frame-font (format "Iosevka-%s" size)))

(defhydra th/font-hydra ()
  "Font size"
  ("d" (th/iosevka 10))
  ("f" (th/iosevka 13))
  ("h" (th/iosevka 17))
  ("j" (th/iosevka 20))
  ("k" (th/iosevka 22))
  ("l" (th/iosevka 24))
  ("i" (describe-char (point)) "font information" :color blue))


(defhydra th/exec-hydra (:foreign-keys warn :exit t)
  "Execution"
  ("e" elfeed "elfeed")
  ("h" (counsel-find-file "/") "hosts")
  ("p" payments/actions/body "payments")
  ("M-p" proced "proced")
  ("q" nil))

(global-set-key (kbd "C-x C-c") 'th/exec-hydra/body)


(provide 'th-hydra)