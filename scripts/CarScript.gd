class_name Car
extends PathFollow3D

# Collective varibles all instances can acces
const my_scene: PackedScene = preload("res://scenes/car.tscn")
static var CARS = []
static var ROAD_DICT
static var INV_ROAD_DICT
static var CROSSINGS_DICT

# Internal varibles for each car object
var max_speed: float
var speed: float
var current_road: Path3D
var current_roads = []
var cars_on_same_road = []
var closest_car = null
var wanted_space:float


# Called every frame. 'delta' is the elapsed time since the previous frame.
func update_car(delta: float) -> void:
	var current_road_length = current_road.get_curve().get_baked_length()

	var self_index = self.get_index()
	var shortest_distance:float = 1000
	if self_index <= 0: # Front runner on own road
		for first_road in current_roads:
			if first_road == current_road: continue
			if first_road.get_child_count() <= 0:
				continue
			var distance = first_road.get_child(-1).get_progress()
			if distance < shortest_distance:
				shortest_distance = distance + current_road_length
	else:
		shortest_distance = current_road.get_child(self_index - 1).get_progress()

	var current_distance = self.get_progress()
	var current_remaing_distance = current_road_length - current_distance
	var incoming_roads = INV_ROAD_DICT[current_roads[1]]
	var shortest_incoming:bool = true
	for iroad in incoming_roads:
		if iroad == current_road: continue
		if iroad.get_child_count() == 0: continue
		var hello = iroad.get_curve().get_baked_length() - iroad.get_child(0).get_progress()
		if hello < current_remaing_distance:
			shortest_incoming = false

	# Get information about next crossing
	var crossing_own_section = current_roads[1].get_parent()
	var crossing = crossing_own_section.get_parent()
	var is_light_green:bool = true
	var distance_to_crossing = current_road_length - self.get_progress()
	
	# Determine if next crossing contains cars on other paths
	var crossings_contains_invalid_cars:bool = false
	if crossing.is_in_group("TrafficLights"):
		for road in CROSSINGS_DICT[crossing]:
			if road in ROAD_DICT[current_road]: continue
			if road.get_child_count() != 0:
				crossings_contains_invalid_cars = true
				break

	# Determine if next traffic light is green
	if crossing.is_in_group("TrafficLights"):
		is_light_green = crossing.call("get_status", crossing_own_section)
	
	#=================================
	# Logic for speed settings
	#=================================
	# Stop for light crossing, given different conditions
	if (not is_light_green # If the crossing is red, hold back
	#or not shortest_incoming # If there is anyone in the crossing, that will intersect it # it shouldnt be neccesary due to next line
	or crossings_contains_invalid_cars): # if there is cars in the crossing
		slow_down(delta)

	elif (shortest_distance - self.get_progress() < wanted_space * 2 and shortest_distance - self.get_progress() > wanted_space and self.speed > 2):
		self.speed = self.speed -0.2


	elif shortest_distance - self.get_progress() < wanted_space:
		if self.speed > 1.5:
			self.speed *= 0.6*delta
		elif self.speed <= 1:
			self.speed = 0

	else:
		if self.speed < 1:
			self.speed = 1
		elif self.speed > self.max_speed:
			self.speed += 6*delta
		else:
			self.speed = self.max_speed

	# Update distance on road
	self.set_progress(self.get_progress() + speed * delta)

	# Change to next segment of road, at the end
	if self.get_progress_ratio() >= 0.99:
		change_road(ROAD_DICT[current_road].pick_random())
	return

var de_acceleration # def = [0.9, 0.1] # First part of acceleration is multiplier and second is constant aswell as the minimum value before flatlining zero
func de_acceleration_curve(delta:float, x:float):
	var new_speed = x * de_acceleration[0] + de_acceleration[1]
	if new_speed >= de_acceleration[1]:
		return new_speed
	else:
		return 0

func slow_down(delta:float):
	
	
	return 

var acceleration # def = [1.1, 0.1] # First part of acceleration is multiplier and second is constant
func acceleration_curve(delta:float, x:float) -> float:
	var new_speed = x * acceleration[0] + acceleration[1]
	if new_speed <= max_speed:
		return new_speed
	else:
		return max_speed

func speed_up(delta:float):
	
	
	return 

func change_road(new_road:Path3D):
	self.reparent(new_road)
	self.set_progress_ratio(0)
	current_road = new_road

	cars_on_same_road = []
	current_roads = []
	current_roads.append(new_road)
	current_roads.append_array(ROAD_DICT[new_road])
	
	for road in current_roads:
		var road_children = road.get_children() 
		cars_on_same_road.append_array(road_children)

	return

# Intializer for new car objects/nodes
static func new_car(road_:Path3D, starting_offset_:float = 0, wanted_space_:float = 2, 
max_speed_:float = 0, acceleration_ = [1.1, 0.1], de_acceleration_: = [0.9, 0.1]) -> Car:
	var new_car_: Car = my_scene.instantiate()
	road_.add_child(new_car_)
	new_car_.current_road = road_
	new_car_.change_road(road_)
	
	new_car_.set_progress(starting_offset_) 
	
	new_car_.wanted_space = wanted_space_
	
	if (max_speed_ == 0):
		new_car_.max_speed = randf_range(5, 15)
	else:
		new_car_.max_speed = max_speed_
	new_car_.speed = new_car_.max_speed
	
	new_car_.acceleration = acceleration_
	new_car_.de_acceleration = de_acceleration_
	
	new_car_.loop = false
	
	CARS.append(new_car_)
	return new_car_

# Import road dictionaries from road baker
static func set_baked_roads(road_dict, inv_road_dict) -> void:
	ROAD_DICT = road_dict
	INV_ROAD_DICT = inv_road_dict
	return

static func set_crossings_dict(crossings_dict):
	CROSSINGS_DICT = crossings_dict
	return
