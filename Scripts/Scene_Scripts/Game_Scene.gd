extends Node
class_name Game_Scene
#-------------------------------------------------------------------------------
enum GAME_STATE{IN_GAMEPLAY, IN_CUTIN, IN_MARKET, IN_OPTION_MENU, IN_DIALOGUE, IN_GAMEOVER}
#region VARIABLES
var singleton: Singleton
#-------------------------------------------------------------------------------
var myGAME_STATE: GAME_STATE = GAME_STATE.IN_GAMEPLAY
var inPause: bool = false
#-------------------------------------------------------------------------------
@export var currentLayer: CanvasLayer
@export var pauseMenu: Pause_Menu
@export var gameoverMenu: GameOver_Menu
@export var marketMenu: Market_Menu
@export var dialogueMenu: Dialogue_Menu
#-------------------------------------------------------------------------------
@export var timerLabel: Label
var timer: int
var difficulty: float
@export var content: Control
@export var player: Player
var cardInventory: Dictionary[CardResource, int]
@export var playerExplotion: PackedScene
#-------------------------------------------------------------------------------
@export var enemy_Prefab: PackedScene
@export var bullet_Prefab: PackedScene
var bulletDictionary: Dictionary[String, BulletResource]
@export var bulletDictionary_Path: String = "res://Resources/Bullets/"
var maxColor: int = 15
@export var item_Prefab: PackedScene
#-------------------------------------------------------------------------------
@export var difficultyLabel: Label
@export var maxScoreLabel_title: RichTextLabel
@export var maxScoreLabel_Num: RichTextLabel
@export var scoreLabel_title: RichTextLabel
@export var scoreLabel_Num: RichTextLabel
@export var powerLabel_title: RichTextLabel
@export var powerLabel_Num: RichTextLabel
@export var livesLabel_title: RichTextLabel
@export var livesLabel_Num: RichTextLabel
@export var moneyLabel_title: RichTextLabel
@export var moneyLabel_Num: RichTextLabel
@export var maxMoneyLabel_Num: RichTextLabel
@export var leftLabel: RichTextLabel
#-------------------------------------------------------------------------------
@export var completedPanel: PanelContainer
@export var completedLabel: Label
#-------------------------------------------------------------------------------
var enemyBullets_Enabled_Array: Array[Bullet]
var enemyBullets_Disabled_Array: Array[Bullet]
#-------------------------------------------------------------------------------
var playerBullets_Enabled_Array: Array[Bullet]
var playerBullets_Disabled_Array: Array[Bullet]
#-------------------------------------------------------------------------------
var items_Enabled_Array: Array[Item]
var items_Disabled_Array: Array[Item]
#-------------------------------------------------------------------------------
var tween_Array: Array[Tween]
#-------------------------------------------------------------------------------
@export_flags_2d_physics var playerLayer: int
@export_flags_2d_physics var grazeLayer: int
@export_flags_2d_physics var magnetLayer: int
@export_flags_2d_physics var enemyLayer: int
#-------------------------------------------------------------------------------
var height: float
var width: float
#-------------------------------------------------------------------------------
var playerLimitsX: Vector2
var playerLimitsY: Vector2
#-------------------------------------------------------------------------------
var enemyLimitsX: Vector2
var enemyLimitsY: Vector2
#-------------------------------------------------------------------------------
var bossStartingPosition: Vector2
#-------------------------------------------------------------------------------
var lifePoints: int
var powerPoints: int
var moneyPoints: int
var scorePoints: int
#-------------------------------------------------------------------------------
var deltaTimeScale: float = 1
#endregion
#-------------------------------------------------------------------------------
#region MONOVEHAVIOUR
func _ready():
	singleton = get_node("/root/singleton")
	#-------------------------------------------------------------------------------
	pauseMenu.Start()
	gameoverMenu.Start()
	marketMenu.Start()
	dialogueMenu.Start()
	#-------------------------------------------------------------------------------
	SetIdiome()
	#-------------------------------------------------------------------------------
	singleton.PlayBGM(singleton.bgmStage1)
	get_tree().set_deferred("paused", false)
	currentLayer.show()
	await BeginGame()
