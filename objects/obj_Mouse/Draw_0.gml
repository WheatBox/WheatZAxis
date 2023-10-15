x = mouse_x;
y = mouse_y;

if(mouse_wheel_up()) { z += 5; }
if(mouse_wheel_down()) { z -= 5; }
if(keyboard_check(ord("W"))) { height += 5; }
if(keyboard_check(ord("S"))) { height -= 5; }

// ZDrawCollisionCylinder(x, y, z, z + height, 40);
// ZDrawCollisionCube(x - 40, y - 40, z, x + 40, y + 40, z + height);

var strInCollision = $"{z} ~ {z + height}";
var zStrInCollision = z + height / 2;
ZDrawSetAlpha(zStrInCollision, 0.7);
ZDrawSetColor(zStrInCollision, c_black);
ZDrawRectangle(mouse_x, mouse_y, mouse_x + string_width(strInCollision), mouse_y + string_height(strInCollision), zStrInCollision, false);
ZDrawSetColor(zStrInCollision, c_white);
ZDrawText(mouse_x, mouse_y, zStrInCollision, strInCollision);
ZDrawSetAlpha(zStrInCollision, 1);

var _len = 0;
var _list = ds_list_create();
// _len = ZCollisionCylinderList(x, y, z, z + height, 40, obj_Floor, false, true, _list, true);
// _len = ZCollisionCubeList(x - 40, y - 40, z, x + 40, y + 40, z + height, obj_Floor, false, true, _list, true);

id[$ "TEST"] ??= degtorad(180);
TEST += degtorad(2);
var rad = 96;
ZDrawCollisionLine(x, y, z, x + cos(TEST) * rad, y + sin(TEST) * rad, z + height);
ZDrawCircleColorAlpha(x, y, z + height, rad, c_yellow, c_yellow, 0.5, true);
_len = ZCollisionLineList(x, y, z, x + cos(TEST) * rad, y + sin(TEST) * rad, z + height, obj_Floor, true, true, _list, true);

var str = ""; for(var i = 0; i < _len; i++) str += string(_list[| i]) + "\n";
ds_list_destroy(_list);

ZDrawSetColor(9999, c_black);
ZDrawInsertCommand(9999, draw_text, [mouse_x, mouse_y + 40, str]);
ZDrawInsertCommand(9999, draw_text, [mouse_x, mouse_y + 20, $"ZCollisionCylinderList() returns {_len}"]);
ZDrawSetColor(9999, c_white);

show_debug_message(ZCollisionPoint(x, y, z, [obj_Floor, obj_FloorCircle], true, false));