extends Button
class_name PlayerButton
#region VARIABLES
@export var name_label: Label
@export var nickname_label: Label
#-------------------------------------------------------------------------------
@export var maxLives_value_label: Label
@export var maxPower_value_label: Label
@export var maxMoney_value_label: Label
#-------------------------------------------------------------------------------
@export var hitboxRad_value_label: Label
@export var grazeboxRad_value_label: Label
@export var magnetboxRad_value_label: Label
#-------------------------------------------------------------------------------
@export var normalSpeed_value_label: Label
@export var focusSpeed_value_label: Label
#-------------------------------------------------------------------------------
@export var description_label: Label
#-------------------------------------------------------------------------------
@export var picture: TextureRect
#endregion
#-------------------------------------------------------------------------------
#region FUNCTIONS
func SetPlayerButtonStats(_playerResource: PlayerResource):
	maxLives_value_label.text = str(_playerResource.maxLives)
	maxPower_value_label.text = str(_playerResource.maxPower)
	maxMoney_value_label.text = str(_playerResource.maxMoney)
	#-------------------------------------------------------------------------------
	hitboxRad_value_label.text = str(_playerResource.hitBox_Scale)
	grazeboxRad_value_label.text = str(_playerResource.grazeBox_Scale)
	magnetboxRad_value_label.text = str(_playerResource.magnetBox_Scale)
	#-------------------------------------------------------------------------------
	normalSpeed_value_label.text = str(_playerResource.normalSpeed)
	focusSpeed_value_label.text = str(_playerResource.focusSpeed)
	#-------------------------------------------------------------------------------
	picture.texture = _playerResource.picture
#endregion
#-------------------------------------------------------------------------------
