extends Node

func execute_last() -> void:
	if get_children().empty():
		return
	var children: Array = get_children()
	children.back().execute()

func unexecute_last() -> void:
	var children: Array = get_children()
	if get_children().empty():
		return
	if ("connect" in children.back().name.to_lower() and
		"control" in children[children.size() - 2].name.to_lower()):
		unexecute_amount_backward(3)
	elif ("score" in children.back().name.to_lower() or
		"control" in children.back().name.to_lower() or
		"connect" in children.back().name.to_lower()):
		unexecute_amount_backward(2)
	else:
		children.back().unexecute()

func execute_all_forward() -> void:
	for child in get_children():
		child.execute()
		
func unexecute_all_forward() -> void:
	for child in get_children():
		child.unexecute()
		
func execute_all_backward() -> void:
	var children: Array = get_children()
	children.invert()
	for child in children:
		child.execute()
		
func unexecute_all_backward() -> void:
	var children: Array = get_children()	
	if children.empty():
		return
	children.invert()
	for child in children:
		child.unexecute()

func execute_amount_backward(amount: int) -> void:
	var children: Array = get_children()	
	if children.empty():
		return
	children.invert()
	for i in range(amount):
		children[i].execute()

func unexecute_amount_backward(amount: int) -> void:
	var children: Array = get_children()	
	if children.empty():
		return
	children.invert()
	for i in range(amount):
		children[i].unexecute()

func execute_amount_forward(amount: int) -> void:
	for i in range(amount):
		get_children()[i].execute()

func unexecute_amount_forward(amount: int) -> void:
	for i in range(amount):
		get_children()[i].unexecute()
		
