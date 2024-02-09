'Sokoban for QB64
'Raster Master Sprite/Map Editor was used to create/assemble graphics/map

Dim Shared board(16, 16), crateboard(16, 16)
Dim Shared emptyblock, wallblock, crateblock, floorblock, pusherleftblock, pusherrightblock
Dim Shared pusherupblock, pusherdownblock, cratemarkerblock, playerleft, playerright
Dim Shared playerup, playerdown, playerdirection
Dim Shared playmode, x, y, i, j, level
Dim Shared maxcol, maxrow, tilewidth, tileheight

Screen _NewImage(800, 600, 32)


Dim Shared VScreen
VScreen = _NewImage(320, 200, 32)
_Dest VScreen

'$INCLUDE:'sokoban.bi'

emptyblock = -1
wallblock = 0
crateblock = 2
floorblock = 4
pusherleftblock = 5
pusherrightblock = 6
pusherupblock = 7
pusherdownblock = 8

cratemarkerblock = 1

playerleft = 0
playerright = 1
playerup = 2
playerdown = 3
playerdirection = playerright

playmode = 1
level = 1

'we read these values from the map data
maxcol = 0
maxrow = 0
tileheight = 0
tileheight = 0


ReadBoard
DrawBoard
DrawPusher
Locate 5, 25
Print "Level:"; level
VScreenToScreen
While playmode
    Sleep
    If _KeyDown(CVI(Chr$(0) + "P")) Then
        MoveDown '_KEYDOWN(20480)
        VScreenToScreen
    End If

    If _KeyDown(CVI(Chr$(0) + "H")) Then
        MoveUp '_KEYDOWN(18432)
        VScreenToScreen
    End If

    If _KeyDown(CVI(Chr$(0) + "K")) Then
        MoveLeft '_KEYDOWN(19200)
        VScreenToScreen
    End If

    If _KeyDown(CVI(Chr$(0) + "M")) Then
        MoveRight '_KEYDOWN(19712)
        VScreenToScreen
    End If

    If PlayerWin Then
        level = level + 1
        If level > 2 Then
            level = 1
        End If

        Sleep 2
        Locate 5, 25
        Print "Level:"; level
        ReadBoard
        DrawBoard
        DrawPusher
        VScreenToScreen
    End If
Wend


Function CanMoveDown
    If (y < maxrow) And board(x, y + 1) = floorblock Then
        CanMoveDown = 1
    ElseIf (y < maxrow) And board(x, y + 1) = cratemarkerblock Then
        CanMoveDown = 1
    ElseIf (y < (maxrow - 1)) And (crateboard(x, y + 1) = crateblock) And ((board(x, y + 2) = floorblock) Or (board(x, y + 2) = cratemarkerblock)) Then
        CanMoveDown = 1
    Else
        CanMoveDown = 0
    End If
End Function

Function CanMoveLeft
    CanMoveLeft = 0
    If (x > 0) And board(x - 1, y) = floorblock Then
        CanMoveLeft = 1
    ElseIf (x > 0) And board(x - 1, y) = cratemarkerblock Then
        CanMoveLeft = 1
    ElseIf (x > 1) And (crateboard(x - 1, y) = crateblock) Then
        If board(x - 2, y) = floorblock Or board(x - 2, y) = cratemarkerblock Then CanMoveLeft = 1
    End If
End Function

Function CanMoveRight
    If (x < maxcol) And board(x + 1, y) = floorblock Then
        CanMoveRight = 1
    ElseIf (x < maxcol) And board(x + 1, y) = cratemarkerblock Then
        CanMoveRight = 1
    ElseIf (x < (maxcol - 1)) And (crateboard(x + 1, y) = crateblock) And ((board(x + 2, y) = floorblock) Or (board(x + 2, y) = cratemarkerblock)) Then
        CanMoveRight = 1
    Else
        CanMoveRight = 0
    End If
End Function

Function CanMoveUp
    CanMoveUp = 0
    If (y > 0) And board(x, y - 1) = floorblock Then
        CanMoveUp = 1
    ElseIf (y > 0) And board(x, y - 1) = cratemarkerblock Then
        CanMoveUp = 1
    ElseIf (y > 1) And (crateboard(x, y - 1) = crateblock) Then
        If (board(x, y - 2) = floorblock) Or (board(x, y - 2) = cratemarkerblock) Then CanMoveUp = 1
    End If
End Function

Sub DrawBoard
    For j = 0 To maxrow
        For i = 0 To maxcol
            Call DrawItem(i, j)
        Next i
    Next j
End Sub

Sub DrawItem (bx As Integer, by As Integer)
    If board(bx, by) = wallblock Then
        _PutImage (bx * tilewidth, by * tileheight), Wall&
    ElseIf crateboard(bx, by) = crateblock Then
        _PutImage (bx * tilewidth, by * tileheight), Crate&
    ElseIf board(bx, by) = cratemarkerblock Then
        _PutImage (bx * tilewidth, by * tileheight), CrateMarker&
    ElseIf board(bx, by) = floorblock Then
        _PutImage (bx * tilewidth, by * tileheight), Floor&
    End If
End Sub

