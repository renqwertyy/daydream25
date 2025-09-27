extends ColorRect

# Gameplay click variables
@export var blur_increment: float = 0.01
@export var health_decrement: float = 0.1
@export var health_bar_path: NodePath

# Intro variables
var intro_active: bool = true
var title_label: Label
var press_start_label: Label
var blink_timer: float = 0.0
var blink_speed: float = 1.5
var original_color: Color
var blur_material: ShaderMaterial

func _ready():
	blur_material = material
	original_color = color
	
	if intro_active:
		setup_intro()

func setup_intro():
	# Temporarily hide blur and make black
	material = null
	color = Color.BLACK
	
	# Create title label
	title_label = Label.new()
	title_label.text = "Beverage Simulator"
	title_label.add_theme_font_size_override("font_size", 64)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	title_label.position.y -= 100
	add_child(title_label)
	
	# Create press start label
	press_start_label = Label.new()
	press_start_label.text = "Click to Start"
	press_start_label.add_theme_font_size_override("font_size", 24)
	press_start_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	press_start_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	press_start_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	press_start_label.position.y += 50
	add_child(press_start_label)
	
	# Ensure the intro is on top
	z_index = 2000
	modulate.a = 1.0

func _process(delta):
	if intro_active:
		# Blink "Click to Start"
		blink_timer += delta * blink_speed
		var alpha = (sin(blink_timer) + 1.0) / 2.0
		press_start_label.modulate.a = lerp(0.3, 1.0, alpha)
	else:
		# Update blur normally
		var mat = material
		if mat and mat is ShaderMaterial:
			var current_blur = mat.get_shader_parameter("blur_strength")
			var new_blur = clamp(current_blur, 0.0, 1.0)
			mat.set_shader_parameter("blur_strength", new_blur)

func _input(event):
	if intro_active:
		if (event is InputEventKey or event is InputEventMouseButton) and event.pressed:
			start_intro_end()
	# After intro, clicks affect gameplay
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		increase_blur()
		decrease_health()

# Intro fade
func start_intro_end():
	intro_active = false
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_callback(switch_to_blur)

func switch_to_blur():
	# Remove intro labels
	if title_label:
		title_label.queue_free()
	if press_start_label:
		press_start_label.queue_free()
	
	# Restore blur shader and original color
	material = blur_material
	color = original_color
	
	# Fade back in
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

# Gameplay functions
func increase_blur():
	var mat = material
	if mat and mat is ShaderMaterial:
		var current_blur = mat.get_shader_parameter("blur_strength")
		var new_blur = clamp(current_blur + blur_increment, 0.0, 1.0)
		mat.set_shader_parameter("blur_strength", new_blur)
		print("blur_strength updated to: ", new_blur)
	else:
		print("ColorRect does not have a ShaderMaterial")

func decrease_health():
	var health_bar = get_node_or_null(health_bar_path)
	if health_bar and health_bar is ProgressBar:
		health_bar.value = clamp(health_bar.value - health_decrement * health_bar.max_value, 0, health_bar.max_value)
		print("Health decreased to: ", health_bar.value)
	else:
		print("Health ProgressBar not found or invali")
