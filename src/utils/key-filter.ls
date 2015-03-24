import require \prelude-ls

# [String] -> Object -> Object
export = (allowed, obj) -->
	(obj) -> obj |> obj-to-pairs |> filter ([name, ]) -> name in (camelize allowed) |> pairs-to-obj
