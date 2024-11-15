class_name TrafficLight
extends Node3D

var roads = [] #list of roads in crossing
var light_dic = {}
var current_light = 0
var material_green = StandardMaterial3D.new()
var material_red = StandardMaterial3D.new()#selects which road to let through

func start() -> void:
	material_green.albedo_color = Color(0,1,0)
	material_red.albedo_color = Color(1,0,0)
	var timer = get_child(-1)
	timer.timeout.connect(update_trafficlight)
	roads = get_children()
	roads.remove_at(roads.size()-1)
	for road in roads:
		light_dic[road] = false
		road.get_child(-1).get_child(0).set_surface_override_material(0, material_red)

func update_trafficlight():
	light_dic[roads[current_light]] = false
	roads[current_light].get_child(-1).get_child(0).set_surface_override_material(0, material_red)
	if current_light < len(roads)-1:
		current_light += 1
	else:
		current_light = 0
	light_dic[roads[current_light]] = true
	roads[current_light].get_child(-1).get_child(0).set_surface_override_material(0, material_green)

func get_status(node: Node3D) -> bool:
	return(light_dic[node])
