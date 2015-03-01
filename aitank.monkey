
Import mojo
Import globals
Import tank

Class AITank Extends Tank

	'AITank inherits a baseSpeed that should be about 1
	Field search:AStarSearch
	Field path:ArrayList<Vector>
	Field pathIndex:Int
	
	'LineOfSight information is stored in an ArrayList
	Field losList:ArrayList<LosInfo>
	Field targetLos:LosInfo
			
	Field state:String 
	Field movingForward:Bool
	Field turning:Int
	
	Field target:Tank

	Field extraDelay:Float

	'--------------------------------------------------------------------------
	Method New(type:String, id:Int, v:Vector)
		Super.New(type, id, v)
		
		search = New AStarSearch()
		state = "NONE"
		image = gGame.images.Find("TankBase")
		explodeImage = gGame.images.Find("TankExplode")
	
		extraDelay = (Rnd() * 3000) + 2000
	
		weapon.elapsedSinceFired = -Rnd(0,1000)
		weapon.cooldown += extraDelay
		weapon.image = gGame.images.Find("Weapon") 
			
		target = Null
	End
	
	'--------------------------------------------------------------------------
	' This method is called after all of the Tanks are initialized for the
	' current level.  Useful for post-initialization tasks and cleaner
	' than an additional variable to see if it is the first frame
	'--------------------------------------------------------------------------
	Method OnPostInit:Void()
		Super.OnPostInit()
		
		losList = New ArrayList<LosInfo>()
		For Local tank:Tank = Eachin gTanks
			losList.Add(New LosInfo())
		End 
		
		targetLos = New LosInfo()
	End	
	
	'--------------------------------------------------------------------------
	Method OnUpdate:Void()		
	
		' If we are dead then there is nothing that we can do 
		' besides be a lump of metal.
		If gAlive = 1 Or health <= 0 Then
			Super.OnUpdate()
			Return
		End
		
		Local visible:ArrayList<Tank> = New ArrayList<Tank>()
		Local notVisible:ArrayList<Tank> = New ArrayList<Tank>()
		
		Local targetAlive:Bool = False 

		For Local i:=0 Until gTanks.Size()
			Local tank:Tank = gTanks.Get(i)
			If tank.id = Self.id Or tank.health <= 0 Then
				Continue
			End
				
			Local los:LosInfo = losList.Get(tank.id)
			los.Update(position, tank)
			If los.IsVisible() Then
				visible.Add(tank)
			Else
				notVisible.Add(tank)
			End
			
			'Has our target recently died or can we still target the
			'target we were focused on last time
			If target <> Null And target.id = tank.id Then
				targetAlive = True
			End

		End
		
		If visible.Size() = 0 Then
		
			' if we are currently not following a path, then let's 
			' pick a target and compute a path to them
			'   For now, we will randomly pick a target with a preference to
			'   the human target
			If state <> "PATH" Then
				Print "Building a path for " + id
				For Local t:Tank = Eachin notVisible
					Print "   Option: " + t.id
				End 
				
				state = "PATH"
				If target = Null Or Not targetAlive Then
					Local index:Int = Rnd(notVisible.Size())				
					target = notVisible.Get(index)
				End 
				
				Print "Selecting a path from tank " + id + " to tank " + target.id
				path = search.FindPath(position, New Vector(target.position.X, target.position.Y))
				pathIndex = 0
				If path.Size() > 0
					pathIndex = 1
				End
			End
			
			'continue following the path....
			FollowPath()
		Else
			'begin facing our opponent		
			If state = "PATH" Then
				StopPathFollowing()
			End
			
			state = "ATTACK"
			
			' should we switch targets?
			If Not targetAlive Or Rnd(0, 1000) < 10 Then
				target = visible.Get( Rnd(visible.Size()) )			
			End
	
			' aim and fire at our opponent			
			Self.weapon.AimAt( target.position )
			Self.weapon.Fire()
			
			' make ourselves a bit harder to hit by moving around
			StrafingMovement()
		End
		
		Super.OnUpdate()	
	End
	
	'--------------------------------------------------------------------------
	Method OnRender:Void()
		Super.OnRender()
		
		RenderAllDebug();
		
		If Not gDebug Then
			DrawText(state, position.X-10, position.Y-60)

			If gDebugTankId = id Then
				Local losInfo:LosInfo = losList.Get(gDebugTargetTankId)
				losInfo.Render()
				
				If state = "PATH" And gDebugTankPathId = 0 Then
					' we are going to render our path to make sure that it looks good
					For Local i := 0 Until path.Size()
						Local v:Vector = path.Get(i)
						If i = pathIndex Then
							SetColor(255, 0, 0)
						Else
							SetColor(255, 255, 255)
						End
						DrawOval( v.X - 3, v.Y - 3, 6, 6)
					End
				End
			End
			
			
			SetColor(255, 255, 255)
		End
	End

	'--------------------------------------------------------------------------
	Method RenderAllDebug:Void()
		If Not gDebug Then
			Return 
		End
		
		DrawText(state, position.X-10, position.Y-60)
	 	For Local losInfo:LosInfo = Eachin losList
			losInfo.Render()
		End 
		
		SetColor(255, 255, 255)
	End
	
	'--------------------------------------------------------------------------
	Method FollowPath:Void()
		If path.Size() = 0 Then
			Return
		End
		
		Local waypoint:Vector = path.Get(pathIndex)
		
		'are we facing it?
		Local direction:Vector = waypoint.Subtract(position)
		Local distance:Float = direction.Length()
		
		If distance < 16 Then
			pathIndex += 1
			If pathIndex >= path.Size()
				state = "NONE"
				Return 
			End
			waypoint = path.Get(pathIndex)
			direction = waypoint.Subtract(position)
		End

		direction.Normalize()
		Local desiredRotation:Float = ATan2( direction.Y, direction.X )
		Local angleDiff = AngleDiff(rotation, desiredRotation)
		If Abs(angleDiff) < 2 
			forward = True 
			backward = False 
		Else If Abs(angleDiff) > 145
			backward = True
			forward = False
		Else
			forward = False
			backward = False 
			
			If angleDiff < 0 Then
				left = True
				right = False
			Else
				right = True
				left = False 
			End
			
		End
	End
	
	'--------------------------------------------------------------------------
	Method StopPathFollowing:Void()
		path.Clear()
		pathIndex = 0
		
		forward = False
		backward = False
		left = False
		right = False
	End
	
	'--------------------------------------------------------------------------
	Method StrafingMovement:Void()
		If Rnd(0, 1000) < 10 Then
			'swap directions
			movingForward = Not movingForward
		End
			
		If movingForward Then
			forward = True
			backward = False
		Else 
			backward = True
			forward = False
		End
			
		If Rnd(0, 1000) < 100 Then
			'turning = Rnd(0,3)
			turning = 0
		End
			
		If turning = 0 Then
			left = False 
			right = False
		Else If turning = 1 Then
			left = True
			right = False
		Else
			left = False
			right = True
		End
		
		TestMove()
	End
	
	'--------------------------------------------------------------------------
	Method TestMove:Void()
		If Not forward And Not backward Then 
			Return
		End
	
		If forward And backward Then
			Return
		End
		
		Local sign:Float = 1;
		If backward Then
			sign = -1
		End		
		
		' perform the move by computing our potential next position
		Local pos:Vector = New Vector()
		pos.Set( sign*Cos(rotation) * speed, sign*Sin(rotation) * speed)		
		pos.AddLocal(position)
		
		If Not TestLocation(pos)
			forward = False
			backward = False 
			movingForward = Not movingForward
		End
	End
	
	'--------------------------------------------------------------------------
	Method TestLocation:Bool(pos:Vector)
		' we will test a potential location to see if it collides with anything
		' or loses sight to our target.
		
		' returns true if it is a good location and false otherwise
		
		If CheckEnvironmentCollisions(pos) >= 0 Then
			Return False
		End
		
		targetLos.Update(pos, target)		
		If Not targetLos.IsVisible() Then
			Return False
		End
		
		Return True
	End

	
