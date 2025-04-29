class_name UiContainerDropAnimation extends Container

# README: Children of this container should be simple control nodes that lay themselves out in the desired way.
# README: These simple control nodes should each hold one control element (whatever desired)
# README: The held control element should have custom anchor points set to (left=0, top=0, right=0, left=0) (this is the same as using fullrect)
# README: These anchor points will be adjusted during the animation process

signal animation_finished

var elements : Array[Control]

func drop_in_from_above():
	var start_anchors = Rect2(0.0, -1.0, 1.0, 0.0)
	var end_anchors = Rect2(0.0, 0.0, 1.0, 1.0)
	var start_color = Color(1.0, 1.0, 1.0, 0.0)
	var end_color = Color(1.0, 1.0, 1.0, 1.0)
	_play_animation(start_anchors, end_anchors, start_color, end_color)
	
func drop_out_to_below():
	var start_anchors = Rect2(0.0, 0.0, 1.0, 1.0)
	var end_anchors = Rect2(0.0, 1.0, 1.0, 2.0)
	var start_color = Color(1.0, 1.0, 1.0, 1.0)
	var end_color = Color(1.0, 1.0, 1.0, 0.0)
	_play_animation(start_anchors, end_anchors, start_color, end_color)
	
func drop_in_from_left():
	var start_anchors = Rect2(-1.0, 0.0, 0.0, 1.0)
	var end_anchors = Rect2(0.0, 0.0, 1.0, 1.0)
	var start_color = Color(1.0, 1.0, 1.0, 0.0)
	var end_color = Color(1.0, 1.0, 1.0, 1.0)
	_play_animation(start_anchors, end_anchors, start_color, end_color)
	
func drop_out_to_right():
	var start_anchors = Rect2(0.0, 0.0, 1.0, 1.0)
	var end_anchors = Rect2(1.0, 0.0, 2.0, 1.0)
	var start_color = Color(1.0, 1.0, 1.0, 1.0)
	var end_color = Color(1.0, 1.0, 1.0, 0.0)
	_play_animation(start_anchors, end_anchors, start_color, end_color)

func _play_animation(startAnchors : Rect2, endAnchors : Rect2, startColor : Color, endColor : Color):
	
	# Start animation for each element
	var tweens : Array[Tween]
	for i in range(elements.size()):
		
		# Set each element to its starting position and color modulation
		_set_anchors(elements[i], startAnchors)
		elements[i].modulate = startColor
		
		# Start the animation
		var tween : Tween = create_tween()
		tweens.append(tween)
		tween.tween_method(func(anchors : Rect2) : _set_anchors(elements[i], anchors), startAnchors, endAnchors, 0.35).set_delay(i / 8.0)
		tween.parallel().tween_property(elements[i], "modulate", endColor, 0.35).set_delay(i / 8.0)

	# Wait until all animations are finished
	for tween in tweens:
		await tween.finished
		
	animation_finished.emit()

func _set_anchors(element : Control, anchors : Rect2):
	element.anchor_left = anchors.position.x
	element.anchor_top = anchors.position.y
	element.anchor_right = anchors.size.x
	element.anchor_bottom = anchors.size.y

func _ready():
	
	for child in get_children():
		elements.append(child.get_child(0))
