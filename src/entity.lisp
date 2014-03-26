;;;; ***********************************************************************
;;;; FILE IDENTIFICATION
;;;;
;;;; Name:          entity.lisp
;;;; Project:       the Fabric
;;;; Purpose:       simple representation of game entities
;;;; Author:        mikel evins
;;;; Copyright:     2014 by mikel evins
;;;;
;;;; ***********************************************************************

(in-package :entity)

;;; ---------------------------------------------------------------------
;;; abstract entity class
;;; ---------------------------------------------------------------------

(defparameter *default-entity-class-name* 'alist-entity)

(defclass entity ()())

(defgeneric contains-key? (entity key &key key-test))
(defgeneric get-key (entity key &key default key-test))
(defgeneric set-key! (entity key val &key key-test))
(defgeneric add-key (entity key val &key key-test))
(defgeneric add-key! (entity key val &key key-test))
(defgeneric ensure-key (entity key val &key key-test))
(defgeneric ensure-key! (entity key val &key key-test))
(defgeneric remove-key (entity key &key key-test))
(defgeneric remove-key! (entity key &key key-test))
(defgeneric keys (entity))
(defgeneric vals (entity))
(defgeneric map-keys (procedure entity))
(defgeneric merge-keys (entity1 entity2 &key key-test resolve-collision))

(defun make-entity (&key (entity-class 'alist-entity)(slots nil) &allow-other-keys)
  (make-instance entity-class :slots slots))

(defun %parse-entity-args (args)
  (if (null args)
    (values *default-entity-class-name* nil)
    (if (symbolp (first args))
      (let ((found-class (find-class (first args) nil)))
        (if found-class
          (values (first args)(rest args))
          (values *default-entity-class-name* args)))
      (values *default-entity-class-name* args))))

(defun entity (&rest args)
  (multiple-value-bind (class-name initargs)(%parse-entity-args args)
    (make-entity :entity-class class-name :slots initargs)))

(defmacro do-keys ((var entity) &body body)
  `(loop for ,var in (keys ,entity)
     do (progn ,@body)))

(defmethod print-object ((e entity)(out stream))
  (print-unreadable-object (e out :type t :identity nil)
    (do-keys (k e)
             (princ "(" out)
             (print-object k out)
             (princ " " out)
             (print-object (get-key e k) out)
             (princ ")" out))))

;;; ---------------------------------------------------------------------
;;; entity conditions
;;; ---------------------------------------------------------------------

(define-condition no-such-key (error)
  ((error-entity :reader error-entity :initarg :entity)
   (error-key :reader error-key :initarg :key)))

(define-condition key-exists (error)
  ((error-entity :reader error-entity :initarg :entity)
   (error-key :reader error-key :initarg :key)))

;;; ---------------------------------------------------------------------
;;; alist-entity
;;; ---------------------------------------------------------------------
;;; a simple default entity class using alists for slots

(defclass alist-entity (entity)
  ((slots :accessor entity-slots :initform nil)))

(defmethod initialize-instance :after ((e alist-entity) &rest initargs &key (slots nil) &allow-other-keys)
  (let ((slots (loop for tail on slots by #'cddr collect (cons (car tail)(cadr tail)))))
    (setf (entity-slots e) slots)))

(defmethod contains-key? ((entity alist-entity) key &key  (key-test #'equal))
  (let ((entry (find key (entity-slots entity) :key #'car :test key-test)))
    (if entry
      (values (car entry)
              (cdr entry))
      (values nil nil))))

(defmethod get-key ((entity alist-entity) key &key (default nil) (key-test #'equal))
  (let ((entry (assoc key (entity-slots entity) :test key-test)))
    (if entry
      (cdr entry)
      default)))

;;; (setf $e (make-instance 'alist-entity))
;;; (describe $e)
;;; (get-key $e :name :default :nope!)


(defmethod set-key! ((entity alist-entity) key val &key  (key-test #'equal))
  (let ((entry (assoc key (entity-slots entity) :test key-test)))
    (if entry
      (setf (cdr entry) val)
      (error 'no-such-key :entity entity :key key))))

;;; (setf $e (make-instance 'alist-entity :slots '(:name "Barney")))
;;; (describe $e)
;;; (set-key! $e :name "Fred")
;;; (describe $e)
;;; (set-key! $e :foo "Bar")
;;; (describe $e)

(defmethod add-key ((entity alist-entity) key val &key (key-test #'equal))
  (let ((entry (assoc key (entity-slots entity) :test key-test)))
    (if entry
      (error 'key-exists :entity entity :key key)
      (let ((e (make-instance 'alist-entity)))
        (setf (entity-slots e)
              (cons (cons key val)
                    (entity-slots entity)))
        e))))

(defmethod add-key! ((entity alist-entity) key val &key (key-test #'equal))
  (let ((entry (assoc key (entity-slots entity) :test key-test)))
    (if entry
      (error 'key-exists :entity entity :key key)
      (setf (entity-slots entity)
            (cons (cons key val)
                  (entity-slots entity))))
    entity))

(defmethod ensure-key ((entity alist-entity) key val &key (key-test #'equal))
  (let ((entry (assoc key (entity-slots entity) :test key-test)))
    (if entry
      entity
      (add-key entity key val :key-test key-test))))

(defmethod ensure-key! ((entity alist-entity) key val &key (key-test #'equal))
  (let ((entry (assoc key (entity-slots entity) :test key-test)))
    (if entry
      entity
      (progn
        (setf (entity-slots entity)
            (cons (cons key val)
                  (entity-slots entity)))
        entity)))

;;; (setf $e1 (make-instance 'alist-entity :slots '(:name "Barney")))
;;; (contains-key? $e1 :name)
;;; (contains-key? $e1 :frob)
;;; (setf $e2 (add-key $e1 :shape :square))
;;; (contains-key? $e1 :shape)
;;; (contains-key? $e2 :shape)
;;; (describe $e1)
;;; (describe $e2)

(defmethod remove-key ((entity alist-entity) key &key  (key-test #'equal))
  (let ((e (make-instance 'alist-entity)))
    (setf (entity-slots e)
          (remove key (entity-slots entity) :key #'car :test key-test))
    e))


(defmethod remove-key! ((entity alist-entity) key &key  (key-test #'equal))
  (setf (entity-slots entity)
        (remove key (entity-slots entity) :key #'car :test key-test))
  entity)

;;; (setf $e1 (make-instance 'alist-entity :slots '(:name "Barney" :age 45)))
;;; (describe $e1)
;;; (setf $e2 (remove-key $e1 :name))
;;; (describe $e2)
;;; (remove-key! $e1 :age)
;;; (describe $e1)

(defmethod keys ((entity alist-entity))
  (mapcar #'car (entity-slots entity)))

(defmethod vals ((entity alist-entity))
  (mapcar #'cdr (entity-slots entity)))

;;; (setf $e1 (make-instance 'alist-entity :slots '(:name "Barney" :age 45)))
;;; (keys $e1)
;;; (vals $e1)

(defmethod map-keys (procedure (entity alist-entity))
  (loop for (k . v) in (entity-slots entity)
    collect (funcall procedure k v)))

;;; (setf $e1 (make-instance 'alist-entity :slots '(:name "Barney" :age 45 :shape :round :wife "Betty")))
;;; (map-keys (lambda (k v)(format t "~%~A: ~A" k v)(force-output)(cons k v)) $e1)

(defun %default-resolve-alist-entity-collision (e1 e2 k1 k2)
  (declare (ignore e1 k1))
  (let ((v2 (get-key e2 k2)))
    (values k2 v2)))

(defmethod merge-keys ((entity1 entity) (entity2 entity) &key 
                       (key-test #'equal)
                       (resolve-collision nil))
  (let* ((resolver (or resolve-collision #'%default-resolve-alist-entity-collision))
         (slots1 (entity-slots entity1))
         (slots2 (entity-slots entity2))
         (unique-slots1 (set-difference slots1 slots2 :key #'car :test key-test))
         (unique-slots2 (set-difference slots2 slots1 :key #'car :test key-test))
         (colliding-slots1 (set-difference slots1 unique-slots1 :key #'car :test key-test))
         (colliding-slots2 (set-difference slots2 unique-slots2 :key #'car :test key-test))
         (resolved-slots (mapcar #'(lambda (s1 s2)
                                     (multiple-value-bind (k v)(funcall resolver entity1 entity2 (car s1)(car s2))
                                       (cons k v)))
                                 colliding-slots1 colliding-slots2))
         (new-slots (append unique-slots2 resolved-slots unique-slots1)))
    (make-instance 'alist-entity :slots new-slots)))

;;; (setf $e1 (entity :a 1 :b 2 :c 3))
;;; (setf $e2 (entity :b 22 :d 44))
;;; (setf $e3 (merge-keys $e1 $e2))


