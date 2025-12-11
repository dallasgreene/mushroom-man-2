extends Area3D
class_name AttackComponent
@export var attack_data: AttackData


func get_attacked_tile_coords(parent_room: Room, temp_attack_data: AttackData) -> Dictionary:
	var attacked_tile_coords = {}
	match temp_attack_data.attack_type:
		AttackData.AttackType.CONE:
			for i in range(temp_attack_data.distance):
				var desired_position = (position + (-Global.TILE_SIZE*(i+1)) * transform.basis.z)
				var global_desired_position = to_global(Vector3(0,0,desired_position.z)).round()
				attacked_tile_coords.get_or_add(roundi(global_desired_position.x), {})[roundi(global_desired_position.z)] = true
				for j in range (i):
					var desired_position_outside = (
						position +
						(-Global.TILE_SIZE*(i+1)) * transform.basis.z +
						(Global.TILE_SIZE * (j+1)) * transform.basis.x
					)
					var global_desired_position_outside_right = to_global(Vector3(desired_position_outside.x,0,desired_position_outside.z)).round()
					attacked_tile_coords.get_or_add(roundi(global_desired_position_outside_right.x), {})[roundi(global_desired_position_outside_right.z)] = true
					var global_desired_position_outside_left = to_global(Vector3(-desired_position_outside.x,0,desired_position_outside.z)).round()
					attacked_tile_coords.get_or_add(roundi(global_desired_position_outside_left.x), {})[roundi(global_desired_position_outside_left.z)] = true
		AttackData.AttackType.LINE:
			for i in range(temp_attack_data.distance):
				var desired_position = (position + (-Global.TILE_SIZE*(i+1)) * transform.basis.z)
				var global_desired_position = to_global(Vector3(0,0,desired_position.z)).round()
				attacked_tile_coords.get_or_add(roundi(global_desired_position.x), {})[roundi(global_desired_position.z)] = true
		AttackData.AttackType.CLEAVE:
			var global_desired_position = to_global(Vector3(0,0,-2)).round()
			attacked_tile_coords.get_or_add(roundi(global_desired_position.x), {})[roundi(global_desired_position.z)] = true
			for i in range(temp_attack_data.distance):
				var desired_position = (position + (-Global.TILE_SIZE*(i+1)) * transform.basis.x)
				var global_desired_position_right = to_global(Vector3(desired_position.x,0,-Global.TILE_SIZE)).round()
				attacked_tile_coords.get_or_add(roundi(global_desired_position_right.x), {})[roundi(global_desired_position_right.z)] = true
				var global_desired_position_left = to_global(Vector3(-desired_position.x,0,-Global.TILE_SIZE)).round()
				attacked_tile_coords.get_or_add(roundi(global_desired_position_left.x), {})[roundi(global_desired_position_left.z)] = true
		AttackData.AttackType.CIRCLE:
			for i in range(0, temp_attack_data.distance + 1):
				for j in range(0, (temp_attack_data.distance + 1) - i):
					var global_positions = []
					global_positions.push_back(to_global(Vector3(i * Global.TILE_SIZE,0,j  * Global.TILE_SIZE)).round())
					global_positions.push_back(to_global(Vector3(-i * Global.TILE_SIZE,0,j * Global.TILE_SIZE)).round())
					global_positions.push_back(to_global(Vector3(i * Global.TILE_SIZE,0,-j * Global.TILE_SIZE)).round())
					global_positions.push_back(to_global(Vector3(-i * Global.TILE_SIZE,0,-j * Global.TILE_SIZE)).round())
					for global_pos in global_positions:
						attacked_tile_coords.get_or_add(roundi(global_pos.x), {})[roundi(global_pos.z)] = true
	# Remove all tile positions which do not exist in the room before returning
	for x_coord in attacked_tile_coords.keys():
		for z_coord in attacked_tile_coords[x_coord].keys():
			if parent_room.get_tile(x_coord, z_coord) == null:
				attacked_tile_coords[x_coord].erase(z_coord)
		if attacked_tile_coords[x_coord].is_empty():
			attacked_tile_coords.erase(x_coord)
	return attacked_tile_coords