#-------------------------------------------------------------------------------
func _physics_process(_delta:float) -> void:
	deltaTimeScale = Engine.time_scale
	tween_Array = get_tree().get_processed_tweens()
	Debug_Information()
	#-------------------------------------------------------------------------------
	for _i in enemyBullets_Enabled_Array.size():
		enemyBullets_Enabled_Array[_i].physics_Update.call()
	#-------------------------------------------------------------------------------
	for _i in playerBullets_Enabled_Array.size():
		playerBullets_Enabled_Array[_i].physics_Update.call()
	#-------------------------------------------------------------------------------
	for _i in items_Enabled_Array.size():
		items_Enabled_Array[_i].physics_Update.call()
	#-------------------------------------------------------------------------------
	match(myGAME_STATE):
		GAME_STATE.IN_GAMEPLAY:
			PlayerMovement()
			PauseGame()
			return
		#-------------------------------------------------------------------------------
		GAME_STATE.IN_CUTIN:
			PlayerMovement()
			PauseGame()
			return
		#-------------------------------------------------------------------------------
		GAME_STATE.IN_MARKET:
			pass
		#-------------------------------------------------------------------------------
		GAME_STATE.IN_OPTION_MENU:
			pass
		#-------------------------------------------------------------------------------
		GAME_STATE.IN_DIALOGUE:
			PlayerMovement()
			if(Input.is_action_just_pressed("input_Shoot")):
				dialogueMenu.isNextPress = true
		#-------------------------------------------------------------------------------
		GAME_STATE.IN_GAMEOVER:
			pass
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
#region PLAYER FUNCTIONS
func PlayerMovement() -> void:
	if(player.myPLAYER_STATE == Player.PLAYER_STATE.DEATH):
		return
	#-------------------------------------------------------------------------------
	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if(input_dir != Vector2.ZERO):
		input_dir.normalized()
		var myPosition: Vector2 = player.position
		if(Input.is_action_pressed("input_Focus")):
			myPosition += input_dir * player.playerResource.focusSpeed * deltaTimeScale
		#-------------------------------------------------------------------------------
		else:
			myPosition += input_dir * player.playerResource.normalSpeed * deltaTimeScale
		#-------------------------------------------------------------------------------
		myPosition.x = clampf(myPosition.x, playerLimitsX.x, playerLimitsX.y)
		myPosition.y = clampf(myPosition.y, playerLimitsY.x, playerLimitsY.y)
		player.position = myPosition
	#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
#region PAUSE INPUTS
func PauseGame() -> void:
	if(myGAME_STATE == GAME_STATE.IN_GAMEOVER):
		return
	#-------------------------------------------------------------------------------
	if(Input.is_action_just_pressed("input_Pause")):
		pauseMenu.show()
		StopTime()
		singleton.MoveToButton(pauseMenu.continuar)
#-------------------------------------------------------------------------------
func StopTime():
	singleton.playPosition = singleton.bgmPlayer.get_playback_position()
	singleton.bgmPlayer.stop()
	get_tree().set_deferred("paused", true)
#-------------------------------------------------------------------------------
func PauseOff():
	pauseMenu.hide()
	myGAME_STATE = GAME_STATE.IN_GAMEPLAY
	get_tree().set_deferred("paused", false)
	singleton.bgmPlayer.play(singleton.playPosition)
