;;;
;;;  =================================================================
;;;
;;;      Simulation world definition
;;;
;;;  =================================================================
;;;

;;;
;;;  Global variables and constants
;;;
globals [ROOM_FLOOR SHELF RAMP WALL WITHOUT_CARGO COLOR_BLUE COLOR_GREEN COLOR_YELLOW COLOR_RED]

;;;
;;;  Declare two types of turtles
;;;
breed [ robots robot ]
breed [ boxes box ]

;;;
;;;  Declare cells' properties
;;;
patches-own [kind shelf-color]

;;;
;;; Declare robots' properties
;;;

robots-own [cargo]
;; cargo: Return the box turtle carried by the robot or WITHOUT_CARGO if no box is currently being carried

;;;
;;;  The boxes have a color property
;;;
boxes-own [box-color]

;;;
;;;  Reset the simulation
;;;
to reset
  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  ;;__clear-all-and-reset-ticks
  clear-all
  reset-ticks
  set-globals
  setup-patches
  setup-turtles
  ask robots [init-robot]
end

;;;
;;;  Setup all the agents. Create robots ands boxes
;;;
to setup-turtles
  create-robots 3

  ;; set robot 1
  ask turtle 0 [set color sky]
  ask turtle 0 [set xcor -5]
  ask turtle 0 [set ycor -3]
  ask turtle 0 [set heading 90]
  ask turtle 0 [set cargo WITHOUT_CARGO]

  ;; set robot 2
  ask turtle 1 [set color orange]
  ask turtle 1 [set xcor -5]
  ask turtle 1 [set ycor -4]
  ask turtle 1 [set heading 90]
  ask turtle 1 [set cargo WITHOUT_CARGO]

  ;; set robot 3
  ask turtle 2 [set color magenta]
  ask turtle 2 [set xcor -5]
  ask turtle 2 [set ycor -5]
  ask turtle 2 [set heading 90]
  ask turtle 2 [set cargo WITHOUT_CARGO]

  set-default-shape boxes "box"
  create-boxes 8

  ;; set caixa 1
  ask turtle 3 [set color blue + 2]
  ask turtle 3 [set xcor -1]
  ask turtle 3 [set ycor -5]
  ask turtle 3 [set heading 0]
  ask turtle 3 [set size 0.7]
  ask turtle 3 [set box-color COLOR_BLUE]

  ;; set caixa 2
  ask turtle 4 [set color red + 2]
  ask turtle 4 [set xcor -1]
  ask turtle 4 [set ycor -4]
  ask turtle 4 [set heading 0]
  ask turtle 4 [set size 0.7]
  ask turtle 4 [set box-color COLOR_RED]

  ;; set caixa 3
  ask turtle 5 [set color yellow + 2]
  ask turtle 5 [set xcor -1]
  ask turtle 5 [set ycor -3]
  ask turtle 5 [set heading 0]
  ask turtle 5 [set size 0.7]
  ask turtle 5 [set box-color COLOR_YELLOW]

  ;; set caixa 4
  ask turtle 6 [set color green + 2]
  ask turtle 6 [set xcor 0]
  ask turtle 6 [set ycor -3]
  ask turtle 6 [set heading 0]
  ask turtle 6 [set size 0.7]
  ask turtle 6 [set box-color COLOR_GREEN]

  ;; set caixa 5
  ask turtle 7 [set color blue + 2]
  ask turtle 7 [set xcor 1]
  ask turtle 7 [set ycor -3]
  ask turtle 7 [set heading 0]
  ask turtle 7 [set size 0.7]
  ask turtle 7 [set box-color COLOR_BLUE]

  ;; set caixa 6
  ask turtle 8 [set color red + 2]
  ask turtle 8 [set xcor 2]
  ask turtle 8 [set ycor -3]
  ask turtle 8 [set heading 0]
  ask turtle 8 [set size 0.7]
  ask turtle 8 [set box-color COLOR_RED]

  ;; set caixa 7
  ask turtle 9 [set color yellow + 2]
  ask turtle 9 [set xcor 2]
  ask turtle 9 [set ycor -4]
  ask turtle 9 [set heading 0]
  ask turtle 9 [set size 0.7]
  ask turtle 9 [set box-color COLOR_YELLOW]

  ;; set caixa 8
  ask turtle 10 [set color green + 2]
  ask turtle 10 [set xcor 2]
  ask turtle 10 [set ycor -5]
  ask turtle 10 [set heading 0]
  ask turtle 10 [set size 0.7]
  ask turtle 10 [set box-color COLOR_GREEN]
