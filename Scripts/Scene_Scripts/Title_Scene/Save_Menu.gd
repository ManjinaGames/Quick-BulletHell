extends Control
class_name Save_Menu
#region VARIABLES
@export var titleScene: Title_Scene
var gameVariables: Game_Variables
#-------------------------------------------------------------------------------
@export var scrollContainer: ScrollContainer
@export var vBoxContainer: VBoxContainer
@export var button: Array[Button]
@export var back: Button
const buttonSize: Vector2 = Vector2(400, 150)
#endregion
#-------------------------------------------------------------------------------
#region STATE MACHINE
func Start() -> void:
	gameVariables = get_node("/root/GameVariables")
	#-------------------------------------------------------------------------------
	CreateSaveButtons()
	gameVariables.SetButton(back, gameVariables.CommonSelected, BackButton_Subited, BackButton_Canceled)
	hide()
#endregion
#-------------------------------------------------------------------------------
#region SAVE BUTTON FUNCTIONS
func CreateSaveButtons() ->void:
	ClearContainer()
	for _i in gameVariables.maxSave:
		var _b : Button = Button.new()
		_b.custom_minimum_size = buttonSize
		_b.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		gameVariables.SetButton(_b, gameVariables.CommonSelected, func():SaveButton_Subited(_i), AnyButton_Canceled)
		vBoxContainer.add_child(_b)
		button.append(_b)
#-------------------------------------------------------------------------------
func DeleteSaveButtons() -> void:
	for _b in button:
		_b.queue_free()
	button.clear()
	ClearContainer()
#-------------------------------------------------------------------------------
func ClearContainer():
	for _child in vBoxContainer.get_children():
		_child.queue_free()
#endregion
#-------------------------------------------------------------------------------
#region BUTTON FUNCTIONS
func SaveButton_Subited(_i:int) -> void:
	hide()
	#-------------------------------------------------------------------------------
	titleScene.saveMenu2.saveLabel.text = SetSaveText(_i)
	titleScene.saveMenu2.Set_SaveMenu2(_i)
	titleScene.saveMenu2.show()
	titleScene.saveMenu2.whatToDo_Menu.show()
	gameVariables.MoveToButton(titleScene.saveMenu2.start)
	gameVariables.CommonSubmited()
#-------------------------------------------------------------------------------
func AnyButton_Canceled() -> void:
	gameVariables.MoveToButton(back)
	gameVariables.CommonCanceled()
#-------------------------------------------------------------------------------
func BackButton_Subited() -> void:
	BackButton_Common()
	gameVariables.CommonSubmited()
#-------------------------------------------------------------------------------
func BackButton_Canceled() -> void:
	BackButton_Common()
	gameVariables.CommonCanceled()
#-------------------------------------------------------------------------------
func BackButton_Common() -> void:
	hide()
	gameVariables.MoveToButton(titleScene.titleMenu.button[0])
	titleScene.titleMenu.show()
#endregion
#-------------------------------------------------------------------------------
#region IDIOME FUNC
func SetIdiome():
	#title.text = "saveMenu_title"
	back.text = tr("optionMenu_back")
	pass
#-------------------------------------------------------------------------------
func SetSaveButtons() -> void:
	for _i in gameVariables.maxSave:
		button[_i].text = SetSaveText(_i)
#-------------------------------------------------------------------------------
func SetSaveText(_i:int) -> String:
	var _path: String = gameVariables.Get_SaveDataPath(_i)
	var _s:String
	if(ResourceLoader.exists(_path)):
		var _saveData: SaveData = load(_path) as SaveData
		var _player: int = _saveData.playerIndex
		var _difficulty: int = _saveData.difficultyIndex
		#-------------------------------------------------------------------------------
		_s = tr("saveMenu_save")+" N°"+str(_i)+"\n"
		_s += tr("playerMenu_button"+str(_saveData.playerIndex)) + " - "
		_s +=  tr("difficultyMenu_button"+str(_saveData.difficultyIndex)) + " - "
		_s += tr("stageMenu_button"+str(_saveData.stageIndex))+"\n"
		#-------------------------------------------------------------------------------
		_s += "-"
		for _j in _saveData.player[_player].difficulty[_difficulty].stage.size():
			_s += str(_saveData.player[_player].difficulty[_difficulty].stage[_j].mySTAGE_STATE)+"-"
	else:
		_s = SetEmptySaveText(_i)
	return _s 
#-------------------------------------------------------------------------------
func SetEmptySaveText(_i:int) -> String:
	var _s:String = tr("saveMenu_save")+" N°"+str(_i)+"\n"+tr("saveMenu_empty")
	return _s
#endregion
#-------------------------------------------------------------------------------
