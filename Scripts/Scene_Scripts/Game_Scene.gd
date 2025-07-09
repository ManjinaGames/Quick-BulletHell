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
var isFocus: bool = false
var cardInventory: Dictionary[CardResource, int]
#-------------------------------------------------------------------------------
@export var enemy_Prefab: PackedScene
@export var bullet_Prefab: PackedScene
@export var item_Prefab: PackedScene
#-------------------------------------------------------------------------------
var bulletDictionary: Dictionary[String, BulletResource]
@export var bulletDictionary_Path: String = "res://Resources/Bullets/"
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
var enemy_Enabled_Array: Array[Enemy]
var enemy_Disabled_Array: Array[Enemy]
#-------------------------------------------------------------------------------
var playerBullets_Enabled_Array: Array[Bullet]
var playerBullets_Disabled_Array: Array[Bullet]
#-------------------------------------------------------------------------------
var items_Enabled_Array: Array[Item]
var items_Disabled_Array: Array[Item]
#-------------------------------------------------------------------------------
var tween_Array: Array[Tween]
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
#-------------------------------------------------------------------------------
var timer_tween: Tween
var main_tween_Array: Array[Tween]
var player_tween_Array: Array[Tween]
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
	for _i in range(enemyBullets_Enabled_Array.size()-1,-1,-1):
		enemyBullets_Enabled_Array[_i].physics_Update.call()
	#-------------------------------------------------------------------------------
	for _i in range(enemy_Enabled_Array.size()-1,-1,-1):
		enemy_Enabled_Array[_i].physics_Update.call()
	#-------------------------------------------------------------------------------
	for _i in range(playerBullets_Enabled_Array.size()-1,-1,-1):
		playerBullets_Enabled_Array[_i].physics_Update.call()
	#-------------------------------------------------------------------------------
	for _i in range(items_Enabled_Array.size()-1,-1,-1):
		items_Enabled_Array[_i].physics_Update.call()
	#-------------------------------------------------------------------------------
	Player_StateMachine()
#endregion
#-------------------------------------------------------------------------------
#region PLAYER FUNCTIONS
func Player_StateMachine():
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
#-------------------------------------------------------------------------------
func PlayerMovement() -> void:
	if(player.myPLAYER_STATE == Player.PLAYER_STATE.DEATH):
		return
	#-------------------------------------------------------------------------------
	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#-------------------------------------------------------------------------------
	if(isFocus):
		player.hitBox_Sprite.rotate(0.05*deltaTimeScale)
		#-------------------------------------------------------------------------------
		if(!Input.is_action_pressed("input_Focus")):
			player.grazeBox_Sprite.hide()
			player.hitBox_Sprite.hide()
			isFocus = false
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
	else:
		if(Input.is_action_pressed("input_Focus")):
			player.grazeBox_Sprite.show()
			player.hitBox_Sprite.show()
			isFocus = true
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
	if(input_dir != Vector2.ZERO):
		input_dir.normalized()
		var myPosition: Vector2 = player.position
		#-------------------------------------------------------------------------------
		if(isFocus):
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
	enemyLimitsX = Vector2(0, width)
	enemyLimitsY = Vector2(0, height)
	#-------------------------------------------------------------------------------
	bossStartingPosition = Vector2(width*0.5, height*0.25)