End

'--------------------------------------------------------------------------
' LosInfo keeps track of the LineOfSight information for this AI Tank
'--------------------------------------------------------------------------
Class LosInfo
	'Currently we are performing 4 tests to make
	'sure that the enemy is visible from all positions of our
	'tank
	Field test1:Bool
	Field test2:Bool
	Field test3:Bool
	Field test4:Bool
	
	Field path1:ArrayList<TanksPoint>
	Field path2:ArrayList<TanksPoint>
	Field path3:ArrayList<TanksPoint>
	Field path4:ArrayList<TanksPoint>
	
	Method New()
		' initialize everything and get it ready to run
		path1 = New ArrayList<TanksPoint>()
		path2 = New ArrayList<TanksPoint>()
		path3 = New ArrayList<TanksPoint>()
		path4 = New ArrayList<TanksPoint>()
	End
	
	Method Update:Void(position:Vector, tank:Tank)
		If gDebug Then
			path1.Clear();
			path2.Clear();
			path3.Clear();
			path4.Clear();
		
			test1 = gWorld.LineOfSight(position.X - 32, position.Y - 32, tank.position.X, tank.position.Y, path1)
			test2 = gWorld.LineOfSight(position.X - 32, position.Y + 32, tank.position.X, tank.position.Y, path2)
			test3 = gWorld.LineOfSight(position.X + 32, position.Y - 32, tank.position.X, tank.position.Y, path3)
			test4 = gWorld.LineOfSight(position.X + 32, position.Y + 32, tank.position.X, tank.position.Y, path4)
		Else
			test1 = gWorld.LineOfSight(position.X - 32, position.Y - 32, tank.position.X, tank.position.Y)
			test2 = gWorld.LineOfSight(position.X - 32, position.Y + 32, tank.position.X, tank.position.Y)
			test3 = gWorld.LineOfSight(position.X + 32, position.Y - 32, tank.position.X, tank.position.Y)
			test4 = gWorld.LineOfSight(position.X + 32, position.Y + 32, tank.position.X, tank.position.Y)
		End
	End
	
	Method IsVisible:Bool()
		Return test1 And test2 And test3 And test4
	End
	
	Method Render:Void()
		If gDebugTankPathId = 1 Then
			RenderVisiblePath(path1)
		Elseif gDebugTankPathId = 2 Then
			RenderVisiblePath(path2)
		Elseif gDebugTankPathId = 3 Then
			RenderVisiblePath(path3)
		Elseif gDebugTankPathId = 4 Then
			RenderVisiblePath(path4)
		End
	End
	
	'All is private below here......
	Private 
	
	Method RenderVisiblePath:Void(path:ArrayList<TanksPoint>)
		Local alpha:Float = GetAlpha()
		SetAlpha(0.25)
		For Local p:TanksPoint = Eachin path
			DrawRect( p.x * gWorld.tileWidth, p.y * gWorld.tileHeight, gWorld.tileWidth, gWorld.tileHeight )		
		End
		SetAlpha(alpha)
	End
End

'--------------------------------------------------------------------------
'  Moving between the different waypoints in our path is accomplished with
'  SteeringBehaviors
'--------------------------------------------------------------------------
Class SteeringOutput
	Field velocity:Vector
	Field rotation:Float
	
	Method New()
		velocity = New Vector(0,0)
		rotation = 0
	End
End

'--------------------------------------------------------------------------
Class SteeringBehavior Abstract
	Field steeringOutput:SteeringOutput
	Field target:Vector
	Field ai:AITank
	
	Method New(ai:AITank)
		Self.ai = ai
		steeringOutput = New SteeringOutput()
	End

	Method GetSteering:SteeringBehavior() Abstract
End

'--------------------------------------------------------------------------
Class Seek
	Method New(ai:AITank)
		Super.New(ai)
	End
	
	Method GetSteering:SteeringOutput()
		Local steering:SteeringOutput = New SteeringOutput()
		
		steering.velocity = target.Subtract(ai.position)
		steering.velocity.Normalize()
		steering.velocity.ScaleLocal(ai.speed)
		
		steering.rotation = 0
		Return steering
	End
End

'--------------------------------------------------------------------------
