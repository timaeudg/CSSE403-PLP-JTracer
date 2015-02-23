require 'rgb'
require 'viewmat'

NB. usage: vector2image matrix
vector2image =: 3 : 0
BGR <.255*| y
)

norm =: 3 : 0 "1
if. +./+./ y ="0 1 (_ __)
do. y
else. (% +/&.(*:"_)) y
end.
)

dot =: 4 : 0 "1
if. (+./+./ y ="0 1 (_ __)) +. (+./+./ x ="0 1 (_ __))
do. _
else. x (+/ .*) y
end.
)

NB. takes boxed list of parameters
NB. Camera Loc
NB. Camera look at position
NB. image dimensions
NB. horizontal fov 
RayGen =: 3 : 0

cross=. [: > [: -&.>/ .(*&.>) (<"1=i.3) , ,:&:(<"0)

cameraPos =. >0{>0{ y
cameraLookAt =. norm >1{ > 0 { y
dimensions =. > 1 { y
fov =. > 2 { y

w =. -cameraLookAt
u =. 0 0 1 cross w
v =. w cross u

loc =. dimensions $ cameraPos

ix =. dimensions $(1{dimensions)$i: 2%~ 1{dimensions 
iy =. |: (|. dimensions) $(0{dimensions)$i: 2%~ 0{dimensions

dist =. 0{dimensions % 2 * 3 o. fov % 2

NB. -w * dist + ix * u + iy * v

rayDir =. ((dimensions,3)$(-w*dist))
rayDir =. rayDir + (iy*((dimensions,3)$v))
rayDir =. rayDir + (ix*((dimensions,3)$u))
rayDir =. norm rayDir


   ((dimensions,3)$cameraPos) ; rayDir                                   

)

NB. Return distance of sphere intersection 
NB. Usage (spherePos ; sphereRadius ; materialIndex) intersectSphere ((dimensions, 3)$vector)
IntersectSphere =: 4 : 0 " 1 1
cross=. [: > [: -&.>/ .(*&.>) (<"1=i.3) , ,:&:(<"0)

direction =. >1} y
position =. >0} y
center =. >0} x
radius =. >1} x

A =. dot~ direction
B =. 2*(direction dot (position -"1 center))
C =. (radius^2) -~ dot~ (position -"1 center) 

rootPart =. (*~B) - (4*A*C)
rootPart =. convertToInf rootPart
rootPart =. (%:"0) rootPart
plusPart =. rootPart + -B
minusPart =. rootPart -~ -B
plusPart =. plusPart % 2*A
minusPart =. minusPart % 2*A
plusPart <. minusPart
)

convertToInf =: 3 : 'if. 0>y do. _ else. y end.' "0
convertToDrawable =: 3 : 'if. _ = y do. 0 else. y end.' "0
compareWithIndex =: 4 : 'if. 0{x<0{y do. x else. y end.' "1

convertHitpoints =: 3 : 0 "1
first =. 0{ y
second =. 1{y
third =. 2{y
isInfinite =. 3 : '+./ (y =/ _ __)'
if. (isInfinite first) +. (isInfinite second) +. (isInfinite third)
do. _,_,_
else. y
end.

)

giveEmTehClampz =: 3 : 0 "0
if. y < 0
do. 0
elseif. y = _
do. _
elseif. y > 1
do. 1 
elseif. 1
do. y
end.
)

IntersectSpheres =: 4 : 0 
sphereints =. x IntersectSphere y
converted =. convertToInf sphereints
sphereIndex =. i. # x
indexAppended =.  converted ,"0 sphereIndex
combinedTValues =.  (compareWithIndex)/ indexAppended
combinedTValues
)

GetHitpoints =: 4 : 0
hitTValues =. 0{"1 y
direction =. >1} x
hitpoints =. hitTValues * direction
convertedHitpoints =. convertHitpoints hitpoints
)

GetNormalsFromSphere =: 4 : 0
hitSphereIndeces =. 1{"1 >0{y
intersects =. >0{y
spheres =. >1{y
sphereCenters =. 0{"1 spheres
sphereIndices =. 1{"1 intersects
NB. (*"0 1) (>sphereCenters)
sphereCentreMap =.(sphereIndices ="_ 0 (i.#>sphereCenters)) (*"0 1) (>sphereCenters)
sphereCentreMap =. +"1/ sphereCentreMap
norm (x -"1 sphereCentreMap)
)


shade =: 4 : 0
cameraPos =. >0{>0{x
light =. >1{x
materials =. >2{x
speculars =. >3{x

hitpoints =. >0{y
indicies =. >1{y
normals =. >2{y

toCamera =. norm (cameraPos -"1 hitpoints)
toLight =. norm (light -"1 hitpoints)

LR =. norm (toLight -~ (normals * 2 * (toLight dot normals)))

ambient =. 0.1 0.1 0.1

material =. indicies{"0 _ materials 
specular =. indicies{"0 _ speculars

diffuse =. material * (toLight dot normals)
specularColor =. (giveEmTehClampz (toCamera dot LR)) ^ specular

color =. diffuse + specularColor

)

NB. TESTING CODE

dimensions =. 512 512

camera =. 0 0 0; 0 _1 0
light =. 2 0 _4

camera; dimensions; 123
rays =. RayGen camera; dimensions; 1p1%2
sphere =. 0 _5 0; 1 ; 0
sphere2 =. 2 _3 0; 1; 0
spheres =. sphere ,: sphere2

materials =. (1 0.5 0,:0 0.5 1) ; (3 10)

intersects =. (spheres IntersectSpheres rays)
hitpoints =. rays GetHitpoints intersects
indicies =. 1{"1 intersects
normals =. hitpoints GetNormalsFromSphere (intersects ; <spheres)

NB.viewrgb vector2image convertToDrawable normals

color =. (camera; light; materials) shade (hitpoints; indicies; normals)
drawableColor =. convertToDrawable color
drawableColor =. giveEmTehClampz drawableColor
biggestColor =. >./ >./ >./ drawableColor
color =. drawableColor %"1 biggestColor
NB.color
viewrgb vector2image convertToDrawable drawableColor



