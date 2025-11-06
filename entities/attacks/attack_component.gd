extends Area3D
class_name AttackComponent
## range of the attack in tiles
@export_range(1,100) var distance: int
## Determines the shape of the area affected by the attack
@export var attack_type: AttackType
@export var enemy_attack: bool
@export_range(1,100) var time_to_attack: int
@export_range(1,100) var attack_damage: int
var attack_collision_shape: CollisionShape3D

enum AttackType {
	CONE,
	LINE,
	CLEAVE,
	CIRCLE
}

func _ready() -> void:
	recreate_attack_shape()

func recreate_attack_shape() -> void:
	attack_collision_shape = CollisionShape3D.new()
	attack_collision_shape.debug_color = Color(0.0, 0.6, 0.702, 0.42)
	attack_collision_shape.debug_fill = true
	match attack_type:
		AttackType.CONE:
			pass
		AttackType.LINE:
			pass
		AttackType.CLEAVE:
			pass
		AttackType.CIRCLE:
			var new_shape = CylinderShape3D.new()
			new_shape.radius = (distance * Global.TILE_SIZE) + 0.5
			attack_collision_shape.shape = new_shape
	add_child(attack_collision_shape)

func create_attack(parent_room: Room, parent_entity: Creature):
	print(str(parent_entity.global_position), "  ", str(parent_entity.tile_position))
	print(str(Global.player.tile_position))
	var attack_area_rid = get_rid()
	attack_collision_shape.global_position = parent_entity.tile_position
	var raycast = RayCast3D.new()
	raycast.collide_with_areas = true
	raycast.collide_with_bodies = false
	raycast.hit_from_inside = true
	raycast.exclude_parent = false
	add_child(raycast)
	var lower_x_bound = parent_entity.tile_position.x - (distance * Global.TILE_SIZE) - 0.5
	var upper_x_bound = parent_entity.tile_position.x + (distance * Global.TILE_SIZE) + 0.5
	var lower_z_bound = parent_entity.tile_position.z - (distance * Global.TILE_SIZE) - 0.5
	var upper_z_bound = parent_entity.tile_position.z + (distance * Global.TILE_SIZE) + 0.5
	print(str(lower_x_bound), str(upper_x_bound), str(lower_z_bound), str(upper_z_bound))
	var y_coord: int = roundi(parent_entity.tile_position.y)
	var tiles_affected: Array[Vector3i] = []
	for x_coord in parent_room.tile_states:
		if x_coord < lower_x_bound or x_coord > upper_x_bound:
			continue
		for z_coord in parent_room.tile_states[x_coord]:
			if z_coord < lower_z_bound or z_coord > upper_z_bound:
				continue
			raycast.global_position = Vector3(x_coord, y_coord - 1, z_coord)
			raycast.target_position = to_local(Vector3(x_coord, y_coord + 1, z_coord))
			raycast.force_raycast_update()
			print(str(raycast.global_position), "  ", str(attack_collision_shape.global_position))
			if raycast.get_collider_rid() == attack_area_rid:
				tiles_affected.push_back(Vector3i(x_coord, y_coord, z_coord))
				print("raycast hit: ", str(Vector3i(x_coord, y_coord, z_coord)))
			else:
				print("raycast missed: ", str(Vector3i(x_coord, y_coord, z_coord)))
	raycast.queue_free()
	var attack_id = Global.get_next_available_attack_id()
	var attack_data = TileAttackData.new(time_to_attack, attack_damage, not enemy_attack)
	print(str(tiles_affected))
	TileState.queue_attack(attack_id, attack_data, tiles_affected)

func old_create_attack(parent_room: Room, parent_entity: Node3D):
	match attack_type:
		AttackType.CONE:	
			print("position: ", parent_entity.global_position)
			for i in range(distance):
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
				var desired_position = (position + (-2*(i+1)) * transform.basis.z)
				parent_room.mark_attack_tile(parent_entity.to_global(Vector3(0,.5,desired_position.z)))
	
				for j in range (i):
					var desired_position_outside = (
						position +
						(-2*(i+1)) * transform.basis.z +
						(2 * (j+1)) * transform.basis.x
					)
					
					parent_room.mark_attack_tile(parent_entity.to_global(Vector3(desired_position_outside.x,.5,desired_position_outside.z)).round())
					parent_room.mark_attack_tile(parent_entity.to_global(Vector3(-desired_position_outside.x,.5,desired_position_outside.z)).round())
		AttackType.LINE:
			var collision_shape:CollisionShape3D = CollisionShape3D.new()
			var box_shape = BoxShape3D.new()
			box_shape.size = Vector3(2, 1, 2*distance)
			collision_shape.shape = box_shape
			collision_shape.position = Vector3(0,.5,-distance-1)
			#Debug stuff for showing collision shape debugs
			collision_shape.debug_color = Color(0.0, 0.6, 0.702, 0.42)
			collision_shape.debug_fill=true
			add_child(collision_shape)	
		AttackType.CLEAVE:
			var collision_shape:CollisionShape3D = CollisionShape3D.new()
			var box_shape = BoxShape3D.new()
			box_shape.size = Vector3(2*distance,1,2)
			collision_shape.shape = box_shape
			collision_shape.position = Vector3(0,.5,-2)
			#Debug stuff for showing collision shape debugs
			collision_shape.debug_color = Color(0.0, 0.6, 0.702, 0.42)
			collision_shape.debug_fill=true
			add_child(collision_shape)	
		AttackType.CIRCLE:
			var count: int
			var layer: int = 0
			if distance % 2 == 0:
				count = distance + 2
			else:
				count = distance + 1
			for i in range(count):
				var collision_shape:CollisionShape3D = CollisionShape3D.new()
				var box_shape = BoxShape3D.new()
				if i % 2 == 0:	
					layer += 1
					box_shape.size = Vector3((((count+(distance%2)-1)*4)+2)-(layer*4), 1, 2+((layer-1)*4))
				else:
					box_shape.size = Vector3(2+((layer-1)*4), 1, (((count+(distance%2)-1)*4)+2)-(layer*4))
				collision_shape.shape = box_shape
				#Debug stuff for showing collision shape debugs
				collision_shape.debug_color = Color(0.0, 0.6, 0.702, 0.42)
				collision_shape.debug_fill=true
				add_child(collision_shape)
		
func attack():
	pass
