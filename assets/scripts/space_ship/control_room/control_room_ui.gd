extends Control

@export var dungeon_map_string: Label
@export var detected_rooms: Label
var dungeon: Array

func _init_dungeon_map(dungeon_info: Dictionary) -> void:
	for x in dungeon_info.dungeon.size():
		dungeon.append([])
		
		for y in dungeon_info.dungeon[0].size():
			if dungeon_info.dungeon[x][y] != null:
				dungeon[x].append({
					"terminal": " ",
					"entity": " "
				})
				
				for i in dungeon_info.terminals.size():
					if dungeon_info.terminals[i].room_id == dungeon_info.dungeon[x][y].id:
						dungeon[x][y].terminal = dungeon_info.terminals[i].color[0]
			else:
				dungeon[x].append(null)
	
	_print_dungeon_map(false)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_manager.send_dungeon_map.connect(_init_dungeon_map)
	game_manager.receive_detected_rooms.connect(_update_entities)
	game_manager.show_detected_rooms.connect(_print_dungeon_map)

func _update_entities(entities: Array) -> void:
	for y in dungeon.size():
		for x in dungeon[0].size():
			if dungeon[x][y] == null:
				continue
			
			if entities.has(Vector2i(x, y)):
				dungeon[x][y].entity = "X"
			else:
				dungeon[x][y].entity = " "
	_print_dungeon_map(true)

func _print_dungeon_map(scan: bool):
	var dungeon_as_string : String = ""
	for y in dungeon[0].size():
		for x in dungeon.size():
			# Setting the room map in the pattern: "[ ]". 
			var cell = dungeon[x][y]
			if cell != null:
				if scan:
					dungeon_as_string += "[" + cell.entity + "]"
				else:
					dungeon_as_string += "[" + cell.terminal + "]"
			else:
				dungeon_as_string += "   "
		dungeon_as_string += "\n"
	dungeon_map_string.text = dungeon_as_string
	print("Przekazano: \n" + dungeon_as_string)
