extends Node2D

const CAMERA_MOVE_SPEED = 32
var tilemap_selected = "TileMap"
var tile_type = 0
var tile_selected = Vector2(0,0)
var old_tile_selected = Vector2(0,0)
var sidebar_offset = 0
var bottombar_offset = 0
var swipe_speed = 0
var mouse_down = false

func _ready():
	$Grid.visible = false
	update_selected_tile()
	if get_tree().current_scene.editmode == false:
		sidebar_offset = 128
		bottombar_offset = 128
	
func _process(delta):
	$Grid.rect_size = Vector2(get_viewport().size.x + 32, get_viewport().size.y + 32)
	$Grid.rect_position = Vector2(get_tree().current_scene.get_node("Camera2D").position.x - (get_viewport().size.x / 2), get_tree().current_scene.get_node("Camera2D").position.y - (get_viewport().size.y / 2))
	$Grid.rect_position = Vector2(floor($Grid.rect_position.x / 32) * 32, floor($Grid.rect_position.y / 32) * 32)
	$Grid.visible = true
	$Grid.self_modulate = Color(1, 1, 1, 1 - (sidebar_offset / 128))
	
	if get_tree().current_scene.editmode == false:
		swipe_speed += 10
		sidebar_offset += swipe_speed
		bottombar_offset += swipe_speed
		if sidebar_offset >= 128:
			visible = false
			$UI.offset = Vector2 (get_viewport().size.x * 9999,get_viewport().size.y * 9999)
			sidebar_offset = 128
			bottombar_offset = 128
		return
	else:
		swipe_speed = 0
		visible = true
		if sidebar_offset < 2:
			sidebar_offset = 0
			bottombar_offset = 0
		else:
			sidebar_offset *= 0.8
			bottombar_offset *= 0.8
		$UI.offset = Vector2(0,0)
		
	# Navigation
	if Input.is_action_pressed("ui_up"):
		get_tree().current_scene.get_node("Camera2D").position.y -= CAMERA_MOVE_SPEED
		
	if Input.is_action_pressed("ui_down"):
		get_tree().current_scene.get_node("Camera2D").position.y += CAMERA_MOVE_SPEED
		
	if Input.is_action_pressed("ui_left"):
		get_tree().current_scene.get_node("Camera2D").position.x -= CAMERA_MOVE_SPEED
		
	if Input.is_action_pressed("ui_right"):
		get_tree().current_scene.get_node("Camera2D").position.x += CAMERA_MOVE_SPEED

func _input(event):
	
	tile_selected = get_tree().current_scene.get_node(str("Level/", tilemap_selected)).world_to_map(get_global_mouse_position())
	update_selected_tile()
	
	if Input.is_action_pressed("click_left"):
		if get_viewport().get_mouse_position().x < get_viewport().size.x - 128 and get_viewport().get_mouse_position().y < get_viewport().size.y - 64:
			if tile_selected != old_tile_selected or mouse_down == false:
				get_tree().current_scene.get_node(str("Level/", tilemap_selected)).set_cellv(tile_selected, tile_type)
				get_tree().current_scene.get_node(str("Level/", tilemap_selected)).update_bitmask_area(tile_selected)
		mouse_down = true
	else: mouse_down = false
	
	old_tile_selected = tile_selected
	
	# Transition animation
	if Input.is_action_pressed("click_right") && get_tree().current_scene.editmode == false:
		$UI/AnimationPlayer.play("MoveIn")
	
	if Input.is_action_pressed("click_right") && get_tree().current_scene.editmode == true:
		$UI/AnimationPlayer.play("MoveOut")

func update_selected_tile():
	$SelectedTile.visible = false
	if get_viewport().get_mouse_position().x < get_viewport().size.x - 128 and get_viewport().get_mouse_position().y < get_viewport().size.y - 64:
		$SelectedTile.visible = true
		var selected_texture = get_tree().current_scene.get_node(str("Level/", tilemap_selected)).get_tileset().tile_get_texture(0)
		$SelectedTile.texture = (selected_texture)
		$SelectedTile.region_rect.position = get_tree().current_scene.get_node(str("Level/", tilemap_selected)).get_tileset().autotile_get_icon_coordinate(tile_type) * get_tree().current_scene.get_node(str("Level/", tilemap_selected)).cell_size
		$SelectedTile.position.x = (tile_selected.x + 0.5) * get_tree().current_scene.get_node(str("Level/", tilemap_selected)).cell_size.x
		$SelectedTile.position.y = (tile_selected.y + 0.5) * get_tree().current_scene.get_node(str("Level/", tilemap_selected)).cell_size.y

#Buttons
func _on_TilesButton_pressed():
	print("tiles")

func _on_ObjectsButton_pressed():
	print("objects")
