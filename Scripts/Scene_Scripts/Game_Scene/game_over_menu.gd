extends Panel
class_name GameOver_Menu
#region VARIABLES
var singleton: Singleton
@export var gameScene: Game_Scene
#-------------------------------------------------------------------------------
@export var title: Label
@export var retry: Button
@export var quit: Button
#endregion
#-------------------------------------------------------------------------------
#region STATE MACHINE
func Start() -> void:
	singleton = get_node("/root/singleton")
	#-------------------------------------------------------------------------------
	SetAllButtons()
	hide()
#endregion
#-------------------------------------------------------------------------------
#region Set Menu Buttons
func SetAllButtons() -> void:
	singleton.SetButton(retry, singleton.CommonSelected, RetryButton_Subited, AnyButton_Canceled)
	singleton.SetButton(quit, singleton.CommonSelected, GoToTitleButton_Subited, AnyButton_Canceled)
#-------------------------------------------------------------------------------
func RetryButton_Subited() -> void:
	singleton.CommonSubmited()
	get_tree().reload_current_scene()
#-------------------------------------------------------------------------------
func GoToTitleButton_Subited() -> void:
	singleton.CommonSubmited()
	gameScene.GoToMainScene()
#-------------------------------------------------------------------------------
func AnyButton_Canceled() -> void:
	singleton.MoveToButton(quit)
	singleton.CommonCanceled()
#endregion