#endregion
#-------------------------------------------------------------------------------
#region UI FINCTIONS
func SetGameLimits() -> void:
	await content.resized
	#-------------------------------------------------------------------------------
	height = content.size.y
	width = content.size.x
	#-------------------------------------------------------------------------------
	var _offSet: float = 10
	playerLimitsX = Vector2(_offSet, width-_offSet)
	playerLimitsY = Vector2(_offSet, height-_offSet)
	#-------------------------------------------------------------------------------
	enemyLimitsX = Vector2(width*-0.1, width*1.1)
	enemyLimitsY = Vector2(height*-0.5, height*1.1)
	#-------------------------------------------------------------------------------
	bossStartingPosition = Vector2(width*0.5, height*0.25)
#-------------------------------------------------------------------------------
func Debug_Information() -> void:
	var _s: String = ""
	_s += "-------------------------------------------------------\n"
	_s += "Enemy Bullets Enabled: " + str(enemyBullets_Enabled_Array.size())+"\n"
	_s += "Enemy Bullets Disabled: " + str(enemyBullets_Disabled_Array.size())+"\n"
	_s += "-------------------------------------------------------\n"
	_s += "Player Bullets Enabled: " + str(playerBullets_Enabled_Array.size())+"\n"
	_s += "Player Bullets Disabled: " + str(playerBullets_Disabled_Array.size())+"\n"
	_s += "-------------------------------------------------------\n"
	_s += "Items Enabled: " + str(items_Enabled_Array.size())+"\n"
	_s += "Items Disabled: " + str(items_Disabled_Array.size())+"\n"
	_s += "-------------------------------------------------------\n"
	_s += "Tweens: "+str(tween_Array.size())+"\n"
	_s += "-------------------------------------------------------\n"
	_s += "GAME_STATE." + GAME_STATE.keys()[myGAME_STATE]+"\n"
	_s += "PLAYER_STATE." + Player.PLAYER_STATE.keys()[player.myPLAYER_STATE]+"\n"
	_s += "-------------------------------------------------------\n"
	leftLabel.text = _s
#-------------------------------------------------------------------------------
func SetScore() -> void:
	var _s: String = str(scorePoints).pad_zeros(9)
	_s = _s.insert(_s.length()-3,",")
	_s = _s.insert(_s.length()-7,",")
	scoreLabel_Num.text = "[center]"+_s+"[/center]"
#-------------------------------------------------------------------------------
func SetInfoText_Life() -> void:
	livesLabel_Num.text = GetInfoText_LifePower(lifePoints, player.playerResource.maxLives)
#-------------------------------------------------------------------------------
func SetInfoText_Power() -> void:
	powerLabel_Num.text = GetInfoText_LifePower(powerPoints, player.playerResource.maxPower)
#-------------------------------------------------------------------------------
func GetInfoText_LifePower(_point:int, _maxPoint:int) -> String:
	var _s: String = "[center]"+str(_point).pad_zeros(2)+" / "+str(_maxPoint).pad_zeros(2)+"[/center]"
	return _s
#-------------------------------------------------------------------------------
func SetInfoText_Death():
	livesLabel_Num.text = "[center]"+"  --"+" / "+str(player.playerResource.maxLives).pad_zeros(2)+"[/center]"
#-------------------------------------------------------------------------------
func SetMoney() -> void:
	moneyLabel_Num.text = "[center]"+str(moneyPoints)+" G[/center]"
	#-------------------------------------------------------------------------------
func SetMaxMoney() -> void:
	maxMoneyLabel_Num.text = "[center]"+str(player.playerResource.maxMoney)+" G[/center]"
