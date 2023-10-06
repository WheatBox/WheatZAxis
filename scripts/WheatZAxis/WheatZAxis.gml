#macro ZtoY_RATIO 0.75 // finalY = y - Z2YRATIO * z

function ZtoY(_y, _z) {
	return _y - ZtoY_RATIO * _z;
}

/// @desc Same with ZtoY()
function YZ(_y, _z) {
	return _y - ZtoY_RATIO * _z;
}

globalvar __gZDrawCommands, __gZDrawGpuDepthWas;
__gZDrawCommands = []; // { m_z, m_func, m_args }

#macro ZDRAW_BEGIN __gZDrawCommands = []
#macro ZDRAW_END \
	__gZDrawGpuDepthWas = gpu_get_depth(); \
	array_foreach(__gZDrawCommands, __ZDRAW_COMMAND_RUN); \
	gpu_set_depth(__gZDrawGpuDepthWas)

function __ZDRAW_COMMAND_RUN(element, index) {
	gpu_set_depth(-element.m_z);
	method_call(element.m_func, element.m_args);
	return true;
}

#macro __ZDRAW_COMMAND_INITED { m_z : _z, m_func : _func, m_args : _args }
globalvar __zDrawCommandZ;
function ZDrawInsertCommand(_z, _func, _args = []) {
	static _findFunc = function(element, index) {
		return __zDrawCommandZ < element.m_z;
	}
	static _zDrawCommand = undefined, _index = -1;
	
	_zDrawCommand = __ZDRAW_COMMAND_INITED;
	__zDrawCommandZ = _zDrawCommand.m_z;
	
	_index = array_find_index(__gZDrawCommands, _findFunc);
	if(_index == -1) {
		array_push(__gZDrawCommands, _zDrawCommand);
	} else {
		array_insert(__gZDrawCommands, _index, _zDrawCommand);
	}
}

#macro VISIT_Z [$ "z"]

/* Initialize */

gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);

/* ---------- */

#macro __ZDRAW_ALPHA_BEGIN static _alphaWas = 0;\
		_alphaWas = draw_get_alpha();\
		draw_set_alpha(alpha)
#macro __ZDRAW_ALPHA_END draw_set_alpha(_alphaWas)

/* ZDrawSprite */

function ZDrawSelf(_z = z) {
	static _func = function(_z) {
		static _ytmp = 0;
		_ytmp = y;
		y = ZtoY(y, _z);
		draw_self();
		y = _ytmp;
	}
	
	ZDrawInsertCommand(_z, _func, [_z]);
	
	//ZDrawInsertCommand(_z, draw_sprite_ext, [sprite_index, image_index, x, YZ(y, _z), image_xscale, image_yscale, image_angle, image_blend, image_alpha]);
}

function ZDrawSprite(sprite, subimg, _x, _y, _z) {
	ZDrawInsertCommand(_z, draw_sprite, [sprite, subimg, _x, YZ(_y, _z)]);
}

function ZDrawSpriteExt(sprite, subimg, _x, _y, _z, xscale, yscale, rot, col, alpha) {
	ZDrawInsertCommand(_z, draw_sprite_ext, [sprite, subimg, _x, YZ(_y, _z), xscale, yscale, rot, col, alpha]);
}

function ZDrawSpriteGeneral(sprite, subimg, left, top, width, height, _x, _arr_y_z, xscale, yscale, rot, c1, c2, c3, c4, alpha) {
	ZDrawInsertCommand(_arr_y_z[1], draw_sprite_general, [sprite, subimg, left, top, width, height, _x, YZ(_arr_y_z[0], _arr_y_z[1]), xscale, yscale, rot, c1, c2, c3, c4, alpha]);
}

function ZDrawSpritePart(sprite, subimg, left, top, width, height, _x, _y, _z) {
	ZDrawInsertCommand(_z, draw_sprite_part, [sprite, subimg, left, top, width, height, _x, YZ(_y, _z)]);
}

function ZDrawSpritePartExt(sprite, subimg, left, top, width, height, _x, _y, _z, xscale, yscale, col, alpha) {
	ZDrawInsertCommand(_z, draw_sprite_part_ext, [sprite, subimg, left, top, width, height, _x, YZ(_y, _z), xscale, yscale, col, alpha]);
}

