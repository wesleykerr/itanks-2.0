		
Import diddy
Import fantomEngine

Import game_screen
Import screens
Import tank
Import world
Import thumbstick

'world information that could eventually be put into a manager
'necessary currently for collision detection between projectile and tanks
Global gTanks:ArrayList<Tank>

'Information for debugging so that we can cycle through
'what is displayed on the screen.
Global gDebug

Global gDebugTankId
Global gDebugTargetTankId
Global gDebugTankPathId

Global gAlive:Int
Global gGameOver:Bool
Global gWon:Bool

Global gWorld:World

Global gGameSaveState:GameSaveState

' These two integers store the max level
' information so that we can enforce a progression
' through the levels.
Global gZoneCount:Int

'screens
Global gTitleScreen:TitleScreen
Global gCreditsScreen:BackgroundScreen
Global gHelpScreen:BackgroundScreen
Global gGameScreen:GameScreen
Global gLevelScreens:ArrayList<LevelSelectScreen>

'managers
Global gProjectileManager:ProjectileManager

'fonts
Global gTextFont:ftFont

'images
Global gGame:iTanks

' Some constants below the jump...
Global ZONE_COUNT:Int = 5
Global LEVEL_COUNT:Int = 6


Global KEYBOARD:String = "keyboard"
Global THUMBSTICK:String = "thumbstick"
Global CONTROLLER:String = "controller"
Global ACCELEROMETER:String = "accelerometer"


'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
Class GameSaveState
	Field zoneCompleted:Int 
	Field levelCompleted:Int
	
	Field inputName:String
	
	Field sound:Int
	Field music:Int
	
	'----------------------------------------------------------------------
	Method New()
		zoneCompleted = 1
		levelCompleted = 0
		
		#If TARGET="ios" Or TARGET="android"
			inputName = THUMBSTICK
		#Else If TARGET="xna"
			inputName = CONTROLLER
		#Else 
			inputName = KEYBOARD
		#End			

		sound = 1
		music = 1 
	End
	
	'----------------------------------------------------------------------
	Method Load:Void()
		Local state:String = LoadState()
		If state.Length() > 0 Then
			Local tokens:String[] = state.Split(",")
			zoneCompleted = Int(tokens[0].Trim())
			levelCompleted = Int(tokens[1].Trim())

			If tokens.Length() > 2 Then
				inputName = tokens[2].Trim()
 			End

			If tokens.Length() > 3 Then
				sound = Int(tokens[3].Trim())
				music = Int(tokens[4].Trim())
			End
		End	
	End
	
	'----------------------------------------------------------------------
	Method OnWin:Void(zone:Int, level:Int)
		If zone = zoneCompleted And level = levelCompleted Then
			levelCompleted += 1
			If levelCompleted >= LEVEL_COUNT Then
				zoneCompleted += 1
				levelCompleted = 0
			End
		End
		Save()		
	End
	
	'----------------------------------------------------------------------
	Method Save:Void()
		SaveState(zoneCompleted + "," + levelCompleted + "," + inputName + "," + sound + "," + music)
	End
End