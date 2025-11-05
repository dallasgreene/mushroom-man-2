extends Area3D
class_name AttackComponent
@export_range(1,100) var distance: int
@export var attack_type:AttackType
@export var enemy_attack: bool
@export_range(1,100) var time_to_attack: int

enum AttackType{
	CONE,
	LINE,
	CLEAVE,
	CIRCLE
}
	
func create_attack(parent_room: Room, parent_entity: Node3D):
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
	for child in get_children():
		child.queue_free()
