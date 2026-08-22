extends Node3D

@export var data: Dictionary[String, CometBinaryTree] = {}

func _ready() -> void:
	if true:
		var dataset: Array[int] = [50, 30, 70, 20, 40, 60, 80, 10, 25, 35, 45, 55, 65, 75, 85]
		var root: CometBinaryTree = CometBinaryTree.new(dataset[0])
		for value in dataset.slice(1):
			root.add_as_bst(value)
		print("In-order: ", root.get_inord().map(func(n): return n.v()))
		print("Pre-order: ", root.get_preord().map(func(n): return n.v()))
		print("Post-order: ", root.get_postord().map(func(n): return n.v()))
		print("Level-order: ", root.get_levelord().map(func(n): return n.v()))
		print("Balanceness: ", root.balanceness())
		print("Is BST?: ", str(root.is_bst()))
		var some_node: CometBinaryTree
		some_node = root.get_first_node_eq_to_as_bst(70).unwrap()
		some_node.remove(true, CometBinaryTree.AsBSTBalancingMode.USE_DEEPER)
		print("After remove 70 | In-order:", root.get_inord().map(func(n): return n.v()))
		print("Balanceness: ", root.balanceness())
		print("Is BST?: ", str(root.is_bst()))
		some_node = root.get_first_node_eq_to(25).unwrap()
		some_node.remove(true, CometBinaryTree.AsBSTBalancingMode.USE_DEEPER)
		print("After remove 25 | In-order:", root.get_inord().map(func(n): return n.v()))
		print("Balanceness: ", root.balanceness())
		print("Is BST?: ", str(root.is_bst()))
		some_node = root.get_inord_suc_as_bst()
		print("inord_suc: ", some_node.v())
		some_node.split(0.5)
		print("After split inord_suc | In-order:", root.get_inord().map(func(n): return n.v()))
		print("Balanceness: ", root.balanceness())
		print("Is BST?: ", str(root.is_bst()))
		root.l().unwrap().orphan_descendants()
		print("After orphan_descendants left of root node:", root.get_inord().map(func(n): return n.v()))
		root.r().unwrap().orphan_all()
		print("After orphan_all right of root node:", root.get_inord().map(func(n): return n.v()))
	print("Scope end")
	await CometSingleton.wait(1)
	print("Test end")