end

;;;
;;;  Setup the environment. Populate the room.
;;;
to setup-patches
  ;; Build the floor
  ask patches [
    set kind ROOM_FLOOR
    set pcolor gray + 4 ]

  ;; Build the wall
  foreach [-6 -5 -4 -3 -2 -1 1 0 1 2 3 4 5 6]
    [ [?1] -> ask patch ?1 -6 [set pcolor black]
      ask patch ?1 -6 [set kind WALL]
      ask patch ?1 6 [set pcolor black]
      ask patch ?1 6 [set kind WALL]
      ask patch -6 ?1 [set pcolor black]
      ask patch -6 ?1 [set kind WALL]
      ask patch 6 ?1 [set pcolor black]
      ask patch 6 ?1 [set kind WALL] ]

  ;; Build the ramp
  foreach [-1 0 1 2] [ [?1] ->
    ask patch ?1 -5 [set pcolor gray + 3]
    ask patch ?1 -5 [set kind RAMP]
    ask patch ?1 -4 [set pcolor gray + 3]
    ask patch ?1 -4 [set kind RAMP]
    ask patch ?1 -3 [set pcolor gray + 3]
    ask patch ?1 -3 [set kind RAMP]
  ]

  ;; Build the blue shelf
  ask patch -5 4 [set pcolor blue]
  ask patch -5 4 [set kind SHELF]
  ask patch -5 4 [set shelf-color COLOR_BLUE]
  ask patch -4 4 [set pcolor blue]
  ask patch -4 4 [set kind SHELF]
  ask patch -4 4 [set shelf-color COLOR_BLUE]

  ;; Build the yellow shelf
  ask patch 5 4 [set pcolor yellow]
  ask patch 5 4 [set kind SHELF]
  ask patch 5 4 [set shelf-color COLOR_YELLOW]
  ask patch 4 4 [set pcolor yellow]
  ask patch 4 4 [set kind SHELF]
  ask patch 4 4 [set shelf-color COLOR_YELLOW]

  ;; Build the green shelf
  ask patch 5 2 [set pcolor green]
  ask patch 5 2 [set kind SHELF]
  ask patch 5 2 [set shelf-color COLOR_GREEN]
  ask patch 4 2 [set pcolor green]
  ask patch 4 2 [set kind SHELF]
  ask patch 4 2 [set shelf-color COLOR_GREEN]

  ;; Build the red shelf
  ask patch -5 2 [set pcolor red]
  ask patch -5 2 [set kind SHELF]
  ask patch -5 2 [set shelf-color COLOR_RED]
  ask patch -4 2 [set pcolor red]
  ask patch -4 2 [set kind SHELF]
  ask patch -4 2 [set shelf-color COLOR_RED]
end

;;;
;;;  Set global variables' values
;;;
to set-globals
  set WITHOUT_CARGO 0
  set ROOM_FLOOR 1
  set SHELF 2
  set RAMP 3
  set WALL 4
  set COLOR_BLUE 10
  set COLOR_GREEN 11
  set COLOR_YELLOW 12
  set COLOR_RED 13
end

;;;
;;;  Count the number of boxes on shelves
;;;
to-report delivered-boxes
  let num-boxes 0

  foreach [who] of boxes
  [ [?1] -> ask turtle ?1
    [ if [kind] of patch-here = SHELF
      [ set num-boxes (num-boxes + 1) ]
    ]
  ]
  report num-boxes
end

;;;
;;;  Return the number of robots in the initial position
;;;
to-report robots-initial-position
  let num-robots 0
  let positions [-5 -3  ; robot 1
                -5 -4  ; robot 2
                -5 -5] ; robot 3

  foreach [0 1 2] ; robots' ids
  [ [?1] -> ask turtle ?1
    [ if xcor = item (2 * ?1) positions and
         ycor = item (2 * ?1 + 1) positions
      [ set num-robots (num-robots + 1) ]
    ]
  ]

  report num-robots
