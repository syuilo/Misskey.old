import require \prelude-ls

allowed = <[
	color
	comment
	created-at
	is-plus
	is-suspended
	lang
	last-name
	link
	location
	name
	screen-name
	tags
	url
]> |> map camelize

exports = (user) -> user |> obj-to-pairs |> filter ([name, ]) -> name in allowed |> pairs-to-obj
