var xMove = -keyboard_check(ord("A")) + keyboard_check(ord("D"));
var yMove = -keyboard_check(ord("W")) + keyboard_check(ord("S"));

if(xMove == 0) {
	xMove = -keyboard_check_pressed(ord("J")) + keyboard_check_pressed(ord("L"));
}
if(yMove == 0) {
	yMove = -keyboard_check_pressed(ord("I")) + keyboard_check_pressed(ord("K"));
}

var haxis = gamepad_axis_value(0, gp_axislh);
var vaxis = gamepad_axis_value(0, gp_axislv);
if(abs(haxis) > 0.4 || abs(vaxis) > 0.4) {
	xMove = haxis;
	yMove = vaxis;
}

var n = sqrt(xMove * xMove + yMove * yMove);

if(n != 0) {
	//ZMovementFast(xMove / n, yMove / n, 0, moveSpeed, [obj_Floor, obj_FloorCircle]);
	//ZMovementFast_Stairs(xMove / n, yMove / n, 0, moveSpeed, [obj_Floor, obj_FloorCircle], 60);
	//ZMovement(xMove / n, yMove / n, 0, moveSpeed, [obj_Floor, obj_FloorCircle]);
	//ZMovement_Stairs(xMove / n, yMove / n, 0, moveSpeed, [obj_Floor, obj_FloorCircle], 60);
	//ZMovementPlus_PixelVer(xMove / n, yMove / n, 0, moveSpeed, [obj_Floor, obj_FloorCircle], 60);
	ZMovementPlus_ShapeVer(xMove / n, yMove / n, 0, moveSpeed, [obj_Floor, obj_FloorCircle], 60);
}

// show_debug_message([n, x - xprevious, y - yprevious]);

ZDrawCollisionCube(bbox_left, bbox_top, z - zOffset, bbox_right, bbox_bottom, z - zOffset + zHeight);
// ZDrawTextColor(x, y, z + 100, z, c_black, c_black, c_black, c_black, 1);

if(xMove != 0 || yMove != 0) {
	ZDrawCircleColorAlpha(500, 500, 100, 64, c_black, c_black, 1, true);
	var _dir = point_direction(0, 0, xMove, yMove);
	ZDrawLineWidthColorAlpha(500, 500, 100, 500 + lengthdir_x(64, _dir), 500 + lengthdir_y(64, _dir), 100, 4, c_black, c_black, 1);
}