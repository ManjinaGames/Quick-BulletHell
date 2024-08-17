extends Control
class_name Option_Menu
#region VARIABLES
#-------------------------------------------------------------------------------
@export var gameVariables: Game_Variables
#-------------------------------------------------------------------------------
@export var title : Label
@export var idiome : Option_OptionButton
signal idiomeChange
@export var resolution : Option_OptionButton
@export var vsync : Option_CheckButton
@export var master : Option_Slider
@export var sfx : Option_Slider
@export var bgm : Option_Slider
@export var back : Button
#-------------------------------------------------------------------------------
const optionSaveData_name : String = "optionSaveData.tres"
const optionSaveData_path : String = "user://Options/"
var optionSaveData : OptionSaveData;
#-------------------------------------------------------------------------------
var bus_master_Index: int = AudioServer.get_bus_index("Master")
var bus_sfx_Index: int = AudioServer.get_bus_index("sfx")
var bus_bgm_Index: int = AudioServer.get_bus_index("bgm")
#-------------------------------------------------------------------------------
const resolution_dictionary : Dictionary = {
	"1920 x 1080": Vector2i(1920, 1080),
	"1600 x 900": Vector2i(1600, 900),
	"1366 x 768": Vector2i(1366, 768),
	"1280 x 720": Vector2i(1280, 720),
	"1024 x 576": Vector2i(1024, 576),
	"960 x 540": Vector2i(960, 540),
	"854 x 480": Vector2i(854, 480),
	"640 x 360": Vector2i(640 , 360)
}
#endregion
#-------------------------------------------------------------------------------
#region MONOVEHAVIOUR
func Start() -> void:
	#SetTheme()
	optionSaveData = Load_OptionSaveData()
	#-------------------------------------------------------------------------------
	SetResolution_Start()
	SetIdiome_Start()
	SetVsync_Start()
	#-------------------------------------------------------------------------------
	SetValume_Start(master.slider, master.number, MasterSlider_Submit, bus_master_Index, optionSaveData.masterVolumen)
	SetValume_Start(sfx.slider, sfx.number, sfxSlider_Submit, bus_sfx_Index, optionSaveData.sfxVolumen)
	SetValume_Start(bgm.slider, bgm.number, bgmSlider_Submit, bus_bgm_Index, optionSaveData.bgmVolumen)
	#-------------------------------------------------------------------------------
	hide()
#endregion
#-------------------------------------------------------------------------------
#region OPTION SAVE SYSTEM
func Save_OptionSaveData(_osd:OptionSaveData) -> void:
	DirAccess.make_dir_absolute(optionSaveData_path)
	ResourceSaver.save(_osd, GetPath_OptionSaveData())
#-------------------------------------------------------------------------------
func Load_OptionSaveData() -> OptionSaveData:
	var _path:String = GetPath_OptionSaveData()
	if(ResourceLoader.exists(_path)):
		return load(_path) as OptionSaveData
	else:
		var _optionSaveData: OptionSaveData = OptionSaveData.new()
		return _optionSaveData
#-------------------------------------------------------------------------------
func Delete_OptionSaveData() -> void:
	var _path: String = GetPath_OptionSaveData()
	if(ResourceLoader.exists(_path)):
		DirAccess.remove_absolute(_path)
#-------------------------------------------------------------------------------
func GetPath_OptionSaveData() -> String:
	var _path: String = optionSaveData_path+optionSaveData_name
	return _path
#endregion
#-------------------------------------------------------------------------------
#region RESOLUTION SETTINGS
func SetResolution_Start():
	SetResolution(optionSaveData.resolutionIndex)
	AddResolutionOptions(resolution.optionButton, resolution_dictionary)
	resolution.optionButton.select(optionSaveData.resolutionIndex)
	gameVariables.SetOptionButtons(resolution.optionButton, gameVariables.CommonSelected, ResolutionButton_Submited, AnyButton_Cancel)
#-------------------------------------------------------------------------------
func AddResolutionOptions(_ob:OptionButton, _dictionary:Dictionary) -> void:
	_ob.clear()
	_ob.add_item(tr("optionMenu_fullScreen"))
	for i in _dictionary:
		_ob.add_item(i)
#-------------------------------------------------------------------------------
func ResolutionButton_Submited(_index:int) -> void:
	gameVariables.CommonSubmited()
	optionSaveData.resolutionIndex = _index
	SetResolution(_index)
#-------------------------------------------------------------------------------
func SetResolution(_index:int) -> void:
	_index = clamp(_index, 0, resolution_dictionary.size())
	if(_index == 0):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(resolution_dictionary.values()[_index-1])
		var _center: Vector2i = (DisplayServer.screen_get_size()-DisplayServer.window_get_size())/2
		DisplayServer.window_set_position(_center)