#-------------------------------------------------------------------------------
func Debug_Information() -> void:
	var _s: String = ""
	_s += "-------------------------------------------------------\n"
	_s += str(Engine.get_frames_per_second()) + " fps.\n"
	_s += "Tweens: "+str(tween_Array.size())+"\n"
	_s += "-------------------------------------------------------\n"
	_s += "Enemy Bullets Enabled: " + str(enemyBullets_Enabled_Array.size())+"\n"
	_s += "Enemy Bullets Disabled: " + str(enemyBullets_Disabled_Array.size())+"\n"
	_s += "-------------------------------------------------------\n"
	_s += "Enemy Enabled: " + str(enemy_Enabled_Array.size())+"\n"
	_s += "Enemy Disabled: " + str(enemy_Disabled_Array.size())+"\n"
	_s += "-------------------------------------------------------\n"
	_s += "Player Bullets Enabled: " + str(playerBullets_Enabled_Array.size())+"\n"
	_s += "Player Bullets Disabled: " + str(playerBullets_Disabled_Array.size())+"\n"
	_s += "-------------------------------------------------------\n"
	_s += "Items Enabled: " + str(items_Enabled_Array.size())+"\n"
	_s += "Items Disabled: " + str(items_Disabled_Array.size())+"\n"
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
	player.grazeBox_Sprite.hide()
	player.hitBox_Sprite.hide()
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
	Create_EnemyBullets_Disabled(3000)
	Create_PlayerBullets_Disabled(50)
	Create_Items_Disabled(2000)
	#-------------------------------------------------------------------------------
	LoadBulletDatabase()
	Enter_GameState_InGameplay()
	Choreography()
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
func StageCommon(_s:String, _enabled:int, _completed:int):
	await ShowBanner(_s)
	EnableStage(_enabled)
	CompletedStage(_completed)
	singleton.Save_SaveData_Json(singleton.optionMenu.optionSaveData_Json["saveIndex"])
	singleton.CommonSubmited()
	GoToMainScene()
#-------------------------------------------------------------------------------
func ShowBanner(_s:String, _timer:float = 1.0):
	await Seconds(_timer)
	await ShowBanner2(_s)
#-------------------------------------------------------------------------------
func ShowBanner2(_s:String):
	Banner_Open(_s)
	await Seconds(3)
	Banner_Close()
#-------------------------------------------------------------------------------
func Banner_Open(_s:String):
	completedPanel.show()
	completedLabel.text = _s
#-------------------------------------------------------------------------------
func Banner_Close():
	completedPanel.hide()
	completedLabel.text = ""
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
func Choreography():
	match(singleton.currentSaveData_Json["stageIndex"]):
		singleton.STAGE.STAGE_1:
			await Stage1()
		#-------------------------------------------------------------------------------
		singleton.STAGE.STAGE_2:
			await Stage2()
		#-------------------------------------------------------------------------------
		singleton.STAGE.STAGE_3:
			await Stage3()
		#-------------------------------------------------------------------------------
		singleton.STAGE.STAGE_4:
			await Stage4()
		#-------------------------------------------------------------------------------
		singleton.STAGE.STAGE_5:
			await Stage5()
		#-------------------------------------------------------------------------------
		singleton.STAGE.STAGE_6:
			await Stage6()
		#-------------------------------------------------------------------------------
		singleton.STAGE.STAGE_7:
			await Stage7()
		#-------------------------------------------------------------------------------
		singleton.STAGE.ROGUELIKE_MODE:
			await Stage_RougeLike()
		#-------------------------------------------------------------------------------
		singleton.STAGE.BOSSRUSH_MODE:
			await Stage_BossRish()
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Stage1():
	#await Seconds(3)
	#Create_Items(width*0.5, height*0.5, 200, 1000)
	#-------------------------------------------------------------------------------
	var _tween: Tween = CreateTween_ArrayAppend(main_tween_Array)
	#-------------------------------------------------------------------------------
	_tween.tween_interval(3.0)
	_tween.tween_callback(func(): Create_SpellCard())
	#-------------------------------------------------------------------------------
	#Boss_InstantDeath_inSeconds(15.0)
	await TimeOut_Tween(60)
	await Nothing_and_Market()
	await StageCommon("Stage 1 Completed",1,0)
#-------------------------------------------------------------------------------
func Stage2():
	await StageCommon("Stage 2 Completed",2,1)
#-------------------------------------------------------------------------------
func Stage3():
	await StageCommon("Stage 3 Completed",3,2)
