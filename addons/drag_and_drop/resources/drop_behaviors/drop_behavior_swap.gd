class_name DropBehaviorSwap extends DropBehavior

func evaluate(zone: DropZone, dropped_area: Area2D) -> DropPlan:
	var plan := DropPlan.new()
	
	var draggable := find_draggable(dropped_area)
	var prev_zone : DropZone = null
	if draggable:
		prev_zone = find_drop_zone(draggable.previous_parent) as DropZone
	var spot : SnappingSpot = null
	if prev_zone:
		spot = DropUtils.closest_spot(prev_zone, dropped_area)
	
	var result := DropUtils.evaluate_drop_target(zone, dropped_area, false)
	if not result.can_drop:
		return plan
	plan.can_drop = true
	plan.drop_target = result.target
	
	if plan.drop_target and plan.drop_target.occupant and plan.drop_target.occupant != dropped_area:
		if spot:
			plan.actions.append(ActionRelocate.new(plan.drop_target.occupant, spot))
			prev_zone._attach(plan.drop_target.occupant)
		else:
			plan.can_drop = false 
	
	return plan

func find_drop_zone(node: Node) -> DropZone:
	for child in node.get_children():
		if child is DropZone:
			return child
	return null
	
func find_draggable(node: Node) -> Draggable:
	for child in node.get_children():
		if child is Draggable:
			return child
	return null
