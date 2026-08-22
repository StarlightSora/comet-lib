## The CometBinaryTree type is in essence, a doubly linked binary tree,
## with helper functions that lets it mimic other binary tree types.
class_name CometBinaryTree
extends Resource

enum ChildSide {
    NONE,
    LEFT,
    RIGHT,
    UNKNOWN,
}

enum TraversalMode {
    INORD,
    PREORD,
    POSTORD,
    LEVELORD,
    SURFACE,
}

enum AsBSTBalancingMode {
    NOT_BST_LEFT,
    NOT_BST_RIGHT,
    USE_DEEPER,
    ALWAYS_PRE,
    ALWAYS_SUC,
}

enum LinkAndOrphanMode {
    RELINK_THEN_NONE,
    RELINK_THEN_SHALLOW,
    DIRECT_THEN_NONE,
    DIRECT_THEN_SHALLOW,
    DIRECT_THEN_DEEP,
}

enum LinkMode {
    DIRECT,
    RELINK,
}

enum SplitResult {
    SPLIT_TO_BOTH,
    SPLIT_TO_LEFT,
    SPLIT_TO_RIGHT,
    NO_OP,
}

static func _default_comp_fn(lhs: Variant, rhs: Variant) -> bool: return lhs < rhs
static func _default_eq_fn(lhs: Variant, rhs: Variant) -> bool: return lhs == rhs
static func _default_split_fn(from: Variant, ratio: float) -> ABCTriplet: return ABCTriplet.new(from * (1.0 - ratio), from * ratio, from)

static var debug_mode: bool = true 

@export var _comp_fn: Callable = _default_comp_fn ## Func(T, T) -> bool
@export var _eq_fn: Callable = _default_eq_fn ## Func(T, T) -> bool
@export var _split_fn: Callable = _default_split_fn ## Func(T, R) -> ABCTriplet<T, T, T>

@export var left__: CometBinaryTree: ## CometBinaryTree<T>?
    set(new_l):
        if _l:
            _l._p = weakref(null)
        if new_l:
            new_l._p = weakref(self)
        _l = new_l
@export var right__: CometBinaryTree: ## CometBinaryTree<T>?
    set(new_r):
        if _r:
            _r._p = weakref(null)
        if new_r:
            new_r._p = weakref(self)
        _r = new_r
@export var value__: Variant: ## T
    set(new_v):
        _v = new_v

var _p: WeakRef = weakref(null) ## WeakRef<CometBinaryTree<T>?>
var _l: CometBinaryTree ## CometBinaryTree<T>?
var _r: CometBinaryTree ## CometBinaryTree<T>?
var _v: Variant ## T

func _notification(what: int) -> void:
    if not debug_mode: return
    match what:
        NOTIFICATION_PREDELETE:
            print("Freeing a CometBinaryTree node!")

# Constructors #

## (T) -> CometBinaryTree<T>
##
## Creates a new `CometBinaryTree` node.
## (not to be confused with Godot's `Node` type)
func _init(has: Variant = null) -> void:
    _v = has

# Naive Getters / Setters #

## () -> (Func(T, T) -> bool)
##
## Gets the callable used when doing comparisons.
func comp_fn() -> Callable:
    return _comp_fn

## mut (Func(T, T) -> bool) -> void
##
## Sets the callable to use when doing comparisons.
func mut_comp_fn(fn: Callable) -> void:
    _comp_fn = fn

## () -> (Func(T, T) -> bool)
##
## Gets the callable used when doing equality checks.
func eq_fn() -> Callable:
    return _eq_fn

## mut (Func(T, T) -> bool) -> void
##
## Sets the callable to use when doing equality checks.
func mut_eq_fn(fn: Callable) -> void:
    _eq_fn = fn

