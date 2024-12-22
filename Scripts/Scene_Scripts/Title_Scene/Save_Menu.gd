extends Control
class_name Save_Menu
#region VARIABLES
@export var titleScene: Title_Scene
var singleton: Singleton
#-------------------------------------------------------------------------------
@export var clipContainer: MarginContainer
@export var scrollContainer: ScrollContainer
@export var vBoxContainer: VBoxContainer
@export var button: Array[Button]
@export var back: Button
#endregion
#-------------------------------------------------------------------------------
#region STATE MACHINE
func Start() -> void:
	singleton = get_node("/root/singleton")
	#-------------------------------------------------------------------------------
	await CreateSaveButtons()
	singleton.SetButton(back, singleton.CommonSelected, BackButton_Subited, BackButton_Canceled)
	hide()
#endregion
#-------------------------------------------------------------------------------
#region SAVE BUTTON FUNCTIONS
func CreateSaveButtons() ->void:
	await clipContainer.resized
	ClearContainer()
	var _buttonSizeX: float = clipContainer.size.x
	var _buttonSizeY: float = GetContainer_ButtonSize_Y_Current()
	#print(_buttonSizeX)	#NOTA: Hice un print para saber por que los botones no se aliniaban.
	#print(_buttonSizeY)	#NOTA: Resulta que necesitaba un await para que las medidas se arreglaran.
	for _i in singleton.maxSave:
		var _b : Button = Button.new()
		_b.custom_minimum_size.x = _buttonSizeX
		_b.custom_minimum_size.y = _buttonSizeY
		if(singleton.useCustomButton):
			_b.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		singleton.SetButton(_b, singleton.CommonSelected, func():SaveButton_Subited(_i), AnyButton_Canceled)
		vBoxContainer.add_child(_b)
		button.append(_b)
#-------------------------------------------------------------------------------
func GetContainer_ButtonSize_X_Current(_clipContainer:MarginContainer, _vBoxContainer: VBoxContainer, _n: float) -> float:
	return GetContainer_ButtonSize_X(clipContainer, vBoxContainer, 1)
#-------------------------------------------------------------------------------
func GetContainer_ButtonSize_X(_clipContainer:MarginContainer, _vBoxContainer: VBoxContainer, _n: float) -> float:
	var _f: float
	#boton.x = [ClipContainer.x - n * separación.x]/n
	_f = (_clipContainer.size.x - _n* _vBoxContainer.get_theme_constant("separation")) / _n
	return _f
#-------------------------------------------------------------------------------
func GetContainer_ButtonSize_Y_Current() -> float:
	return GetContainer_ButtonSize_Y(clipContainer, vBoxContainer, 3)
#-------------------------------------------------------------------------------
func GetContainer_ButtonSize_Y(_clipContainer:MarginContainer, _vBoxContainer: VBoxContainer, _n: float) -> float:
	var _f: float
	#boton.y = [ClipContainer.y - n * separación.y]/n
	_f = (_clipContainer.size.y - _n* _vBoxContainer.get_theme_constant("separation")) / _n
	return _f
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
	singleton.MoveToButton(titleScene.saveMenu2.start)
	singleton.CommonSubmited()
#-------------------------------------------------------------------------------
func AnyButton_Canceled() -> void:
	singleton.MoveToButton(back)
	singleton.CommonCanceled()
#-------------------------------------------------------------------------------
func BackButton_Subited() -> void:
	BackButton_Common()
	singleton.CommonSubmited()
#-------------------------------------------------------------------------------
func BackButton_Canceled() -> void:
	BackButton_Common()
	singleton.CommonCanceled()
#-------------------------------------------------------------------------------
func BackButton_Common() -> void:
	hide()
	singleton.MoveToButton(titleScene.titleMenu.button[0])
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
	for _i in singleton.maxSave:
		button[_i].text = SetSaveText(_i)
#-------------------------------------------------------------------------------
func SetSaveText(_i:int) -> String:
	var _path: String = singleton.Get_SaveDataPath_Json(_i)
	var _s:String
	if(ResourceLoader.exists(_path)):
		var _saveData: Dictionary = singleton.Load_SaveData_Json(_i)
		var _playerIndex: String = str(_saveData["playerIndex"])
		var _difficultyIndex: String = str(_saveData["difficultyIndex"])
		#-------------------------------------------------------------------------------
		_s = tr("saveMenu_save")+" N°"+str(_i)+"\n"
		_s += tr("playerMenu_button"+str(_saveData["playerIndex"])) + " - "
		_s +=  tr("difficultyMenu_button"+str(_saveData["difficultyIndex"])) + " - "
		_s += tr("stageMenu_button"+str(_saveData["stageIndex"]))+"\n"
		#-------------------------------------------------------------------------------
		_s += "-"
		var _stage: Dictionary = _saveData["saveData"][_playerIndex][_difficultyIndex]
		for _j in _stage.size():
			_s += str(_stage[str(_j)]["value"])+"-"
	else:
		_s = SetEmptySaveText(_i)
	return _s 
#-------------------------------------------------------------------------------
func SetEmptySaveText(_i:int) -> String:
	var _s:String = tr("saveMenu_save")+" N°"+str(_i)+"\n"+tr("saveMenu_empty")
	return _s
#endregion
#-------------------------------------------------------------------------------