function ZDrawSpritePos(sprite, subimg, x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4, alpha) {
	// TODO - 写个自己的 draw_sprite_pos，把GM内置的这个里的BUG给去了
	ZDrawInsertCommand(mean(z1, z2, z3, z4), draw_sprite_pos, [sprite, subimg, x1, YZ(y1, z1), x2, YZ(y2, z2), x3, YZ(y3, z3), x4, YZ(y4, z4), alpha]);
}

function ZDrawSpriteStretched(sprite, subimg, _x, _y, _z, w, h) {
	ZDrawInsertCommand(_z, draw_sprite_stretched, [sprite, subimg, _x, YZ(_y, _z), w, h]);
}

function ZDrawSpriteStretchedExt(sprite, subimg, _x, _y, _z, w, h, col, alpha) {
	ZDrawInsertCommand(_z, draw_sprite_stretched_ext, [sprite, subimg, _x, YZ(_y, _z), w, h, col, alpha]);
}

function ZDrawSpriteTiled(sprite, subimg, _x, _y, _z) {
	ZDrawInsertCommand(_z, draw_sprite_tiled, [sprite, subimg, _x, YZ(_y, _z)]);
}

function ZDrawSpriteTiledExt(sprite, subimg, _x, _y, _z, xscale, yscale, col, alpha) {
	ZDrawInsertCommand(_z, draw_sprite_tiled_ext, [sprite, subimg, _x, YZ(_y, _z), xscale, yscale, col, alpha]);
}

/* ZDraw Shapes */

function ZDrawCircle(_x, _y, _z, radius, outline) {
	ZDrawInsertCommand(_z, draw_circle, [_x, YZ(_y, _z), radius, outline]);
}

function ZDrawCircleAlpha(_x, _y, _z, radius, alpha, outline) {
	static _func = function(_x, _y, radius, alpha, outline) {
		__ZDRAW_ALPHA_BEGIN
		draw_circle(_x, _y, radius, outline);
		__ZDRAW_ALPHA_END
	}
	ZDrawInsertCommand(_z, _func, [_x, YZ(_y, _z), radius, alpha, outline]);
}

function ZDrawCircleColor(_x, _y, _z, radius, col1, col2, outline) {
	ZDrawInsertCommand(_z, draw_circle_color, [_x, YZ(_y, _z), radius, col1, col2, outline]);
}

function ZDrawCircleColorAlpha(_x, _y, _z, radius, col1, col2, alpha, outline) {
	static _func = function(_x, _y, radius, col1, col2, alpha, outline) {
		__ZDRAW_ALPHA_BEGIN
		draw_circle_color(_x, _y, radius, col1, col2, outline);
		__ZDRAW_ALPHA_END
	}
	ZDrawInsertCommand(_z, _func, [_x, YZ(_y, _z), radius, col1, col2, alpha, outline]);
}

function ZDrawEllipse(_x, _y, _z, xRadius, yRadius, outline) {
	static _yz = 0;
	_yz = YZ(_y, _z);
	ZDrawInsertCommand(_z, draw_ellipse, [_x - xRadius, _yz - yRadius, _x + xRadius, _yz + yRadius, outline]);
}

function ZDrawEllipseAlpha(_x, _y, _z, xRadius, yRadius, alpha, outline) {
	static _func = function(x1, y1, x2, y2, alpha, outline) {
		__ZDRAW_ALPHA_BEGIN
		draw_ellipse(x1, y1, x2, y2, outline);
		__ZDRAW_ALPHA_END
	}
	static _yz = 0;
	_yz = YZ(_y, _z);
	ZDrawInsertCommand(_z, _func, [_x - xRadius, _yz - yRadius, _x + xRadius, _yz + yRadius, alpha, outline]);
}

function ZDrawEllipseColor(_x, _y, _z, xRadius, yRadius, col1, col2, outline) {
	static _whalf = 0, _hhalf = 0, _yz = 0;
	_yz = YZ(_y, _z);
	ZDrawInsertCommand(_z, draw_ellipse_color, [_x - xRadius, _yz - yRadius, _x + xRadius, _yz + yRadius, col1, col2, outline]);
}