## () -> (Func(T, R) -> ABCTriplet<T, T, T>)
##
## Gets the callable used when splitting.
## 
## If this is a leaf node, the first return value will be assigned to the left side, the second to the right, the third to the current node.
## If one side of the node is occupied, then the vacant side will get the current node's value assigned, then the current node gets the third return value.
## No-op if both sides are occupied.
func split_fn() -> Callable:
    return _split_fn

## (Func(T, R) -> ABCTriplet<T, T, T>) -> void
##
## Sets the callable used when splitting.
##
## If this is a leaf node, the first return value will be assigned to the left side, the second to the right, the third to the current node.
## If one side of the node is occupied, then the vacant side will get the current node's value assigned, then the current node gets the third return value.
## No-op if both sides are occupied.
func mut_split_fn(fn: Callable) -> void:
    _split_fn = fn


## () -> T
##
## Gets the value of this node.
func v() -> Variant:
    return _v

## mut (T) -> void
##
## Sets the value of this node.
func mut_v(new_v) -> void:
    _v = new_v

## mut (T) -> T
##
## Sets the value of this node, and returns the old value.
func mut_v_returning(new_v) -> Variant:
    var temp: Variant = _v
    _v = new_v
    return temp


## () -> bool
func has_p() -> bool:
    return true if _p.get_ref() else false

## () -> OptionalType<CometBinaryTree<T>>
##
## Gets the parent of this node.
func p() -> OptionalType:
    return OptionalType.new(_p.get_ref())


## () -> bool
func has_l() -> bool:
    return true if _l else false

## () -> OptionalType<CometBinaryTree<T>>
##
## Gets the left child of this node.
func l() -> OptionalType:
    return OptionalType.new(_l)

## mut (CometBinaryTree<T>?, LinkAndOrphanMode?) -> void
##
## Sets the left child of this node.
## By default, the children of the old left child will relinked to the new left child then be shallow-orphaned.
func mut_l(new_l: CometBinaryTree, then_orphan_old: LinkAndOrphanMode = LinkAndOrphanMode.RELINK_THEN_SHALLOW) -> void:
    if _l:
        if new_l and (then_orphan_old == LinkAndOrphanMode.RELINK_THEN_SHALLOW or then_orphan_old == LinkAndOrphanMode.RELINK_THEN_NONE):
            new_l._l = _l._l
            new_l._r = _l._r
            if _l._l: _l._l._p = weakref(new_l)
            if _l._r: _l._r._p = weakref(new_l)
        _l.detatch_parent()
        if new_l and then_orphan_old == LinkAndOrphanMode.RELINK_THEN_NONE:
            _l._l = null
            _l._r = null
        if then_orphan_old == LinkAndOrphanMode.DIRECT_THEN_DEEP:
            _l.orphan_all()
        elif then_orphan_old == LinkAndOrphanMode.DIRECT_THEN_SHALLOW or then_orphan_old == LinkAndOrphanMode.RELINK_THEN_SHALLOW:
            _l.detatch_all()
    _l = new_l
    if _l:
        _l._p = weakref(self)

## mut (CometBinaryTree<T>?, LinkMode?) -> OptionalType<CometBinaryTree<T>>
##
## Sets the left child of this node. Returns the old left child.
## By default, the children of the old left child will be relinked to the new left child.
func mut_l_returning(new_l: CometBinaryTree, then_: LinkMode = LinkMode.RELINK) -> OptionalType:
    var temp: CometBinaryTree = null
    if _l:
        temp = _l
        if new_l and then_ == LinkMode.RELINK:
            new_l._l = _l._l
            new_l._r = _l._r
            if _l._l: _l._l._p = weakref(new_l)
            if _l._r: _l._r._p = weakref(new_l)
        _l.detatch_parent()
        if new_l and then_ == LinkMode.RELINK:
            _l._l = null
            _l._r = null
    _l = new_l
    if _l:
        _l._p = weakref(self)
    return OptionalType.new(temp)


## () -> bool
func has_r() -> bool:
    return true if _r else false