#endregion
#-------------------------------------------------------------------------------
#region IDIOME SETTINGS
func SetIdiome_Start():
	SetIdiome(optionSaveData.idiomeIndex)
	AddIdiomeButtons(idiome.optionButton)
	idiome.optionButton.select(optionSaveData.idiomeIndex)
	gameVariables.SetOptionButtons(idiome.optionButton, gameVariables.CommonSelected, IdiomeButton_Submited, AnyButton_Cancel)
#-------------------------------------------------------------------------------
func AddIdiomeButtons(_ob:OptionButton) -> void:
	var _idiomes:PackedStringArray = TranslationServer.get_loaded_locales()
	for _i in _idiomes.size():
		_ob.add_item(TranslationServer.get_locale_name(_idiomes[_i]))
#-------------------------------------------------------------------------------
func IdiomeButton_Submited(_index:int):
	optionSaveData.idiomeIndex = _index
	SetIdiome(_index)
	idiomeChange.emit()
	gameVariables.CommonSubmited()
#-------------------------------------------------------------------------------
func SetIdiome(_index:int):
	var _idiomes:PackedStringArray = TranslationServer.get_loaded_locales()
	TranslationServer.set_locale(_idiomes[_index])
	#-------------------------------------------------------------------------------
	AddResolutionOptions(resolution.optionButton, resolution_dictionary)
	resolution.optionButton.select(optionSaveData.resolutionIndex)
	#-------------------------------------------------------------------------------
	title.text = tr("optionMenu_title")
	idiome.title.text = tr("optionMenu_idiome")
	resolution.title.text = tr("optionMenu_resolution")
	master.title.text = tr("optionMenu_master")
	back.text = tr("optionMenu_back")
#endregion
#-------------------------------------------------------------------------------
#region VSYNC SETTINGS
func SetVsync_Start():
	SetVsync(optionSaveData.vsync)
	vsync.checkButton.button_pressed = optionSaveData.vsync
	gameVariables.SetCheckButton(vsync.checkButton, gameVariables.CommonSelected, VsyncButton_Submited, AnyButton_Cancel)
#-------------------------------------------------------------------------------
func VsyncButton_Submited(_b:bool) -> void:
	gameVariables.CommonSubmited()
	optionSaveData.vsync = _b
	SetVsync(_b)
#-------------------------------------------------------------------------------
func SetVsync(_b: bool) -> void:
	if(_b):
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
#endregion
#-------------------------------------------------------------------------------
#region VOLUME SETTINGS
func SetValume_Start(_slider: Slider, _label: Label, _submit: Callable, _index:int, _value:float):
	SetValume(_label, _index, _value)
	_slider.value = db_to_linear(AudioServer.get_bus_volume_db(_index))
	gameVariables.SetSlider(_slider, gameVariables.CommonSelected, _submit, AnyButton_Cancel)
#-------------------------------------------------------------------------------
func MasterSlider_Submit(_value:float) -> void:
	gameVariables.CommonSubmited()
	optionSaveData.masterVolumen = _value
	SetValume(master.number, bus_master_Index, _value)
	pass
#-------------------------------------------------------------------------------
func sfxSlider_Submit(_value:float) -> void:
	gameVariables.CommonSubmited()
	optionSaveData.sfxVolumen = _value
	SetValume(sfx.number, bus_sfx_Index, _value)
#-------------------------------------------------------------------------------
func bgmSlider_Submit(_value:float) -> void:
	gameVariables.CommonSubmited()
	optionSaveData.bgmVolumen = _value
	SetValume(bgm.number, bus_bgm_Index, _value)
#-------------------------------------------------------------------------------
func SetValume(_label: Label, _index:int, _value:float):
	_label.text = str(_value*100)+"%"
	AudioServer.set_bus_volume_db(_index, linear_to_db(_value))
#endregion
#-------------------------------------------------------------------------------
#region BUTTON FUNCTIONS
func AnyButton_Cancel(_event:InputEvent) -> void:
	if(_event.is_action_pressed(gameVariables.cancelInput)):
		gameVariables.MoveToButton(back)
		gameVariables.CommonCanceled()
#endregion
#-------------------------------------------------------------------------------
#region MISC
func SetTheme():
	idiome.optionButton.theme = gameVariables.myTheme
	resolution.optionButton.theme = gameVariables.myTheme
	#-------------------------------------------------------------------------------
	#vsync.theme = gameVariables.myTheme
	#-------------------------------------------------------------------------------
	master.label.theme = gameVariables.myTheme
	sfx.label.theme = gameVariables.myTheme
	bgm.label.theme = gameVariables.myTheme
	#-------------------------------------------------------------------------------
	back.theme = gameVariables.myTheme
#endregion
#-------------------------------------------------------------------------------