function ZDrawEllipseColorAlpha(_x, _y, _z, xRadius, yRadius, col1, col2, alpha, outline) {
	static _func = function(x1, y1, x2, y2, col1, col2, alpha, outline) {
		__ZDRAW_ALPHA_BEGIN
		draw_ellipse_color(x1, y1, x2, y2, col1, col2, outline);
		__ZDRAW_ALPHA_END
	}
	static _yz = 0;
	_yz = YZ(_y, _z);
	ZDrawInsertCommand(_z, _func, [_x - xRadius, _yz - yRadius, _x + xRadius, _yz + yRadius, col1, col2, alpha, outline]);
}

function ZDrawRectangle(x1, y1, x2, y2, _z, outline) {
	static _yAddZ = 0;
	_yAddZ = -_z * ZtoY_RATIO;
	ZDrawInsertCommand(_z, draw_rectangle, [x1, y1 + _yAddZ, x2, y2 + _yAddZ, outline]);
}

function ZDrawRectangleAlpha(x1, y1, x2, y2, _z, alpha, outline) {
	static _func = function(x1, y1, x2, y2, alpha, outline) {
		__ZDRAW_ALPHA_BEGIN
		draw_rectangle(x1, y1, x2, y2, outline);
		__ZDRAW_ALPHA_END
	}
	static _yAddZ = 0;
	_yAddZ = -_z * ZtoY_RATIO;
	ZDrawInsertCommand(_z, _func, [x1, y1 + _yAddZ, x2, y2 + _yAddZ, alpha, outline]);
}

function ZDrawRectangleColor(x1, y1, x2, y2, _z, col1, col2, col3, col4, outline) {
	static _yAddZ = 0;
	_yAddZ = -_z * ZtoY_RATIO;
	ZDrawInsertCommand(_z, draw_rectangle_color, [x1, y1 + _yAddZ, x2, y2 + _yAddZ, col1, col2, col3, col4, outline]);
}

function ZDrawRectangleColorAlpha(x1, y1, x2, y2, _z, col1, col2, col3, col4, alpha, outline) {
	static _func = function(x1, y1, x2, y2, col1, col2, col3, col4, alpha, outline) {
		__ZDRAW_ALPHA_BEGIN
		draw_rectangle_color(x1, y1, x2, y2, col1, col2, col3, col4, outline);
		__ZDRAW_ALPHA_END
	}
	static _yAddZ = 0;
	_yAddZ = -_z * ZtoY_RATIO;
	ZDrawInsertCommand(_z, _func, [x1, y1 + _yAddZ, x2, y2 + _yAddZ, col1, col2, col3, col4, alpha, outline]);
}

function ZDrawLine(x1, y1, z1, x2, y2, z2) {
	ZDrawInsertCommand(z1, draw_line, [x1, YZ(y1, z1), x2, YZ(y2, z2)]);
}

function ZDrawLineAlpha(x1, y1, z1, x2, y2, z2, alpha) {
	static _func = function(x1, y1, x2, y2, alpha) {
		__ZDRAW_ALPHA_BEGIN
		draw_line(x1, y1, x2, y2);
		__ZDRAW_ALPHA_END
	}
	ZDrawInsertCommand(z1, _func, [x1, YZ(y1, z1), x2, YZ(y2, z2), alpha]);
}

function ZDrawLineColor(x1, y1, z1, x2, y2, z2, col1, col2) {
	ZDrawInsertCommand(z1, draw_line_color, [x1, YZ(y1, z1), x2, YZ(y2, z2), col1, col2]);
}

function ZDrawLineColorAlpha(x1, y1, z1, x2, y2, z2, col1, col2, alpha) {
	static _func = function(x1, y1, x2, y2, col1, col2, alpha) {
		__ZDRAW_ALPHA_BEGIN
		draw_line_color(x1, y1, x2, y2, col1, col2);
		__ZDRAW_ALPHA_END
	}
	ZDrawInsertCommand(z1, _func, [x1, YZ(y1, z1), x2, YZ(y2, z2), col1, col2, alpha]);
}