## () -> OptionalType<CometBinaryTree<T>>
##
## Gets the right child of this node.
func r() -> OptionalType:
    return OptionalType.new(_r)

## mut (CometBinaryTree<T>?, LinkAndOrphanMode?) -> void
##
## Sets the right child of this node.
## By default, the children of the old right child will relinked to the new right child then be shallow-orphaned.
func mut_r(new_r: CometBinaryTree, then_orphan_old: LinkAndOrphanMode = LinkAndOrphanMode.RELINK_THEN_SHALLOW) -> void:
    if _r:
        if new_r and (then_orphan_old == LinkAndOrphanMode.RELINK_THEN_SHALLOW or then_orphan_old == LinkAndOrphanMode.RELINK_THEN_NONE):
            new_r._l = _r._l
            new_r._r = _r._r
            if _r._l: _r._l._p = weakref(new_r)
            if _r._r: _r._r._p = weakref(new_r)
        _r.detatch_parent()
        if new_r and then_orphan_old == LinkAndOrphanMode.RELINK_THEN_NONE:
            _r._l = null
            _r._r = null
        if then_orphan_old == LinkAndOrphanMode.DIRECT_THEN_DEEP:
            _r.orphan_all()
        elif then_orphan_old == LinkAndOrphanMode.DIRECT_THEN_SHALLOW or then_orphan_old == LinkAndOrphanMode.RELINK_THEN_SHALLOW:
            _r.detatch_all()
    _r = new_r
    if _r:
        _r._p = weakref(self)

## mut (CometBinaryTree<T>?, LinkMode?) -> OptionalType<CometBinaryTree<T>>
##
## Sets the right child of this node. Returns the old right child.
## By default, the children of the old right child will be relinked to the new right child.
func mut_r_returning(new_r: CometBinaryTree, then_: LinkMode = LinkMode.RELINK) -> OptionalType:
    var temp: CometBinaryTree = null
    if _r:
        temp = _r
        if new_r and then_ == LinkMode.RELINK:
            new_r._l = _r._l
            new_r._r = _r._r
            if _r._l: _r._l._p = weakref(new_r)
            if _r._r: _r._r._p = weakref(new_r)
        if new_r and then_ == LinkMode.RELINK:
            _r._l = null
            _r._r = null
        _r.detatch_parent()
    _r = new_r
    if _r:
        _r._p = weakref(self)
    return OptionalType.new(temp)

# Relation Checkers #

## () -> ChildSide
func child_side() -> ChildSide:
    var parent: CometBinaryTree = _p.get_ref()
    if parent:
        if parent._l == self: return ChildSide.LEFT
        elif parent._r == self: return ChildSide.RIGHT
        else: return ChildSide.UNKNOWN
    else: return ChildSide.NONE

## () -> bool
func is_leaf() -> bool:
    if not _l and not _r: return true
    else: return false

# Algorithmic Getters / Setters / Checkers #

## () -> int
##
## Starts from 1, where a value of 1 indicates that this is the root node.
func depth() -> int:
    return get_surface().size()

## () -> int
##
## Starts from 1, where a value of 1 indicates that the deepest node is the root node.
func max_depth() -> int:
    var arr := get_levelord()
    return arr[arr.size() - 1].depth()

## () -> int
##
## Starts from 1, where a value of 1 indicates that this node has no children.
func size() -> int:
    return get_traverse().size()

## () -> int
##
## How balanced the binary tree is, in the range of (0, 1].
## To be precise, this is measured as sqrt(size() / (2^max_depth() - 1)).
func balanceness() -> float:
    return sqrt(size() as float / (pow(2, max_depth()) - 1.0))