func create_attack(parent_room: Room, parent_entity: Creature, parent_attack_data: AttackData):
	attack_data = parent_attack_data
	match attack_data.attack_type:
		AttackData.AttackType.CONE:
			print("position: ", parent_entity.global_position)
			for i in range(attack_data.distance):
				#Creating the layers of the cone (increasing length lines as it goes farther out) (we can change this later for collision)
				var collision_shape:CollisionShape3D = CollisionShape3D.new()
				var box_shape = BoxShape3D.new()
				box_shape.size = Vector3(2 + (i*4),1,2)
				collision_shape.shape = box_shape
				collision_shape.position = Vector3(0,.5,-2-(i*2))
				#Debug stuff for showing collision shape debugs
				collision_shape.debug_color = Color(0.0, 0.6, 0.702, 0.42)
				collision_shape.debug_fill=true
				add_child(collision_shape)	
				var desired_position = (position + (-Global.TILE_SIZE*(i+1)) * transform.basis.z)
				parent_room.mark_attack_tile(parent_entity, parent_entity.to_global(Vector3(0,0,desired_position.z)).round(), attack_data.duplicate())
	
				for j in range (i):
					var desired_position_outside = (
						position +
						(-Global.TILE_SIZE*(i+1)) * transform.basis.z +
						(Global.TILE_SIZE * (j+1)) * transform.basis.x
					)
					
					parent_room.mark_attack_tile(parent_entity, parent_entity.to_global(Vector3(desired_position_outside.x,0,desired_position_outside.z)).round(), attack_data.duplicate())
					parent_room.mark_attack_tile(parent_entity, parent_entity.to_global(Vector3(-desired_position_outside.x,0,desired_position_outside.z)).round(), attack_data.duplicate())
		AttackData.AttackType.LINE:
			var collision_shape:CollisionShape3D = CollisionShape3D.new()
			var box_shape = BoxShape3D.new()
			box_shape.size = Vector3(Global.TILE_SIZE, 1, Global.TILE_SIZE*attack_data.distance)
			collision_shape.shape = box_shape
			collision_shape.position = Vector3(0,.5,-attack_data.distance-1)
			#Debug stuff for showing collision shape debugs
			collision_shape.debug_color = Color(0.0, 0.6, 0.702, 0.42)
			collision_shape.debug_fill=true
			add_child(collision_shape)	
			for i in range(attack_data.distance):
				var desired_position = (position + (-Global.TILE_SIZE*(i+1)) * transform.basis.z)
				parent_room.mark_attack_tile(parent_entity, parent_entity.to_global(Vector3(0,0,desired_position.z)).round(), attack_data.duplicate())
		AttackData.AttackType.CLEAVE:
			var collision_shape:CollisionShape3D = CollisionShape3D.new()
			var box_shape = BoxShape3D.new()
			box_shape.size = Vector3(2+(4*attack_data.distance),1,2)
			collision_shape.shape = box_shape
			collision_shape.position = Vector3(0,.5,-2)
			#Debug stuff for showing collision shape debugs
			collision_shape.debug_color = Color(0.0, 0.6, 0.702, 0.42)
			collision_shape.debug_fill=true
			add_child(collision_shape)	
			parent_room.mark_attack_tile(parent_entity, parent_entity.to_global(Vector3(0,0,-2)).round(), attack_data.duplicate())
			for i in range(attack_data.distance):
				var desired_position = (position + (-Global.TILE_SIZE*(i+1)) * transform.basis.x)
				parent_room.mark_attack_tile(parent_entity, parent_entity.to_global(Vector3(desired_position.x,0,-Global.TILE_SIZE)).round(), attack_data.duplicate())
				parent_room.mark_attack_tile(parent_entity, parent_entity.to_global(Vector3(-desired_position.x,0,-Global.TILE_SIZE)).round(), attack_data.duplicate())
				
		AttackData.AttackType.CIRCLE:
			var count: int
			var layer: int = 0
			if attack_data.distance % 2 == 0:
				count = attack_data.distance + 2
			else:
				count = attack_data.distance + 1
			for i in range(count):
				var collision_shape:CollisionShape3D = CollisionShape3D.new()
				var box_shape = BoxShape3D.new()
				if i % 2 == 0:	
					layer += 1
					box_shape.size = Vector3((((count+(attack_data.distance%2)-1)*4)+2)-(layer*4), 1, 2+((layer-1)*4))
				else:
					box_shape.size = Vector3(2+((layer-1)*4), 1, (((count+(attack_data.distance%2)-1)*4)+2)-(layer*4))
				collision_shape.shape = box_shape
				#Debug stuff for showing collision shape debugs
				collision_shape.debug_color = Color(0.0, 0.6, 0.702, 0.42)
				collision_shape.debug_fill=true
				add_child(collision_shape)
			for i in range(0,attack_data.distance+1):
				for j in range(0,(attack_data.distance+1) - i):
					parent_room.mark_attack_tile(parent_entity, parent_entity.to_global(Vector3(i * Global.TILE_SIZE,0,j  * Global.TILE_SIZE)).round(), attack_data.duplicate())
					parent_room.mark_attack_tile(parent_entity, parent_entity.to_global(Vector3(-i * Global.TILE_SIZE,0,j * Global.TILE_SIZE)).round(), attack_data.duplicate())
					parent_room.mark_attack_tile(parent_entity, parent_entity.to_global(Vector3(i * Global.TILE_SIZE,0,-j * Global.TILE_SIZE)).round(), attack_data.duplicate())
					parent_room.mark_attack_tile(parent_entity, parent_entity.to_global(Vector3(-i * Global.TILE_SIZE,0,-j * Global.TILE_SIZE)).round(), attack_data.duplicate())
		
func attack():
	for child in get_children():
		child.queue_free()
