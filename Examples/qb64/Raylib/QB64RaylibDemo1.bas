'Raster Master Demo Showing how inlcude RES Text Include using QB64 and Raylib

'$INCLUDE:'include/raylib.bi'

Const screenWidth = 800
Const screenHeight = 450

InitWindow screenWidth, screenHeight, "Raster Master Export to raylib RGB"
'make sure to always include after the InitWindow command, if you don't things will not work properly
'$INCLUDE:'planes.bas'

SetTargetFPS 60
Dim X, Y, C As Integer
X = 190
Y = 150
C = 0
Do Until WindowShouldClose
    If IsKeyDown(KEY_UP) Then Y = Y - 5
    If IsKeyDown(KEY_DOWN) Then Y = Y + 5
    If IsKeyDown(KEY_RIGHT) Then X = X + 5
    If IsKeyDown(KEY_LEFT) Then X = X - 5
    If IsKeyDown(KEY_C) Then C = C + 1: If C > 2 Then C = 0

    BeginDrawing
    ClearBackground BLUE
    DrawText "Use the arrow keys to move image texture arround", 150, 200, 20, LIGHTGRAY
    DrawText "Press C to Change Planes", 150, 220, 20, LIGHTGRAY
    Select Case C
        Case 0: DrawTexture BluePlaneTexture, X, Y, WHITE
        Case 1: DrawTexture OrangePlaneTexture, X, Y, WHITE
        Case 2: DrawTexture GreenPlaneTexture, X, Y, WHITE
    End Select


    EndDrawing
Loop

CloseWindow

System
'$INCLUDE:'include/raylib.bas'