Sub DrawPusher
    If playerdirection = playerleft Then
        _PutImage (x * tilewidth, y * tileheight), PusherLeft&
    ElseIf playerdirection = playerright Then
        _PutImage (x * tilewidth, y * tileheight), PusherRight&
    ElseIf playerdirection = playerup Then
        _PutImage (x * tilewidth, y * tileheight), PusherUp&
    ElseIf playerdirection = playerdown Then
        _PutImage (x * tilewidth, y * tileheight), PusherDown&
    End If
End Sub

Sub GoDown
    playerdirection = playerdown
    If (board(x, y + 1) = floorblock) Or (board(x, y + 1) = cratemarkerblock) Then
        Call DrawItem(x, y)
        y = y + 1
    ElseIf crateboard(x, y + 1) = crateblock Then
        crateboard(x, y + 1) = emptyblock
        crateboard(x, y + 2) = crateblock
        board(x, y + 1) = floorblock
        board(x, y + 2) = emptyblock
        Call DrawItem(x, y + 2)
        Call DrawItem(x, y)
        y = y + 1
    End If
    DrawPusher
End Sub

Sub GoLeft
    playerdirection = playerleft
    If (board(x - 1, y) = floorblock) Or (board(x - 1, y) = cratemarkerblock) Then
        Call DrawItem(x, y)
        x = x - 1
    ElseIf crateboard(x - 1, y) = crateblock Then
        crateboard(x - 1, y) = emptyblock
        crateboard(x - 2, y) = crateblock
        board(x - 1, y) = floorblock
        board(x - 2, y) = emptyblock
        Call DrawItem(x - 2, y)
        Call DrawItem(x, y)
        x = x - 1
    End If
    DrawPusher
End Sub

Sub GoRight
    playerdirection = playerright
    If (board(x + 1, y) = floorblock) Or (board(x + 1, y) = cratemarkerblock) Then
        Call DrawItem(x, y)
        x = x + 1
    ElseIf crateboard(x + 1, y) = crateblock Then
        crateboard(x + 1, y) = emptyblock
        crateboard(x + 2, y) = crateblock
        board(x + 1, y) = floorblock
        board(x + 2, y) = emptyblock
        Call DrawItem(x + 2, y)
        Call DrawItem(x, y)
        x = x + 1
    End If
    Call DrawPusher
End Sub

Sub GoUp
    playerdirection = playerup
    If (board(x, y - 1) = floorblock) Or (board(x, y - 1) = cratemarkerblock) Then
        Call DrawItem(x, y)
        y = y - 1
    ElseIf crateboard(x, y - 1) = crateblock Then
        crateboard(x, y - 1) = emptyblock
        crateboard(x, y - 2) = crateblock
        board(x, y - 1) = floorblock
        board(x, y - 2) = emptyblock
        Call DrawItem(x, y - 2)
        Call DrawItem(x, y)
        y = y - 1
    End If
    DrawPusher
End Sub

Sub MoveDown
    If CanMoveDown Then
        GoDown
    End If
End Sub

Sub MoveLeft
    If CanMoveLeft Then
        GoLeft
    End If
End Sub

Sub MoveRight
    If CanMoveRight Then
        GoRight
    End If
End Sub

Sub MoveUp
    If CanMoveUp Then
        GoUp
    End If
End Sub


Function PlayerWin
    count = 0
    match = 0
    For j = 0 To maxrow
        For i = 0 To maxcol
            If board(i, j) = cratemarkerblock Then
                count = count + 1
                If crateboard(i, j) = crateblock Then
                    match = match + 1
                End If
            End If
        Next i
    Next j
    If count = match Then PlayerWin = 1 Else PlayerWin = 0
End Function

Sub ReadBoard
    If level = 1 Then
        Restore boardMapLabel1
    ElseIf level = 2 Then
        Restore boardMapLabel2
    ElseIf level = 3 Then
        'Restore boardMapLabel3
    ElseIf level = 4 Then
        'Restore boardMapLabel4
    ElseIf level = 5 Then
        'Restore boardMapLabel5
    End If

    Read maxcol, maxrow, tilewidth, tileheight
    maxcol = maxcol - 1
    maxrow = maxrow - 1

    For j = 0 To maxrow
        For i = 0 To maxcol
            Read tile
            If tile = crateblock Then
                crateboard(i, j) = crateblock
                board(i, j) = emptyblock
            ElseIf (tile = pusherleftblock) Then
                x = i
                y = j
                playerdirection = playerleft
                board(i, j) = floorblock
            ElseIf (tile = pusherrightblock) Then
                x = i
                y = j
                playerdirection = playerright
                board(i, j) = floorblock
            ElseIf (tile = pusherupblock) Then
                x = i
                y = j
                playerdirection = playerup
                board(i, j) = floorblock
            ElseIf (tile = pusherdownblock) Then
                x = i
                y = j
                playerdirection = playerdown
                board(i, j) = floorblock
            Else
                board(i, j) = tile
                crateboard(i, j) = emptyblock
            End If
        Next i
    Next j
End Sub

Sub VScreenToScreen
    _Dest 0
    _PutImage (0, 0)-(799, 599), VScreen
    _Dest VScreen
End Sub