#endregion
#-------------------------------------------------------------------------------
#region START FUNCTIONS
func BeginGame() -> void:
	var _difficulty: int = singleton.currentSaveData_Json.get("difficultyIndex", 0)
	difficulty = float(_difficulty)
	difficultyLabel.text = tr("difficultyMenu_button"+str(_difficulty))
	#-------------------------------------------------------------------------------
	await SetGameLimits()
	player.SetPlayer(singleton.Copy_CurrentPlayer())
	#-------------------------------------------------------------------------------
	SetScore()
	SetMoney()
	SetMaxMoney()
	lifePoints = int(float(player.playerResource.maxLives)*1)
	SetInfoText_Life()
	powerPoints = int(float(player.playerResource.maxPower)*1)
	SetInfoText_Power()
	#-------------------------------------------------------------------------------
	completedPanel.hide()
	completedLabel.text = ""
	timerLabel.text = ""
	#-------------------------------------------------------------------------------
	player.position = Vector2(width*0.5, height*0.85)
	player.myPLAYER_STATE = Player.PLAYER_STATE.ALIVE
	myGAME_STATE = GAME_STATE.IN_GAMEPLAY
	cardInventory = {}
	#-------------------------------------------------------------------------------
	Load_EnemyBullets_Disabled_Array(3000)
	Load_PlayerBullets_Disabled_Array(100)
	Load_Items_Disabled_Array(200)
	Load_Items_Enabled_Array(1)
	#-------------------------------------------------------------------------------
	LoadBulletDatabase()
#-------------------------------------------------------------------------------
func LoadBulletDatabase():
	bulletDictionary.clear()
	#-------------------------------------------------------------------------------
	var dir_array = DirAccess.get_files_at(bulletDictionary_Path)
	if(dir_array):
		for _i in dir_array.size():
			var _base_name: String = dir_array[_i].get_slice(".",0)
			var _bulletResource: BulletResource = load(bulletDictionary_Path+"/"+_base_name+".tres") as BulletResource
			bulletDictionary[_base_name] = _bulletResource
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
#region STAGE FUNCTIONS COMMON
#-------------------------------------------------------------------------------
func EnableStage(_i:int):
	var _playerIndex: StringName = str(int(singleton.currentSaveData_Json["playerIndex"]))
	var _difficultyIndex: StringName = str(int(singleton.currentSaveData_Json["difficultyIndex"]))
	if(singleton.currentSaveData_Json["saveData"][_playerIndex][_difficultyIndex][str(_i)]["value"] == singleton.STAGE_STATE.DISABLED):
		singleton.currentSaveData_Json["saveData"][_playerIndex][_difficultyIndex][str(_i)]["value"] = singleton.STAGE_STATE.ENABLED
#-------------------------------------------------------------------------------
func CompletedStage(_i:int):
	var _playerIndex: StringName = str(int(singleton.currentSaveData_Json["playerIndex"]))
	var _difficultyIndex: StringName = str(int(singleton.currentSaveData_Json["difficultyIndex"]))
	singleton.currentSaveData_Json["saveData"][_playerIndex][_difficultyIndex][str(_i)]["value"] = singleton.STAGE_STATE.COMPLETED
#-------------------------------------------------------------------------------
func GoToMainScene():
	singleton.PlayBGM(singleton.bgmTitle)
	get_tree().set_deferred("paused", false)
	get_tree().change_scene_to_file(singleton.mainScene_Path)