#-------------------------------------------------------------------------------
func Stage4():
	await StageCommon("Stage 4 Completed",4,3)
#-------------------------------------------------------------------------------
func Stage5():
	await StageCommon("Stage 5 Completed",5,4)
#-------------------------------------------------------------------------------
func Stage6():
	await StageCommon("Stage 6 Completed",6,5)
#-------------------------------------------------------------------------------
func Stage7():
	await StageCommon("Stage 7 Completed",7,6)
#-------------------------------------------------------------------------------
func Stage_RougeLike():
	await StageCommon("Stage Rogue-Like Completed",8,7)
#-------------------------------------------------------------------------------
func Stage_BossRish():
	await StageCommon("Stage Boss-Rish Completed",8,8)
#-------------------------------------------------------------------------------
func Nothing_and_Market():
	await OpenMarket()
	Enter_GameState_InGameplay()
#-------------------------------------------------------------------------------
func OpenMarket():
	myGAME_STATE = GAME_STATE.IN_CUTIN
	await ShowBanner2("Flea Market has being Open")
	myGAME_STATE = GAME_STATE.IN_MARKET
	await marketMenu.OpenMarket()
#-------------------------------------------------------------------------------
func Enter_GameState_InGameplay():
	myGAME_STATE = GAME_STATE.IN_GAMEPLAY
	#PlayerShoot()
#-------------------------------------------------------------------------------
func Create_SpellCard():
	var _enemy: Enemy = Create_Enemy(width*0.1, width*0.1, 100)
	var _tween: Tween = CreateTween_ArrayAppend(_enemy.tween_Array)
	_tween.tween_property(_enemy, "position",Vector2(width*0.5, height*0.2), 0.5)
	_tween.tween_interval(0.5)
	#-------------------------------------------------------------------------------
	_tween.tween_callback(func():
		var _tween2: Tween = CreateTween_ArrayAppend(_enemy.tween_Array)
		_tween2.set_loops()
		Create_SpellCard_Tween(_enemy, _tween2, 1)
		Create_SpellCard_Tween(_enemy, _tween2, -1)
	)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Create_SpellCard_Tween(_enemy:Enemy, _tween:Tween, _mirror: float):
	var _dir: float
	var _dir2: float = 0.0
	var _max1: float = 10.0*(difficulty+1)
	var _max2: float = 10.0*(difficulty+1)
	var _vel1: float = 4.0
	var _vel2: float = 1.0
	var _dvel: float = (_vel2-_vel1)/_max2
	#-------------------------------------------------------------------------------
	for _j in _max2:
		_dir = 0.0
		for _i in _max1:
			_tween.tween_callback(func():Create_SpellCard_bullet(_enemy, _dir+_dir2*_mirror, _max1, _vel1, _mirror))
			_dir += 360/_max1
		#-------------------------------------------------------------------------------
		_tween.tween_interval(0.1)
		_vel1 += _dvel
		_dir2 += 2
	#-------------------------------------------------------------------------------
	_tween.set_parallel(false)
	_tween.tween_interval(4.0)
#-------------------------------------------------------------------------------
func Create_SpellCard_bullet(_enemy:Enemy, _dir:float, _max1:float, _vel:float, _mirror: float):
	var _bullet: Bullet = Create_EnemyBullet(_enemy.position.x, _enemy.position.y, 4.0, _dir)
	_bullet.isDestroyed_OutScreen = false
	_dir += 360/_max1
	#-------------------------------------------------------------------------------
	var _tween: Tween = CreateTween_ArrayAppend(_bullet.tween_Array)
	#-------------------------------------------------------------------------------
	_tween.tween_property(_bullet, "vel",0.5, 1.0)
	_tween.parallel().tween_property(_bullet, "dir",_bullet.dir+30*_mirror, 1.0)
	_tween.tween_property(_bullet, "dir",_bullet.dir+165*_mirror, 0.25)
	_tween.tween_property(_bullet, "vel",_vel, 1.0)
	_tween.parallel().tween_property(_bullet, "dir",_bullet.dir+270*_mirror, 3.0)
	_tween.tween_callback(func(): _bullet.isDestroyed_OutScreen = true)
