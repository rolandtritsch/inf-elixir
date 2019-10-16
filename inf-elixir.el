;;; inf-elixir.el --- Run an Elixir shell in a buffer

;; Copyright 2019 Jonathan Arnett

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;;; Commentary:

;; Provides access to an IEx shell in a buffer, optionally running a
;; specific command (e.g. iex -S mix, iex -S mix phx.server, etc)

;;; Code:
(defvar inf-elixir-buffer nil
  "The buffer of the currently-running Elixir REPL subprocess.")

(define-minor-mode inf-elixir-minor-mode
  "Minor mode for interacting with the REPL.")

(define-derived-mode inf-elixir-mode comint-mode "Inf-Elixir"
  "Major mode for interacting with the REPL.")

(defun inf-elixir (&optional cmd)
  "Run Elixir shell, using CMD if given."
  (interactive)
  (run-elixir cmd))

(defun run-elixir (&optional cmd)
  "Run Elixir shell, using CMD if given."
  (interactive)
  (unless (buffer-live-p inf-elixir-buffer)
    (setq inf-elixir-buffer nil))
  (if inf-elixir-buffer
      (pop-to-buffer inf-elixir-buffer)
    (let* ((name "Elixir")
	   (cmd (or cmd "iex"))
	   (cmd (if current-prefix-arg
		    (read-from-minibuffer "Command: " cmd nil nil 'inf-elixir)
		  cmd))
	   (cmdlist (split-string cmd)))
      (set-buffer (apply 'make-comint-in-buffer
			 name
			 (generate-new-buffer-name (format "*%s*" name))
			 (car cmdlist)
			 nil
			 (cdr cmdlist)))
      (inf-elixir-mode)
      (setq inf-elixir-buffer (current-buffer))
      (pop-to-buffer (current-buffer)))))

(defun inf-elixir-project ()
  "Run iex -S mix."
  (interactive)
  (let ((default-directory (locate-dominating-file default-directory "mix.exs")))
    (run-elixir "iex -S mix")))

;;; inf-elixir.el ends here