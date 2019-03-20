;;;
;;;  =================================================================
;;;
;;;      Simulation world definition
;;;
;;;  =================================================================
;;;

;;;
;;;  Use the "array" extension for easy and efficient Q-value storage
;;;
extensions [array]

;;;
;;;  Declare three types of entities in the environment
;;;
breed [ blocks block ]
breed [ passengers passenger ]
breed [ taxis taxi ]

;;;
;;;  Global variables and constants:
;;;
;;;  - NUM-ACTIONS: the number of actions considered
;;;  - ACTION-LIST: the available actions in (x y) increment form
;;;  - epsilon: probability of choosing a random action, decreased in each trial
;;;  - temperature: a paremeter influencing action selection in soft-max
;;;  - episode-count: the total number of episodes
;;;  - time-steps: the number of time-steps within the current episode
;;;
globals [NUM-ACTIONS ACTION-LIST epsilon temperature episode-count time-steps total-time-steps]

;;;
;;;  Declare agents' properties:
;;;
;;;  - Q-values: holds the Q-value function updated by Q-learning in the form (x y action) -> value
;;;  - reward: the current reward
;;;
taxis-own [Q-values reward total-reward init_xcor init_ycor previous-xcor previous-ycor]

;;;
;;;  Declare passenger / problem properties
;;;
passengers-own [destination]

;;;  =================================================================
;;;      Interface reports
;;;  =================================================================

to-report get-total-time-steps
  report total-time-steps
end

to-report get-episode-count
  report episode-count
end

;;;  =================================================================
;;;      Setup
;;;  =================================================================

;;;
;;;  Setup the simulation.
;;;
to setup
  clear-all
  set-globals
  setup-patches
  setup-turtles
  reset-ticks
end

;;;
;;;  Set global variables' values.
;;;
to set-globals
  set time-steps 0
  set episode-count 0
  set epsilon 1
  set temperature 100

  ; defines list of actions as (x y) move increments
  set ACTION-LIST (list
    list 0 1    ; N north
    list 0 -1   ; S south
    list 1 0    ; E east
    list -1 0   ; W west
    )

  ; defines the number of available actions from above
  set NUM-ACTIONS 4
end

;;;
;;;  Setup patches.
;;;
to setup-patches
  ask patches [ set pcolor white ]
  ask patches with [ (pxcor + pycor) mod 2 = 0 ][ set pcolor gray + 4.5 ]
end

;;;
;;;  Setup all the entities.
;;;
to setup-turtles

  ; set default shapes
  set-default-shape passengers "person"
  set-default-shape taxis "car"
  set-default-shape blocks "tile brick"

  ; create blocks
  create-blocks num-of-blocks [
    setxy random-pxcor random-pycor
    set color orange - 1
  ]

  ; create taxis / agents
  create-taxis num-taxis [
    set color blue + (random 6) - 2
    set label who - num-of-blocks + 1
    set label-color black
    set size .9
    set heading 0

    set-random-position
    set init_xcor xcor
    set init_ycor ycor

    set previous-xcor (xcor + max-pxcor)
    set previous-ycor (ycor + max-pycor)
    set Q-values get-initial-Q-values
    set reward 0
    set total-reward 0
  ]

  ; create passengers
  create-passengers num-taxis [
    set-random-position
    set color pink + (random 6) - 2
    set label who - num-taxis - num-of-blocks + 1
    set label-color black
    set size .9
  ]

end

;;;
;;;  Sets the turtle in a random, empty position
;;;
to set-random-position
  setxy random-pxcor random-pycor
  while [any? other turtles-here] [
    setxy random-pxcor random-pycor
  ]
end

;;;  =================================================================
;;;      Update
;;;  =================================================================

;;;
;;;  Step the simulation.
;;;
to go

  ; if episode is finished starts new episode, otherwise ask each agent to update
  ifelse episode-finished? [
    reset
    if episode-count >= max-episodes [stop]
  ]
  [
    ask taxis [ agent-loop ]
    set total-time-steps (total-time-steps + 1)
  ]
end

;;;
;;;  Starts a new learning episode by resetting the simulation.
;;;
to reset

  ask taxis [
    ; plot reward in episode
    set-current-plot "Reward performance"
    set-current-plot-pen (word who "reward")
    plot total-reward
    set total-reward 0

    ; reset positions
    set xcor init_xcor
    set ycor init_ycor
    set previous-xcor xcor
    set previous-ycor ycor
  ]

  ; plots and update variables
  set-current-plot "Time performance"
  set-current-plot-pen "time-steps"
  plot time-steps

  set episode-count (episode-count + 1)
  set time-steps 0

  ; linearly decrease explorations over time
  set epsilon max list 0 (1 - (episode-count / max-episodes))
  set temperature max list 0.01 epsilon

