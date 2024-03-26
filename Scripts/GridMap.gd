extends GridMap

#grid consts
const ROWS := 20
const COLS := 10

const SPAWN = Vector3i(-1, 8, 0)

#game piece vars
var piece_type
var next_piece_type
var rotation_index : int = 0
var active_piece : Array
var current_loc

#grid vars
var cube_id : int = 0
var piece_color : int

#movement variables
const directions := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]
var steps : Array
const steps_req : int = 50
var speed : float
const ACCEL : float = 0.25

var bag = SRS.shapes.duplicate()

func convert_vec2_vec3(vec2 : Vector2i) -> Vector3i:
	return Vector3i(vec2.x, -vec2.y, 0)

func _ready():
	new_game()
	
func _physics_process(_delta):
	if Input.is_action_pressed("ui_left"):
		steps[0] += 10
	elif Input.is_action_pressed("ui_right"):
		steps[1] += 10
	elif Input.is_action_pressed("ui_down"):
		steps[2] += 10
	
	steps[2] += speed
	for i in range(steps.size()):
		if steps[i] > steps_req:
			move_piece(directions[i])
			steps[i] = 0
		
func new_game():
	speed = 1.0
	steps = [0, 0, 0]
	piece_type = pick_piece()
	piece_color = SRS.shapes.find(piece_type)
	create_piece()
	
func pick_piece():
	var piece
	if not bag.is_empty():
		bag.shuffle()
		piece = bag.pop_front()
	else:
		bag = SRS.shapes.duplicate()
		pick_piece()
	return piece

func create_piece():
	steps = [0, 0, 0]
	current_loc = SPAWN
	active_piece = piece_type[rotation_index]
	draw_piece(active_piece, SPAWN)

func clear_piece():
	for i in active_piece:
		set_cell_item(convert_vec2_vec3(i) + current_loc, -1)

func draw_piece(piece, pos):
	for i in piece:
		set_cell_item(convert_vec2_vec3(i) + pos, piece_color)

func move_piece(dir):
	if can_move(dir):
		clear_piece()
		current_loc += convert_vec2_vec3(dir)
		draw_piece(active_piece, current_loc)
	


func can_move(dir):
	# Check if the entire piece can move in the specified direction
	for i in active_piece:
		if not is_free(convert_vec2_vec3(i) + current_loc + convert_vec2_vec3(dir)):
			return false  # Return false as soon as a block cannot move
	return true  # Return true only if all blocks can move
	
func is_free(pos):
	return get_cell_item(pos) == -1