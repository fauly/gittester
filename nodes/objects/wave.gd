extends Node2D

# ─── EXPORTS ───────────────────────────────────────────────────────────────
@export var raw_size:       int   = 512     # how many raw samples to pull each frame
@export var segment_count:  int   = 8       # number of line segments (resolution of graph)
@export var bias:           float = 0.5     # 0 = raw anchor sample, 1 = full average
@export var thickness:      float = 2.0     # line thickness
@export var mono:           bool  = true    # true = draw only left channel; false = show both
@export var process_audio:  bool  = true    # true = apply envelope smoothing to reduce wave flipping
@export var amplitude_x: 	float = 1.0

# ─── INTERNALS ─────────────────────────────────────────────────────────────
var bus_index: int
var capture_effect: AudioEffectCapture
var avg_l : float
var avg_r :float

func _ready():
	set_process(true)
	bus_index = AudioServer.get_bus_index("Master")
	for i in range(AudioServer.get_bus_effect_count(bus_index)):
		var eff = AudioServer.get_bus_effect(bus_index, i)
		if eff is AudioEffectCapture:
			capture_effect = eff
			break
	if capture_effect == null:
		push_error("No AudioEffectCapture found on Master bus. Add one in Project → Audio → Buses.")

func _process(_delta):
	queue_redraw()

func _draw():
	if capture_effect == null:
		return

	var available = capture_effect.get_frames_available()
	var sample_count = min(raw_size, available)
	if sample_count <= 1:
		return

	var raw: PackedVector2Array = capture_effect.get_buffer(sample_count)
	
	for i in range(raw.size()):
		raw[i].x *= amplitude_x
		raw[i].y *= amplitude_x
	
	var size = get_viewport_rect().size
	var w = size.x
	var h = size.y
	var cy = h * 0.5

	var left_points := PackedVector2Array()
	var right_points := PackedVector2Array()

	for s in range(segment_count):
		var start = int(sample_count * s / segment_count)
		var end   = int(sample_count * (s + 1) / segment_count)
		if end <= start:
			end = min(start + 1, sample_count)

		var anchor_l = raw[start].x
		var anchor_r = raw[start].y

		var sum_l = 0.0
		var sum_r = 0.0

		for i in range(start, end):
			var l = raw[i].x
			var r = raw[i].y

			if process_audio:
				# Square the samples instead of using abs()
				l = l * l
				r = r * r

			sum_l += l
			sum_r += r

		if process_audio:
			# RMS = sqrt(mean of squares)
			var avg_l = sqrt(sum_l / float(end - start))
			var avg_r = sqrt(sum_r / float(end - start))
		else:
			# Raw average (no RMS)
			var avg_l = sum_l / float(end - start)
			var avg_r = sum_r / float(end - start)

		var value_l = lerp(anchor_l, avg_l, bias)
		var value_r = lerp(anchor_r, avg_r, bias)

		var x = w * float(s) / float(segment_count - 1)
		var y_l = cy - value_l * cy
		var y_r = cy - value_r * cy

		left_points.append(Vector2(x, y_l))
		right_points.append(Vector2(x, y_r))

	if mono:
		draw_polyline(left_points, Color.WHITE, thickness)
	else:
		draw_polyline(left_points, Color.RED, thickness)
		draw_polyline(right_points, Color.BLUE, thickness)

# ─── UI CALLBACKS ──────────────────────────────────────────────────────────
func _on_thickness_value_changed(value: float) -> void:
	thickness = value
	
func _on_sample_count_value_changed(value: float) -> void:
	raw_size = value

func _on_segments_value_changed(value: float) -> void:
	segment_count = value

func _on_bias_value_changed(value: float) -> void:
	bias = value

func _on_mono_toggled(toggled_on: bool) -> void:
	mono = toggled_on

func _on_process_audio_toggled(toggled_on: bool) -> void:
	process_audio = toggled_on

func _on_amplitude_value_changed(value: float) -> void:
	amplitude_x = value