end

;;;
;;;  Step up the simulation
;;;
to go
  tick
  ;; hte robots act
  ask robots [
      robot-loop
  ]
  ;; Check if the goal was achieved
  ;; the 8 boxes are on their shelves and the 3 robots are on their initial positions
  if delivered-boxes = 8 and robots-initial-position = 3
    [ stop ]
end

;;;
;;;  NOTE: Please, do not change the code abothe this line.
;;;

;;;
;;;  =================================================================
;;;
;;;      AGENT DEFINITION
;;;
;;;  =================================================================
;;;

;;;
;;;  Procedure that initializes the robot's state
;;;
to init-robot
  set cargo WITHOUT_CARGO
end

;;;
;;;  Robot's updating procedure, which defines the rules of its behaviors
;;;

to robot-loop
  ;;; move-ahead
  ifelse not(box-cargo?) and box-cell? and ramp-cell?
  [pick-box]
  [ ifelse box-cargo? and (shelf-color? = cargo-box-color) and not(box-cell?) and shelf-cell?
    [drop-box]
    [ifelse not(free-cell?)
      [rotate]
      [ifelse (random 5 = 0)
        [rotate]
        [move-ahead]
      ]
    ]
  ]
end

;;;to robot-loop-antigo
;;;  ifelse not(box-cargo?) and box-ahead and ramp-ahead
;;;  [move-box]
;;;  [ ifelse box-cargo? and (shelf-ahead = cargo-box-color) and not(box-ahead)
;;;    [];drop-box]
;;;    [ifelse not(free-ahead)
;;;      [rotate]
;;;      [move-ahead]
;;;    ]
;;;  ]
;;;end

;;;
;;; ------------------------
;;;   Supplementary functions
;;; ------------------------
;;;

;; Stor
to-report box-cell?
  report box-ahead != nobody
end

to-report ramp-cell?
  let ahead (patch-ahead 1)
  report ( [kind] of ahead = RAMP)
end

to-report shelf-cell?
  let ahead (patch-ahead 1)
  report ( [kind] of ahead = SHELF)
end

to-report shelf-color?
  let ahead (patch-ahead 1)
  report [shelf-color] of ahead
end

to-report free-cell?
  let ahead (patch-ahead 1)
  report ( [kind] of ahead = ROOM_FLOOR and not any? robots-on ahead)
end

;;;
;;;  Returns the shelf in front of the robot
;;;  Returns 'nobody' if no boxes are found
;;;
to-report free-ahead
  let ahead (patch-ahead 1)
  if [kind] of ahead = ROOM_FLOOR and not([kind] of ahead = SHELF)
  and not([kind] of ahead = RAMP) and not([kind] of ahead = WALL)
  [report [shelf-color] of ahead]
end

;;;
;;;  Returns the shelf color in front of the robot
;;;  Returns 'nobody' if no shelf are found
;;;
;;;to-report shelf-ahead
;;;  let ahead (patch-ahead 1)
;;;  if [kind] of ahead = SHELF
;;;  [report [shelf-color] of ahead]
;;;end

;;;
;;;  Returns the ramp in front of the robot
;;;  Returns 'nobody' if no ramp are found
;;;
;;;to-report ramp-ahead
;;;  let ahead (patch-ahead 1)
;;;  if [kind] of ahead = RAMP
;;;  [report true]
;;;end

;;;
;;;  Returns the box in front of the robot
;;;  Returns 'nobody' if no boxes are found
;;;
to-report box-ahead
  report one-of boxes-on patch-ahead 1
end

;;;
;;;  Move the box to the robot's current position
;;;
to move-box
  let r-xcor xcor
  let r-ycor ycor
  ask cargo [set xcor r-xcor]
  ask cargo [set ycor r-ycor]
end

;;;
;;; ------------------------
;;;   Actuators
;;; ------------------------
;;;

;;;
;;;  Move the robot forward
;;;
to move-ahead
  let ahead (patch-ahead 1)
  ;; check if the cell is free
  if ([kind] of ahead = ROOM_FLOOR) and (not any? robots-on ahead)
  [ fd 1
    if not (cargo = WITHOUT_CARGO)
    [move-box] ]
end

