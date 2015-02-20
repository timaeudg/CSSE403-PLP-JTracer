


NB. takes boxed list of parameters
NB. Camera Loc
NB. Camera look at position
NB. image dimensions
NB. horizontal fov 

require 'rgb'
require 'viewmat'

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

rayDir =. (dimensions$<(-w*dist)) +each (iy *each dimensions$<v) +each (ix * each dimensions$<u)
rayDir =. norm each rayDir


   (dimensions$<cameraPos) ; <rayDir                                   

)


NB. dimensions vector2image matrix
vector2image =: 3 : 0
:
tmp =. RGB each <.each 255*each |each y
x$;tmp
)


NB. TESTING CODE

dimensions =. 512 512

rayDir =. >}. RayGen 0 0 0;0 _1 0; dimensions; 1p1%2

viewrgb dimensions vector2image rayDir