#-------------------------------------------------------------------------------
func Create_EnemyBullets_Disabled(_iMax:int):
	for _i in _iMax:
		var _bullet: Bullet = bullet_Prefab.instantiate() as Bullet
		enemyBullets_Disabled_Array.append(_bullet)
		_bullet.hide()
		_bullet.physics_Update = func(): Bullet_PhysicsUpdate(_bullet)
		content.add_child(_bullet)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Create_EnemyBullet(_x:float, _y:float, _v:float, _dir:float) ->Bullet:
	var _bullet: Bullet
	#-------------------------------------------------------------------------------
	if(enemyBullets_Disabled_Array.size() > 0):
		_bullet = enemyBullets_Disabled_Array[0]
		_bullet.show()
		enemyBullets_Disabled_Array.erase(_bullet)
	#-------------------------------------------------------------------------------
	else:
		_bullet = bullet_Prefab.instantiate() as Bullet
		_bullet.physics_Update = func(): Bullet_PhysicsUpdate(_bullet)
		content.add_child(_bullet)
	#-------------------------------------------------------------------------------
	enemyBullets_Enabled_Array.append(_bullet)
	#-------------------------------------------------------------------------------
	_bullet.position = Vector2(_x, _y)
	_bullet.isGrazed = false
	_bullet.dir = _dir
	_bullet.vel = _v
	#-------------------------------------------------------------------------------
	return _bullet
#-------------------------------------------------------------------------------
func Create_Enemy(_x:float, _y:float, _hp: int) -> Enemy:
	var _enemy: Enemy
	#-------------------------------------------------------------------------------
	if(enemy_Disabled_Array.size() > 0):
		_enemy = enemy_Disabled_Array[0]
		_enemy.show()
		enemy_Disabled_Array.erase(_enemy)
	#-------------------------------------------------------------------------------
	else:
		_enemy = enemy_Prefab.instantiate() as Enemy
		_enemy.physics_Update = func(): Enemy_PhysicsUpdate(_enemy)
		content.add_child(_enemy)
	#-------------------------------------------------------------------------------
	enemy_Enabled_Array.append(_enemy)
	#-------------------------------------------------------------------------------
	_enemy.position = Vector2(_x, _y)
	_enemy.maxHp = _hp
	_enemy.hp = _hp
	#-------------------------------------------------------------------------------
	return _enemy
#-------------------------------------------------------------------------------
func Create_PlayerBullets_Disabled(_iMax:int):
	for _i in _iMax:
		var _bullet: Bullet = bullet_Prefab.instantiate() as Bullet
		playerBullets_Disabled_Array.append(_bullet)
		_bullet.hide()
		content.add_child(_bullet)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Create_Items_Disabled(_iMax:int):
	for _i in _iMax:
		var _item: Item = item_Prefab.instantiate() as Item
		items_Disabled_Array.append(_item)
		_item.physics_Update = func(): Items_PhysicsUpdate(_item)
		_item.hide()
		content.add_child(_item)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Create_Items(_x:float, _y:float, _rad: float, _num:int):
	for _i in _num:
		Create_Item(_x+randf_range(-_rad,_rad), _y+randf_range(-_rad,_rad))