function ZDrawLineWidth(x1, y1, z1, x2, y2, z2, width) {
	ZDrawInsertCommand(z1, draw_line_width, [x1, YZ(y1, z1), x2, YZ(y2, z2), width]);
}

function ZDrawLineWidthAlpha(x1, y1, z1, x2, y2, z2, width, alpha) {
	static _func = function(x1, y1, x2, y2, width, alpha) {
		__ZDRAW_ALPHA_BEGIN
		draw_line_width(x1, y1, x2, y2, width);
		__ZDRAW_ALPHA_END
	}
	ZDrawInsertCommand(z1, _func, [x1, YZ(y1, z1), x2, YZ(y2, z2), width, alpha]);
}

function ZDrawLineWidthColor(x1, y1, z1, x2, y2, z2, width, col1, col2) {
	ZDrawInsertCommand(z1, draw_line_width_color, [x1, YZ(y1, z1), x2, YZ(y2, z2), width, col1, col2]);
}

function ZDrawLineWidthColorAlpha(x1, y1, z1, x2, y2, z2, width, col1, col2, alpha) {
	static _func = function(x1, y1, x2, y2, width, col1, col2, alpha) {
		__ZDRAW_ALPHA_BEGIN
		draw_line_width_color(x1, y1, x2, y2, width, col1, col2);
		__ZDRAW_ALPHA_END
	}
	ZDrawInsertCommand(z1, _func, [x1, YZ(y1, z1), x2, YZ(y2, z2), width, col1, col2, alpha]);
}

function ZDrawPoint(_x, _y, _z) {
	ZDrawInsertCommand(_z, draw_point, [_x, YZ(_y, _z)]);
}

function ZDrawPointAlpha(_x, _y, _z, alpha) {
	static _func = function(_x, _y, alpha) {
		__ZDRAW_ALPHA_BEGIN
		draw_point(_x, _y);
		__ZDRAW_ALPHA_END
	}
	ZDrawInsertCommand(_z, _func, [_x, YZ(_y, _z)]);
}

function ZDrawPointColor(_x, _y, _z, col) {
	ZDrawInsertCommand(_z, draw_point_color, [_x, YZ(_y, _z), col]);
}

function ZDrawPointColorAlpha(_x, _y, _z, col, alpha) {
	static _func = function(_x, _y, col, alpha) {
		__ZDRAW_ALPHA_BEGIN
		draw_point_color(_x, _y, col);
		__ZDRAW_ALPHA_END
	}
	ZDrawInsertCommand(_z, _func, [_x, YZ(_y, _z), col, alpha]);
}

/* ZCollision */

#macro __ZCOLLISION_HANDLE_INIT \
	static _ins = noone, _list = -1, _len = 0, i = 0; \
	_list = ds_list_create();\
	_len = 

