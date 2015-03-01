
Import world

Import diddy
Import monkey.list

Class AStarSearch

	Field neighbors:ArrayList<TanksPoint>
	Field comparator:StateComparator
	
	Field offsets:ArrayList<TanksPoint>
	
	'--------------------------------------------------------------------------
	Method New()
		neighbors = New ArrayList<TanksPoint>()
		neighbors.Add(New TanksPoint(0, 1))
		neighbors.Add(New TanksPoint(1, 0))
		neighbors.Add(New TanksPoint(0, -1))
		neighbors.Add(New TanksPoint(-1, 0))
		
		offsets = New ArrayList<TanksPoint>()
		offsets.Add(neighbors.Get(0))
		offsets.Add(neighbors.Get(1))
		offsets.Add(neighbors.Get(2))
		offsets.Add(neighbors.Get(3))
		offsets.Add(New TanksPoint(-1, -1))
		offsets.Add(New TanksPoint(1, -1))
		offsets.Add(New TanksPoint(1, 1))
		offsets.Add(New TanksPoint(1, 1))
	End

	'--------------------------------------------------------------------------
	's is the start location
	'g is the goal location
	Method FindPath:ArrayList<Vector>(s:Vector, g:Vector)
		Local start:State = New State(Floor(s.X / gWorld.tileWidth), Floor(s.Y / gWorld.tileHeight))
		Local goal:State = New State(Floor(g.X / gWorld.tileWidth), Floor(g.Y / gWorld.tileHeight))
			
		Local explored:StringMap<State>	= New StringMap<State>()
		start.cost = 0
		start.estimate = ManhattanDistanceTB(start, start, goal)
		
		Local openMap:StringMap<State> = New StringMap<State>()
		Local open:StateList = New StateList()
		
		open.Add(start)
		openMap.Set( start.key, start)
		
		Local endState:State = Null		
		While Not open.IsEmpty()
			Local current:State = open.RemoveAt(0)
			openMap.Remove(current.key)
			
			If current.key.Compare(goal.key) = 0 Then
				endState = current
				Exit
			End
			
			explored.Set( current.key, current )
			Local list:ArrayList<State> = Neighbors(current)
			For Local n:State = Eachin list
				
				If explored.Contains(n.key) Then
					Continue
				End
				
				Local g:Float = current.cost + n.actionCost
				Local h:Float = ManhattanDistanceTB(n, start, goal)
				
				Local isBetter:Bool = False
				Local tmp:State = openMap.Get( n.key )
				If tmp = Null Then
					isBetter = True
				Else If g < tmp.cost
					isBetter = True
					
					openMap.Remove( tmp.key )
					open.Remove( tmp )
				Else
					isBetter = False
				End
				
				If isBetter Then
					n.cost = g
					n.estimate = h
					n.cameFrom = current
					
					open.Add(n)
					openMap.Set(n.key, n)
					
					' At this point we need to resort the open list
					open.Sort(False, comparator)
				End
			End
		End
		
		Local path:ArrayList<Vector> = New ArrayList<Vector>()
		If endState = Null Then
			'no path so no where to go to
			Return path
		End
		
		'now that end state is not null, we need to create the sequence of steps from
		'where the current user is to the final position
		
		path.Add( g )
		
		Local tmp:State = endState
		While tmp.cameFrom <> Null 
			tmp = tmp.cameFrom
			path.AddFirst(New Vector( tmp.x * gWorld.tileWidth + 16, tmp.y * gWorld.tileHeight + 16 ) )
		End
		Return path		
	End
	
	'--------------------------------------------------------------------------
	Method ManhattanDistance:Float(current:State, start:State, goal:State)
		Local dx:Int = Abs( goal.x - current.x )
		Local dy:Int = Abs( goal.y - current.y )
		Return dx + dy		
	End
	
	'--------------------------------------------------------------------------
	Method ManhattanDistanceTB:Float(current:State, start:State, goal:State)
		Local h:Float = ManhattanDistance(current, start, goal)
	
		Local dx1:Int = current.x - goal.x
		Local dy1:Int = current.y - goal.y
		
		Local dx2:Int = start.x - goal.x
		Local dy2:Int = start.y - goal.y
		
		Local cross:Float = Abs( dx1*dy2 - dx2*dy1 )
		h += cross*0.001		
		Return h
	End

	'--------------------------------------------------------------------------
	Method IsPassable:Bool(x:Int, y:Int)
		'first test the tile itself
		If x >= gWorld.numTilesX Or x < 0 Then
			Return False 
		End
			
		If y >= gWorld.numTilesY Or y < 0 Then
			Return False
		End

		If gWorld.world1[y][x] >= 17 Then
			Return False	
		End

		For Local delta: TanksPoint = Eachin offsets
			Local newx:Int = x + delta.x
			Local newy:Int = y + delta.y

			If newx >= gWorld.numTilesX Or newx < 0 Then
				Return False 
			End
			
			If newy >= gWorld.numTilesY Or newy < 0 Then
				Return False
			End
			
			If gWorld.world1[newy][newx] >= 17
				Return False
			End
		End
		Return True
	End
	
	'--------------------------------------------------------------------------
	Method Neighbors:ArrayList<State>(s:State)
		'This method will test and add the four neighbor states
		Local results:ArrayList<State> = New ArrayList<State>
		
		For Local delta: TanksPoint = Eachin neighbors
			Local newx:Int = s.x + delta.x
			Local newy:Int = s.y + delta.y
			
			If Not IsPassable(newx, newy) Then
				Continue
			End

			Local cost:Float = 1
			If delta.x <> 0 Or delta.y <> 0 Then
				cost = 1.44
			End 			
			
			If gWorld.world1[newy][newx] > 0 Then
				cost += 0.25
			End	
			
			results.Add(New State(s, newx, newy, cost))
		End
		
		Return results
	End
	
	
End

'--------------------------------------------------------------------------
Class State
	Field x:Int
	Field y:Int
	
	Field key:String
	
	Field cameFrom:State
	
	Field cost:Float
	Field estimate:Float
	
	Field actionCost:Float
	
	Method New(x:Int, y:Int)
		Self.x = x
		Self.y = y
		
		Self.key = x + "," + y
	End
	
	Method New(cameFrom:State, x:Int, y:Int, actionCost:Float)
		Self.x = x
		Self.y = y
		
		Self.key = x + "," + y

		Self.cameFrom = cameFrom
		Self.actionCost = actionCost
	End
End


'--------------------------------------------------------------------------
Class StateList Extends List<State>
	
	Method New( data:State[] )
		Super.New( data )
	End
	
	Method Join$( separator:String="" )
		Return separator.Join( ToArray() )
	End
	
	Method Equals?( lhs$,rhs$ )
		Return lhs=rhs
	End

	Method Compare( lhs$,rhs$ )
		Local s1:State = State(lhs)
		Local s2:State = State(rhs)
		
		If s1.cost < s2.cost Then Return -1
		If s1.cost > s2.cost Then Return 1
		Return 0
	End

End