## (T) -> CometBinaryTree<T>
##
## Add a node with the given value, treating the binary tree as a binary search tree.
##
## Uses `comp_fn`.
func add_as_bst(value: Variant, from: CometBinaryTree = self) -> CometBinaryTree:
    if _comp_fn.call(value, from._v):
        if from._l:
            return add_as_bst(value, from._l)
        else:
            var new_node: CometBinaryTree = CometBinaryTree.new(value)
            from.mut_l(new_node)
            return new_node
    else:
        if from._r:
            return add_as_bst(value, from._r)
        else:
            var new_node: CometBinaryTree = CometBinaryTree.new(value)
            from.mut_r(new_node)
            return new_node

## () -> bool
##
## Check if the binary tree is a binary search tree.
##
## Uses `comp_fn`.
func is_bst(from: CometBinaryTree = self) -> bool:
    var b: bool = true
    if from._l:
        if _comp_fn.call(from._l._v, from._v):
            b = is_bst(from._l)
            if not b: return false
        else: return false
    if from._r:
        if not _comp_fn.call(from._r._v, from._v):
            b = is_bst(from._r)
            if not b: return false
        else: return false
    return true

## () -> CometBinaryTree<T>
##
## Create a reordered CometBinaryTree, treating the binary tree as a binary search tree.
func reorder_as_bst(from: CometBinaryTree = self, start: int = 0, end: int = INT64_MIN, nodes: Array[CometBinaryTree] = []) -> CometBinaryTree:
    if nodes.size() <= 0:
        nodes = get_inord(from)
    if end == INT64_MIN:
        end = nodes.size() - 1
    if start > end: return null
    var mid: int = floori((start + end) as float / 2.0)
    var root: CometBinaryTree = CometBinaryTree.new(nodes[mid]._v)
    root._l = reorder_as_bst(from, start, mid - 1, nodes)
    root._r = reorder_as_bst(from, mid + 1, end, nodes)
    return root


## (T, TraversalMode?) -> Array<CometBinaryTree<T>>
##
## Get an array of nodes that has the same value as the given value.
##
## Uses `eq_fn`.
func get_nodes_eq_to(equals_to: Variant, traversal_mode: TraversalMode = TraversalMode.INORD) -> Array[CometBinaryTree]:
    var list: Array[CometBinaryTree] = get_traverse(traversal_mode)
    list.filter(func(lhs: Variant) -> bool: return _eq_fn.call(lhs, equals_to))
    return list

## (T, TraversalMode?) -> OptionalType<CometBinaryTree<T>>
##
## Get the first node that has the same value as the given value. Equivalent to calling `first_traverse`.
##
## Uses `eq_fn`.
func get_first_node_eq_to(equals_to: Variant, traversal_mode: TraversalMode = TraversalMode.INORD) -> OptionalType:
    return first_traverse(equals_to, traversal_mode)

## (T) -> OptionalType<CometBinaryTree<T>>
##
## Get the first node that has the same value as the given value, treating the binary tree as a binary search tree.
## This is faster than using `get_first_node_eq_to` if you know that this is a binary search tree.
##
## Uses `comp_fn` and `eq_fn`.
func get_first_node_eq_to_as_bst(equals_to: Variant) -> OptionalType:
    var current: CometBinaryTree = self
    while current:
        if _eq_fn.call(current._v, equals_to):
            return OptionalType.new(current)
        else:
            if _comp_fn.call(equals_to, current._v):
                current = current._l
            else:
                current = current._r
    return OptionalType.new(null)

