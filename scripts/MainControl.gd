extends Node3D
@export var car_spawn_count: int = 10
@export var wanted_space: float = 3
@export var light_time: float = 10 
@export var lights_on: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("_on_all_loaded")
	return

func _on_all_loaded():
	var roads = get_node("road_paths") # Gets road_baker.gd script
	roads.bake_roads()
	roads.spawn_cars(car_spawn_count, wanted_space)
	roads.assign_traffic_lights(light_time, lights_on)
	return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_cars(delta)
	return

func update_cars(delta: float):
	for car in Car.CARS:
		car.update_car(delta)
	return