end

;;;
;;;  Updates an agent by choosing an action and updating Q-value function.
;;;
to agent-loop
  ; chooses action
  let action select-action xcor ycor

  ; updates environmet
  execute-action action

  ; gets reward
  set reward get-reward action
  set total-reward (total-reward + reward)

  ; updates Q-value function
  update-Q-value action
end

;;;  =================================================================
;;;      Utils
;;;  =================================================================

to-report get-action-index [ action ]
  report position action ACTION-LIST
end

;;;
;;;  Creates the initial Q-value function structure: (x y action) <- 0.
;;;
to-report get-initial-Q-values
  report array:from-list n-values world-width [
    array:from-list n-values world-height [
      array:from-list n-values NUM-ACTIONS [0]]]
end

;;;
;;;  Gets the Q-values for a specific state (x y).
;;;
to-report get-Q-values [x y]
  report array:item (array:item Q-values x) y
end

;;;
;;;  Gets the Q-value for a specific state-action pair (x y action).
;;;
to-report get-Q-value [x y action]
  let action-values get-Q-values x y
  report array:item action-values (get-action-index action)
end

;;;
;;;  Sets the Q-value for a specific state-action pair (x y action).
;;;
to set-Q-value [x y action value]
  array:set (get-Q-values x y) (get-action-index action) value
end

;;;
;;;  Gets the maximum Q-value for a specific state (x y).
;;;
to-report get-max-Q-value [x y]
    report max array:to-list get-Q-values x y
end

;;;
;;;  Gets the reward related with the current state and a given action (x y action).
;;;
to-report get-reward [action]

  ; did it pick a passenger solo?
  ifelse (any? passengers-here) and (count taxis-here = 1)
  [
    report reward-value ] [

    ; did it hit another taxi?
    ifelse count taxis-here > 1 [
      report hit-taxi-reward ] [

      ; did it hit a wall / border?
      let next-x xcor + first action
      let next-y ycor + last action
      ifelse (any? blocks-here) or (not legal-move? next-x next-y) [
        report hit-wall-reward ] [
        report 0
      ]
    ]
  ]
end

;;;
;;;  Executes a given action by changing the agent's position accordingly.
;;;
to execute-action [action]

  ; stores previous position
  set previous-xcor xcor
  set previous-ycor ycor

  ; sets position according to action move values for x and y (if possible)
  let next-x xcor + first action
  let next-y ycor + last action
  if legal-move? next-x next-y [
    set xcor next-x
    set ycor next-y
  ]

  ; increases action count
  set time-steps (time-steps + 1)
end

;;;
;;;  Checks whether a given position (x y) is valid for an agent to move.
;;;  A position is valid if it is within the world's limits and there are no blocks there.
;;;
to-report legal-move? [x y]
  report (
    (x >= 0) and (y >= 0) and
    (x <= max-pxcor) and (y <= max-pycor) and
    (not any? blocks-on patch x y))
end

;;;
;;;  Checks whether a episode/trial has finished.
;;;  An episode finishes when all agents/taxis have picked up a different passenger.
;;;
to-report episode-finished?
  report all? taxis [any? passengers-here and (count taxis-here = 1)]
end

;;;  =================================================================
;;;      Learning
;;;  =================================================================

;;;
;;;  Chooses an action for a given state according to the current action selection strategy ("e-greedy" or "soft-max").
;;;
to-report select-action [x y]
  ifelse action-selection = "ε-greedy" [
    report select-action-e-greedy x y] [
    report select-action-soft-max x y]
end

;;;
;;;  Updates the Q-value for a given action according to the selected learning algorithm ("SARSA" or "Q-learning").
;;;
to update-Q-value [action]
  ifelse learning-algorithm = "SARSA" [
    update-SARSA action ] [
    update-Q-learning action ]
end


;;;
;;;  =================================================================
;;;
;;;  NOTE: Do not change the code above this line.
;;;
;;;  =================================================================
;;;

;;;
;;;  LAB EXERCISES: Read the class document carefully and complete the functions below.
;;;


;;;
;;;  Updates the Q-value for a given action according to SARSA algorithm update rule.
;;;  Tips:
;;;    - use "get-Q-value" and "set-Q-value" to update the action-value function
;;;    - properties "previous-xcor" and "previous-ycor" give access to the previous state
;;;
to update-SARSA [action]

