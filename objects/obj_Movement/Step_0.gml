var xMove = -keyboard_check(ord("A")) + keyboard_check(ord("D"));
var yMove = -keyboard_check(ord("W")) + keyboard_check(ord("S"));

move_and_collide(xMove * moveSpeed, yMove * moveSpeed, [obj_Floor, obj_FloorCircle]);

ZDrawCollisionCube(bbox_left, bbox_top, z - zOffset, bbox_right, bbox_bottom, z - zOffset + zHeight);
