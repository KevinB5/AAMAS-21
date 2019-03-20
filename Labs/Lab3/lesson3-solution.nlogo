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
globals [ROOM_FLOOR SHELF RAMP WALL WITHOUT_CARGO OCCUPIED UNKNOWN COLOR_BLUE COLOR_GREEN COLOR_YELLOW COLOR_RED NUM_STEPS WAREHOUSE_WIDTH NUM_BOXES]

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
;;;  The boxes have a color property
;;;
boxes-own [box-color]


;;;
;;;  =================================================================
;;;
;;;      AGENT DEFINITION
;;;
;;;  =================================================================


;;;            Declare robots' properties
robots-own [
  cargo
  warehouse-map
  current-position
  shelves
  ramp-zone
  boxes-on-shelves
  boxes-on-ramp
  last-action
  desire
  intention
  plan
  ]
;; cargo:            Return the box turtle carried by the robot
;;                   WITHOUT_CARGO if no box is currently being carried
;;
;; warehouse-map:    It is internal map of the warehouse. The (0,0) position is the robot's initial position
;;                   The x coordinate increases from left to right
;;                   The y coordinate increases from bottom to top
;;
;; current-position: It is the current position of the robot, considering origin in its warehouse-map
;;                   It uses the internal abstract type 'postion'
;;
;; shelves:          It contains information about the shelves of the warehouse
;;                   It uses a list with (internal abstract type) 'shelf-info' elements
;;                   Initially the shelf-info is empty
;;
;; ramp-zone:        It contains information about the ramp zone
;;                   It uses a list with (internal abstract type) 'ramp-info' elements
;;                   Initially the shelf-info is empty
;;
;; boxes-on-shelves: Number of delivered boxes
;;
;; boxes-on-ramp:    Number of boxes on the ramp
;;
;; last-action:      It contains the robot's action in the previous robot-loop
;;                   Its values range between: "grab", "drop", "move-ahead", "rotate-left" and "rotate-right"
;;
;; desire:           It indentifies the robot's current desire, according to the desire definition in Chap.4 of [Wooldridge02].
;;                   Its values range between: "grab", "drop" and "initial-position"
;;
;; intention:        It identifies the robot's current intention, according to the intention definition in Chap.4 of [Wooldridge02].
;;                   It uses the internal abstract type 'intention'
;;
;; plan:             It identifies the robot's current plan to achieve its intention
;;                   It uses the internal abstract type 'plan'
;;

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
  ask turtle 0 [
    set color sky
    set xcor -5
    set ycor -3
    set heading 90
    set cargo WITHOUT_CARGO
  ]

  ;; set robot 2
  ask turtle 1 [
    set color orange
    set xcor -5
    set ycor -4
    set heading 90
    set cargo WITHOUT_CARGO
  ]

  ;; set robot 3
  ask turtle 2 [
    set color magenta
    set xcor -5
    set ycor -5
    set heading 90
    set cargo WITHOUT_CARGO
  ]

  set-default-shape boxes "box"
  create-boxes 8

  ;; set box 1
  ask turtle 3 [
    set color blue + 2
    set xcor -1
    set ycor -5
    set heading 0
    set size 0.7
    set box-color COLOR_BLUE
  ]

  ;; set box 2
  ask turtle 4 [
    set color red + 2
    set xcor -1
    set ycor -4
    set heading 0
    set size 0.7
    set box-color COLOR_RED
  ]

  ;; set box 3
  ask turtle 5 [
    set color yellow + 2
    set xcor -1
    set ycor -3
    set heading 0
    set size 0.7
    set box-color COLOR_YELLOW
  ]

  ;; set box 4
  ask turtle 6 [
    set color green + 2
    set xcor 0
    set ycor -3
    set heading 0
    set size 0.7
    set box-color COLOR_GREEN
  ]

  ;; set box 5
  ask turtle 7 [
    set color blue + 2
    set xcor 1
    set ycor -3
    set heading 0
    set size 0.7
    set box-color COLOR_BLUE
  ]

  ;; set box 6
  ask turtle 8 [
    set color red + 2
    set xcor 2
    set ycor -3
    set heading 0
    set size 0.7
    set box-color COLOR_RED
  ]

  ;; set box 7
  ask turtle 9 [
    set color yellow + 2
    set xcor 2
    set ycor -4
    set heading 0
    set size 0.7
    set box-color COLOR_YELLOW
  ]

  ;; set box 8
  ask turtle 10 [
    set color green + 2
    set xcor 2
    set ycor -5
    set heading 0
    set size 0.7
    set box-color COLOR_GREEN
  ]
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
  foreach [-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6]
    [ [x] ->
      ask patch x -6 [set pcolor black]
      ask patch x -6 [set kind WALL]
      ask patch x 6 [set pcolor black]
      ask patch x 6 [set kind WALL]
      ask patch -6 x [set pcolor black]
      ask patch -6 x [set kind WALL]
      ask patch 6 x [set pcolor black]
      ask patch 6 x [set kind WALL]]

  ;; Build the ramp
  foreach [-1 0 1 2]
  [ [x] ->
    ask patch x -5 [set pcolor gray + 3]
    ask patch x -5 [set kind RAMP]
    ask patch x -4 [set pcolor gray + 3]
    ask patch x -4 [set kind RAMP]
    ask patch x -3 [set pcolor gray + 3]
    ask patch x -3 [set kind RAMP]
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
  set OCCUPIED 5
  set UNKNOWN 0
  set COLOR_BLUE 10
  set COLOR_GREEN 11
  set COLOR_YELLOW 12
  set COLOR_RED 13
  set NUM_BOXES 8
  set WAREHOUSE_WIDTH 13
end

;;;
;;;  Count the number of boxes on shelves
;;;
to-report delivered-boxes
  let num-boxes 0

  ask boxes
  [ if [kind] of patch-here = SHELF
      [ set num-boxes (num-boxes + 1) ]
  ]
  report num-boxes
end

;;;
;;;  Return the number of robots in the initial position
;;;
to-report robots-initial-position
  let num-robots 0

  ask robots
    [ if initial-position?
      [ set num-robots (num-robots + 1) ]
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
;;;  Procedure that initializes the robot's state
;;;
to init-robot
  set cargo WITHOUT_CARGO
  set boxes-on-shelves 0
  set boxes-on-ramp NUM_BOXES
  set shelves []
  set ramp-zone []

  set current-position [0 0]
  set warehouse-map build-new-map
  write-map [0 0] ROOM_FLOOR
  ;; Fill in the robot's map, since in this simulation one can assume the robots know the map
  fill-map

  set desire "grab"
  set intention build-empty-intention
  set plan build-empty-plan
  set last-action ""
end

;;;
;;; -------------------------------------------------------
;;; -------------------------------------------------------
;;;   BEGINNING: The exercises resolution starts here
;;;   Please do not change the code above this zone
;;; -------------------------------------------------------
;;; -------------------------------------------------------
;;;

;;;
;;; Robot's updating procedure, which defines the rules of its behaviors
;;; It follows the deliberative architecture presented in Chap.4 of [Wooldridge02]
;;;
to robot-loop
  if goal-succeeded?
    [stop]

  set last-action ""
  ifelse not (empty-plan? plan or intention-succeeded? intention or impossible-intention? intention)
  [
    execute-plan-action
    update-beliefs
  ]
  [
    update-beliefs
    ;; Check the robot's options
    set desire BDI-options
    set intention BDI-filter
    set plan build-plan-for-intention intention

    ;; If it could not build a plan, the robot should behave as a reactive agent
    if(empty-plan? plan)
      [ reactive-agent-loop ]
  ]

  if (last-action = "grab")
  [
    send-message "grab"
  ]

  if (last-action = "drop")
  [
    send-message "drop"
  ]
end

;;;
;;;  Handle a new received message
;;;
to new-message [msg]

  if(msg = "grab")
  [
    set boxes-on-ramp (boxes-on-ramp - 1)
  ]
  if(msg = "drop")
  [
    set boxes-on-shelves (boxes-on-shelves + 1)
  ]

end

;;;
;;; According to the current beliefs, it selects the robot's desires
;;; Its values can be "grab", "drop" or "initial-position"
;;; Reference: Chap.4 de [Wooldridge02]
;;;
to-report BDI-options

  ifelse boxes-on-shelves = 8
  [
    report "initial-position"
  ]
  [
    ifelse box-cargo?
    [
      report "drop"
    ]
    [
      ifelse boxes-on-ramp > 0
      [
        report "grab"
      ]
      [
        report "initial-position"
      ]
    ]
  ]
end

;;;
;;; It selects a desire and coverts it into an intention
;;; Reference: Chap.4 de [Wooldridge02]
;;;
to-report BDI-filter
  let pos-or 0

  ifelse desire = "initial-position"
  [
    report build-intention desire [0 0] 90
  ]
  [
    ifelse desire = "grab"
    [
      set pos-or adjacent-position-of-occupied-ramp
      report build-intention desire item 0 pos-or item 1 pos-or
    ]
    [
      if desire = "drop"
      [
        set pos-or adjacent-position-of-free-shelf cargo-box-color
        report build-intention desire item 0 pos-or item 1 pos-or
      ]
    ]
  ]
  report build-empty-intention
end

;;;
;;;  Create a plan for a given intention
;;;
to-report build-plan-for-intention [iintention]
  let new-plan 0

  set new-plan build-empty-plan

  if  not empty-intention? iintention
  [
    set new-plan build-path-plan current-position item 1 iintention
    set new-plan add-instruction-to-plan new-plan build-instruction-find-heading item 2 iintention

    if get-intention-desire iintention = "grab"
    [
      set new-plan add-instruction-to-plan new-plan build-instruction-grab
    ]
    if get-intention-desire iintention = "drop"
    [
      set new-plan add-instruction-to-plan new-plan build-instruction-drop
    ]
  ]

  report new-plan
end

;;;
;;;  A colision between robots occured whihe executing the plan
;;;
to collided

  if (random 10 < 7)
  [
    write-map position-ahead OCCUPIED

  ]

  set plan build-plan-for-intention intention
end

;;;
;;; -------------------------------------------------------
;;; -------------------------------------------------------
;;;   END: The exercises resolution stops here
;;;   Please do not change the code below this zone
;;; -------------------------------------------------------
;;; -------------------------------------------------------
;;;


;;;
;;;  Check if the goal has been achieved ( all boxes on shelves and robot on their initial positions)
;;;
to-report goal-succeeded?
  report ( equal-positions? current-position build-position 0 0
          and (boxes-on-shelves = NUM_BOXES) )
end

;;;
;;;  Update the robot's beliefs based on its perceptions
;;;  Reference: Chap.4 of [Wooldridge02]
;;;
to update-beliefs
  update-state
end

;;;
;;;  Check if the robot's intention has been achieved
;;;
to-report intention-succeeded? [iintention]
  let ddesire 0


  if(empty-intention? iintention)
    [ report false ]

  set ddesire get-intention-desire iintention
  ifelse(ddesire = "grab")
  [ report not (cargo = WITHOUT_CARGO) ]
  [ ifelse(ddesire = "drop")
    [ report last-action = "drop"]
    [ report equal-positions? current-position build-position 0 0
             and (heading = 90) ]
  ]
end

;;;
;;;  Check if an intention cannot be achieved anymore
;;;  However, in this scenario, the only intention that can become impossible is "grab", which is already tested in 'execute-plan-action'
;;;
to-report impossible-intention? [iintention]
  report false
end

;;;
;;;  Reactive agent control loop
;;;
to reactive-agent-loop
  ifelse (cell-has-box? and ramp-cell? and not box-cargo?)
    [ grab-box ]
    [
      ifelse (shelf-cell? and not cell-has-box?) and (cell-color = cargo-box-color)
        [ drop-box ]
        [
          ifelse (not free-cell?)
            [ rotate-random ]
            [ move-random ]
        ]
    ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;                                            ;;;
;;;           INTERNAL ABSTRACT TYPES          ;;;
;;;                                            ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;
;;; -------------------------
;;;    Plan Intructions
;;; -------------------------
;;;
to-report build-instruction [ttype vvalue]
  report list ttype vvalue
end

to-report get-instruction-type [iinstruction]
  report first iinstruction
end

to-report get-instruction-value [iinstruction]
  report last iinstruction
end

to-report build-instruction-find-adjacent-position [aadjacent-position]
  report build-instruction "ad" aadjacent-position
end

to-report build-instruction-find-heading [hheading]
  report build-instruction "h" hheading
end

to-report build-instruction-drop []
  report build-instruction "d" ""
end

to-report build-instruction-grab []
  report build-instruction "g" ""
end

to-report instruction-find-adjacent-position? [iinstruction]
  report get-instruction-type iinstruction = "ad"
end

to-report instruction-find-heading? [iinstruction]
  report get-instruction-type iinstruction = "h"
end

to-report instruction-drop? [iinstruction]
  report get-instruction-type iinstruction = "d"
end

to-report instruction-grab? [iinstruction]
  report get-instruction-type iinstruction = "g"
end

;;;
;;; -------------------------
;;;    Plans
;;; -------------------------
;;;
to-report build-empty-plan
  report []
end

to-report add-instruction-to-plan [pplan iinstruction]
  report lput iinstruction pplan
end

to-report remove-plan-first-instruction [pplan]
  report butfirst pplan
end

to-report get-plan-first-instruction [pplan]
  report first pplan
end

to-report empty-plan? [pplan]
  report empty? pplan
end

;;;
;;; Build a pan to move the agent from posi to posf
;;;
to-report build-path-plan [posi posf]
  let newPlan 0
  let path 0

  set newPlan build-empty-plan
  set path (find-path posi posf)
  foreach path
    [ [x] ->
      set newPlan add-instruction-to-plan newPlan build-instruction-find-adjacent-position x ]

  report newPlan
end

;;;
;;; -------------------------
;;; Intention
;;;
;;; Chap.4 of [Wooldridge02]
;;; An intention is a list such as [desire position heading]
;;; -------------------------
;;;
to-report build-empty-intention
  report []
end

to-report build-intention [ddesire pposition hheading]
  let aux 0

  set aux list ddesire pposition
  set aux lput hheading aux
  report aux
end

to-report get-intention-desire [iintention]
  report item 0 iintention
end

to-report get-intention-position [iintention]
  report item 1 iintention
end

to-report get-intention-heading [iintention]
  report item 2 iintention
end

to-report empty-intention? [iintention]
  report empty? iintention
end

;;;
;;; Return a list with a position and a heading
;;; The position is an adjacent position of a free shelf of the given color
;;; The heading is a possible heading to be in front of the shelf position
;;; If no shelf of the given color is available, it will return an empty list
;;;
to-report adjacent-position-of-free-shelf [ccolor]
  let aux 0
  let adjacentPosition 0


  set aux find-shelf-of-color ccolor false

  ifelse not empty? aux
    [
      set adjacentPosition one-of free-adjacent-positions shelf-info-position aux
      report list adjacentPosition calculate-heading adjacentPosition (shelf-info-position aux)
    ]
    [ report [] ]
end

;;;
;;; Return a list with a position and a heading
;;; The position is an adjacent position of a free ramp patch
;;; The heading is a possible heading to be in front of the ramp patch
;;; If no free ramp is available, it will return an empty list
;;;
to-report adjacent-position-of-occupied-ramp
  let aux 0
  let adjacentPosition 0


  set aux find-occupied-ramp

  ifelse not empty? aux
    [
      set adjacentPosition one-of free-adjacent-positions get-ramp-info-position aux
      report list adjacentPosition (calculate-heading adjacentPosition (get-ramp-info-position aux))
    ]
    [ report [] ]
end

;;;
;;;  Return the heading that is required to have pos2 in front of a turtle that is currently in pos1
;;;
to-report calculate-heading [pos1 pos2]
  let x1 0
  let x2 0
  let y1 0
  let y2 0


  set x1 item 0 pos1
  set x2 item 0 pos2
  set y1 item 1 pos1
  set y2 item 1 pos2

  ifelse x1 = x2
  [ ifelse y1 > y2
    [report 180]
    [report 0]
  ]
  [ ifelse x1 > x2
    [report 270]
    [report 90]
  ]
end

;;;
;;; -------------------------
;;; Position
;;; -------------------------
;;;
to-report build-position [x y]
  report list x y
end

to-report xcor-of-position [pposition]
  report first pposition
end

to-report ycor-of-position [pposition]
  report last pposition
end

to-report equal-positions? [pos1 pos2]
  report ((xcor-of-position(pos1) = (xcor-of-position(pos2)))
          and (ycor-of-position(pos1) = (ycor-of-position(pos2))))
end

to-report position-ahead
  ifelse heading = 90
    [ report build-position
               ((xcor-of-position current-position) + 1)
               (ycor-of-position current-position) ]
    [ ifelse heading = 180
      [ report build-position
                  (xcor-of-position current-position)
                  ((ycor-of-position current-position) - 1) ]
      [ ifelse heading = 270
        [ report build-position
               ((xcor-of-position current-position) - 1)
               (ycor-of-position current-position) ]
        [ report build-position
                  (xcor-of-position current-position)
                  ((ycor-of-position current-position) + 1) ]
      ]
    ]
end

;;;
;;; ----------------------------
;;;  Plan execution procedures
;;; ----------------------------
;;;

;;;
;;;  Execute the next action of the current plan
;;;
to execute-plan-action
  let currentInstruction 0

  set currentInstruction get-plan-first-instruction plan

  ifelse(instruction-grab? currentInstruction)
  [
    if(cell-has-box? and ramp-cell? and not box-cargo?)
      [grab-box]
    set plan remove-plan-first-instruction plan
  ]
  [ ifelse(instruction-drop? currentInstruction)
    [
      if(shelf-cell? and not cell-has-box?) and (cell-color = cargo-box-color)
        [ drop-box ]
      set plan remove-plan-first-instruction plan
    ]
    [ ifelse(instruction-find-adjacent-position? currentInstruction)
      [
        ifelse(position-ahead = get-instruction-value currentInstruction)
        [
          ifelse(free-cell?)
          [ move-ahead
            set plan remove-plan-first-instruction plan ]
          [ collided ]
        ]
        [ rotate-right ]
      ]
      [ if(instruction-find-heading? currentInstruction)
        [
          ifelse(heading = get-instruction-value currentInstruction)
          [ set plan remove-plan-first-instruction plan ]
          [ rotate-right ]
        ]
      ]
    ]
  ]
end

;;;
;;; ----------------------------------------
;;;    Internal state updating procedures
;;; ----------------------------------------
;;;

;;;
;;;  Update the robot's state
;;;
to update-state
  let aux 0

  write-map position-ahead ([kind] of patch-ahead 1)

  if shelf-cell?
    [ update-shelf-info ]

  if ramp-cell?
    [ update-ramp-info ]
end


to update-shelf-info
  let aux 0

  set aux find-shelf-on-position position-ahead

  if not empty? aux
    [ set shelves remove first aux shelves ]

  set shelves
      fput (build-shelf-info position-ahead cell-color cell-has-box?)
           shelves
end


to update-ramp-info
  let aux 0

  set aux find-ramp-on-position position-ahead

  if not empty? aux
    [ set ramp-zone remove first aux ramp-zone ]

  set ramp-zone
      fput (build-ramp-info position-ahead cell-has-box?)
           ramp-zone
end

;;;
;;; ----------------------------
;;;    Comunication procedures
;;; ----------------------------
;;;

;;;
;;;  Send a message to all robots
;;;
to send-message [msg]
  ask robots [new-message msg]
end

;;;
;;;  Send a message to a specified robot
;;;
to send-message-to-robot [id-robot msg]
  ask turtle id-robot [new-message msg]
end

;;;
;;; -------------------------
;;;    Shelf-info
;;; -------------------------
;;;

to-report build-shelf-info [pos ccolor occupied?]
  report (list pos ccolor occupied?)
end

to-report shelf-info-position [sshelf]
  report first sshelf
end

to-report shelf-info-color [sshelf]
  report first butfirst sshelf
end

to-report shelf-info-occupied [sshelf]
  report first butfirst butfirst sshelf
end

to-report find-shelf-on-position [pos]
  let aux 0

set aux filter [ [x] -> pos = shelf-info-position x ] shelves
  ifelse empty? aux
    [report aux]
    [report first aux]
end

to-report find-shelf-of-color [ppcolor poccupied?]
  let aux 0

set aux filter [ [x] -> ppcolor = shelf-info-color x
                   and poccupied? = shelf-info-occupied x ] shelves
  ifelse empty? aux
    [report aux]
    [report one-of aux]
end

;;;
;;; -------------------------
;;;    ramp-info
;;; -------------------------
;;;

to-report build-ramp-info [pos occupied?]
  report (list pos occupied?)
end

to-report get-ramp-info-position [rramp]
  report first rramp
end

to-report get-ramp-info-occupied [rramp]
  report first butfirst rramp
end

to-report find-ramp-on-position [pos]
  let aux 0

set aux filter [ [x] -> pos = get-ramp-info-position x ] ramp-zone
  ifelse empty? aux
    [report aux]
    [report first aux]
end

to-report find-occupied-ramp
  let aux 0

set aux filter [ [x] -> get-ramp-info-occupied x ] ramp-zone

  ifelse empty? aux
    [report aux]
    [report one-of aux]
end

;;;
;;; -------------------------
;;;    Map
;;; -------------------------
;;;

;;;
;;;  Build a new map with UNKOWN in all positions
;;;
to-report build-new-map
  let m 0

  set m ""

  repeat (2 * WAREHOUSE_WIDTH + 1) * (2 * WAREHOUSE_WIDTH + 1)
    [ set m word m UNKNOWN ]

  report m
end


to write-map [pos mtype]
  let x 0
  let y 0

  set x item 0 pos
  set y item 1 pos

  set warehouse-map replace-item ((WAREHOUSE_WIDTH + x) +
                         (WAREHOUSE_WIDTH - y) * (2 * WAREHOUSE_WIDTH + 1))
                        warehouse-map
                        (word "" mtype)
end


to-report read-map-position [pos]
  let x 0
  let y 0

  set x item 0 pos
  set y item 1 pos
  report item ((WAREHOUSE_WIDTH + x) + (WAREHOUSE_WIDTH - y) * (2 * WAREHOUSE_WIDTH + 1))
              warehouse-map
end

;;;
;;;  Return a list of positions from initialPos to FinalPos
;;;  The returning list excludes the initialPos
;;;  If no path is found, the returning list is empty
;;;
to-report find-path [intialPos FinalPos]
  let opened 0
  let closed 0
  let aux 0
  let aux2 0
  let aux3 0
  let to-explore 0

  set to-explore []
  set closed []
  set opened []
  set opened fput (list (list 0 0 intialPos) []) opened

  while [not empty? opened]
  [
    set to-explore first opened
    set opened remove to-explore opened
    set closed fput to-explore closed

    ifelse last first to-explore = FinalPos
    [ report find-solution to-explore closed ]
    [ set aux adjacents to-explore FinalPos
      foreach aux
      [ [x] ->
        set aux2 x
        set aux3 filter [ [y] -> last first aux2 = last first y and first first aux2 < first first y ] opened
        ifelse not empty? aux3
        [ set opened remove first aux3 opened
          set opened fput aux2 opened ]
        [
          set aux3 filter [ [z] -> last first aux2 = last first z ] closed
          ifelse not empty? aux3
          [
            if first first first aux3 > first first aux2
              [ set closed remove first aux3 closed
                set opened fput aux2 opened ]
          ]
          [ set opened fput aux2 opened ]
        ]
      ]

      ;; orders the opened list according to the heuristic
      set opened sort-by [ [a b] -> first first a < first first b ] opened
    ]
  ]
  report []
end


to-report find-solution [node closed]
  let solution 0
  let parent 0

  set solution (list last first node)
  set parent item 1 node
  while [not empty? parent] [
    set parent first filter [ [x] -> parent = first x ] closed
    set solution fput last first parent solution
    set parent last parent
  ]

  report butfirst solution
end

;;;
;;;  Add the distance to the goal position and the current node cost
;;;
to-report heuristic [node mgoal]
  let cost 0
  let x 0
  let y 0

  set cost item 1 node
  set x first item 2 node
  set y first butfirst item 2 node

  report cost +
         2 * (abs(x - item 0 mgoal) +  abs(y - item 1 mgoal))
end


to-report adjacents [node mobjectivo]
  let aux 0
  let aux2 0

  set aux2 []
  set aux adjacent-positions-of-type (last first node) ROOM_FLOOR
  foreach aux [
    [x] ->
    set aux2 fput (list 0 ((item 1 first node) + 1) x) aux2
  ]
  set aux []
  foreach aux2
  [ [x] ->
    set aux fput (list (replace-item 0 x (heuristic x mobjectivo))
                       first node)
                 aux ]
  report aux
end


to-report free-adjacent-positions [pos]
  report adjacent-positions-of-type pos ROOM_FLOOR
end


to-report adjacent-positions-of-type [pos ttype]
  let solution 0
  let x 0
  let y 0

  set x item 0 pos
  set y item 1 pos

  set solution []

  if (not (y <= (- WAREHOUSE_WIDTH)))
    [ set solution fput (list x (y - 1)) solution ]

  if (not (y >= WAREHOUSE_WIDTH))
    [ set solution fput (list x (y + 1)) solution ]

  if (not (x <= (- WAREHOUSE_WIDTH)))
    [ set solution fput (list (x - 1) y) solution ]

  if (not (x >= WAREHOUSE_WIDTH))
    [ set solution fput (list (x + 1) y) solution ]

  foreach solution
  [ [i] ->
    if not (read-map-position i = (word "" ttype))
    [ set solution remove i solution ] ]
  report solution
end

;;;
;;;  Write on the robot's map the initial state of the warehouse
;;;
to fill-map
  let x 0
  let y 0
  let t 0

  set x -6
  set y -6

  repeat (WAREHOUSE_WIDTH)
    [
      repeat (WAREHOUSE_WIDTH)
      [
        set t [kind] of patch x y
        write-map (list (x - xcor) (y - ycor)) t
        if t = SHELF
          [ set shelves
                fput (build-shelf-info (list round (x - xcor) round (y - ycor))
                                           [shelf-color] of patch x y
                                           false)
                shelves ]
        if t = RAMP and (any? boxes-on (patch x y))
          [ set ramp-zone
                fput (build-ramp-info (list round (x - xcor) round (y - ycor))
                                      any? boxes-on (patch x y))
                ramp-zone ]
        set y y + 1 ]
      set y -6
      set x x + 1 ]
end


to print-map
  let i 0

  set i 0
  repeat (2 * WAREHOUSE_WIDTH + 1)
  [ show substring warehouse-map (i * (2 * WAREHOUSE_WIDTH + 1))
                        ((i + 1) * (2 * WAREHOUSE_WIDTH + 1))
    set i i + 1]
end


;;;
;;; ------------------------
;;;   Actuators
;;; ------------------------
;;;

;;;
;;;  Move the robot forward or rotate with a 25% probability
;;;
to move-random
  ifelse (random 4 = 0)
    [ rotate-random ]
    [ move-ahead ]
end

;;;
;;;  Move the robot forward
;;;
to move-ahead
  let ahead (patch-ahead 1)
  ;; check if the cell is free
  if ([kind] of ahead = ROOM_FLOOR) and (not any? robots-on ahead)
    [ fd 1
      set current-position position-ahead
      set last-action "move-ahead"
      if not (cargo = WITHOUT_CARGO)
    [move-box] ]
end

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
;;;  Rotate turtle to left
;;;
to rotate-left
  lt 90
  set last-action "rotate-left"
end

;;;
;;;  Rotate turtle to right
;;;
to rotate-right
  rt 90
  set last-action "rotate-right"
end

;;;
;;;  Rotate turtle to a random direction
;;;
to rotate-random
  ifelse (random 2 = 0)
  [ rotate-left ]
  [ rotate-right ]
end

;;;
;;;  Allow the robot to put a box on its cargo
;;;
to grab-box
  let box-temp box-ahead
  ; Check if there is a box on the cell ahead
  if box-temp != nobody
    [ set cargo box-temp
      set last-action "grab"
      move-box ]
end

;;;
;;;  Allow the robot to drop the box in its cargo
;;;
to drop-box
  let cell (patch-ahead 1)
  ;; Check if the robot is carrying a box
  if not (cargo = WITHOUT_CARGO) [
    ;; Put the box on the cell ahead
    ask cargo [set xcor [pxcor] of cell]
    ask cargo [set ycor [pycor] of cell]
    set last-action "drop"
    set cargo WITHOUT_CARGO]
end

;;;
;;; ------------------------
;;;   Sensors
;;; ------------------------
;;;

;;;
;;;
;;;
to-report initial-position?
  report equal-positions? current-position build-position 0 0
end

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

;;;
;;; Return the color of the box ahead
;;;
to-report box-ahead-color
  let box-temp box-ahead
  ; only if there is a box in front of the robot
  if box-temp != nobody
    [report [box-color] of box-temp]
end

;;;
;;;  Return the color of the shelf ahead or 0 otherwise
;;;
to-report cell-color
  report [shelf-color] of (patch-ahead 1)
end

;;;
;;;  Check if the cell ahead is floor (which means not a wall, not a shelf nor a ramp) and there are any robot there
;;;
to-report free-cell?
  let frente (patch-ahead 1)
  report ([kind] of frente = ROOM_FLOOR) and (not any? robots-on frente)
end

;;;
;;;  Check if the cell ahead contains a box
;;;
to-report cell-has-box?
  report any? boxes-on (patch-ahead 1)
end

;;;
;;;  Check if the cell ahead is a shelf
;;;
to-report shelf-cell?
  report ([kind] of (patch-ahead 1) = SHELF)
end

;;;
;;;  Check if the cell ahead is a ramp
;;;
to-report ramp-cell?
  report ([kind] of (patch-ahead 1) = RAMP)
end
@#$#@#$#@
GRAPHICS-WINDOW
321
10
589
279
-1
-1
20.0
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
1
1
1
ticks
30.0

BUTTON
29
26
94
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
150
71
313
116
Robots in initial position
robots-initial-position
0
1
11

@#$#@#$#@
## ABSTRACT TYPES


### intention
An 'intention' is a list with 3 elements <desire, position, heading> ( desire is a string, position is internal abstract type 'position' and the heading is a numerical degree between 0 and 360.
####Basic reporters:
- build-empty-intention
- build-intention [ddesire pposition hheading]
- get-intention-desire [iintention]
- get-intention-position [iintention]
- get-intention-heading [iintention]
- empty-intention? [iintention]

### plan-instruction
A 'plan-instruction' is a single instruction that is part of a plan. It contains a list of 2 elements <type,value> (the type of the instruction as a string and a value, when it is required). There are four instructions: grab, drop, find an adjacent position and find heading.
####Basic eporters:
- build-instruction [ttype vvalue]
- get-instruction-type [iinstruction]
- get-instruction-value [iinstruction]
- build-instruction-find-adjacent-position [aadjacent-position]
- build-instruction-find-heading [hheading]
- build-instruction-drop []
- build-instruction-grab []
- instruction-find-adjacent-position? [iinstruction]
- instruction-find-heading? [iinstruction]
- instruction-drop? [iinstruction]
- instruction-grab? [iinstruction]

### plan
A 'plan' is composed by 'plan-insctruction' elements. It is initialized as an empty list and instructions are then added or removed.

####Basic reporters:
- build-empty-plan
- add-instruction-to-plan [pplan iinstruction]
- remove-plan-first-instruction [pplan]
- get-plan-first-instruction [pplan]
- empty-plan? [pplan]
- build-path-plan [posi posf]

####Extra reporters:
- execute-plan-action


### position
A 'position' is a list of two elements <x-cor,y-cor> (the x coordinate and the y coordinate).
####Basic reporters:
- build-position [x y]
- xcor-of-position [pposition]
- ycor-of-position [pposition]
- equal-positions? [pos1 pos2]
- position-ahead

####Extra reporters:
- find-path [intialPos FinalPos]
- free-adjacent-positions [pos]
- adjacent-positions-of-type [pos ttype]

### shelf-info
A 'shelf-info' contains information about a shelf cell and uses a list of 3 elements <position,color,occupied?> (the shelf cell position, the shelf color and a boolean referring the state of the shelf).
####Basic reporters:
- build-shelf-info [pos ccolor occupied?]
- shelf-info-position [sshelf]
- shelf-info-color [sshelf]
- shelf-info-occupied [sshelf]

####Extra reporters:
- find-shelf-position [pos]
- find-shelf-of-color [ppcolor poccupied?]

### ramp-info
A 'ramp-info' contains information about a ramp cell and uses a list of 2 elements <position,occupied?> (the ramp cell position and a boolean referring the state of the ramp).
####Basic reporters:
- build-ramp-info [pos occupied?]
- get-ramp-info-position [rramp]
- get-ramp-info-occupied [rramp]

####Extra reporters:
- find-ramp-on-position [pos]
- find-occupied-ramp

### map
####Basic reporters:
- build-new-map
- write-map [pos mtype]
- read-map-position [pos]

####Extra reporters:
- fill-map
- print-map

## Other reporters

###Comunication
- send-message [msg]
- send-message-to-robot [id-robot msg]

###Auxiliary reporters:
- find-solution [node closed]
- heuristic [node mgoal]
- adjacents [node mobjectivo]
- free-adjacent-positions [pos]

## ACTUATORES:

- move-ahead
- rotate-left
- rotate-right: Rotate turtle to right
- rotate-random: Rotate turtle to a random direction
- grab-box: Allow the robot to put a box on its cargo
- drop-box: Allow the robot to drop the box in its cargo

## SENSORS:

- box-cargo?: Check if the robot is carrying a box
- cargo-box-color: Return the color of the box in robot's cargo or WITHOUT_CARGO otherwise
- box-ahead-color: Return the color of the box ahead
- cell-color: Return the color of the shelf ahead or 0 otherwise
- free-cell?: Check if the cell ahead is floor (which means not a wall, not a shelf nor a ramp) and there are any robot there
- cell-has-box?: Check if the cell ahead contains a box
- shelf-cell?: Check if the cell ahead is a shelf
- ramp-cell?: Check if the cell ahead is a ramp



##REFERENCES:

[Wooldridge02] - Wooldridge, M.; An Introduction to Multiagent Systems; John WIley & Sons, Ltd; 2002
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
0
@#$#@#$#@