#-------------------------------------------------------------------------------
func Create_Item(_x:float, _y:float):
	var _item: Item
	#-------------------------------------------------------------------------------
	if(items_Disabled_Array.size()>0):
		_item = items_Disabled_Array[0]
		items_Disabled_Array.erase(_item)
		_item.show()
	#-------------------------------------------------------------------------------
	else:
		_item = item_Prefab.instantiate() as Item
		_item.physics_Update = func(): Items_PhysicsUpdate(_item)
		content.add_child(_item)
	#-------------------------------------------------------------------------------
	items_Enabled_Array.append(_item)
	#-------------------------------------------------------------------------------
	_item.myITEM_STATE = Item.ITEM_STATE.SPIN
	_item.velocity = Vector2(0, -5)
	_x = clamp(_x, playerLimitsX.x, playerLimitsX.y)
	_y = clamp(_y, playerLimitsY.x, playerLimitsY.y)
	_item.position = Vector2(_x, _y)
#-------------------------------------------------------------------------------
func Items_PhysicsUpdate(_item:Item):
	var _velY_Max: float = 3.0
	var _velY_Accel: float = 0.05
	var _magnetVel: float = 8.0
	match(_item.myITEM_STATE):
		Item.ITEM_STATE.SPIN:
			if(_item.velocity.y <= 0):
				_item.velocity.y += _velY_Accel * deltaTimeScale
				_item.position.y += _item.velocity.y * deltaTimeScale
				_item.rotation += 0.5 * deltaTimeScale
				return
			#-------------------------------------------------------------------------------
			else:
				_item.rotation = 0
				_item.myITEM_STATE = Item.ITEM_STATE.FALL
				return
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
		Item.ITEM_STATE.FALL:
			if(_item.position.y <= height):
				if(_item.velocity.y > _velY_Max):
					_item.velocity.y = _velY_Max
				#-------------------------------------------------------------------------------
				elif(_item.velocity.y < _velY_Max):
					_item.velocity.y += _velY_Accel * deltaTimeScale
				#-------------------------------------------------------------------------------
				_item.position.y += _item.velocity.y * deltaTimeScale
				#-------------------------------------------------------------------------------
				if(_item.position.distance_to(player.position)< 98.0 and player.myPLAYER_STATE != Player.PLAYER_STATE.DEATH):
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
func Bullet_PhysicsUpdate(_bullet: Bullet):
	if(!_bullet.isDestroyed_OutScreen):
		Bullet_PhysicsUpdate2(_bullet)
	#-------------------------------------------------------------------------------
	else:
		if(_bullet.position.x > enemyLimitsX.x and _bullet.position.x < enemyLimitsX.y):
			if(_bullet.position.y > enemyLimitsY.x and _bullet.position.y < enemyLimitsY.y):
				Bullet_PhysicsUpdate2(_bullet)
			#-------------------------------------------------------------------------------
			else:
				DestroyBullet(_bullet)
				return
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
		else:
			DestroyBullet(_bullet)
			return
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Bullet_PhysicsUpdate2(_bullet: Bullet):
	if(_bullet.position.distance_to(player.position)< 34.0 and !_bullet.isGrazed):
		Create_Item(_bullet.position.x, _bullet.position.y)
		_bullet.isGrazed = true
	#-------------------------------------------------------------------------------
	if(_bullet.position.distance_to(player.position)> 10.0):
		var _dir2: float = deg_to_rad(_bullet.dir)
		_bullet.velocity.x = _bullet.vel * cos(_dir2)
		_bullet.velocity.y = _bullet.vel * sin(_dir2)
		_bullet.position += _bullet.velocity * deltaTimeScale
		_bullet.rotation_degrees = _bullet.dir+90
		return
	#-------------------------------------------------------------------------------
	else:
		Player_Shooted()
		DestroyBullet(_bullet)
		return
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Enemy_PhysicsUpdate(_enemy:Enemy):
	if(_enemy.hp <= 0):
		DestroyEnemy(_enemy)
		return
	#-------------------------------------------------------------------------------
	var _dir2: float = deg_to_rad(_enemy.dir)
	_enemy.velocity.x = _enemy.vel * cos(_dir2)
	_enemy.velocity.y = _enemy.vel * sin(_dir2)
	_enemy.position += _enemy.velocity * deltaTimeScale
	#_enemy.rotation_degrees = _enemy.dir+90
