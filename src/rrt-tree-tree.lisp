(in-package :cl-rrt)
(use-syntax :annot)

@export
@export-accessors
@doc "an rrt-tree implementation which 
seaches from the root in nearest-search."
(defclass rrt-tree-tree (rrt-tree-mixin) ())

(defmethod print-object ((tree rrt-tree-tree) s)
  (print-unreadable-object (tree s :type t)
	(format s "NODES: ~a" (count-nodes tree))))

(defmethod reinitialize-instance :around ((tree rrt-tree-tree) &rest args)
  @ignore args
  (call-next-method)
  (with-slots (root finish) tree
	;; もし根に親がいればつながりを切る
	(awhen (parent root)
	  (disconnect it root)))
  tree)

(defmethod nearest-node (target-content (tree rrt-tree-tree))
  (let* ((best-node (root tree))
		 (best-content (content best-node))
		 (best-distance (configuration-space-distance
						 best-content target-content)))
	(mapc-rrt-tree-node-recursively
	 best-node
	 (lambda (node)
	   (let* ((content (content node))
			  (dist (configuration-space-distance
					 content target-content)))
		 (when (< dist best-distance)
		   (setf best-node node
				 best-content content
				 best-distance dist)))))
	(values best-node best-distance best-content)))

(defmethod nodes ((tree rrt-tree-tree))
  (let (leafs)
	(mapc-rrt-tree-node-recursively
	 (root tree)
	 (lambda (node)
	   (push node leafs)))
	leafs))

(defmethod leafs ((tree rrt-tree-tree))
  (let (leafs)
	(mapc-rrt-tree-node-recursively
	 (root tree)
	 (lambda (node)
	   (unless (children node)
		 (push node leafs))))
	leafs))

(defmethod count-nodes ((tree rrt-tree-tree))
  (let ((count 0))
	(mapc-rrt-tree-node-recursively
	 (root tree)
	 (lambda (node)
	   @ignore node
	   (incf count)))
	count))
