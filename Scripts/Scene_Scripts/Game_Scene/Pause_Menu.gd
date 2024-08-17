extends Panel
class_name Pause_Menu
#region VARIABLES
var gameVariables: Game_Variables
@export var gameScene: Game_Scene
#-------------------------------------------------------------------------------
@export var title: Label
@export var continuar: Button
@export var retry: Button
@export var options: Button
@export var goToTitle: Button
@export var quitGame: Button
#-------------------------------------------------------------------------------
var inOption: bool = false
#endregion
#-------------------------------------------------------------------------------
#region STATE MACHINE
func Start() -> void:
	gameVariables = get_node("/root/GameVariables")
	#-------------------------------------------------------------------------------
	SetAllButtons()
	OptionMenu_BackButton_Set()
	hide()
#-------------------------------------------------------------------------------
func _physics_process(_delta:float) -> void:
	if(inOption):
		return
	if(Input.is_action_just_pressed("input_Pause")):
		gameScene.PauseOff()
		gameVariables.CommonCanceled()
#endregion
#-------------------------------------------------------------------------------
#region BUTTON FUNCTIONS
func SetAllButtons() -> void:
	gameVariables.SetButton(continuar, gameVariables.CommonSelected, ContinueButton_Subited, AnyButton_Canceled)
	gameVariables.SetButton(retry, gameVariables.CommonSelected, RetryButton_Subited, AnyButton_Canceled)
	gameVariables.SetButton(options, gameVariables.CommonSelected, OptionButton_Subited, AnyButton_Canceled)
	gameVariables.SetButton(goToTitle, gameVariables.CommonSelected, GoToTitleButton_Subited, AnyButton_Canceled)
	gameVariables.SetButton(quitGame, gameVariables.CommonSelected, QuitGameButton_Subited, AnyButton_Canceled)
#-------------------------------------------------------------------------------
func ContinueButton_Subited() -> void:
	gameScene.PauseOff()
	gameVariables.CommonSubmited()
	#-------------------------------------------------------------------------------
func RetryButton_Subited() -> void:
	gameVariables.CommonSubmited()
	get_tree().reload_current_scene()
#-------------------------------------------------------------------------------
func OptionButton_Subited() -> void:
	gameScene.currentLayer.hide()
	inOption = true
	gameVariables.MoveToButton(gameVariables.optionMenu.back)
	gameVariables.optionMenu.show()
	gameVariables.CommonSubmited()
#-------------------------------------------------------------------------------
func GoToTitleButton_Subited() -> void:
	gameVariables.CommonSubmited()
	gameScene.GoToMainScene()
#-------------------------------------------------------------------------------
func QuitGameButton_Subited() -> void:
	gameVariables.CommonSubmited()
	get_tree().quit()
#-------------------------------------------------------------------------------
func AnyButton_Canceled(_event:InputEvent) -> void:
	if(_event.is_action_pressed(gameVariables.cancelInput)):
		gameVariables.MoveToButton(quitGame)
		gameVariables.CommonCanceled()
#endregion
#-------------------------------------------------------------------------------
#region OPTION MENU BACK BUTTON
func OptionMenu_BackButton_Set() -> void:
	gameVariables.DisconnectButton(gameVariables.optionMenu.back)
	gameVariables.SetButton(gameVariables.optionMenu.back,  gameVariables.CommonSelected, OptionMenu_BackButton_Subited, OptionMenu_BackButton_Canceled)
#-------------------------------------------------------------------------------
func OptionMenu_BackButton_Subited() -> void:
	OptionMenu_BackButton_Common()
	gameVariables.CommonSubmited()
#-------------------------------------------------------------------------------
func OptionMenu_BackButton_Canceled(_event:InputEvent) -> void:
	if(_event.is_action_pressed(gameVariables.cancelInput)):
		OptionMenu_BackButton_Common()
		gameVariables.CommonCanceled()
#-------------------------------------------------------------------------------
func OptionMenu_BackButton_Common() -> void:
	gameVariables.optionMenu.Save_OptionSaveData(gameVariables.optionMenu.optionSaveData)
	gameVariables.optionMenu.hide()
	gameScene.currentLayer.show()
	inOption = false
	gameVariables.MoveToButton(options)
#endregion
#-------------------------------------------------------------------------------
#region IDIOME FUNCTIONS
func SetIdiome():
	title.text = tr("pauseMenu_title")
	continuar.text = tr("pauseMenu_button0")
	retry.text = tr("pauseMenu_button1")
	options.text = tr("pauseMenu_button2")
	goToTitle.text = tr("pauseMenu_button3")
	quitGame.text = tr("pauseMenu_button4")
#endregion
