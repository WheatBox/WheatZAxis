x = mouse_x;
y = mouse_y;

if(mouse_wheel_up()) { z += 5; }
if(mouse_wheel_down()) { z -= 5; }
if(keyboard_check(ord("W"))) { height += 5; }
if(keyboard_check(ord("S"))) { height -= 5; }

ZDRAW_BEGIN

	ZDrawCollisionCylinder(x, y, z, z + height, 40);
	// ZDrawCollisionCube(x - 40, y - 40, z, x + 40, y + 40, z + height);

ZDRAW_END

var _list = ds_list_create();
var _len = ZCollisionCylinderList(x, y, z, z + height, 40, obj_Floor, false, true, _list, true);
// var _len = ZCollisionCubeList(x - 40, y - 40, z, x + 40, y + 40, z + height, obj_Floor, false, true, _list, true);

var str = ""; for(var i = 0; i < _len; i++) str += string(_list[| i]) + "\n";
ds_list_destroy(_list);

ZDRAW_BEGIN

	ZDrawInsertCommand(9999, draw_set_color, [c_black]);
	ZDrawInsertCommand(9999, draw_text, [mouse_x, mouse_y + 20, str]);
	ZDrawInsertCommand(9999, draw_text, [mouse_x, mouse_y - 20, $"ZCollisionCylinderList() returns {_len}"]);
	ZDrawInsertCommand(9999, draw_text, [mouse_x, mouse_y - 40, $"{z} ~ {z + height}"]);
	ZDrawInsertCommand(9999, draw_set_color, [c_white]);

ZDRAW_END