end


;;;
;;;  Updates the Q-value for a given action according to the Q-learning algorithm update rule.
;;;  Tips:
;;;    - use "get-Q-value" and "set-Q-value" to update the action-value function
;;;    - properties "previous-xcor" and "previous-ycor" give access to the previous state
;;;
to update-Q-learning [action]

end


;;;
;;;  Chooses an action according to the ε-greedy method.
;;;  Tips:
;;;    - use "array:to-list" to convert an array to a list
;;;
to-report select-action-e-greedy [x y]
  report item (random NUM-ACTIONS) ACTION-LIST
end


;;;
;;;  Chooses an action according to the soft-max method.
;;;  Tips:
;;;    - use "array:to-list" to convert an array to a list
;;;    - use "map" to create a list based on values of another list
;;;
to-report select-action-soft-max [x y]
  report item (random NUM-ACTIONS) ACTION-LIST
end
@#$#@#$#@
GRAPHICS-WINDOW
255
20
529
295
-1
-1
38.0
1
10
1
1
1
0
1
1
1
0
6
0
6
0
0
1
ticks
30.0

BUTTON
15
20
84
53
Set Up
setup
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
160
20
223
53
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
555
20
830
245
Time performance
episode
time-steps / moves
0.0
10.0
0.0
10.0
true
false
"" "set-plot-y-range  min-pycor max-pycor"
PENS
"time-steps" 1.0 0 -16777216 true "" ""

SLIDER
15
196
187
229
learning-rate
learning-rate
0
1
0.9
0.1
1
NIL
HORIZONTAL

SLIDER
15
132
187
165
num-of-blocks
num-of-blocks
0
10
10.0
1
1
NIL
HORIZONTAL

SLIDER
15
305
187
338
reward-value
reward-value
1
5
5.0
0.2
1
NIL
HORIZONTAL

SLIDER
15
91
187
124
num-taxis
num-taxis
1
5
1.0
1
1
NIL
HORIZONTAL

BUTTON
90
20
153
53
Go
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
15
237
187
270
discount-factor
discount-factor
0
1
0.99
0.01
1
NIL
HORIZONTAL

TEXTBOX
16
69
166
87
Environment parameters:
11
0.0
1

TEXTBOX
15
175
165
193
Learning parameters:
11
0.0
1

TEXTBOX
15
285
165
303
Rewards:
11
0.0
1

SLIDER
15
350
187
383
hit-wall-reward
hit-wall-reward
-1
0
-1.0
0.01
1
NIL
HORIZONTAL

SLIDER
15
395
187
428
hit-taxi-reward
hit-taxi-reward
-1
0
-0.5
0.01
1
NIL
HORIZONTAL

MONITOR
260
330
362
375
num. episodes
get-episode-count
17
1
11

MONITOR
385
330
492
375
total time-steps
get-total-time-steps
17
1
11

PLOT
850
20
1120
245
Reward performance
episode
total reward
0.0
10.0
0.0
10.0
true
false
"ask taxis [\n  let pen-name (word who \"reward\")\n  create-temporary-plot-pen pen-name\n  set-current-plot-pen pen-name\n  set-plot-pen-color color\n]" ""
PENS

SLIDER
260
395
432
428
max-episodes
max-episodes
0
1000
1000.0
50
1
NIL
HORIZONTAL

TEXTBOX
15
440
165
458
Options:
11
0.0
1

CHOOSER
15
465
185
510
Learning-algorithm
Learning-algorithm
"SARSA" "Q-learning"
1

CHOOSER
15
520
185
565
Action-selection
Action-selection
"ε-greedy" "soft-max"
0

@#$#@#$#@
Introduction to Reinforcement Learning

Corpo Docente de AASMA

Adaptado de Jose M. Vidal
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

link
true
0
Line -7500403 true 150 0 150 300

link direction
true
0
Line -7500403 true 150 150 30 225
Line -7500403 true 150 150 270 225

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tile brick
false
0
Rectangle -1 true false 0 0 300 300
Rectangle -7500403 true true 15 225 150 285
Rectangle -7500403 true true 165 225 300 285
Rectangle -7500403 true true 75 150 210 210
Rectangle -7500403 true true 0 150 60 210
Rectangle -7500403 true true 225 150 300 210
Rectangle -7500403 true true 165 75 300 135
Rectangle -7500403 true true 15 75 150 135
Rectangle -7500403 true true 0 0 60 60
Rectangle -7500403 true true 225 0 300 60
Rectangle -7500403 true true 75 0 210 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0
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
1
@#$#@#$#@