;;;
;;;  Rotate the robot
;;;
to rotate
  ifelse (random 2 = 0)
  [lt 90 ]
  [rt 90 ]
end

;;;
;;;  Drop the box
;;;
to drop-box
  let ahead (patch-ahead 1)
  if (not (cargo = WITHOUT_CARGO))
  [ask cargo [set xcor [pxcor] of ahead]
    ask cargo [set ycor [pycor] of ahead]
    set cargo WITHOUT_CARGO]
end

;;;
;;;  Pick the box
;;;
to pick-box
  let b (box-ahead)
  if (not (b = nobody))
  [set cargo b
    move-box]
end

;;;
;;; ------------------------
;;;   Sensors
;;; ------------------------
;;;

;;;
;;;  Check if the robot is carrying a box
;;;
to-report box-cargo?
  report not (cargo = WITHOUT_CARGO)
end

;;;
;;;  Return the color of the box in robot's cargo or WITHOUT_CARGO otherwise
;;;
to-report cargo-box-color
  ifelse box-cargo?
    [ report [box-color] of cargo ]
    [ report WITHOUT_CARGO ]
end
@#$#@#$#@
GRAPHICS-WINDOW
321
10
849
539
-1
-1
40.0
1
10
1
1
1
0
1
1
1
-6
6
-6
6
0
0
1
ticks
30.0

BUTTON
29
26
95
59
NIL
Reset
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
130
27
199
60
Run
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
230
27
298
60
Step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
29
71
143
116
Delivered boxes
delivered-boxes
0
1
11

MONITOR
30
124
196
169
Robots in initial postion
robots-initial-position
0
1
11

@#$#@#$#@
## ACTUATORES:

move-ahead: Move the robot forward

## SENSORS:

box-cargo?: Check if the robot is carrying a box
cargo-box-color: Return the color of the box in robot's cargo or WITHOUT_CARGO otherwise

## Supplementary functions

box-ahead: Returns the box in front of the robot or 'nobody' if no boxes are found
move-box: Move the box to the robot's current position
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

ant
true
0
Polygon -7500403 true true 136 61 129 46 144 30 119 45 124 60 114 82 97 37 132 10 93 36 111 84 127 105 172 105 189 84 208 35 171 11 202 35 204 37 186 82 177 60 180 44 159 32 170 44 165 60
Polygon -7500403 true true 150 95 135 103 139 117 125 149 137 180 135 196 150 204 166 195 161 180 174 150 158 116 164 102
Polygon -7500403 true true 149 186 128 197 114 232 134 270 149 282 166 270 185 232 171 195 149 186
Polygon -7500403 true true 225 66 230 107 159 122 161 127 234 111 236 106
Polygon -7500403 true true 78 58 99 116 139 123 137 128 95 119
Polygon -7500403 true true 48 103 90 147 129 147 130 151 86 151
Polygon -7500403 true true 65 224 92 171 134 160 135 164 95 175
Polygon -7500403 true true 235 222 210 170 163 162 161 166 208 174
Polygon -7500403 true true 249 107 211 147 168 147 168 150 213 150

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

bee
true
0
Polygon -1184463 true false 152 149 77 163 67 195 67 211 74 234 85 252 100 264 116 276 134 286 151 300 167 285 182 278 206 260 220 242 226 218 226 195 222 166
Polygon -16777216 true false 150 149 128 151 114 151 98 145 80 122 80 103 81 83 95 67 117 58 141 54 151 53 177 55 195 66 207 82 211 94 211 116 204 139 189 149 171 152
Polygon -7500403 true true 151 54 119 59 96 60 81 50 78 39 87 25 103 18 115 23 121 13 150 1 180 14 189 23 197 17 210 19 222 30 222 44 212 57 192 58
Polygon -16777216 true false 70 185 74 171 223 172 224 186
Polygon -16777216 true false 67 211 71 226 224 226 225 211 67 211
Polygon -16777216 true false 91 257 106 269 195 269 211 255
Line -1 false 144 100 70 87
Line -1 false 70 87 45 87
Line -1 false 45 86 26 97
Line -1 false 26 96 22 115
Line -1 false 22 115 25 130
Line -1 false 26 131 37 141
Line -1 false 37 141 55 144
Line -1 false 55 143 143 101
Line -1 false 141 100 227 138
Line -1 false 227 138 241 137
Line -1 false 241 137 249 129
Line -1 false 249 129 254 110
Line -1 false 253 108 248 97
Line -1 false 249 95 235 82
Line -1 false 235 82 144 100

