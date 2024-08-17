extends Panel
class_name Market_Menu
#region VARIABLES
var gameVariables: Game_Variables
@export var gameScene: Game_Scene
@export var scrollContainer: ScrollContainer
#-------------------------------------------------------------------------------
@export var close: Button
#endregion
#-------------------------------------------------------------------------------
#region STATE MACHINE
func Start():
	gameVariables = get_node("/root/GameVariables")
	SetAllButtons()
	hide()
#endregion
#-------------------------------------------------------------------------------
#region BUTTON FUNCTIONS
func SetAllButtons() -> void:
	gameVariables.SetButton(close, gameVariables.CommonSelected, CloseButton_Subited, AnyButton_Canceled)
#-------------------------------------------------------------------------------
func CloseButton_Subited() -> void:
	gameVariables.CommonSubmited()
	hide()
	gameScene.myPLAY_STATE = gameScene.PLAY_STATE.IN_GAME
	gameScene.PlayerShoot()
	gameScene.endMoment.emit()
#-------------------------------------------------------------------------------
func AnyButton_Canceled(_event:InputEvent) -> void:
	if(_event.is_action_pressed(gameVariables.cancelInput)):
		gameVariables.MoveToButton(close)
		gameVariables.CommonCanceled()
#endregion
#-------------------------------------------------------------------------------
