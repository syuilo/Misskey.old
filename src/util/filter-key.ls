import require \prelude-ls

# [String] -> Object -> Object
export = (allowed, obj) -->
	(obj) -> obj |> obj-to-pairs |> filter ([key, ]) -> key in (camelize allowed) |> pairs-to-obj
