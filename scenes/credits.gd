extends Control
class_name CreditsScene

const CREDITS_FILEPATH := "res://CREDITS.md"

signal close_requested

var paused: bool = false

@onready var _close_btn := $Panel/Main/Actions/Close as Button
@onready var _pause_btn := $Panel/Main/Actions/Pause as Button
@onready var _scroll_container := $Panel/Main/Credits as ScrollContainer
@onready var _credits_list := $Panel/Main/Credits/List/Credits as Control


func _ready() -> void:
	_close_btn.pressed.connect(close_requested.emit)
	_pause_btn.toggled.connect(func(toggled: bool): paused = toggled)
	_populate_credits()


func _process(_delta: float) -> void:
	if paused:
		return
	_scroll_container.scroll_vertical += 1
	# TODO: Change this to a fixed-step func? Like _physics_process


func _populate_credits() -> void:
	var data := _load_credits_data()
	for category in data:
		var subtitle := Label.new()
		subtitle.text = category
		subtitle.add_theme_font_size_override(&"font_size", 32)
		subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_credits_list.add_child(subtitle)
		for entry in data[category]:
			var title := RichTextLabel.new()
			title.bbcode_enabled = true
			title.fit_content = true
			title.append_text("[center]")
			title.append_text(entry["link"])
			title.add_theme_font_size_override(&"normal_font_size", 22)
			title.meta_clicked.connect(OS.shell_open)
			var author := RichTextLabel.new()
			author.bbcode_enabled = true
			author.fit_content = true
			author.append_text("[center]")
			author.append_text(entry["author"])
			author.meta_clicked.connect(OS.shell_open)
			_credits_list.add_child(title)
			_credits_list.add_child(author)
			var spacing := HSeparator.new()
			spacing.add_theme_stylebox_override(&"separator", StyleBoxEmpty.new())
			spacing.add_theme_constant_override(&"separation", 32)
			_credits_list.add_child(spacing)
		var padding := HSeparator.new()
		padding.add_theme_stylebox_override(&"separator", StyleBoxEmpty.new())
		padding.add_theme_constant_override(&"separation", 32)
		_credits_list.add_child(padding)


func _load_credits_data() -> Dictionary:
	var credits_data := {}
	var credits_text := FileAccess.open(CREDITS_FILEPATH, FileAccess.READ).get_as_text()
	var lines := credits_text.split("\n")
	var i := 0
	while true:
		if i >= lines.size():
			break
		if lines[i].strip_edges().is_empty():
			i += 1
			continue
		var category := lines[i].get_slice(":", 0)
		var link := lines[i].get_slice(": ", 1)
		if link.begins_with("["):
			link = _to_bbcode_link(link)
		if not credits_data.has(category):
			credits_data[category] = []
		var author := lines[i+1].trim_prefix("By ")
		if author.begins_with("["):
			author = _to_bbcode_link(author)
		var license := lines[i+2]
		credits_data[category].append({
			"link": link.strip_edges(),
			"author": author.strip_edges(),
			"license": license.strip_edges(),
		})
		i += 3
	return credits_data


func _to_bbcode_link(markdown_link: String) -> String:
	var text := markdown_link.get_slice("]", 0).substr(1).strip_edges()
	var url := markdown_link.get_slice("(", 1).trim_suffix(")").strip_edges()
	return "[url=%s]%s[/url]" % [url, text]
