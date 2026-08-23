extends Node3D

@export var data: Dictionary[String, CometBinaryTree] = {}

func _ready() -> void:
	test_c()

func test_c() -> void:
	print("Scope start")
	if true:
		var rand := RandomNumberGenerator.new()
		var root := CometBinaryTree.new(Vector2i(256, 256))
		root.mut_split_fn(func(input: Vector2i, split_ratio: float) -> ABCTriplet:
			print("Did a split here")
			if input.x > input.y:
				var split_pos: int = roundi(input.x * (1.0 - split_ratio))
				return ABCTriplet.new(Vector2i(split_pos, input.y), Vector2i(input.x - split_pos, input.y), input)
			else:
				var split_pos: int = roundi(input.y * (1.0 - split_ratio))
				return ABCTriplet.new(Vector2i(input.x, split_pos), Vector2i(input.x, input.y - split_pos), input)
		)
		var do_recursive_split: Callable
		do_recursive_split = func(as_closure: Callable, on_behalf_of: CometBinaryTree, recursions_left: int) -> void:
			if recursions_left <= 0: return
			on_behalf_of.split(rand.randf_range(0.2, 0.8))
			as_closure.call(as_closure, on_behalf_of.l().unwrap(), recursions_left - 1)
			as_closure.call(as_closure, on_behalf_of.r().unwrap(), recursions_left - 1)
		do_recursive_split.call(do_recursive_split, root, 4)
		print("Trying visualization in inner scope...")
		if true:
			var preord := root.get_preord()
			for entry in preord:
				var depth_base_zero := entry.depth() - 1
				print("-".repeat(depth_base_zero) + ": " + str(entry.v()))
		print("Inner scope end")
	print("Scope end")
	await CometSingleton.wait(1)
	print("Test end")

func test_b() -> void:
	print("Scope start")
	if true:
		const DATA_SIZE: int = 127
		const DATA_MIN: int = INT8_MIN
		const DATA_MAX: int = INT8_MAX
		var rand := RandomNumberGenerator.new()
		var dataset: Array[int] = []
		dataset.resize(DATA_SIZE)
		for i in range(DATA_SIZE):
			dataset[i] = rand.randi_range(DATA_MIN, DATA_MAX)
		print("Dataset: ", dataset)
		var root: CometBinaryTree = CometBinaryTree.new(dataset[0])
		for value in dataset.slice(1):
			var result: ResultType = root.add_as_bst(value)
			if result.is_err():
				print(value, " was skipped as it is a duplicate!")
		print("Converted to BST")
		print("In-order: ", root.get_inord().map(func(n): return n.v()))
		print("Pre-order: ", root.get_preord().map(func(n): return n.v()))
		print("Post-order: ", root.get_postord().map(func(n): return n.v()))
		print("Level-order: ", root.get_levelord().map(func(n): return n.v()))
		print("Balanceness: ", root.balanceness())
		print("Is BST?: ", str(root.is_bst()))
		root = root.reorder_as_bst()
		print("Reordered!")
		print("In-order: ", root.get_inord().map(func(n): return n.v()))
		print("Pre-order: ", root.get_preord().map(func(n): return n.v()))
		print("Post-order: ", root.get_postord().map(func(n): return n.v()))
		print("Level-order: ", root.get_levelord().map(func(n): return n.v()))
		print("Balanceness: ", root.balanceness())
		print("Is BST?: ", str(root.is_bst()))
		
		print("Begin random removal tests")
		for i in range(16):
			var cur_inord: Array[CometBinaryTree] = root.get_inord()
			var random_node: CometBinaryTree = cur_inord[rand.randi_range(0, cur_inord.size() - 1)]
			var result: KVPair = random_node.remove(true, CometBinaryTree.AsBSTBalancingMode.USE_DEEPER)
			if result.v() == root:
				root = result.v()
			assert(root.is_bst())
			print("Balanceness: ", root.balanceness())
		print("End random removal tests")
		print("In-order: ", root.get_inord().map(func(n): return n.v()))
		print("Pre-order: ", root.get_preord().map(func(n): return n.v()))
		print("Post-order: ", root.get_postord().map(func(n): return n.v()))
		print("Level-order: ", root.get_levelord().map(func(n): return n.v()))
		
		print("Trying visualization in inner scope...")
		if true:
			var preord := root.get_preord()
			for entry in preord:
				var depth_base_zero := entry.depth() - 1
				print("-".repeat(depth_base_zero) + ": " + str(entry.v()))
		print("Inner scope end")
	print("Scope end")
	await CometSingleton.wait(1)
	print("Test end")

func test_a() -> void:
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
		some_node = root.get_first_node_eq_to_as_bst(50).unwrap()
		assert(some_node == root, "Selected node should be root node!")
		var result: KVPair = some_node.remove(true, CometBinaryTree.AsBSTBalancingMode.ALWAYS_PRE)
		root = result.v().unwrap()
		print("After remove 50 | Pre-order: ", root.get_preord().map(func(n): return n.v()))
		print("After remove 50 | In-order:", root.get_inord().map(func(n): return n.v()))
		assert(root.is_bst(), "Should still qualify as a BST!")
		
		#some_node = root.get_first_node_eq_to_as_bst(70).unwrap()
		#some_node.remove(true, CometBinaryTree.AsBSTBalancingMode.USE_DEEPER)
		#print("After remove 70 | In-order:", root.get_inord().map(func(n): return n.v()))
		#print("Balanceness: ", root.balanceness())
		#print("Is BST?: ", str(root.is_bst()))
		#some_node = root.get_first_node_eq_to(25).unwrap()
		#some_node.remove(true, CometBinaryTree.AsBSTBalancingMode.USE_DEEPER)
		#print("After remove 25 | In-order:", root.get_inord().map(func(n): return n.v()))
		#print("Balanceness: ", root.balanceness())
		#print("Is BST?: ", str(root.is_bst()))
		#some_node = root.get_inord_suc_as_bst()
		#print("inord_suc: ", some_node.v())
		#some_node.split(0.5)
		#print("After split inord_suc | In-order:", root.get_inord().map(func(n): return n.v()))
		#print("Balanceness: ", root.balanceness())
		#print("Is BST?: ", str(root.is_bst()))
		#root.l().unwrap().orphan_descendants()
		#print("After orphan_descendants left of root node:", root.get_inord().map(func(n): return n.v()))
		#root.r().unwrap().orphan_all()
		#print("After orphan_all right of root node:", root.get_inord().map(func(n): return n.v()))
	print("Scope end")
	await CometSingleton.wait(1)
	print("Test end")