#macro __ZCOLLISION_HANDLE_LIST_HEAD \
	for(i = 0; i < _len; i++) { \
		_ins = _list[| i]; \
		if(_ins != noone) { \
			if(InRange(_ins VISIT_Z, z1, z2)) {

#macro __ZCOLLISION_HANDLE_LIST_TAIL }}} ds_list_destroy(_list); return

function ZCollisionPoint(_x, _y, _z, obj, prec, notme) {
	__ZCOLLISION_HANDLE_INIT collision_point_list(_x, _y, obj, prec, notme, _list, false);
	
	__ZCOLLISION_HANDLE_LIST_HEAD
		ds_list_destroy(_list);
		return _ins;
	__ZCOLLISION_HANDLE_LIST_TAIL noone;
}

function ZDrawCollisionCylinder(_x, _y, z1, z2, radius, _radius_use_ZtoY = false) {
	static col1 = c_blue, col2 = c_red, alpha = 0.7;
	static _yz1 = 0, _yz2 = 0, _left = 0, _right = 0, _radFin = 0;
	
	_yz1 = YZ(_y, z1);
	_yz2 = YZ(_y, z2);
	_left = _x - radius;
	_right = _x + radius;
	
	if(_radius_use_ZtoY) {
		_radFin = radius * ZtoY_RATIO;
		ZDrawEllipseColorAlpha(_x, _y, z1, radius, _radFin, col1, col1, alpha, false);
	} else {
		ZDrawCircleColorAlpha(_x, _y, z1, radius, col1, col1, alpha, false);
	}
	
	ZDrawLineColorAlpha(_left, _y, z1, _left, _y, z2, col1, col1, alpha);
	ZDrawLineColorAlpha(_right, _y, z1, _right, _y, z2, col1, col1, alpha);
	
	if(_radius_use_ZtoY) {
		ZDrawEllipseColorAlpha(_x, _y, z2, radius, _radFin, col2, col2, alpha, false);
	} else {
		ZDrawCircleColorAlpha(_x, _y, z2, radius, col2, col2, alpha, false);
	}
}

function ZCollisionCylinder(_x, _y, z1, z2, radius, obj, prec, notme, _radius_use_ZtoY = false) {
	static _radFin = 0;
	
	__ZCOLLISION_HANDLE_INIT 0;
	
	if(_radius_use_ZtoY) {
		_radFin = radius * ZtoY_RATIO;
		_len = collision_ellipse_list(_x - radius, _y - _radFin, _x + radius, _y + _radFin, obj, prec, notme, _list, false);
	} else {
		_len = collision_circle_list(_x, _y, radius, obj, prec, notme, _list, false);
	}
	
	__ZCOLLISION_HANDLE_LIST_HEAD
		ds_list_destroy(_list);
		return _ins;
	__ZCOLLISION_HANDLE_LIST_TAIL noone;
}

function ZCollisionCylinderList(_x, _y, z1, z2, radius, obj, prec, notme, list, ordered, _radius_use_ZtoY = false) {
	static resLen = 0, _radFin = 0;
	
	__ZCOLLISION_HANDLE_INIT 0;
	
	if(_radius_use_ZtoY) {
		_radFin = radius * ZtoY_RATIO;
		_len = collision_ellipse_list(_x - radius, _y - _radFin, _x + radius, _y + _radFin, obj, prec, notme, _list, ordered);
	} else {
		_len = collision_circle_list(_x, _y, radius, obj, prec, notme, _list, ordered);
	}
	
	resLen = 0;
	__ZCOLLISION_HANDLE_LIST_HEAD
		resLen++;
		ds_list_add(list, _ins);
	__ZCOLLISION_HANDLE_LIST_TAIL resLen;
}

function ZDrawCollisionCube(x1, y1, z1, x2, y2, z2) {
	static col1 = c_blue, col2 = c_red, alpha = 0.7;
	
	ZDrawRectangleColorAlpha(x1, y1, x2, y2, z1, col1, col1, col1, col1, alpha, false);
	
	ZDrawLineColorAlpha(x1, y1, z1, x1, y1, z2, col1, col1, alpha);
	ZDrawLineColorAlpha(x2, y2, z1, x2, y2, z2, col1, col1, alpha);
	
	ZDrawRectangleColorAlpha(x1, y1, x2, y2, z2, col2, col2, col2, col2, alpha, false);
}

function ZCollisionCube(x1, y1, z1, x2, y2, z2, obj, prec, notme) {
	__ZCOLLISION_HANDLE_INIT collision_rectangle_list(x1, y1, x2, y2, obj, prec, notme, _list, false);
	
	__ZCOLLISION_HANDLE_LIST_HEAD
		ds_list_destroy(_list);
		return _ins;
	__ZCOLLISION_HANDLE_LIST_TAIL noone;
}

function ZCollisionCubeList(x1, y1, z1, x2, y2, z2, obj, prec, notme, list, ordered) {
	static resLen = 0;
	
	__ZCOLLISION_HANDLE_INIT collision_rectangle_list(x1, y1, x2, y2, obj, prec, notme, _list, ordered);
	
	resLen = 0;
	__ZCOLLISION_HANDLE_LIST_HEAD
		resLen++;
		ds_list_add(list, _ins);
	__ZCOLLISION_HANDLE_LIST_TAIL resLen;
}

/* Others */

function InRange(val, n1, n2) {
	if(n1 > n2) {
		return val >= n2 && val <= n1;
	}
	return val <= n2 && val >= n1;
}