bird1
false
0
Polygon -7500403 true true 2 6 2 39 270 298 297 298 299 271 187 160 279 75 276 22 100 67 31 0

bird2
false
0
Polygon -7500403 true true 2 4 33 4 298 270 298 298 272 298 155 184 117 289 61 295 61 105 0 43

boat1
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -13345367 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7500403 true true 158 33 230 157 182 150 169 151 157 156
Polygon -7500403 true true 149 55 88 143 103 139 111 136 117 139 126 145 130 147 139 147 146 146 149 55

boat2
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -13345367 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7500403 true true 157 54 175 79 174 96 185 102 178 112 194 124 196 131 190 139 192 146 211 151 216 154 157 154
Polygon -7500403 true true 150 74 146 91 139 99 143 114 141 123 137 126 131 129 132 139 142 136 126 142 119 147 148 147

boat3
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -13345367 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7500403 true true 158 37 172 45 188 59 202 79 217 109 220 130 218 147 204 156 158 156 161 142 170 123 170 102 169 88 165 62
Polygon -7500403 true true 149 66 142 78 139 96 141 111 146 139 148 147 110 147 113 131 118 106 126 71

box
true
0
Polygon -7500403 true true 45 255 255 255 255 45 45 45

butterfly1
true
0
Polygon -16777216 true false 151 76 138 91 138 284 150 296 162 286 162 91
Polygon -7500403 true true 164 106 184 79 205 61 236 48 259 53 279 86 287 119 289 158 278 177 256 182 164 181
Polygon -7500403 true true 136 110 119 82 110 71 85 61 59 48 36 56 17 88 6 115 2 147 15 178 134 178
Polygon -7500403 true true 46 181 28 227 50 255 77 273 112 283 135 274 135 180
Polygon -7500403 true true 165 185 254 184 272 224 255 251 236 267 191 283 164 276
Line -7500403 true 167 47 159 82
Line -7500403 true 136 47 145 81
Circle -7500403 true true 165 45 8
Circle -7500403 true true 134 45 6
Circle -7500403 true true 133 44 7
Circle -7500403 true true 133 43 8

circle
false
0
Circle -7500403 true true 35 35 230

link
true
0
Line -7500403 true 150 0 150 300

link direction
true
0
Line -7500403 true 150 150 30 225
Line -7500403 true 150 150 270 225

person
false
0
Circle -7500403 true true 155 20 63
Rectangle -7500403 true true 158 79 217 164
Polygon -7500403 true true 158 81 110 129 131 143 158 109 165 110
Polygon -7500403 true true 216 83 267 123 248 143 215 107
Polygon -7500403 true true 167 163 145 234 183 234 183 163
Polygon -7500403 true true 195 163 195 233 227 233 206 159

sheep
false
15
Rectangle -1 true true 90 75 270 225
Circle -1 true true 15 75 150
Rectangle -16777216 true false 81 225 134 286
Rectangle -16777216 true false 180 225 238 285
Circle -16777216 true false 1 88 92

spacecraft
true
0
Polygon -7500403 true true 150 0 180 135 255 255 225 240 150 180 75 240 45 255 120 135

thin-arrow
true
0
Polygon -7500403 true true 150 0 0 150 120 150 120 293 180 293 180 150 300 150

truck-down
false
0
Polygon -7500403 true true 225 30 225 270 120 270 105 210 60 180 45 30 105 60 105 30
Polygon -8630108 true false 195 75 195 120 240 120 240 75
Polygon -8630108 true false 195 225 195 180 240 180 240 225

truck-left
false
0
Polygon -7500403 true true 120 135 225 135 225 210 75 210 75 165 105 165
Polygon -8630108 true false 90 210 105 225 120 210
Polygon -8630108 true false 180 210 195 225 210 210

truck-right
false
0
Polygon -7500403 true true 180 135 75 135 75 210 225 210 225 165 195 165
Polygon -8630108 true false 210 210 195 225 180 210
Polygon -8630108 true false 120 210 105 225 90 210