#endregion
#-------------------------------------------------------------------------------
func Load_EnemyBullets_Disabled_Array(_iMax:int):
	for _i in _iMax:
		var _bullet: Bullet = bullet_Prefab.instantiate() as Bullet
		enemyBullets_Disabled_Array.append(_bullet)
		_bullet.hide()
		content.add_child(_bullet)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Load_PlayerBullets_Disabled_Array(_iMax:int):
	for _i in _iMax:
		var _bullet: Bullet = bullet_Prefab.instantiate() as Bullet
		playerBullets_Disabled_Array.append(_bullet)
		_bullet.hide()
		content.add_child(_bullet)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Load_Items_Disabled_Array(_iMax:int):
	for _i in _iMax:
		var _item: Item = item_Prefab.instantiate() as Item
		items_Disabled_Array.append(_item)
		_item.physics_Update = func(): Items_Physics_Update(_item)
		_item.hide()
		content.add_child(_item)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Load_Items_Enabled_Array(_iMax:int):
	for _i in _iMax:
		var _item: Item = item_Prefab.instantiate() as Item
		_item.physics_Update = func(): Items_Physics_Update(_item)
		items_Enabled_Array.append(_item)
		_item.show()
		_item.velocity = Vector2(0, -5)
		_item.position = Vector2(width*0.5, height*0.5)
		content.add_child(_item)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Items_Physics_Update(_item:Item):
	var _maxVelY: float = 3.0
	var _magnetVel: float = 8.0
	match(_item.myITEM_STATE):
		Item.ITEM_STATE.SPIN:
			if(_item.velocity.y <= 0):
				ItemMovement_Fall(_item, _maxVelY)
				_item.rotation += 0.5 * deltaTimeScale
			#-------------------------------------------------------------------------------
			else:
				_item.rotation = 0
				_item.myITEM_STATE = Item.ITEM_STATE.FALL
				return
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
		Item.ITEM_STATE.FALL:
			if(_item.position.y <= height):
				ItemMovement_Fall(_item, _maxVelY)
				#-------------------------------------------------------------------------------
				if(_item.position.distance_to(player.position)< 96.0 and player.myPLAYER_STATE != Player.PLAYER_STATE.DEATH):
					_item.myITEM_STATE = Item.ITEM_STATE.IMANTED
					return
				#-------------------------------------------------------------------------------
				elif(!CanPlayerShoot() and player.myPLAYER_STATE != Player.PLAYER_STATE.DEATH):
					_item.myITEM_STATE = Item.ITEM_STATE.IMANTED
					return
				#-------------------------------------------------------------------------------
			#-------------------------------------------------------------------------------
			else:
				DestroyItem(_item)
				return
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
		Item.ITEM_STATE.IMANTED:
			var _vel: Vector2 = (player.position - _item.position)
			if(_vel.length_squared() > 144.0):
				var _dir = atan2(_vel.y, _vel.x)
				var _vel2 = Vector2(cos(_dir), sin(_dir))
				_item.position += _vel2 * _magnetVel * deltaTimeScale
			#-------------------------------------------------------------------------------
			else:
				scorePoints += 10
				moneyPoints += 1
				SetScore()
				SetMoney()
				DestroyItem(_item)
				return
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func ItemMovement_Fall(_item:Item, _maxVelY:float):
	if(_item.velocity.y > _maxVelY):
		_item.velocity.y = _maxVelY
	#-------------------------------------------------------------------------------
	elif(_item.velocity.y < _maxVelY):
		_item.velocity.y += 0.05 * deltaTimeScale
	#-------------------------------------------------------------------------------
	_item.position.y += _item.velocity.y * deltaTimeScale
#-------------------------------------------------------------------------------
func DestroyItem(_item:Item) -> void:
	_item.hide()
	items_Enabled_Array.erase(_item)
	items_Disabled_Array.append(_item)
#-------------------------------------------------------------------------------
func CanPlayerShoot() -> bool:
	if(myGAME_STATE == GAME_STATE.IN_GAMEPLAY or myGAME_STATE == GAME_STATE.IN_CUTIN):
		return true
	else:
		return false
#region IDIOME FUNCTIONS
func SetIdiome():
	singleton.DisconnectAll(singleton.optionMenu.idiomeChange)
	#-------------------------------------------------------------------------------
	singleton.optionMenu.idiomeChange.connect(pauseMenu.SetIdiome)
	singleton.optionMenu.idiomeChange.connect(SetIdiome2)
	#-------------------------------------------------------------------------------
	pauseMenu.SetIdiome()
	SetIdiome2()
#-------------------------------------------------------------------------------
func SetIdiome2():
	maxScoreLabel_title.text = "[u]"+tr("gameUI_maxScore")+":[/u]"
	scoreLabel_title.text = "[u]"+tr("gameUI_score")+":[/u]"
	livesLabel_title.text = "[u]"+tr("gameUI_lives")+":[/u]"
	powerLabel_title.text = "[u]"+tr("gameUI_power")+":[/u]"
#endregion
#-------------------------------------------------------------------------------
