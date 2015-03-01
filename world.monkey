Strict

Import diddy
Import mojo

Import globals
Import search
Import vector

Class World

	Field tileSheet:Image
	Field background:Image
	
	Field numTilesX:Int = 30
	Field numTilesY:Int = 20
	
	Field tileWidth:Int = 32
	Field tileHeight:Int = 32
	
	Field spawnPoints:ArrayList<SpawnPoint> = New ArrayList<SpawnPoint>()

	
	Field world1:Int[][]
	Field foreground1:Int[][]
	
	
	Field backgroundImageStart:Int
	Field spawnPointsStart:Int
	Field backgroundTilesStart:Int
	Field foregroundTilesStart:Int

	'--------------------------------------------------------------------------
	Method New(file:String)
		tileSheet = LoadImage("graphics/TileSheet.png", tileWidth, tileHeight, 128, Image.MidHandle)
		
		Local index:Int = 0
		Local str$=LoadString( "worlds/" + file + ".txt" )
		
		Local lines:String[] = str.Split("~n")
		Local line:String = ""
		
		For index = 0 Until lines.Length()
			Select lines[index].Trim()
				Case "[Background Image]"
					backgroundImageStart = index + 1
				Case "[Spawn Points]"
					spawnPointsStart = index + 1
				Case "[Background Tiles]"
					backgroundTilesStart = index + 1
				Case "[Foreground Tiles]"
					foregroundTilesStart = index + 1
			End
		Next
	
		background =  LoadImage(lines[backgroundImageStart].Trim(), 1, Image.MidHandle)
		
		index = 0
		line = lines[spawnPointsStart + index].Trim()
		While line <> ""
			Local coords:String[] = line.Split(",")
			Local vec:Vector = New Vector(Float(coords[0].Trim()), Float(coords[1].Trim()))
			Local sp:SpawnPoint = New SpawnPoint(vec, Float(coords[2].Trim()))
			spawnPoints.Add(sp)
			
			index = index + 1
			line = lines[spawnPointsStart + index].Trim()
		End
		
		Local x:Int = 0;
		Local y:Int = 0;
			
		world1 = [[ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
				  [ 1,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17, 1],
				  [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
				  [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
				  [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
				  [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
				  [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
				  [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
				  [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
				  [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
				  [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
				  [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
				  [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
				  [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,55,56,57,55,56,57, 0, 0, 0, 0, 0, 0, 0, 0, 1],
				  [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,71,72,73,71,72,73, 0, 0, 0, 0, 0, 0, 0, 0, 1],
				  [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
				  [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
				  [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
				  [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
				  [18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18]]

   		foreground1 = [[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
				  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
				  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
				  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
				  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
				  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
				  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
				  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
				  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
				  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
				  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
				  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
				  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,39,40,41,39,40,41, 0, 0, 0, 0, 0, 0, 0, 0, 0],
				  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,55,56,57,55,56,57, 0, 0, 0, 0, 0, 0, 0, 0, 0],
				  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,71,72,73,71,72,73, 0, 0, 0, 0, 0, 0, 0, 0, 0],
				  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
				  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
				  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
				  [ 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0],
				  [18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18]]
		
		For y = 0 Until 20
			Local tiles:String[]
			For x = 0 Until 30
				line = lines[backgroundTilesStart + y].Trim()
				tiles = line.Split(",");
				world1[y][x] = Int(tiles[x].Trim())
			End
			For x = 0 Until 30
				line = lines[foregroundTilesStart + y].Trim()
				tiles = line.Split(",");
				foreground1[y][x] = Int(tiles[x].Trim())
			End
		End
		
	End
	
	'--------------------------------------------------------------------------
	Method RenderBackground:Void()
		DrawImage(background, 480, 320, 0)
		For Local y:=0 To 19 Step 1
        	For Local x:=0 To 29 Step 1
				If world1[y][x] <> 0 'And world1[y][x] <> 13 Then
					DrawImage(tileSheet, x * tileWidth + 16, y * tileHeight + 16, world1[y][x] - 1)
				End
			Next
		Next
	End
		
	'--------------------------------------------------------------------------
	Method RenderForeground:Void()
		For Local y:=0 To 19 Step 1
        	For Local x:=0 To 29 Step 1
				If foreground1[y][x] <> 0 Then
					DrawImage(tileSheet, x * tileWidth + 16, y * tileHeight + 16, foreground1[y][x] - 1)
				End
			Next
		Next
	End
	
	'--------------------------------------------------------------------------
	Method RenderGrid:Void()
		SetColor(20,20,20)
		For Local y:=0 Until numTilesY
			DrawLine(0, y*tileHeight, tileWidth*numTilesX, y*tileHeight)			
		End
		
		For Local x:=0 Until numTilesX
			DrawLine(x*tileWidth, 0, x*tileWidth, tileHeight*numTilesY)			
		Next
		SetColor(255,255,255)
	End
	
	'--------------------------------------------------------------------------
	Method IsCollision:Bool(x:Float, y:Float)
		Local xIndex:Int = Floor(x / tileWidth)
		Local yIndex:Int = Floor(y / tileHeight)

		If xIndex >= numTilesX	Or xIndex < 0 Then
			Error "Index Out of Bounds (x): " + xIndex
		End
		
		If yIndex >= numTilesY Or yIndex < 0 Then
			Error "Index Out of Bounds (y): " + yIndex
		End
		
		If world1[yIndex][xIndex] < 17 Then
			Return False
		End
		
		Return True
	End
		
	'--------------------------------------------------------------------------
	Method GetCollisionModifier:Float(x:Float, y:Float)
		Local xIndex:Int = Floor(x / tileWidth)
		Local yIndex:Int = Floor(y / tileHeight)
		
		If world1[yIndex][xIndex] = 0 Then
			Return 1
		Else If world1[yIndex][xIndex] < 17 Then
			Return 0.6
		End
		
		Return 0
	End
	
	'--------------------------------------------------------------------------
	Method IsCollision:Bool(v:Vector)
		Return IsCollision(v.X, v.Y)
	End
		
	'--------------------------------------------------------------------------
	Method GetCollisionModifier:Float(v:Vector)
		Return GetCollisionModifier(v.X, v.Y)
	End
	
	'--------------------------------------------------------------------------
	
	Method IsCollision:Bool(x:Int, y:Int)
		If world1[y][x] < 17 Then
			Return False
		End
		Return True	
	End
	
	'--------------------------------------------------------------------------
	Method Reflect:Vector(p:Vector, v:Vector)
		Local xIndex:Int = Floor(p.X / tileWidth)
		Local yIndex:Int = Floor(p.Y / tileHeight)
		
		'If we are moving down then we need to check one above
		Local yDir:Int = 1
		If v.Y > 0 Then
			yDir = -1
		End	
		
		Local xDir:Int = 1
		If v.X > 0 Then
			xDir = -1
		End
		
		Local result:Vector = New Vector(-1,-1)			
		If world1[yIndex+yDir][xIndex] < 17 Then
			result.X = 1
		End

		If world1[yIndex][xIndex+xDir] < 17 Then
			result.Y = 1
		End
		
		Return result
	End
	
	'--------------------------------------------------------------------------
	Method LineOfSight:Bool(v1x:Float, v1y:Float, v2x:Float, v2y:Float, list:ArrayList<TanksPoint>=Null)
		Local x0:Int = Min( numTilesX, Max( 0, Int(Floor(v1x / tileWidth)) ) )
		Local y0:Int = Min( numTilesY, Max( 0, Int(Floor(v1y / tileHeight)) ) )
		
		Local x1:Int = Min( numTilesX, Max( 0, Int(Floor(v2x / tileWidth)) ) )
		Local y1:Int = Min( numTilesY, Max( 0, Int(Floor(v2y / tileWidth)) ) )

		Return TileLineOfSight(x0, y0, x1, y1, list)	
	End
	
	'--------------------------------------------------------------------------
	Method TileLineOfSight:Bool(x0:Int, y0:Int, x1:Int, y1:Int, list:ArrayList<TanksPoint>=Null)
		Local dx:Int = Abs(x1 - x0)
		Local dy:Int = Abs(y1 - y0)
		
		Local sx:Int = -1
		Local sy:Int = -1
		
		If x0 < x1 Then
			sx = 1
		End
		
		If y0 < y1 Then
			sy = 1
		End

		Local error:Int = dx - dy
		Local error2:Int = 0

		Local finish:Bool = False
		While Not finish
			If list <> Null Then
				list.Add(New TanksPoint(x0,y0))
			End

			If world1[y0][x0] >= 17 Then
				Return False
			End
			
			If x0 = x1 And y0 = y1 Then
				finish = True
				Continue
			End
			
			error2 = 2 * error
			If error2 > -dy Then
				error = error - dy
				x0 = x0 + sx
			End

			If error2 < dx Then
				error = error + dx
				y0 = y0 + sy
			End
		End
		Return True
	End

End

'--------------------------------------------------------------------------
' Helper class that contains an integer x and y for grid point
' access
'--------------------------------------------------------------------------
Class TanksPoint
	Field x:Int
	Field y:Int

	Method New(x:Int, y:Int)
		Self.x = x
		Self.y = y
	End
End

'--------------------------------------------------------------------------
' Helper class 
'--------------------------------------------------------------------------
Class SpawnPoint
	Field vector:Vector
	Field rotation:Float

	Method New(v:Vector, rot:Float)
		vector = v
		rotation = rot
	End
End