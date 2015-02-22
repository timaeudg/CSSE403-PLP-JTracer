require 'rgb'
require 'viewmat'

NB. usage: vector2image matrix
vector2image =: 3 : 0
RGB <.255*| y
)

NB. takes boxed list of parameters
NB. Camera Loc
NB. Camera look at position
NB. image dimensions
NB. horizontal fov 
RayGen =: 3 : 0

norm =. % +/&.(*:"_)"1
cross=. [: > [: -&.>/ .(*&.>) (<"1=i.3) , ,:&:(<"0)
dot  =. +/ .* 

cameraPos =. > 0 { y
cameraLookAt =. norm > 1 { y
dimensions =. > 2 { y
fov =. > 3 { y

w =. -cameraLookAt
u =. 0 0 1 cross w
v =. w cross u

loc =. dimensions $ cameraPos

ix =. dimensions $(0{dimensions)$i: 2%~ 0{dimensions 
iy =. |: ix

dist =. 0{dimensions % 2 * 3 o. fov % 2

NB. -w * dist + ix * u + iy * v

rayDir =. ((dimensions,3)$(-w*dist))+(iy*(dimensions,3)$v)+(ix*(dimensions,3)$u)
rayDir =. norm rayDir


   ((dimensions,3)$cameraPos) ; rayDir                                   

)

NB. Return distance of sphere intersection 
NB. Usage (spherePos ; sphereRadius ; materialIndex) intersectSphere ((dimensions, 3)$vector)
IntersectSphere =: 4 : 0 " 1 1
norm =. % +/&.(*:"_)"1
cross=. [: > [: -&.>/ .(*&.>) (<"1=i.3) , ,:&:(<"0)
dot  =. +/ .*"1 

direction =. >1} y
assert (3 = ({: $ direction))
position =. >0} y
assert (3 = {:@$ position)
center =. >0} x
assert (3 = $ center)
radius =. >1} x
assert (1 = $ radius)

A =. dot~ direction
B =. 2*(direction dot (position -"1 center))
C =. (radius^2) -~ dot~ (position -"1 center) 

NB.lt2inf =. (_:`[@.([>0:))"0
rootPart =. (*~B) - (4*A*C)
rootPart =. convertToInf rootPart
rootPart =. (%:"0) rootPart
plusPart =. rootPart + -B
minusPart =. rootPart -~ -B
plusPart =. plusPart % 2*A
minusPart =. minusPart % 2*A
plusPart <. minusPart
)

convertToInf =: 3 : 0 "0
if. 0 > y
do. _
else.
y
end.
)

convertToDrawable =: 3 : 0 "0
if. _ = y
do. 0
else.
y
end.
)

IntersectSpheres =: 4 : 0 
sphereints =. x IntersectSphere y
converted =. convertToInf sphereints
combinedTValues =.  <./ converted
combinedTValues
)


NB. TESTING CODE

dimensions =. 128 128

rays =. RayGen 0 0 0; 0 _1 0; dimensions; 1p1%2
sphere =. 0 _5 0; 1 ; 0
sphere2 =. 2 _3 0; 0.5; 0
spheres =. sphere ,: sphere2

inf20 =. (0:`[@.([>(-_:)))"0

viewmat convertToDrawable (spheres IntersectSpheres rays)

