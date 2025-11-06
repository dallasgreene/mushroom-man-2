extends Area3D
class_name AttackComponent
@export_range(1,100) var distance: int
@export var attack_type: AttackType
var attack_data: AttackData

enum AttackType{
	CONE,
	LINE,
	CLEAVE,
	CIRCLE
}
	
func create_attack(parent_room: Room, parent_entity: Node3D):
	attack_data = parent_entity.attack_data
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
		AttackType.LINE:
			var collision_shape:CollisionShape3D = CollisionShape3D.new()
			var box_shape = BoxShape3D.new()
			box_shape.size = Vector3(Global.TILE_SIZE, 1, Global.TILE_SIZE*distance)
			collision_shape.shape = box_shape
			collision_shape.position = Vector3(0,.5,-distance-1)
			#Debug stuff for showing collision shape debugs
			collision_shape.debug_color = Color(0.0, 0.6, 0.702, 0.42)
			collision_shape.debug_fill=true
			add_child(collision_shape)	
			for i in range(distance):
				var desired_position = (position + (-Global.TILE_SIZE*(i+1)) * transform.basis.z)
				parent_room.mark_attack_tile(parent_entity, parent_entity.to_global(Vector3(0,0,desired_position.z)).round(), attack_data.duplicate())
		AttackType.CLEAVE:
			var collision_shape:CollisionShape3D = CollisionShape3D.new()
			var box_shape = BoxShape3D.new()
			box_shape.size = Vector3(2+(4*distance),1,2)
			collision_shape.shape = box_shape
			collision_shape.position = Vector3(0,.5,-2)
			#Debug stuff for showing collision shape debugs
			collision_shape.debug_color = Color(0.0, 0.6, 0.702, 0.42)
			collision_shape.debug_fill=true
			add_child(collision_shape)	
			parent_room.mark_attack_tile(parent_entity, parent_entity.to_global(Vector3(0,0,-2)).round(), attack_data.duplicate())
			for i in range(distance):
				var desired_position = (position + (-Global.TILE_SIZE*(i+1)) * transform.basis.x)
				parent_room.mark_attack_tile(parent_entity, parent_entity.to_global(Vector3(desired_position.x,0,-Global.TILE_SIZE)).round(), attack_data.duplicate())
				parent_room.mark_attack_tile(parent_entity, parent_entity.to_global(Vector3(-desired_position.x,0,-Global.TILE_SIZE)).round(), attack_data.duplicate())
				
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
			for i in range(0,distance+1):
				for j in range(0,(distance+1) - i):
					parent_room.mark_attack_tile(parent_entity, parent_entity.to_global(Vector3(i * Global.TILE_SIZE,0,j  * Global.TILE_SIZE)).round(), attack_data.duplicate())
					parent_room.mark_attack_tile(parent_entity, parent_entity.to_global(Vector3(-i * Global.TILE_SIZE,0,j * Global.TILE_SIZE)).round(), attack_data.duplicate())
					parent_room.mark_attack_tile(parent_entity, parent_entity.to_global(Vector3(i * Global.TILE_SIZE,0,-j * Global.TILE_SIZE)).round(), attack_data.duplicate())
					parent_room.mark_attack_tile(parent_entity, parent_entity.to_global(Vector3(-i * Global.TILE_SIZE,0,-j * Global.TILE_SIZE)).round(), attack_data.duplicate())
		
func attack():
	for child in get_children():
		child.queue_free()
