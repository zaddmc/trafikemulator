extends Node3D

var road_dict = {}
var inv_road_dict = {} # For crossings to look backwards
var crossings_dict = {}
var roads = []

func bake_roads():
	roads = recursive_road_finder(self)
	for road in roads:

		var close_roads = []
		var backup_list = []
		for rod in roads:
			var points1 = road.get_curve().get_baked_points()
			var point1 = road.to_global(points1[points1.size()-1])
			var points2 = rod.get_curve().get_baked_points()
			var point2 = rod.to_global(points2[0])
			var space_between = (point1 - point2).length()

			if space_between <= 2:
				close_roads.append(rod)
			elif space_between <= 5:
				backup_list.append(rod)

		if close_roads == []:
			close_roads = backup_list

		road_dict[road] = close_roads
		for croad in close_roads:
			if inv_road_dict.has(croad):
				inv_road_dict[croad].append(road)
			else:
				inv_road_dict[croad] = [road]

	Car.set_baked_roads(road_dict, inv_road_dict)
	return

func recursive_road_finder(input):
	if input is Path3D:
		return [input]
	elif input is Node3D:
		var return_value = []
		for child in input.get_children():
			var result = recursive_road_finder(child)
			if result != null:
				return_value.append_array(result)
		return return_value
	else: # invalid value, skips
		return null

func spawn_cars(car_spawn_count: int = 10, wanted_space:float = 2):
	if car_spawn_count <= 0:
		car_spawn_count = 10
	var spawnable_roads = get_tree().get_nodes_in_group("road_allow_spawn")
	var itteration = 1
	var spawned_cars = 0

	while true:
		var spawned_cars_before = spawned_cars
		for road in spawnable_roads:
			if spawned_cars >= car_spawn_count: break 
			var road_len = road.get_curve().get_baked_length()
			var spot_on_road = road_len - wanted_space * itteration
			if spot_on_road > wanted_space:
				Car.new_car(road, spot_on_road, wanted_space, 10)
				spawned_cars += 1
		if spawned_cars_before == spawned_cars or spawned_cars >= car_spawn_count:
			break
		itteration += 1
	print("Spawned cars: %s" % spawned_cars)
	return

@export var point_distance: float = 0.2
func find_divering_paths():
	for road in roads:
		var roadpoints = road.get_curve().get_baked_points()
		if roadpoints.size() < 0: 
			print(road.get_name()) # For debug / removal of occuring names
			continue

		var roadpoint1 = road.to_global(roadpoints[0])
		for rod in roads:
			if rod == road: continue
			var rodpoints = rod.get_curve().get_baked_points()
			if rodpoints.size() > 0:
				var rodpoint1 = rod.to_global(rodpoints[0])
				var distance = (rodpoint1 - roadpoint1).length()
				if road.get_parent().get_name() == "Roads" and distance < point_distance:
					var DivPath = Node3D.new()
					add_child(DivPath)
					DivPath.add_to_group("div_path")
					rod.reparent(DivPath)
					road.reparent(DivPath)
				else:
					rod.reparent(road.get_parent())

func assign_traffic_lights(light_timer, light_auto_start):
	var crossings = get_tree().get_nodes_in_group("TrafficLights")
	var script = load("res://scripts/TrafficLight.gd") 
	const lightsphere: PackedScene = preload("res://scenes/light.tscn")
	for n in crossings:
		var directions = n.get_children()
		for d in directions:
			# Used to get a dictoinary of crossings and their roads
			if crossings_dict.has(n):
				crossings_dict[n].append_array(d.get_children())
			else:
				crossings_dict[n] = d.get_children()

			var light = lightsphere.instantiate()
			d.add_child(light)
			light.position = ((d.get_child(0)).to_global(((d.get_child(0)).get_curve().get_baked_points()[0])) + Vector3(0, 5, 0))

		var timer = Timer.new()
		timer.autostart = light_auto_start 
		timer.wait_time = light_timer
		n.add_child(timer)
		n.set_script(script)
		n.set_process(true)
		n.call("start")
	Car.set_crossings_dict(crossings_dict)
