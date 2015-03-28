# [String] -> Object -> Object
module.exports = (allowed, obj) -->
	obj |> obj-to-pairs |> filter ([key, ]) -> key in (allowed.map (it) -> camelize it) |> pairs-to-obj
