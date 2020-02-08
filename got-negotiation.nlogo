breed[starks stark]
breed[baratheons baratheon]

turtles-own[
  strength
  willing;;what we offer (buyer)
  price;;what we ask (seller)
  RU
  beta
]


to setup
  clear-all
  reset-ticks
  setup-patches
  setup-lords
end

to setup-patches
  ask patches [
    set pcolor white
  ]
end

to setup-lords
  create-starks num-starks
  ask starks [
    setxy (random-float 8) + 8 random-ycor
    set shape "wolf"
    set color blue
    set size 2
    set strength init-strength
    set label precision strength 2
    set RU init-RU
    set price strength;;to do: change for a slider
    set willing (strength / 5.0);;to do: change for a slider
    ifelse starks-strategy = "boulware"[
      set beta 0.25
    ]
    [
      ifelse starks-strategy = "lineal"[
        set beta 1.0
      ]
      [set beta 5.0]
    ]
  ]

  create-baratheons num-baratheons
  ask baratheons [
    setxy (random-float -8) - 8  random-ycor
    set shape "moose"
    set color brown
    set size 2
    set strength init-strength
    set label precision strength 2
    set RU init-RU
    set price strength;;TODO: change for a slider
    set willing (strength / 5.0);;TODO: change for a slider
    ifelse baratheons-strategy = "boulware"[
      set beta 0.25
    ]
    [
      ifelse baratheons-strategy = "lineal"[
        set beta 1.0
      ]
      [set beta 5.0]
    ]
  ]
end

to go
  if ticks >= 50000 [ stop ]  ;; stop after 500 ticks
  move-families
  to-do?
  spawn-new
  updates
  ;;WINS
  if (count baratheons) = 0 [
    show "starks win!"
    stop
  ]
  if (count starks) = 0 [
    show "baratheonss win!"
    stop
  ]
  tick
end

to move-families
  ;;STARKS MOVES
  ask starks [
    if (probability-to-win-strength > random 100) and (pcolor = 107)[;only if they're on a own patch, they can get strength
     set strength strength + 1
    ]
    if loss-to-conquer and (pcolor = 37)[;if they're on a rival patch, they can loss strength to conquer it
     set strength strength - strength-to-loss
    ]
    set pcolor 107
  ]
  ;;BARATHEONS MOVES
  ask baratheons [
    if (probability-to-win-strength > random 100) and (pcolor = 37) [;only if they're on a own patch, they can get strength
     set strength strength + 1
    ]
    if loss-to-conquer and (pcolor = 107) [;if they're on a rival patch, they can loss strength to conquer it
     set strength strength - strength-to-loss
    ]
    set pcolor 37
  ]
  ;;GENERAL MOVE
  ask turtles [;;General move, after stay at home or conquer a rival's patch
    general-move
  ]
end

to general-move
  right random 360
  forward 1
end

to to-do?
  ask patches [
    if (any? starks-here) and (any? baratheons-here) [
      ifelse pcolor = "white" ;;if is a blank patch: we will fight for it; else: we will negotiate for it
      [fight]
      [negotiate]
    ]
  ]
end

to spawn-new
  ask patches [
    if pcolor = 37 [
      if spawn-prob > random-float 100 [
        sprout-baratheons 1 [
          setxy pxcor pycor
          set shape "moose"
          set color brown
          set size 2
          set strength init-strength
          set label precision strength 2
          set RU init-RU
          set price strength;;to do: change for a slider
          set willing (strength / 5.0);;to do: change for a slider
          ifelse starks-strategy = "boulware"[
            set beta 0.25
          ]
          [
            ifelse starks-strategy = "lineal"[
              set beta 1.0
            ]
            [set beta 5.0]
          ]
        ]
      ]
    ]
    if pcolor = 107 [
      if spawn-prob > random-float 100 [
        sprout-starks 1 [
          setxy pxcor pycor
          set shape "wolf"
          set color blue
          set size 2
          set strength init-strength
          set label precision strength 2
          set RU init-RU
          set price strength;;to do: change for a slider
          set willing (strength / 5.0);;to do: change for a slider
          ifelse starks-strategy = "boulware"[
            set beta 0.25
          ]
          [
            ifelse starks-strategy = "lineal"[
              set beta 1.0
            ]
            [set beta 5.0]
          ]
        ]
      ]
    ]
  ]
end

to negotiate
  show "TO NEGOTIATE!";;to Debug
  ;;Control of who is seller and who is buyer
  let the-seller [who] of one-of starks-here
  let the-buyer [who] of one-of baratheons-here
  if pcolor = 37
  [;; if patch color is brown: starks try to buy it; else: baratheons try to buy it
    set the-seller [who] of one-of baratheons-here
    set the-buyer [who] of one-of starks-here
  ]
  ;;NEGOTIATION
  let to-deal false
  let asking [price] of one-of turtles-here with [who = the-seller]
  let start-offer [willing] of one-of turtles-here with [who = the-buyer]
  let offer [willing] of one-of turtles-here with [who = the-buyer]
  let i 1.0
  let Sbuyer 1.0
  let Sseller 1.0
  while [(to-deal = false) and (i <= tries-to-deal)] [
    ifelse asking <= offer [;;if we arrive to a deal, seller sells the patch
      sell-patch the-seller the-buyer offer
      set to-deal true
    ]
    [
      ;;TODO: Negotatiation steps unde here

      set Sbuyer nego-temporal the-buyer i
      set Sseller nego-temporal the-seller i
<<<<<<< Updated upstream
      set asking asking * Sbuyer
      set offer start-offer * (2.0 - Sseller)
      show asking
      show offer
=======
      set asking start-asking * Sseller
      if (start-offer / Sbuyer) <= [strength] of one-of turtles-here with [who = the-buyer][
        set offer start-offer / Sbuyer
      ]
>>>>>>> Stashed changes
    ]

    set i i + 1.0
  ]