## mut (R?, DeepDuplicateMode?) -> SplitResult:
##
## Split the node into one or two children nodes. This is useful for binary space partitioning (BSP), commonly used for procedural generation.
## 
## `R` defaults to `float`.
##
## If this is a leaf node, both the left and right sides will have new nodes assigned with the values split accordingly.
## If one side of the node is occupied, then the vacant side will get a new node assigned, with the same value as the current node.
## No-op if both sides are occupied.
func split(split_ratio: Variant = 0.5, deep_subresources_mode = DeepDuplicateMode.DEEP_DUPLICATE_INTERNAL) -> SplitResult:
    if is_leaf():
        var result: ABCTriplet = _split_fn.call(self._v, split_ratio)
        var new_l = CometBinaryTree.new(result.a())
        var new_r = CometBinaryTree.new(result.b())
        mut_l(new_l, CometBinaryTree.LinkAndOrphanMode.DIRECT_THEN_DEEP)
        mut_r(new_r, CometBinaryTree.LinkAndOrphanMode.DIRECT_THEN_DEEP)
        _v = result.c()
        return SplitResult.SPLIT_TO_BOTH
    elif _l and _r:
        return SplitResult.NO_OP
    else:
        var result: ABCTriplet = _split_fn.call(self._v, split_ratio)
        var clo: Variant = _v
        if _v is Object and _v.has_method("duplicate_deep"):
            clo = _v.duplicate_deep(deep_subresources_mode)
        if _l:
            var new_r = CometBinaryTree.new(clo)
            mut_r(new_r, CometBinaryTree.LinkAndOrphanMode.DIRECT_THEN_DEEP)
            _v = result.c()
            return SplitResult.SPLIT_TO_RIGHT
        elif _r:
            var new_l = CometBinaryTree.new(clo)
            mut_l(new_l, CometBinaryTree.LinkAndOrphanMode.DIRECT_THEN_DEEP)
            _v = result.c()
            return SplitResult.SPLIT_TO_LEFT
        else:
            push_error("Unreachable code!")
            assert(false, "Unreachable code!")
            return SplitResult.NO_OP

# Traversal Algorithms #

## (T, TraversalMode?) -> OptionalType<CometBinaryTree<T>>
##
## Uses `eq_fn`.
func first_traverse(to_find: Variant, traversal_mode = TraversalMode.INORD, from: CometBinaryTree = self) -> OptionalType:
    match traversal_mode:
        TraversalMode.INORD:
            return first_inord(to_find, from)
        TraversalMode.PREORD:
            return first_preord(to_find, from)
        TraversalMode.POSTORD:
            return first_postord(to_find, from)
        TraversalMode.LEVELORD:
            return first_levelord(to_find, from)
        TraversalMode.SURFACE:
            return first_surface(to_find, from)
        _:
            push_error("Unreachable code!")
            assert(false, "Unreachable code!")
            return OptionalType.new(null)

## (T) -> OptionalType<CometBinaryTree<T>>
##
## Uses `eq_fn`.
func first_inord(to_find: Variant, from: CometBinaryTree = self) -> OptionalType:
    var found := OptionalType.new(null)
    var stack: Array[CometBinaryTree] = []
    var current: CometBinaryTree = from
    while current or stack.size() > 0:
        while current:
            stack.push_back(current)
            current = current._l
        current = stack.pop_back()
        if _eq_fn.call(current._v, to_find):
            found.insert(current)
            break
        current = current._r
    return found

## (T) -> OptionalType<CometBinaryTree<T>>
##
## Uses `eq_fn`.
func first_preord(to_find: Variant, from: CometBinaryTree = self) -> OptionalType:
    var found := OptionalType.new(null)
    var stack: Array[CometBinaryTree] = [from]
    while stack.size() > 0:
        var current: CometBinaryTree = stack.pop_back()
        if _eq_fn.call(current._v, to_find):
            found.insert(current)
            break
        if current._r:
            stack.push_back(current._r)
        if current._l:
            stack.push_back(current._l)
    return found

## (T) -> OptionalType<CometBinaryTree<T>>
##
## Uses `eq_fn`.
func first_postord(to_find: Variant, from: CometBinaryTree = self) -> OptionalType:
    var found := OptionalType.new(null)
    var stack: Array[CometBinaryTree] = [from]
    var current: CometBinaryTree = from
    while true:
        while current:
            stack.push_back(current)
            stack.push_back(current)
            current = current._l
        if stack.size() <= 0:
            return found
        current = stack.pop_back()
        if stack.size() > 0 and stack.back() == current:
            current = current._r
        else:
            if _eq_fn.call(current._v, to_find):
                found.insert(current)
                break
            current = null
    return found

