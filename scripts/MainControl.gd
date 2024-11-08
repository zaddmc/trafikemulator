extends Node3D
@export var car_spawn_count: int = 10
@export var light_time: float = 10 
@export var lights_on: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("_on_all_loaded")
	

	pass # Replace with function body.

func _on_all_loaded():
	var roads = get_node("Roads2")
	roads.start()
	roads.spawn_cars(car_spawn_count)
	roads.assign_traffic_lights(light_time, lights_on)




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_cars(delta)
	pass


func update_cars(delta: float):
	for car in Car.CARS:
		car.update_car(delta)
