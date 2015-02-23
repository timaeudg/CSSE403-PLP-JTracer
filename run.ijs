require 'rgb'
require 'viewmat'

norm =: (% +/&.(*:"_))"1
cross =:[: > [: -&.>/ .(*&.>) (<"1=i.3) , ,:&:(<"0)"1
dot =: (+/ .*)"1

NB. Using agenda on large datasets seems to crash J, fix until fixed
ClampLt0 =: 3 : 'if. y<0 do. 0 else. y end.' "0

NB. Camera format =. (Position, lookAt, fov (in radians))

NB. Sphere format =. (Position; radius; materialIndex)
NB. Triangle format =. (v1; v2; v3; materialIndex)
NB. Light format =. (Position, color)
NB. Material Format =. (Color, specularFactor, reflectivity, opacity, IOR)

NB. Scene format =. (spheres; triangles; lights; materials)

RayGen =: 3 : 0 " _ _ _
    10 10 RayGen y
:
    cameraPos =. >0{ y
    cameraLookAt =. norm >1{ y
    dimensions =.  x
    fov =. >2{ y

    w =. -cameraLookAt
    u =. 0 0 _1 cross w
    v =. w cross u
    
    loc =. dimensions $ cameraPos
    
    ix =. dimensions $(1{dimensions)$i: 2%~ 1{dimensions 
    iy =. |: (|. dimensions) $(0{dimensions)$i: 2%~ 0{dimensions
    
    dist =. 0{dimensions % 2 * 3 o. fov % 2

    NB. -w * dist + ix * u + iy * v

    rayDir =. (iy *"0 _ v) + (ix *"0 _ u) +"1 _ (-w*dist)
    rayDir =. norm rayDir

   ((dimensions,3)$cameraPos) ,: rayDir                                   

)

Trace =: 3 : 0 " _ _ _
    ((<(0 _2 0;1));a:) Trace y
:
    NB. x = scene
    NB. y = rays

    spheres =. >0{x
    tris    =. >1{x
    rays    =. y

    spheres
    sphereTraced =. spheres SphereTrace rays
    triTraced =. tris TriTrace rays

    
    buffer =. CombineBuffers/ (RankHelper triTraced)
    buffer2 =. CombineBuffers/ (RankHelper sphereTraced)

    buffer CombineBuffers buffer2
)

RankHelper =: 3 : 'if. 5 > $$y do. ,: y else. y end.'

CombineBuffers =: 4 : 0 
    dist1 =. 0{"(1)0{x
    dist2 =. 0{"(1)0{y
   
    mask2 =. ((dist1 > dist2) +. ((0 < dist2) *. (dist1 = 0)))
    mask1 =. ((dist1 <: dist2) +. ((0 < dist1) *. (dist2 = 0)))
    distance =. (dist1 * mask1) + (mask2 * dist2)
    normal =. ((1{x) *"1 0 mask1 ) + (mask2 *"0 1 (1{y))
    hitpoint =. ((2{x) *"1 0 mask1) + (mask2 *"0 1 (2{y))
    materialIndex =. ((3{x) *"1 0 mask1) + (mask2 *"0 1 (3{y))

    (($normal)$(3#,distance)), normal, hitpoint ,: materialIndex
)

Shade =: 4 : 0
    distances =. 0{y
    normals   =. 1{y
    hitpoints =. 2{y
    indices   =. 0{"(1)3{y 
    cameraPos =. >0{>0{x
    lights    =. >1{x
    materials =. >2{x

    light =. >0{lights

    toCamera =. norm (cameraPos -"1 hitpoints)
    toLight =. norm (light -"1 hitpoints)

    LR =. norm (toLight -~ (normals * 2 * (toLight dot normals)))

    ambient =. 0.1 0.1 0.1

    material =. >0{"1 indices {"0 _ materials
    specular =. >1{"1 indices {"0 _ materials

    diffuse =. material * (toLight dot normals)
    specularColor =. (ClampLt0 (toCamera dot LR)) ^ specular

    color =. diffuse + specularColor 
    color =. color +"1 _ ambient

)

NB. ********
NB. Spheres
NB. ********
SphereTrace =: 4 : 0 "1 _
    direction =. 1{y
    position  =. 0{y
    center =. >0{x
    radius =. >1{x
    materialIndex =. >2{x
    
    A =. dot~ direction
    B =. 2*(direction dot (position -"1 center))
    C =. (radius^2) -~ dot~ (position -"1 center) 
    
    rootPart =. (*~B) - (4*A*C)
    mask =. rootPart > 0
    rootPart =. ClampLt0 rootPart
    rootPart =. (%:"0) rootPart
    plusPart =. rootPart + -B
    minusPart =. rootPart -~ -B
    plusPart =. plusPart % 2*A
    minusPart =. minusPart % 2*A
    distance =. plusPart <. minusPart
    mask =. mask *. distance > 0 

    hitpoint =. position + direction * distance
    normal =. ClampLt0 norm hitpoint -"1 _ center

    distance =. distance * mask  
    normal   =. normal *"1 0 mask
    hitpoint =. hitpoint *"1 0 mask

    (($normal)$(3#,distance)), normal, hitpoint ,: (($normal)$materialIndex)
)


NB. ********
NB. Triangles
NB. ********
TriTrace =: 4 : 0 " 1 _
    direction =. >1{y
    position =. >0{y
    p1 =. >0{x
    p2 =. >1{x
    p3 =. >2{x
    materialIndex =. >3{x

    v1 =. p2 -"1 p1
    v2 =. p3 -"1 p2

    tNorm =. norm (v1 cross v2)

    time =: (tNorm dot (p1 -"1 position)) % (direction dot tNorm)

    intersectPoint =. position + direction * time
    v1v3 =. p1 - p3
    v2v1 =. p2 - p1
    v3v2 =. p3 - p2
 
    rayPointV1 =. intersectPoint -"1 p1
    rayPointV2 =. intersectPoint -"1 p2
    rayPointV3 =. intersectPoint -"1 p3

    test1 =. (v2v1 cross"1 rayPointV1) dot tNorm
    test2 =. (v3v2 cross"1 rayPointV2) dot tNorm
    test3 =. (v1v3 cross"1 rayPointV3) dot tNorm
    mask =:(0 < test1) *. (0 < test2) *. (0 < test3)

    hitpoint =. (intersectPoint *"1 0 mask)
    normal =. (tNorm *"_ 0 mask)
    distance =. time * mask
 
    
    (($normal)$(3#,distance)), normal, hitpoint ,: (($normal)$materialIndex)
)




NB. ********
NB. DISPLAY HELPER FUNCTIONS
NB. ********
disp =: <"1@(<.@(100&*))
vector2image =: 3 : 0 
    tmp =. |y
    big =. >./, tmp
    tmp =. tmp % big
    tmp =. tmp * 255
    tmp =. <. tmp
    BGR tmp
)
imshow =:  'rgb' viewmat vector2image

camera =. 0 0 0; 0 _1 0; 1p1%2
dimensions =. 512 512

spheres =. ((0 _2 0);1;0),:((0.1 _0.5 0);0.2;1)
tris =. (5 _3 0; _5 _3 5; _5 _3 _5; 1)
lights =. ((0 0 3; 1 1 1))
materials =. ((0 0.5 1; 3; 0; 1; 1),:(1 0.5 0; 5; 0; 1; 1))
NB. (camera; lights; <materials) Shade
results =:  (camera; lights; <materials) Shade (spheres;<tris) Trace dimensions RayGen camera
$results

imshow results
