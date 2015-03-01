Strict 

Import diddy

Import vector
Import mojo

Import death
Import globals
Import structures
Import weapon
Import health_bar

'All of the collision detection code written in here will ultimately be worthless
'because we won't be physically rotating the tank after we get Tegan's animations
'therefore the collision body will just be a rectangle and will always stay a
'rectangle... still it was fun to write 

'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
Class Tank
	Field type:String
	Field id:Int

	Field position:Vector
	Field rotation:Float
	Field baseSpeed:Float = 1
	Field speed:Float
	Field frame:Int
	Field radius:Int = 30
	Field health:Float = 10
	Field healthMax:Float = 10
	Field healthBar:HealthBar = New HealthBar()

	Field image:GameImage
	Field explodeImage:GameImage
	Field weapon:Weapon
	
	Field forward:Bool
	Field backward:Bool
	Field left:Bool
	Field right:Bool
	
	'This vector contains the four corners of the oriented bounding box
	' 0 - TopLeft, 1 - TopRight, 2 - BottomLeft, 3 - BottomRight
	Field obb:Vector[]
	
	Field aabbMin:Vector
	Field aabbMax:Vector

	Field rollback:Bool
		
	Field previousPosition:Vector 'rounding errors giving me fits
	Field movementVector:Vector
	Field rotationDelta:Float
	
	'The default AABB is never updated so that we always have the reference
	'values to multiply against.
	Field defaultAABB:Vector[]
	
	Field deathAnimation:DeathAnimation
	
	'--------------------------------------------------------------------------
	Method New(type:String, id:Int, startingPosition:Vector)
		Self.type = type
		Self.id = id;
	
		rotation = 0;
		position = startingPosition
		previousPosition = New Vector(0,0)
		
		image = gGame.images.Find("TankBaseBlue")
		explodeImage = gGame.images.Find("TankExplodeBlue")
		weapon = New Weapon(position)
		
		obb = MakeDefaultArray()
		defaultAABB = MakeDefaultArray()
		
		aabbMin = New Vector(0,0)
		aabbMax = New Vector(0,0)
		
		movementVector = New Vector(0,0)		
		deathAnimation = New DeathAnimation()
		
		healthBar.Update(1,1)		
	End
	
	'--------------------------------------------------------------------------
	' This method is called after all of the Tanks are initialized for the
	' current level.  Useful for post-initialization tasks and cleaner
	' than an additional variable to see if it is the first frame
	'--------------------------------------------------------------------------
	Method OnPostInit:Void()
		
	End
	
	'--------------------------------------------------------------------------
	Method OnUpdate:Void()
		movementVector.Set(0,0)
		rotationDelta = 0
		
		If health <= 0 Then
			If Not deathAnimation.started Then 
				deathAnimation.Begin(position)
			End
			
			If Not deathAnimation.finished Then
				deathAnimation.Update()
			End
		End
		
		If health <= 0 Or gGameOver Then		
			forward = False 
			backward = False 
			left = False
			right = False 
			Return
		End
	
		' update our weapon so that it
		' can accurately keep track of the
		' proper amount of cooldown time.
		weapon.OnUpdate()
	
		Turn()
		Move()
		
		UpdateRotationFrame()
		
		'Update the OBB
		'UpdateBB()
		
		Local index:Int = CheckEnvironmentCollisions(position) 
		If  index >= 0 Then
			FixMovementVector()

			'UpdateBB()		
		Else
			movementVector.AddLocal(CheckTankCollisions())
			
			If weapon Then
				weapon.position.AddLocal(movementVector)
			End		
		End
		
		Local SpeedMod:Float = gWorld.GetCollisionModifier(position)
		If SpeedMod > 0
			speed = baseSpeed * SpeedMod
		End
		
		index = CheckEnvironmentCollisions(position)
		If  index >= 0 Then
			position.Set( previousPosition.X, previousPosition.Y )
		End
		
		forward = False
		backward = False
		left = False
		right = False
		'Print "Tank: " + id + " position " + position.X + " " + position.Y
	End

	'--------------------------------------------------------------------------
	Method UpdateRotationFrame:Void()
	
		'Update frame #
		If rotation < 11.25
			frame = 0
		Else If rotation < 33.75
			frame = 1
		Else If rotation < 56.25
			frame = 2
		Else If rotation < 78.75
			frame = 3
		Else If rotation < 101.25
			frame = 4
		Else If rotation < 123.75
			frame = 5
		Else If rotation < 146.25
			frame = 6
		Else If rotation < 168.75
			frame = 7
		Else If rotation < 191.25
			frame = 8
		Else If rotation < 213.75
			frame = 9
		Else If rotation < 236.25
			frame = 10
		Else If rotation < 256.75
			frame = 11
		Else If rotation < 281.25
			frame = 12
		Else If rotation < 303.75
			frame = 13
		Else If rotation < 326.25
			frame = 14
		Else If rotation < 348.75
			frame = 15
		Else
			frame = 0
		End

	End

	'--------------------------------------------------------------------------
	Method OnRender:Void()
		If gDebug Then
			Local alpha:Float = GetAlpha()
			SetAlpha(0.25)
			DrawRect(position.X-32, position.Y-32, 64, 64)
			SetAlpha(alpha)
		End		
			
		If image Then
			If health = 0
				frame = 0
			End
		
			DrawImage(image.image, position.X, position.Y, 0, 1, 1, frame)
		End
		
		If deathAnimation.started And Not deathAnimation.finished Then
			deathAnimation.Render()
		End

		If weapon And health > 0 Then
			weapon.OnRender()
		End
		
		If healthBar And health > 0 Then
			healthBar.Render(position)
		End
	
		If gDebug Then
			DrawText(id, position.X-10, position.Y-80)
			DrawText(type, position.X-10, position.Y-70)
		End
	End
	
	'--------------------------------------------------------------------------
	Method UpdateBB:Void()
		Local cos_th:Float = Cos(rotation)
		Local sin_th:Float = Sin(rotation)
		
		For Local i:=0 To defaultAABB.Length()-1
			Local tmp:Vector = defaultAABB[i]
			Local v1:Vector = obb[i]

			Local x:Float = tmp.X * cos_th - tmp.Y * sin_th
			Local y:Float = tmp.X * sin_th + tmp.Y * cos_th	
			
			v1.Set( position.X + x, position.Y + y)
			
			If i=0 Then
				aabbMin.Set( v1.X, v1.Y )
				aabbMax.Set( v1.X, v1.Y )
			End
			
			aabbMin.X = Min( aabbMin.X, v1.X )
			aabbMin.Y = Min( aabbMin.Y, v1.Y )
			
			aabbMax.X = Max( aabbMax.X, v1.X )
			aabbMax.Y = Max( aabbMax.Y, v1.Y )
		End
	End
	
	'--------------------------------------------------------------------------
	Method Hit:Void(damage:Float)
		health -= damage
		If health <= 0
			health = 0
			'handle death animation
			image = explodeImage
		End
		healthBar.Update(health, healthMax)
	End
	
	' Convert the given vector into directions to move in.  
	' forward, backward, left and right....
	' assumed that the direction is normalized
	Method DirectionalMove:Void(direction:Vector)
		Local desiredRotation:Float = WrapValue(ATan2( direction.Y, direction.X ))
		Local angleDiff:Float = AngleDiff(rotation, desiredRotation)
		
		left = False
		right = False
		forward = True 
		
		If Abs(angleDiff) >= 10  Then
			If angleDiff <= 0 Then
				left = True
				right = False
			Else
				right = True
				left = False 
			End
		End
	End
	
	'--------------------------------------------------------------------------
	'Eventually this should be a private section
	'--------------------------------------------------------------------------
	Method Move:Void()
		If forward And backward Then
			Return
		End
	
		If Not forward And Not backward Then
			Return
		End

		Local sign:Float = 1;
		If backward Then
			sign = -1
		End		
		
		movementVector.Set( sign*Cos(rotation) * speed, sign*Sin(rotation) * speed)		
		previousPosition.Set( position.X, position.Y )
		position.AddLocal(movementVector)
	End
	
	'--------------------------------------------------------------------------
	Method Turn:Void()
		If left And right Then
			Return
		End
		
		If Not left And Not right Then
			Return
		End
		
		Local sign:Float = 1
		If left Then
			sign = -1
		End
		
		rotationDelta = 2*sign
		rotation += rotationDelta
		If rotation > 360 Then
			rotation -= 360
		End
		
		If rotation < 0 Then
			rotation += 360
		End
		
		Local val:Float = (rotation Mod 45) / 45
		radius = val * 32 + (1 - val) * 22
	End
	
	'--------------------------------------------------------------------------
	Method CheckTankCollisions:Vector()
		Local result:Vector = New Vector(0, 0)
		For Local tank:Tank = Eachin gTanks
			If Self = tank Or tank.health <= 0 Then
				Continue
			End
		
			Local combinedRadius:Int = radius + tank.radius
			Local combinedSquared:Int = combinedRadius * combinedRadius
		
			Local difference:Vector = position.Subtract(tank.position)
		
			If difference.LengthSquared() < combinedSquared
				Local length:Float = difference.Length()
				difference.Normalize()
				difference.ScaleLocal(combinedRadius - length)
				result.AddLocal(difference)
			End	
		End
		Return result
	End
	
	'--------------------------------------------------------------------------
	Method CheckEnvironmentCollisions:Int(pos:Vector)
		'The test cannot just take in the collision on the four
		'corners.  It must take into account the grid cells across
		'the line.  Probably pull in Breshenhams line algorithm to
		'determine the grid cells we should be checking.
		For Local i:=0 Until defaultAABB.Length
			If gWorld.IsCollision(pos.Add(defaultAABB[i])) Then
				Return i
			End
		End
		Return -1
	End
	
	'--------------------------------------------------------------------------
	Method MovementVectorTest:Void(h1:Bool, h2:Bool, v1:Bool, v2:Bool)
		If (h1 Or h2) And (v1 Or v2) Then
			rollback = True
		End
		
		If Not v1 And Not v2 And Not h1 And Not h2 Then
			If Abs(movementVector.X) > Abs(movementVector.Y) Then
				movementVector.X = 0
			Else
				movementVector.Y = 0
			End
		Else If h1 Or h2 Then
			movementVector.X = 0
		Else If v1 Or v2 Then
			movementVector.Y = 0
		End
	End
	
	'--------------------------------------------------------------------------
	Method FixMovementVector:Void()
		rollback = False 
	
		Local grid:Bool[] = [ 
			gWorld.IsCollision( position.Add(-30.0, -30.0) ),
			gWorld.IsCollision( position.Add(  0.0, -30.0) ),
			gWorld.IsCollision( position.Add( 30.0, -30.0) ),
			gWorld.IsCollision( position.Add(-30.0,   0.0) ),
			gWorld.IsCollision( position.Add( 30.0,   0.0) ),
			gWorld.IsCollision( position.Add(-30.0,  30.0) ),
			gWorld.IsCollision( position.Add(  0.0,  30.0) ),
			gWorld.IsCollision( position.Add( 30.0,  30.0) ) ]
			
		If grid[0] And grid[2] And grid[5] And grid[7] Then
			position.Set( previousPosition.X, previousPosition.Y )
			movementVector.Set( 0, 0 )
			Return
		End
		
		If grid[0] Then
			MovementVectorTest( grid[1], grid[2], grid[3], grid[5] )
		End 
		
		If grid[2] Then
			MovementVectorTest( grid[0], grid[1], grid[4], grid[7] )
		End
		
		If grid[5] Then
			MovementVectorTest( grid[6], grid[7], grid[0], grid[3] )
		End
		
		If grid[7] Then
			MovementVectorTest( grid[5], grid[6], grid[2], grid[4] )
		End
		
		If rollback Then
			position.Set( previousPosition.X, previousPosition.Y )
			movementVector.Set( 0, 0 )
			Return
		End
		
		position.SubtractLocal(movementVector)		
		
		Local dx:Vector = position.Subtract(previousPosition)
		Local length:Float = dx.Length()
		If Abs(length) > 0.01 Then
			dx.Normalize()
			dx.Scale( speed - length )
			position.AddLocal(dx)
		End

	End

	'--------------------------------------------------------------------------
	Method MakeDefaultArray:Vector[]()
		Return [	New Vector( -30, -30  ),
				New Vector(  30, -30 ),
				New Vector( -30, 30 ),
				New Vector(  30, 30 ) ]
	End	
End

'--------------------------------------------------------------------------
Function AngleDiff:Float(actual:Float, target:Float)
	Local difference:Float = target - actual
	While difference < 180
		difference += 360
	End
	
	While difference > 180
		difference -= 360
	End
	Return difference
End

'--------------------------------------------------------------------------
Function WrapValue:Float(value:Float)
	Local max:Float = 360
	While value > max 
		value -= max
	End
	
	While value < 0
		value += max
	End
	Return value
End
