import require \prelude-ls

# [String] -> Object -> Object
exports = (allowed, obj) -->
	(obj) -> obj |> obj-to-pairs |> filter ([key, ]) -> key in (camelize allowed) |> pairs-to-obj