## (T) -> OptionalType<CometBinaryTree<T>>
##
## Uses `eq_fn`.
func first_levelord(to_find: Variant, from: CometBinaryTree = self) -> OptionalType:
    var found := OptionalType.new(null)
    var queue: Array[CometBinaryTree] = [from]
    while queue.size() > 0:
        var popped: CometBinaryTree = queue.pop_front()
        if _eq_fn.call(popped._v, to_find):
            found.insert(popped)
            break
        if popped._l:
            queue.push_back(popped._l)
        if popped._r:
            queue.push_back(popped._r)
    return found

## (T) -> OptionalType<CometBinaryTree<T>>
##
## Traverse upwards until the first node that has the same value as to_find is found.
##
## Uses `eq_fn`.
func first_surface(to_find: Variant, from: CometBinaryTree = self) -> OptionalType:
    var found := OptionalType.new(null)
    var current: CometBinaryTree = from
    while current._p.get_ref():
        var parent: CometBinaryTree = current._p.get_ref()
        if _eq_fn.call(parent._v, to_find):
            found.insert(parent)
            break
        current = parent
    return found


## (TraversalMode?) -> Array<CometBinaryTree<T>>
func get_traverse(traversal_mode = TraversalMode.INORD, from: CometBinaryTree = self) -> Array[CometBinaryTree]:
    match traversal_mode:
        TraversalMode.INORD:
            return get_inord(from)
        TraversalMode.PREORD:
            return get_preord(from)
        TraversalMode.POSTORD:
            return get_postord(from)
        TraversalMode.LEVELORD:
            return get_levelord(from)
        TraversalMode.SURFACE:
            return get_surface(from)
        _:
            push_error("Unreachable code!")
            assert(false, "Unreachable code!")
            return []

## () -> Array<CometBinaryTree<T>>
func get_inord(from: CometBinaryTree = self, stack: Array[CometBinaryTree] = []) -> Array[CometBinaryTree]:
    if from._l:
        get_inord(from._l, stack)
    stack.push_back(from)
    if from._r:
        get_inord(from._r, stack)
    return stack

## () -> Array<CometBinaryTree<T>>
func get_preord(from: CometBinaryTree = self, stack: Array[CometBinaryTree] = []) -> Array[CometBinaryTree]:
    stack.push_back(from)
    if from._l:
        get_preord(from._l, stack)
    if from._r:
        get_preord(from._r, stack)
    return stack

## () -> Array<CometBinaryTree<T>>
func get_postord(from: CometBinaryTree = self, stack: Array[CometBinaryTree] = []) -> Array[CometBinaryTree]:
    if from._l:
        get_postord(from._l, stack)
    if from._r:
        get_postord(from._r, stack)
    stack.push_back(from)
    return stack

## () -> Array<CometBinaryTree<T>>
func get_levelord(from: CometBinaryTree = self) -> Array[CometBinaryTree]:
    var stack: Array[CometBinaryTree] = [from]
    var queue: Array[CometBinaryTree] = [from]
    while queue.size() > 0:
        var popped: CometBinaryTree = queue.pop_front()
        if popped._l:
            stack.push_back(popped._l)
            queue.push_back(popped._l)
        if popped._r:
            stack.push_back(popped._r)
            queue.push_back(popped._r)
    return stack

## () -> Array<CometBinaryTree<T>>
##
## Traverse upwards until the root node is reached.
func get_surface(from: CometBinaryTree = self, stack: Array[CometBinaryTree] = []) -> Array[CometBinaryTree]:
    stack.push_back(from)
    var parent: CometBinaryTree = from._p.get_ref() ## CometBinaryTree<T>?
    if parent:
        get_surface(parent, stack)
    return stack

## () -> CometBinaryTree<T>
func get_inord_suc_as_bst() -> CometBinaryTree:
    var cur: CometBinaryTree = self
    if cur._r:
        cur = cur._r
    else:
        return self
    while cur._l:
        cur = cur._l
    return cur

