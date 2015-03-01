
Import globals
Import vector

'--------------------------------------------------------------------------
Class LineSegment
	Field p1:Vector
	Field p2:Vector
	
	Method New(x0:Float, y0:Float, x1:Float, y1:Float)
		p1 = New Vector(x0, y0)
		p2 = New Vector(x1, y1)
	End
	
End

'--------------------------------------------------------------------------
Class AABB
	Field min:Vector
	Field max:Vector
	
	Field lines:ArrayList<LineSegment>
	
	Method New(xMin:Float, yMin:Float, xMax:Float, yMax:Float )
		min = New Vector(xMin, yMin)
		max = New Vector(xMax, yMax)
	End
	
	Method GetLines:ArrayList<LineSegment>()
		If lines <> Null
			Return lines
		End
		
		lines = New ArrayList<LineSegment>
		lines.Add(New LineSegment(min.X, min.Y, max.X, min.Y))
		lines.Add(New LineSegment(max.X, min.Y, max.X, max.Y))
		lines.Add(New LineSegment(max.X, max.Y, min.X, max.Y))
		lines.Add(New LineSegment(min.X, max.Y, min.X, min.Y)) 
		Return lines
	End
End


'--------------------------------------------------------------------------
Function Intersects:Bool(l1:LineSegment, l2:LineSegment, p:Vector)
	
	Print "LineSegment 1: " + l1.p1.X + "," + l1.p1.Y + "     " + l1.p2.X + "," + l1.p2.Y
	Print "LineSegment 2: " + l2.p1.X + "," + l2.p1.Y + "     " + l2.p2.X + "," + l2.p2.Y
	
	Local denom:Float = (l2.p2.Y - l2.p1.Y) * (l1.p2.X - l1.p1.X) - (l2.p2.X - l2.p1.X) * (l1.p2.Y - l1.p1.Y)
	
	Local na:Float = (l2.p2.X - l2.p1.X) * (l1.p1.Y - l2.p1.Y) - (l2.p2.Y - l2.p1.Y) * (l1.p1.X - l2.p1.X)
	Local nb:Float = (l1.p2.X - l1.p1.X) * (l1.p1.Y - l2.p1.Y) - (l1.p2.Y - l1.p1.Y) * (l1.p1.X - l2.p1.X)
	
	Local eps:Float = 0.00001
	If Abs(na) < eps And Abs(nb) < eps And Abs(denom) < eps Then
		p.X = (l1.p1.X + l1.p2.X) / 2.0
		p.Y = (l1.p1.Y + l1.p1.Y) / 2.0
		Return True;
	End 
	
	If Abs(denom) < eps Then
		Return False
	End
	
	'calculate fractional point that that the ines potentially intersect
	Local ua:Float = na / denom;
	Local ub:Float = nb / denom
	
	If ua >= 0 And ua <= 1.0 And ub >= 0 And ub <= 1 Then
		p.X = l1.p1.X + (ua * (l1.p2.X - l1.p1.X))
		p.Y = l1.p1.Y + (ua * (l1.p2.Y - l1.p1.Y))
		Return True
	End
	Return False
End

'--------------------------------------------------------------------------
Function FixMovementVector:Vector(position:Vector, movement:Vector)
	'compute the grid coordinates of the position, since already know
	'that it is colliding
	Local xIndex:Int = Floor(position.X / gWorld.tileWidth)
	Local yIndex:Int = Floor(position.Y / gWorld.tileHeight)
	
	If gWorld.world1[yIndex][xIndex] = 0 Then
		Print "Technically not colliding with this position!"
		Return New Vector(0,0)
	End

	Print "x: " + xIndex + " - y:" + yIndex

	Local gridAABB:AABB = New AABB(xIndex*gWorld.tileWidth, yIndex*gWorld.tileHeight, (xIndex+1)*gWorld.tileWidth, (yIndex+1)*gWorld.tileHeight)
	Local lines:ArrayList<LineSegment> = gridAABB.GetLines()

	Local segment:LineSegment = New LineSegment(position.X-(movement.X*2), position.Y-(movement.Y*2), position.X, position.Y)

	Local intersectionFound:Bool = False 
	Local intersectPoint:Vector = New Vector()
	Local index:Int = 0
	For index = 0 Until lines.Size()
		If Intersects(segment, lines.Get(index), intersectPoint) Then
			Print "Intersection Found: " + index
			intersectionFound = True
			Exit
		End
	End	
	
	Print "intersects: " + intersectPoint.X + "," + intersectPoint.Y
	If Not intersectionFound
		Return New Vector(0,0)
	End
	
	Local remaining:Float = position.Subtract(intersectPoint).Length()
	Print "remaining: " + remaining
	Local velocity:Vector = New Vector(movement.X, movement.Y)
	
	Select index
		Case 0 
			velocity.Y *= -1
		Case 1
			velocity.X *= -1
		Case 2
			velocity.Y *= -1
		Case 3
			velocity.X *= -1
	End
	
	velocity.Normalize()
	velocity.ScaleLocal(remaining)
	Return velocity
End

	