<<<<<<< Updated upstream
  if to-deal = false [fight]
=======
  show i;;Debug de que vaya bien la cosa
  if to-deal = false [
    show "Ha fallado una negociación"
    fight
  ]
>>>>>>> Stashed changes
end

to sell-patch [seller buyer payment];;Function that do the payment
  ask turtles-here[
    if who = buyer [;;The buyer stays on the
      set strength strength - payment
      ifelse breed = starks
      [set pcolor 107]
      [set pcolor 37]
    ]
    if who = seller [
      set strength strength + payment
      general-move
    ]
  ]
end

to-report nego-temporal[agent t]
  let r [RU] of one-of turtles-here with [who = agent]
  let b [beta] of one-of turtles-here with [who = agent]
  report (1.0 - (1.0 - r))*((t / tries-to-deal)^(1.0 / b))
  report 1.0 - (1.0 - r)*((t / tries-to-deal)^(1.0 / b))
end

to fight;;A fight, where all the lords loss strength due to rival strength
  show "FIGTH!";;to Debug
  ;;THE FIGTH
  let aux-s-strength [strength] of one-of starks-here
  let aux-b-strength [strength] of one-of baratheons-here
  ask starks-here[
    set strength strength - aux-b-strength
  ]
  ask baratheons-here[
    set strength strength - aux-s-strength
  ]
end

to updates
  ask turtles[
    set label precision strength 2
    if strength < 0 [
      die
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
673
474
-1
-1
13.0
1
10
1
1
1
0
0
0
1
-17
17
-17
17
0
0
1
ticks
30.0

BUTTON
24
121
87
154
setup
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

SLIDER
3
229
175
262
num-starks
num-starks
0
20
20.0
1
1
NIL
HORIZONTAL

SLIDER
14
277
186
310
num-baratheons
num-baratheons
0
20
20.0
1
1
NIL
HORIZONTAL

SLIDER
5
330
203
363
probability-to-win-strength
probability-to-win-strength
0
100
23.0
1
1
NIL
HORIZONTAL

BUTTON
111
121
174
154
go
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
9
166
86
211
Baratheons
count baratheons
17
1
11

MONITOR
115
168
172
213
Starks
count starks
17
1
11

SWITCH
22
375
164
408
loss-to-conquer
loss-to-conquer
0
1
-1000

SLIDER
15
423
187
456
strength-to-loss
strength-to-loss
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
694
19
866
52
spawn-prob
spawn-prob
0
1
0.09
0.01
1
NIL
HORIZONTAL

SLIDER
36
12
208
45
init-strength
init-strength
1.0
500.0
376.0
1.0
1
NIL
HORIZONTAL

SLIDER
29
57
201
90
init-RU
init-RU
0
1
0.35
0.01
1
NIL
HORIZONTAL

SLIDER
694
66
866
99
tries-to-deal
tries-to-deal
1.0
100.0
50.0
1.0
1
NIL
HORIZONTAL

PLOT
692
235
892
385
Strength Graphics
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"baratheons" 1.0 0 -6459832 true "" "plot sum [strength] of baratheons"
"starks" 1.0 0 -13345367 true "" "plot sum [strength] of starks"

CHOOSER
692
116
830
161
starks-strategy
starks-strategy
"boulware" "lineal" "conceder"
1

CHOOSER
694
175
834
220
baratheons-strategy
baratheons-strategy
"boulware" "lineal" "conceder"
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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

moose
false
0
Polygon -7500403 true true 196 228 198 297 180 297 178 244 166 213 136 213 106 213 79 227 73 259 50 257 49 229 38 197 26 168 26 137 46 120 101 122 147 102 181 111 217 121 256 136 294 151 286 169 256 169 241 198 211 188
Polygon -7500403 true true 74 258 87 299 63 297 49 256
Polygon -7500403 true true 25 135 15 186 10 200 23 217 25 188 35 141
Polygon -7500403 true true 270 150 253 100 231 94 213 100 208 135
Polygon -7500403 true true 225 120 204 66 207 29 185 56 178 27 171 59 150 45 165 90
Polygon -7500403 true true 225 120 249 61 241 31 265 56 272 27 280 59 300 45 285 90

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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 47 133 55 131 55 133
Polygon -7500403 true true 298 194 287 197 270 191 262 193 262 205 280 226 280 257 273 265 262 266 260 260 269 253 269 230 240 206 232 198 225 209 234 228 235 243 218 261 216 268 200 267 197 261 223 239 221 231 200 207 202 196 181 201 157 202 140 195 134 210 128 213 127 238 133 251 140 248 146 265 131 264 122 247 114 240 102 260 100 271 83 271 81 262 93 258 105 230 108 198 90 184 73 164 58 144 41 145 16 151 23 141 7 140 1 134 3 127 27 119 30 105
Polygon -7500403 true true 301 195 286 180 264 166 260 153 247 140 218 131 166 133 141 126 112 115 73 108 64 102 62 98 32 86 31 92 19 87 31 103 31 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
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