## () -> CometBinaryTree<T>
func get_inord_pre_as_bst() -> CometBinaryTree:
    var cur: CometBinaryTree = self
    if cur._l:
        cur = cur._l
    else:
        return self
    while cur._r:
        cur = cur._r
    return cur

# Debug Helpers #

## () -> String
##
## Returns the relevant data of this node for debugging, in compact form.
func dbg() -> String:
    return str(self) + "={ value: " + str(_v) + ", left: " + str(_l) + ", right: " + str(_r) + ", up: " + str(_p.get_ref()) + ", depth: " + str(depth()) + " };"

## () -> String
##
## Returns the relevant data of this node for debugging, in beautified form.
func fdbg() -> String:
    return str(self) + " = {\n  value: " + str(_v) + ",\n  left: " + str(_l) + ",\n  right: " + str(_r) + ",\n  up: " + str(_p.get_ref()) + ",\n  depth: " + str(depth()) + "\n};"

# Cleanup Helpers #

## mut (bool?, AsBSTBalancingMode?) -> KVPair<CometBinaryTree?, OptionalType<CometBinaryTree>>
##
## Remove this node from the binary tree. Parent and children nodes will be re-attached accordingly.
##
## If `ignore_old`, then the key of the returned pair will **always** be `null`, discarding the old node's reference.
## Otherwise it will **always** be `self`, after it is orphaned. `ignore_old` is enabled by default.
##
## The value of the returned pair is whatever node that took over the spot of the old node, if any.
##
## Pass something other than `NOT_BST_*` to `as_bst` to treat this as a binary search tree for this operation.
## This only makes a difference if the current node has children on both sides. Defaults to `NOT_BST_RIGHT`.
## In particular, `USE_DEEPER` will use the node with a deeper depth to replace the current node.
##
## NOTE: If this operation is done on the root node, then the variable that holds the root node
## needs to be re-set to the value of the returned pair, otherwise the reference to the entire binary tree will be lost!
##
func remove(ignore_old: bool = true, as_bst: AsBSTBalancingMode = AsBSTBalancingMode.NOT_BST_RIGHT) -> KVPair:
    var fin: Callable = func() -> CometBinaryTree:
        _l = null
        _r = null
        _p = weakref(null)
        if ignore_old:
            return null
        else:
            return self
    if is_leaf():
        var side: ChildSide = child_side()
        var parent: CometBinaryTree = _p.get_ref()
        match side:
            ChildSide.LEFT:
                assert(parent, "Parent should exist!")
                parent._l = null
            ChildSide.RIGHT:
                assert(parent, "Parent should exist!")
                parent._r = null
        return KVPair.new(fin.call(), OptionalType.new(null))
    elif _l and _r:
        var side: ChildSide = child_side()
        var parent: CometBinaryTree = _p.get_ref()
        var to_use: CometBinaryTree = null
        if as_bst != AsBSTBalancingMode.NOT_BST_RIGHT and as_bst != AsBSTBalancingMode.NOT_BST_LEFT:
            match as_bst:
                AsBSTBalancingMode.ALWAYS_PRE:
                    to_use = get_inord_pre_as_bst()
                AsBSTBalancingMode.ALWAYS_SUC:
                    to_use = get_inord_suc_as_bst()
                AsBSTBalancingMode.USE_DEEPER:
                    var pre: CometBinaryTree = get_inord_pre_as_bst()
                    var suc: CometBinaryTree = get_inord_suc_as_bst()
                    to_use = pre if pre.depth() > suc.depth() else suc
                _:
                    push_error("Unreachable code!")
                    assert(false, "Unreachable code!")
        else:
            match as_bst:
                AsBSTBalancingMode.NOT_BST_LEFT:
                    to_use = _l
                AsBSTBalancingMode.NOT_BST_RIGHT:
                    to_use = _r
                _:
                    push_error("Unreachable code!")
                    assert(false, "Unreachable code!")
        to_use.detatch_all()
        match side:
            ChildSide.LEFT:
                assert(parent, "Parent should exist!")
                to_use._p = weakref(parent)
                parent._l = to_use
            ChildSide.RIGHT:
                assert(parent, "Parent should exist!")
                to_use._p = weakref(parent)
                parent._r = to_use
            _:
                to_use._p = weakref(null)
        if _l and _l != to_use:
            _l._p = weakref(to_use)
            to_use._l = _l
        if _r and _r != to_use:
            _r._p = weakref(to_use)
            to_use._r = _r
        return KVPair.new(fin.call(), OptionalType.new(to_use))
    else:
        var side: ChildSide = child_side()
        var parent: CometBinaryTree = _p.get_ref()
        var old: CometBinaryTree = null
        if _l:
            old = _l
            match side:
                ChildSide.LEFT:
                    assert(parent, "Parent should exist!")
                    parent._l = _l
                ChildSide.RIGHT:
                    assert(parent, "Parent should exist!")
                    parent._r = _l
            _l._p = _p
        elif _r:
            old = _r
            match side:
                ChildSide.LEFT:
                    assert(parent, "Parent should exist!")
                    parent._l = _r
                ChildSide.RIGHT:
                    assert(parent, "Parent should exist!")
                    parent._r = _r
            _r._p = _p
        return KVPair.new(fin.call(), OptionalType.new(old))

