extends Panel

signal closed
signal home_requested

@onready var home_button: Button = $HomeButton  # adjust path
@onready var done_button: Button = $DoneButton  # if you have one

func _ready() -> void:
	home_button.pressed.connect(_on_home_pressed)
	home_button.hide()
	done_button.pressed.connect(_on_done_pressed)
	$OptionButton.selected = Settings.anti_aliasing
	$OptionButton2.selected = Settings.quality

func show_home_button(show: bool) -> void:
	home_button.visible = show

func _on_home_pressed() -> void:
	home_requested.emit()

func _on_done_pressed() -> void:
	hide()
	closed.emit()


func _on_option_button_item_selected(index: int) -> void:
	Settings.set_anti_aliasing(index)


func _on_option_button_2_item_selected(index: int) -> void:
	Settings.set_quality(index)
