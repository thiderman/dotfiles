(use-package docker
  :bind (("C-x C-d" . docker-containers)
         (:map docker-containers-command-map
               ("i" . docker-images))))
(use-package dockerfile-mode
  :bind (:map dockerfile-mode-map
              ("C-c C-c" . th/docker-compose)))
(use-package docker-tramp)

(use-package docker-compose-mode
  :ensure t
  :bind (:map docker-compose-mode-map
              ("C-c C-c" . docker-compose-execute-command)
              ("C-c C-b" . docker-compose-build-buffer)
              ("C-c C-s" . docker-compose-start-buffer))
  :load-path "/home/thiderman/src/github.com/meqif/docker-compose-mode")

(defun th/docker-compose ()
  "Run docker compose on the current file"
  (interactive)
  (compile "make docker"))

(provide 'th-docker)