#-------------------------------------------------------------------------------
func DestroyEnemy(_enemy: Enemy):
	KillTween_Array(_enemy.tween_Array)
	enemy_Enabled_Array.erase(_enemy)
	enemy_Disabled_Array.append(_enemy)
	_enemy.hide()
#-------------------------------------------------------------------------------
func DestroyBullet(_bullet: Bullet):
	KillTween_Array(_bullet.tween_Array)
	enemyBullets_Enabled_Array.erase(_bullet)
	enemyBullets_Disabled_Array.append(_bullet)
	_bullet.hide()
#-------------------------------------------------------------------------------
func Player_Shooted():
	lifePoints -= 1
	if(lifePoints < 0):
		SetInfoText_Death()
	else:
		SetInfoText_Life()
#-------------------------------------------------------------------------------
func DestroyItem(_item:Item) -> void:
	items_Enabled_Array.erase(_item)
	items_Disabled_Array.append(_item)
	_item.hide()
#-------------------------------------------------------------------------------
func CanPlayerShoot() -> bool:
	if(myGAME_STATE == GAME_STATE.IN_GAMEPLAY or myGAME_STATE == GAME_STATE.IN_CUTIN):
		return true
	#-------------------------------------------------------------------------------
	else:
		return false
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Boss_InstantDeath_inSeconds(_f: float):
	await Seconds(_f+1.0)
	StopEverithing()
	timer_tween.kill()
	timer_tween.finished.emit()
#-------------------------------------------------------------------------------
func Seconds(_f:float):
	await get_tree().create_timer(_f, false).timeout
#-------------------------------------------------------------------------------
func TimeOut_Tween(_iMax: int):
	var _tween: Tween = create_tween()
	timer_tween = _tween
	#-------------------------------------------------------------------------------
	_tween.tween_callback(func():
		timer = _iMax
		timerLabel.show()
		timerLabel.text = str(timer).pad_zeros(2)+" / " +str(_iMax).pad_zeros(2)
	)
	#-------------------------------------------------------------------------------
	_tween.tween_interval(1.0)
	#-------------------------------------------------------------------------------
	for _i in _iMax:
		_tween.tween_callback(func():
			timer-=1
			timerLabel.text = str(timer).pad_zeros(2)+" / " +str(_iMax).pad_zeros(2)
		)
		_tween.tween_interval(1.0)
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
	_tween.tween_callback(func():
		StopEverithing()
	)
	#-------------------------------------------------------------------------------
	await timer_tween.finished
#-------------------------------------------------------------------------------
func StopEverithing():
	timerLabel.text = ""
	timerLabel.hide()
	#-------------------------------------------------------------------------------
	KillTween_Array(main_tween_Array)
	#-------------------------------------------------------------------------------
	for _i in range(enemy_Enabled_Array.size()-1, -1, -1):
		DestroyEnemy(enemy_Enabled_Array[_i])
	#-------------------------------------------------------------------------------
	for _i in range(enemyBullets_Enabled_Array.size()-1, -1, -1):
		DestroyBullet(enemyBullets_Enabled_Array[_i])
	#-------------------------------------------------------------------------------
#region ARRAY[TWEEN] FUNCTIONS
func CreateTween_ArrayAppend(_tween_Array: Array[Tween]) -> Tween:
	var _tween: Tween = create_tween()
	_tween_Array.append(_tween)
	_tween.finished.connect(func():_tween_Array.erase(_tween))
	return _tween
#-------------------------------------------------------------------------------
func KillTween_Array(_tween_Array: Array[Tween]):
	for _i in range(_tween_Array.size()-1, -1, -1):
		_tween_Array[_i].kill()
		_tween_Array[_i].finished.emit()
#endregion
#-------------------------------------------------------------------------------
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