turtle
true
0
Polygon -7500403 true true 138 75 162 75 165 105 225 105 225 142 195 135 195 187 225 195 225 225 195 217 195 202 105 202 105 217 75 225 75 195 105 187 105 135 75 142 75 105 135 105

wolf
false
0
Rectangle -7500403 true true 15 105 105 165
Rectangle -7500403 true true 45 90 105 105
Polygon -7500403 true true 60 90 83 44 104 90
Polygon -16777216 true false 67 90 82 59 97 89
Rectangle -1 true false 48 93 59 105
Rectangle -16777216 true false 51 96 55 101
Rectangle -16777216 true false 0 121 15 135
Rectangle -16777216 true false 15 136 60 151
Polygon -1 true false 15 136 23 149 31 136
Polygon -1 true false 30 151 37 136 43 151
Rectangle -7500403 true true 105 120 263 195
Rectangle -7500403 true true 108 195 259 201
Rectangle -7500403 true true 114 201 252 210
Rectangle -7500403 true true 120 210 243 214
Rectangle -7500403 true true 115 114 255 120
Rectangle -7500403 true true 128 108 248 114
Rectangle -7500403 true true 150 105 225 108
Rectangle -7500403 true true 132 214 155 270
Rectangle -7500403 true true 110 260 132 270
Rectangle -7500403 true true 210 214 232 270
Rectangle -7500403 true true 189 260 210 270
Line -7500403 true 263 127 281 155
Line -7500403 true 281 155 281 192

wolf-left
false
3
Polygon -6459832 true true 117 97 91 74 66 74 60 85 36 85 38 92 44 97 62 97 81 117 84 134 92 147 109 152 136 144 174 144 174 103 143 103 134 97
Polygon -6459832 true true 87 80 79 55 76 79
Polygon -6459832 true true 81 75 70 58 73 82
Polygon -6459832 true true 99 131 76 152 76 163 96 182 104 182 109 173 102 167 99 173 87 159 104 140
Polygon -6459832 true true 107 138 107 186 98 190 99 196 112 196 115 190
Polygon -6459832 true true 116 140 114 189 105 137
Rectangle -6459832 true true 109 150 114 192
Rectangle -6459832 true true 111 143 116 191
Polygon -6459832 true true 168 106 184 98 205 98 218 115 218 137 186 164 196 176 195 194 178 195 178 183 188 183 169 164 173 144
Polygon -6459832 true true 207 140 200 163 206 175 207 192 193 189 192 177 198 176 185 150
Polygon -6459832 true true 214 134 203 168 192 148
Polygon -6459832 true true 204 151 203 176 193 148
Polygon -6459832 true true 207 103 221 98 236 101 243 115 243 128 256 142 239 143 233 133 225 115 214 114

wolf-right
false
3
Polygon -6459832 true true 170 127 200 93 231 93 237 103 262 103 261 113 253 119 231 119 215 143 213 160 208 173 189 187 169 190 154 190 126 180 106 171 72 171 73 126 122 126 144 123 159 123
Polygon -6459832 true true 201 99 214 69 215 99
Polygon -6459832 true true 207 98 223 71 220 101
Polygon -6459832 true true 184 172 189 234 203 238 203 246 187 247 180 239 171 180
Polygon -6459832 true true 197 174 204 220 218 224 219 234 201 232 195 225 179 179
Polygon -6459832 true true 78 167 95 187 95 208 79 220 92 234 98 235 100 249 81 246 76 241 61 212 65 195 52 170 45 150 44 128 55 121 69 121 81 135
Polygon -6459832 true true 48 143 58 141
Polygon -6459832 true true 46 136 68 137
Polygon -6459832 true true 45 129 35 142 37 159 53 192 47 210 62 238 80 237
Line -16777216 false 74 237 59 213
Line -16777216 false 59 213 59 212
Line -16777216 false 58 211 67 192
Polygon -6459832 true true 38 138 66 149
Polygon -6459832 true true 46 128 33 120 21 118 11 123 3 138 5 160 13 178 9 192 0 199 20 196 25 179 24 161 25 148 45 140
Polygon -6459832 true true 67 122 96 126 63 144
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