## mut () -> void
##
## Call `detatch_all` on this and all descendant nodes. Orphaned nodes will be freed if no variables hold a reference to them.
func orphan_all() -> void:
    var nodes: Array[CometBinaryTree] = get_postord()
    for node in nodes:
        node.detatch_all()

## mut () -> void
##
## Call `detatch_all` all descendant nodes, but not `self`. Orphaned nodes will be freed if no variables hold a reference to them.
func orphan_descendants() -> void:
    var nodes: Array[CometBinaryTree] = get_postord()
    for node in nodes.slice(0, nodes.size() - 1):
        node.detatch_all()

## mut () -> bool
##
## Detaches this node from the parent node.
func detatch_parent() -> void:
    var parent: CometBinaryTree = _p.get_ref() ## CometBinaryTree<T>?
    if parent:
        if parent._l == self:
            parent._l = null
        if parent._r == self:
            parent._r = null
        _p = weakref(null)

## mut () -> OptionalType<CometBinaryTree<T>>
##
## Detaches this node from the parent node. Returns the parent node.
func detatch_parent_returning() -> OptionalType:
    var parent: CometBinaryTree = _p.get_ref() ## CometBinaryTree<T>?
    if parent:
        if parent._l == self:
            parent._l = null
        if parent._r == self:
            parent._r = null
        _p = weakref(null)
        return OptionalType.new(parent)
    else:
        return OptionalType.new(null)

## mut () -> void
##
## Detatches all children nodes from this node.
func detatch_children() -> void:
    if _l:
        _l._p = weakref(null)
        _l = null
    if _r:
        _r._p = weakref(null)
        _r = null

## mut () -> KVPair<OptionalType<CometBinaryTree<T>>, OptionalType<CometBinaryTree<T>>
##
## Detatches all children nodes from this node. Returns a KVPair, with the key and value corresponding to left and right child nodes.
func detatch_children_returning() -> KVPair:
    var kv: KVPair = KVPair.new(OptionalType.new(null), OptionalType.new(null))
    if _l:
        kv._key.insert(_l)
        _l._p = weakref(null)
        _l = null
    if _r:
        kv._value.insert(_r)
        _r._p = weakref(null)
        _r = null
    return kv

## mut () -> void
##
## Calls `self.detatch_parent()` and `self.detatch_children()`, orphaning this node.
func detatch_all() -> void:
    detatch_parent()
    detatch_children()
