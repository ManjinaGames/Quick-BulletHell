extends Panel
class_name Market_Menu
#region VARIABLES
var gameVariables: Game_Variables
@export var gameScene: Game_Scene
@export var scrollContainer: ScrollContainer
#-------------------------------------------------------------------------------
@export var hBoxContainer: HBoxContainer
@export var card: Array[Button]
const buttonSize: Vector2 = Vector2(198, 250)
#endregion
#-------------------------------------------------------------------------------
#region STATE MACHINE
func Start():
	gameVariables = get_node("/root/GameVariables")
	hide()
#endregion
#-------------------------------------------------------------------------------
#region CREATE CARDS FUNCTIONS
func CreateCardButtons() ->void:
	ClearContainer()
	for _i in 30:
		var _b : Button = Button.new()
		_b.custom_minimum_size = buttonSize
		_b.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		gameVariables.SetButton(_b, gameVariables.CommonSelected, func():CardButton_Subited(_i), CardButton_Canceled)
		hBoxContainer.add_child(_b)
		card.append(_b)
#-------------------------------------------------------------------------------
func DeleteCardButtons() -> void:
	for _b in card:
		_b.queue_free()
	card.clear()
	ClearContainer()
#-------------------------------------------------------------------------------
func ClearContainer():
	for _child in hBoxContainer.get_children():
		_child.queue_free()
#endregion
#-------------------------------------------------------------------------------
#region BUTTON FUNCTIONS
func CardButton_Subited(_i:int) -> void:
	gameVariables.CommonSubmited()
	gameScene.endMoment.emit()
#-------------------------------------------------------------------------------
func CardButton_Canceled() -> void:
	gameVariables.MoveToFirstButton(card)
	gameVariables.CommonCanceled()
#endregion
#-------------------------------------------------------------------------------
