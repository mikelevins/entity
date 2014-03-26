;;;; ***********************************************************************
;;;; FILE IDENTIFICATION
;;;;
;;;; Name:          entity.asd
;;;; Project:       representation of simple entities
;;;; Purpose:       system definition
;;;; Author:        mikel evins
;;;; Copyright:     2014 by mikel evins
;;;;
;;;; ***********************************************************************

(in-package :cl-user)

(require :asdf)

;;; ---------------------------------------------------------------------
;;; entity system
;;; ---------------------------------------------------------------------

(asdf:defsystem #:entity
  :serial t
  :description "entity: simple sets of key/value pairs"
  :author "mikel evins <mevins@me.com>"
  :license "Apache 2.0"
  :depends-on ()
  :components ((:module "src"
                        :serial t
                        :components
                        ((:file "package")
                         (:file "entity")))))

;;; (asdf:load-system :entity)
