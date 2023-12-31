#macro ZtoY_RATIO 0.75 // finalY = y - Z2YRATIO * z

function ZtoY(_y, _z) {
	return _y - ZtoY_RATIO * _z;
}

/// @desc Same as ZtoY()
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
	with(element.m_ins) {
		method_call(element.m_func, element.m_args);
	}
}

#macro __ZDRAW_COMMAND_INITED { m_z : _z, m_func : _func, m_args : _args, m_ins : _ins }
globalvar __zDrawCommandZ;
function ZDrawInsertCommand(_z, _func, _args = [], _ins = id) {
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

/* ZDrawText */

function ZDrawText(_x, _y, _z, str) {
	ZDrawInsertCommand(_z, draw_text, [_x, YZ(_y, _z), str]);
}

function ZDrawTextColor(_x, _y, _z, str, col1, col2, col3, col4, alpha) {
	ZDrawInsertCommand(_z, draw_text_color, [_x, YZ(_y, _z), str, col1, col2, col3, col4, alpha]);
}

function ZDrawTextExt(_x, _y, _z, str, sep, _w) {
	ZDrawInsertCommand(_z, draw_text_ext, [_x, YZ(_y, _z), str, sep, _w]);
}

function ZDrawTextExtColor(_x, _y, _z, str, sep, _w, col1, col2, col3, col4, alpha) {
	ZDrawInsertCommand(_z, draw_text_ext_color, [_x, YZ(_y, _z), str, sep, _w, col1, col2, col3, col4, alpha]);
}

function ZDrawTextTransformed(_x, _y, _z, str, xscale, yscale, angle) {
	ZDrawInsertCommand(_z, draw_text_transformed, [_x, YZ(_y, _z), str, xscale, yscale, angle]);
}

function ZDrawTextTransformedColor(_x, _y, _z, str, xscale, yscale, angle, col1, col2, col3, col4, alpha) {
	ZDrawInsertCommand(_z, draw_text_transformed_color, [_x, YZ(_y, _z), str, xscale, yscale, angle, col1, col2, col3, col4, alpha]);
}

function ZDrawTextExtTransformed(_x, _y, _z, str, sep, _w, xscale, yscale, angle) {
	ZDrawInsertCommand(_z, draw_text_ext_transformed, [_x, YZ(_y, _z), str, sep, _w, xscale, yscale, angle]);
}

function ZDrawTextExtTransformedColor(_x, _y, _z, str, sep, _w, xscale, yscale, angle, col1, col2, col3, col4, alpha) {
	ZDrawInsertCommand(_z, draw_text_ext_transformed_color, [_x, YZ(_y, _z), str, sep, _w, xscale, yscale, angle, col1, col2, col3, col4, alpha]);
}

/* ZDrawSet */

/// @desc
/// 给 ZDraw 函数的 draw_set_alpha()，注意会影响到大于该 z 坐标的其它 z 坐标的 ZDraw 函数
///
/// _
///
/// draw_set_alpha() for ZDraw functions, note that it will affect the ZDraw function of other z coordinates greater than this z coordinate
function ZDrawSetAlpha(_z, alpha) {
	ZDrawInsertCommand(_z, draw_set_alpha, [alpha]);
}

/// @desc
/// 给 ZDraw 函数的 draw_set_color()，注意会影响到大于该 z 坐标的其它 z 坐标的 ZDraw 函数
///
/// _
///
/// draw_set_color() for ZDraw functions, note that it will affect the ZDraw function of other z coordinates greater than this z coordinate
function ZDrawSetColor(_z, col) {
	ZDrawInsertCommand(_z, draw_set_color, [col]);
}

function ZDrawSetFont(_z, font) {
	ZDrawInsertCommand(_z, draw_set_font, [font]);
}

function ZDrawSetHalign(_z, halign) {
	ZDrawInsertCommand(_z, draw_set_halign, [halign]);
}

function ZDrawSetValign(_z, valign) {
	ZDrawInsertCommand(_z, draw_set_valign, [valign]);
}

function ZDrawSetCirclePrecision(_z, precision) {
	ZDrawInsertCommand(_z, draw_set_circle_precision, [precision]);
}

/* ZCollision */

#macro __ZCOLLISION_HANDLE_MAKE_Z1Z2 static z1 = 0, z2 = 0; z1 = _z; z2 = _z

#macro __ZCOLLISION_HANDLE_INIT \
	static _ins = noone, _list = -1, _len = 0, i = 0; \
	static __visZ = 0, __n1 = 0, __n2 = 0; \
	_list = ds_list_create();\
	_len = 

#macro __ZCOLLISION_HANDLE_LIST_HEAD \
	for(i = 0; i < _len; i++) { \
		_ins = _list[| i]; \
		if(_ins != noone) { \
			__visZ = _ins VISIT_Z; \
			if(__visZ == undefined) { \
				__n1 = 0; __n2 = 0; \
			} else { \
				__n1 = __visZ - _ins.zOffset; \
				__n2 = __n1 + _ins.zHeight; \
			} \
			if(RangeInRange(__n1, __n2, z1, z2)) {

#macro __ZCOLLISION_HANDLE_LIST_TAIL }}} ds_list_destroy(_list); return

#macro __ZCOLLISION_HANDLE \
	__ZCOLLISION_HANDLE_LIST_HEAD \
		ds_list_destroy(_list); \
		return _ins; \
	__ZCOLLISION_HANDLE_LIST_TAIL noone

#macro __ZCOLLISION_HANDLE_LIST \
	static resLen = 0; \
	resLen = 0; \
	__ZCOLLISION_HANDLE_LIST_HEAD \
		resLen++; \
		ds_list_add(list, _ins); \
	__ZCOLLISION_HANDLE_LIST_TAIL resLen

function ZCollisionPoint(_x, _y, _z, obj, prec, notme) {
	__ZCOLLISION_HANDLE_MAKE_Z1Z2
	
	__ZCOLLISION_HANDLE_INIT collision_point_list(_x, _y, obj, prec, notme, _list, false);
	
	__ZCOLLISION_HANDLE
}

function ZCollisionPointList(_x, _y, _z, obj, prec, notme, list, ordered) {
	__ZCOLLISION_HANDLE_MAKE_Z1Z2
	
	__ZCOLLISION_HANDLE_INIT collision_point_list(_x, _y, obj, prec, notme, _list, ordered);
	
	__ZCOLLISION_HANDLE_LIST
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
	
	__ZCOLLISION_HANDLE
}

function ZCollisionCylinderList(_x, _y, z1, z2, radius, obj, prec, notme, list, ordered, _radius_use_ZtoY = false) {
	static _radFin = 0;
	
	__ZCOLLISION_HANDLE_INIT 0;
	
	if(_radius_use_ZtoY) {
		_radFin = radius * ZtoY_RATIO;
		_len = collision_ellipse_list(_x - radius, _y - _radFin, _x + radius, _y + _radFin, obj, prec, notme, _list, ordered);
	} else {
		_len = collision_circle_list(_x, _y, radius, obj, prec, notme, _list, ordered);
	}
	
	__ZCOLLISION_HANDLE_LIST
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
	
	__ZCOLLISION_HANDLE
}

function ZCollisionCubeList(x1, y1, z1, x2, y2, z2, obj, prec, notme, list, ordered) {
	__ZCOLLISION_HANDLE_INIT collision_rectangle_list(x1, y1, x2, y2, obj, prec, notme, _list, ordered);
	
	__ZCOLLISION_HANDLE_LIST
}

function ZDrawCollisionLine(x1, y1, z1, x2, y2, z2) {
	static col1 = c_blue, col2 = c_red, alpha = 0.7;
	
	ZDrawLineColorAlpha(x1, y1, z1, x2, y2, z2, c_blue, c_red, alpha);
}

#macro __ZCOLLISION_HANDLE_INIT__ZCOLLISIONLINE \
	static x1 = 0, y1 = 0, z1 = 0, x2 = 0, y2 = 0, z2 = 0;\
	if(_z1 < _z2) { \
		z1 = _z1; z2 = _z2; \
		x1 = _x1; x2 = _x2; \
		y1 = _y1; y2 = _y2; \
	} else { \
		z1 = _z2; z2 = _z1; \
		x1 = _x2; x2 = _x1; \
		y1 = _y2; y2 = _y1; \
	} \
	\
	static _collitionZLow = 0, _collitionZHigh = 0; \
	static _xRatio = 0, _yRatio = 0; \
	static _xFrom = 0, _xTo = 0, _yFrom = 0, _yTo = 0; \
	static _lineZHeight = 0; \
	\
	_lineZHeight = (z2 - z1); \
	\
	if(_lineZHeight == 0) { \
		_xRatio = 0; \
		_yRatio = 0; \
	} else { \
		_xRatio = (x2 - x1) / _lineZHeight; \
		_yRatio = (y2 - y1) / _lineZHeight; \
	} \
	\
	__ZCOLLISION_HANDLE_INIT collision_line_list(x1, y1, x2, y2, obj, prec, notme, _list, false)

#macro __ZCOLLISION_HANDLE_LIST_HEAD__ZCOLLISIONLINE \
	__ZCOLLISION_HANDLE_LIST_HEAD \
	_collitionZLow = max(min(__n1, __n2), z1) - z1; \
	_collitionZHigh = min(max(__n1, __n2), z2) - z1; \
	\
	_xFrom = x1 + _xRatio * _collitionZLow; \
	_xTo = x1 + _xRatio * _collitionZHigh; \
	_yFrom = y1 + _yRatio * _collitionZLow; \
	_yTo = y1 + _yRatio * _collitionZHigh; \
	\
	if(collision_line(_xFrom, _yFrom, _xTo, _yTo, _ins, prec, notme)) {

#macro __ZCOLLISION_HANDLE_LIST_TAIL__ZCOLLISIONLINE } __ZCOLLISION_HANDLE_LIST_TAIL

function ZCollisionLine(_x1, _y1, _z1, _x2, _y2, _z2, obj, prec, notme) {
	__ZCOLLISION_HANDLE_INIT__ZCOLLISIONLINE
	
	__ZCOLLISION_HANDLE_LIST_HEAD__ZCOLLISIONLINE
		ds_list_destroy(_list);
		return _ins;
	__ZCOLLISION_HANDLE_LIST_TAIL__ZCOLLISIONLINE noone;
}

function ZCollisionLineList(_x1, _y1, _z1, _x2, _y2, _z2, obj, prec, notme, list, ordered) {
	static resLen = 0;
	
	__ZCOLLISION_HANDLE_INIT__ZCOLLISIONLINE
	
	resLen = 0;
	__ZCOLLISION_HANDLE_LIST_HEAD__ZCOLLISIONLINE
		resLen++;
		ds_list_add(list, _ins);
	__ZCOLLISION_HANDLE_LIST_TAIL__ZCOLLISIONLINE resLen;
}

function ZInstancePlace(_x, _y, _z, obj) {
	__ZCOLLISION_HANDLE_MAKE_Z1Z2
	
	__ZCOLLISION_HANDLE_INIT instance_place_list(_x, _y, obj, _list, false);
	
	__ZCOLLISION_HANDLE
}

function ZInstancePlaceList(_x, _y, _z, obj, list, ordered) {
	__ZCOLLISION_HANDLE_MAKE_Z1Z2
	
	__ZCOLLISION_HANDLE_INIT instance_place_list(_x, _y, obj, _list, ordered);
	
	__ZCOLLISION_HANDLE_LIST
}

function ZInstancePosition(_x, _y, _z, obj) {
	__ZCOLLISION_HANDLE_MAKE_Z1Z2
	
	__ZCOLLISION_HANDLE_INIT instance_position_list(_x, _y, obj, _list, false);
	
	__ZCOLLISION_HANDLE
}

function ZInstancePositionList(_x, _y, _z, obj, list, ordered) {
	__ZCOLLISION_HANDLE_MAKE_Z1Z2
	
	__ZCOLLISION_HANDLE_INIT instance_position_list(_x, _y, obj, _list, ordered);
	
	__ZCOLLISION_HANDLE_LIST
}

/* Physics */

function ZOnFloor(_objWall) {
	return (ZInstancePlace(x, y, z - 1, _objWall) != noone);
}

function __ZMovementCollideX(_x, _y, _z, _xStep, _xDir, _objWall) {
	if(ZInstancePlace(_x + _xStep, _y, _z, _objWall) != noone) {
		while(ZInstancePlace(_x + _xDir, _y, _z, _objWall) == noone) {
			_x += _xDir;
		}
	} else {
		_x += _xStep;
	}
	return _x;
}

function __ZMovementCollideY(_x, _y, _z, _yStep, _yDir, _objWall) {
	if(ZInstancePlace(_x, _y + _yStep, _z, _objWall) != noone) {
		while(ZInstancePlace(_x, _y + _yDir, _z, _objWall) == noone) {
			_y += _yDir;
		}
	} else {
		_y += _yStep;
	}
	return _y;
}

function __ZMovementCollideZ(_x, _y, _z, _zStep, _zDir, _objWall) {
	if(ZInstancePlace(_x, _y, _z + _zStep, _objWall) != noone) {
		while(ZInstancePlace(_x, _y, _z + _zDir, _objWall) == noone) {
			_z += _zDir;
		}
	} else {
		_z += _zStep;
	}
	return _z;
}

/// @desc
/// 参数 _arrDest：这是一个用于输入和输出的数组
///
/// _[0] = z（输入） | 变化后的 z（输出）
///
/// _[1] = 楼梯的最高高度（输入） | 没用完的楼梯高度（输出）
///
/// _
///
/// Argument _arrDest: This is a array for input and output
///
/// _[0] = z (input) | z after (output)
///
/// _[1] = Stairs' max height (input) | Stairs' unused height (output)
function __ZMovementCollideX_Stairs(_x, _y, _arrDest, _xStep, _xDir, _objWall) {
	static _zTemp = 0, _stairHeight = 0, _isStair = false;
	
	_zTemp = _arrDest[0];
	_stairHeight = _arrDest[1];
	
	if(ZInstancePlace(_x + _xStep, _y, _zTemp, _objWall) != noone) {
		
		_isStair = true;
		do {
			_zTemp++;
			if(_zTemp > _stairHeight) {
				_isStair = false;
				break;
			}
		} _do_while_(ZInstancePlace(_x + _xStep, _y, _zTemp, _objWall) != noone);
		
		if(_isStair) {
			_arrDest[1] = _zTemp - _arrDest[0];
			_arrDest[0] = _zTemp;
			
			// [0] = 新的 Z 坐标 | New Z coordinate
			// [1] = 没用完的楼梯高度 | Stairs' unused height
			
			return _x + _xStep;
		}
		_zTemp = _arrDest[0];
		
		while(ZInstancePlace(_x + _xDir, _y, _zTemp, _objWall) == noone) {
			_x += _xDir;
		}
	} else {
		_x += _xStep;
	}
	return _x;
}

/// @desc
/// 见 __ZMovementCollideX_Stairs()
///
/// See __ZMovementCollideX_Stairs()
function __ZMovementCollideY_Stairs(_x, _y, _arrDest, _yStep, _yDir, _objWall) {
	static _zTemp = 0, _stairHeight = 0, _isStair = false;
	
	_zTemp = _arrDest[0];
	_stairHeight = _arrDest[1];
	
	if(ZInstancePlace(_x, _y + _yStep, _zTemp, _objWall) != noone) {
		
		_isStair = true;
		do {
			_zTemp++;
			if(_zTemp > _stairHeight) {
				_isStair = false;
				break;
			}
		} _do_while_(ZInstancePlace(_x, _y + _yStep, _zTemp, _objWall) != noone);
		
		if(_isStair) {
			_arrDest[1] = _zTemp - _arrDest[0];
			_arrDest[0] = _zTemp;
			
			// [0] = 新的 Z 坐标 | New Z coordinate
			// [1] = 没用完的楼梯高度 | Stairs' unused height
			
			return _y + _yStep;
		}
		_zTemp = _arrDest[0];
		
		while(ZInstancePlace(_x, _y + _yDir, _zTemp, _objWall) == noone) {
			_y += _yDir;
		}
	} else {
		_y += _yStep;
	}
	return _y;
}

function ZMovementFast(_xDir, _yDir, _zDir, _moveSpeed, _objWall) {
	if(_xDir == 0 && _yDir == 0 && _zDir == 0) {
		return;
	}
	if(_moveSpeed == 0) {
		return;
	}
	
	x = __ZMovementCollideX(x, y, z, _xDir * _moveSpeed, _xDir, _objWall);
	y = __ZMovementCollideY(x, y, z, _yDir * _moveSpeed, _yDir, _objWall);
	z = __ZMovementCollideZ(x, y, z, _zDir * _moveSpeed, _zDir, _objWall);
}

function ZMovementFast_Stairs(_xDir, _yDir, _zDir, _moveSpeed, _objWall, _stairsMaxHeight) {
	if(_xDir == 0 && _yDir == 0 && _zDir == 0) {
		return;
	}
	if(_moveSpeed == 0) {
		return;
	}
	
	static _arrDest_z = [ 0, 0 ];
	_arrDest_z[0] = z;
	_arrDest_z[1] = _stairsMaxHeight;
	
	x = __ZMovementCollideX_Stairs(x, y, _arrDest_z, _xDir * _moveSpeed, _xDir, _objWall);
	y = __ZMovementCollideY_Stairs(x, y, _arrDest_z, _yDir * _moveSpeed, _yDir, _objWall);
	z = __ZMovementCollideZ(x, y, _arrDest_z[0], _zDir * _moveSpeed, _zDir, _objWall);
}

#macro __ZMovement_BASIC_HEAD \
	if(_xDir == 0 && _yDir == 0 && _zDir == 0) { \
		return; \
	} \
	if(_moveSpeed == 0) { \
		return; \
	} \
	\
	static _steplen = 0; \
	_steplen = min(bbox_right - bbox_left, bbox_bottom - bbox_top, _moveSpeed); \
	_steplen = ((_steplen < 1) ? 1 : _steplen); \
	\
	static _xStep = 0, _yStep = 0, _zStep = 0; \
	_xStep = _xDir * _steplen; \
	_yStep = _yDir * _steplen; \
	_zStep = _zDir * _steplen; \
	\
	static _x = 0, _y = 0, _z = 0; \
	_x = x; _y = y; _z = z; \
	\
	static _movedDis = 0; /* 已经移动过的距离 | Distance that already moved */ \
	_movedDis = 0; \
	\
	static _movedDisOver = 0; /* 超出的移动距离 | Distance that exceed */ \
	\
	static _xCurrStep = 0, _yCurrStep = 0, _zCurrStep = 0; \
	\
	while(_movedDis < _moveSpeed) { \
		\
		if(_movedDis <= _moveSpeed) { \
			_xCurrStep = _xStep; \
			_yCurrStep = _yStep; \
			_zCurrStep = _zStep; \
		}/* else { \
			_movedDisOver = _movedDis - _moveSpeed; \
			_xCurrStep += _xStep - _xDir * _movedDisOver; \
			_yCurrStep += _yStep - _yDir * _movedDisOver; \
			_zCurrStep += _zStep - _zDir * _movedDisOver; \
		}*/

#macro __ZMovement_BASIC_TAIL \
		if(_x != _x + _xCurrStep || _y != _y + _yCurrStep || _z != _z + _zCurrStep) { \
			break; \
		} \
	}

function ZMovement(_xDir, _yDir, _zDir, _moveSpeed, _objWall) {
	__ZMovement_BASIC_HEAD
		
		_x = __ZMovementCollideX(_x, _y, _z, _xCurrStep, _xDir, _objWall);
		_y = __ZMovementCollideY(_x, _y, _z, _yCurrStep, _yDir, _objWall);
		_z = __ZMovementCollideZ(_x, _y, _z, _zCurrStep, _zDir, _objWall);
		
		_movedDis += _steplen;
		
	__ZMovement_BASIC_TAIL
	
	x = _x;
	y = _y;
	z = _z;
}

function ZMovement_Stairs(_xDir, _yDir, _zDir, _moveSpeed, _objWall, _stairsMaxHeight) {
	static _arrDest_z = [ 0, 0 ];
	
	__ZMovement_BASIC_HEAD
	
		_arrDest_z[0] = z;
		_arrDest_z[1] = _stairsMaxHeight;
		
		_x = __ZMovementCollideX_Stairs(_x, _y, _arrDest_z, _xCurrStep, _xDir, _objWall);
		_y = __ZMovementCollideY_Stairs(_x, _y, _arrDest_z, _yCurrStep, _yDir, _objWall);
		_z = __ZMovementCollideZ(_x, _y, _arrDest_z[0], _zCurrStep, _zDir, _objWall);
		
		_movedDis += _steplen;
		
	__ZMovement_BASIC_TAIL
	
	x = _x;
	y = _y;
	z = _z;
}

function ZMovementPlus_PixelVer(_xDir, _yDir, _zDir, _moveSpeed, _objWall, _stairsMaxHeight) {
	
	static _xPrev = 0, _yPrev = 0, _zPrev = 0;
	_xPrev = x;
	_yPrev = y;
	_zPrev = z;
	
	static _arrDest_z = [ 0, 0 ];
	
	__ZMovement_BASIC_HEAD
		
		_arrDest_z[0] = z;
		_arrDest_z[1] = _stairsMaxHeight;
		
		_x = __ZMovementCollideX_Stairs(_x, _y, _arrDest_z, _xCurrStep, _xDir, _objWall);
		_y = __ZMovementCollideY_Stairs(_x, _y, _arrDest_z, _yCurrStep, _yDir, _objWall);
		_z = __ZMovementCollideZ(_x, _y, _arrDest_z[0], _zCurrStep, _zDir, _objWall);
		
		_movedDis += point_distance_3d(_x, _y, _z, _xPrev, _yPrev, _zPrev);
		
		_xPrev = _x;
		_yPrev = _y;
		_zPrev = _z;
		
	__ZMovement_BASIC_TAIL
	
	/* 关于 XY 轴的靠墙移动 | About moving against the wall of XY Axis */
	
	static _iDisSign = 0, _iDis = 0, _iDisCmp = 0, _iDisCmpSign = 0;
	static _remainDis = 0, _remainDisTemp = 0, _xDirSign = 0, _yDirSign = 0;
	
	static _iDisDestArr = [];
	static _Calculate_iDis = function(_destArr, _remainDis, _moveSpeed, _x, _y, _z, _xDirSign, _yDirSign, _objWall) {
		static _iDis = 0, _iDisSign = 0;
		
		_destArr[0] = _moveSpeed + 1; // _iDisCmp
		_destArr[1] = 0; // _iDisCmpSign
		
		for(_iDisSign = -1; _iDisSign <= 1; _iDisSign += 2) {
			
			for(_iDis = _remainDis; _iDis >= 0; _iDis--) {
				if(_xDirSign != 0) {
					if(ZInstancePlace(_x + _xDirSign * (_remainDis - _iDis), _y + _iDisSign * _iDis, _z, _objWall) != noone) {
						_iDis++;
						break;
					}
				} else {
					if(ZInstancePlace(_x + _iDisSign * _iDis, _y + _yDirSign * (_remainDis - _iDis), _z, _objWall) != noone) {
						_iDis++;
						break;
					}
				}
			}
			if(_iDis < 0 || _iDis == _remainDis + 1) {
				_iDis = 0;
			}
			
			if(_iDis < _destArr[0] && _iDis != 0) {
				_destArr[0] = _iDis;
				_destArr[1] = _iDisSign;
			}
			
		}
	}
	
	/* 嗯……是的，宏。 | emmm... yes, macro. */
	#macro __ZMovementPlus_PixelVer_MovementX if(_iDisCmpSign != 0) { \
		_xPrev = _x; \
		_x = __ZMovementCollideX(_x, _y + _iDisCmpSign * _iDisCmp, _z, _xDirSign * (_remainDis - _iDisCmp), _xDir, _objWall); \
		if(_x != _xPrev) { \
			_y += _iDisCmpSign * _iDisCmp; \
		} \
		_remainDis -= _iDisCmp; \
		if(_remainDis < 0) { \
			_remainDis = 0; \
		} \	
		_remainDisTemp = _remainDis; \
	}
	#macro __ZMovementPlus_PixelVer_MovementY if(_iDisCmpSign != 0) { \
		_yPrev = _y; \
		_y = __ZMovementCollideY(_x + _iDisCmpSign * _iDisCmp, _y, _z, _yDirSign * (_remainDis - _iDisCmp), _yDir, _objWall); \
		if(_y != _yPrev) { \
			_x += _iDisCmpSign * _iDisCmp; \
		} \
		_remainDis -= _iDisCmp; \
		if(_remainDis < 0) { \
			_remainDis = 0; \
		} \	
		_remainDisTemp = _remainDis; \
	}
	
	static _xFirst = false;
	
	if(_movedDis < _moveSpeed) {
		_xDirSign = sign(_xDir);
		_yDirSign = sign(_yDir);
		
		_remainDisTemp = _moveSpeed - _movedDis;
		
		if(_xDirSign != 0 && _yDirSign == 0) {
			
			_remainDis = _remainDisTemp;
			
			_Calculate_iDis(_iDisDestArr, _remainDis, _moveSpeed, _x, _y, _z, _xDirSign, 0, _objWall);
			
			_iDisCmp = _iDisDestArr[0];
			_iDisCmpSign = _iDisDestArr[1];
			
			__ZMovementPlus_PixelVer_MovementX
		
		}
		else
		if(_xDirSign == 0 && _yDirSign != 0) {
			
			_remainDis = _remainDisTemp;
			
			_Calculate_iDis(_iDisDestArr, _remainDis, _moveSpeed, _x, _y, _z, 0, _yDirSign, _objWall);
			
			_iDisCmp = _iDisDestArr[0];
			_iDisCmpSign = _iDisDestArr[1];
			
			__ZMovementPlus_PixelVer_MovementY
			
		}
		else
		if(_xDirSign != 0 && _yDirSign != 0) {
			
			_xDirSign = _xDir;
			_yDirSign = _yDir;
			
			// 确定应当 x 优先，还是 y 优先 | Determine whether x should be prioritized or y should be prioritized
			
			_remainDis = _remainDisTemp;
			_Calculate_iDis(_iDisDestArr, _remainDis, _moveSpeed, _x, _y, _z, _xDirSign, 0, _objWall);
			
			_iDisCmp = _iDisDestArr[0];
			_iDisCmpSign = _iDisDestArr[1];
			
			_remainDis = _remainDisTemp;
			_Calculate_iDis(_iDisDestArr, _remainDis, _moveSpeed, _x, _y, _z, 0, _yDirSign, _objWall);
			
			if(_iDisDestArr[0] < _iDisCmp) {
				
				_xFirst = false;
				
				_iDisCmp = _iDisDestArr[0];
				_iDisCmpSign = _iDisDestArr[1];
			} else {
				
				_xFirst = true;
				
			}
			
			if(_xFirst) {
				
				__ZMovementPlus_PixelVer_MovementX
				
				_remainDis = _remainDisTemp;
			
				_Calculate_iDis(_iDisDestArr, _remainDis, _moveSpeed, _x, _y, _z, 0, _yDirSign, _objWall);
			
				_iDisCmp = _iDisDestArr[0];
				_iDisCmpSign = _iDisDestArr[1];
			
				__ZMovementPlus_PixelVer_MovementY
				
			} else {
				
				__ZMovementPlus_PixelVer_MovementY
				
				_remainDis = _remainDisTemp;
			
				_Calculate_iDis(_iDisDestArr, _remainDis, _moveSpeed, _x, _y, _z, _xDirSign, 0, _objWall);
			
				_iDisCmp = _iDisDestArr[0];
				_iDisCmpSign = _iDisDestArr[1];
			
				__ZMovementPlus_PixelVer_MovementX
				
			}
			
		}
	}
	
	x = _x;
	y = _y;
	z = _z;
	
	//show_debug_message(point_distance(x, y, xprevious, yprevious));
}

function ZMovementPlus_ShapeVer(_xDir, _yDir, _zDir, _moveSpeed, _objWall, _stairsMaxHeight) {
	
	static _listWalls = ds_list_create(), _listWallsLen = 0, _insWallTemp = noone, i = 0;
	
	static _xTemp = 0, _yTemp = 0;
	
	static _remainStep = 0, _finalStep = 0, _finalStepSign = 0, _finalXDir = 0, _finalYDir = 0, _finalDir = 0;
	
	static _toWallDis = 0, _toWallDir = 0;
	
	static _toWallDisLT = 0, _toWallDisLB = 0, _toWallDisRT = 0, _toWallDisRB = 0;
	static _toWallDirLT = 0, _toWallDirLB = 0, _toWallDirRT = 0, _toWallDirRB = 0;
	
	static _side = 0;
	
	__ZMovement_BASIC_HEAD
	
		ds_list_clear(_listWalls);
		_listWallsLen = ZInstancePlaceList(_x + _xCurrStep, _y + _yCurrStep, _z, _objWall, _listWalls, true);
		
		if(_listWallsLen > 0) {
			
			_remainStep = _steplen;
			
			for(i = 0; i < _listWallsLen; i++) {
			
				_insWallTemp = _listWalls[| i];
				
				_xCurrStep = _xDir * _remainStep;
				_yCurrStep = _yDir * _remainStep;
			
				// TODO - 圆
				if(ZInstancePlace(_x + _xCurrStep, _y + _yCurrStep, _z, _insWallTemp) != noone) {
				
					while(ZInstancePlace(_x + _xDir, _y + _yDir, _z, _objWall) == noone) {
						_x += _xDir;
						_y += _yDir;
					
						_remainStep -= 1;
						if(_remainStep <= 0) {
							_remainStep = 0;
							break;
						}
					}
				
					if(_remainStep == 0) {
						continue;
					}
					
					/* 检测在墙体的上下面还是左右面 | Check whether on the Top & Bottom or Left & Right of the wall */
					
					/* 或者说，是所接触墙面的法向向量的方向
					 * （相对于墙体的本地方向建立的坐标系来说）
					 * |
					 * Or rather, it is the direction of the normal vector of the wall surface in contact with it
					 * (Compared to the coordinate system established in the local direction of the wall)
					 */
					
					_finalDir = _insWallTemp.image_angle;
					
					_insWallTemp.image_angle = 0;
					
					_toWallDisLT = point_distance(_insWallTemp.x, _insWallTemp.y, bbox_left, bbox_top);
					_toWallDisLB = point_distance(_insWallTemp.x, _insWallTemp.y, bbox_left, bbox_bottom);
					_toWallDisRT = point_distance(_insWallTemp.x, _insWallTemp.y, bbox_right, bbox_top);
					_toWallDisRB = point_distance(_insWallTemp.x, _insWallTemp.y, bbox_right, bbox_bottom);
					_toWallDirLT = point_direction(_insWallTemp.x, _insWallTemp.y, bbox_left, bbox_top) - _finalDir;
					_toWallDirLB = point_direction(_insWallTemp.x, _insWallTemp.y, bbox_left, bbox_bottom) - _finalDir;
					_toWallDirRT = point_direction(_insWallTemp.x, _insWallTemp.y, bbox_right, bbox_top) - _finalDir;
					_toWallDirRB = point_direction(_insWallTemp.x, _insWallTemp.y, bbox_right, bbox_bottom) - _finalDir;
					
					/* 0b00 =         | 无          | Nothing
					 * 0b10 =   "|"   | 在 上下      | On Top & Bottom
					 * 0b01 =   "-"   | 在 左右      | On Left & Right
					 * 0b11 =         | 在 凸出的直角 | At right angles protruding
					 */
					_side =
					((
						RangeInRange(
							_insWallTemp.x + lengthdir_x(_toWallDisLT, _toWallDirLT),
							_insWallTemp.x + lengthdir_x(_toWallDisRB, _toWallDirRB),
							_insWallTemp.bbox_left, _insWallTemp.bbox_right
						) | RangeInRange(
							_insWallTemp.x + lengthdir_x(_toWallDisLB, _toWallDirLB),
							_insWallTemp.x + lengthdir_x(_toWallDisRT, _toWallDirRT),
							_insWallTemp.bbox_left, _insWallTemp.bbox_right
						)
					) << 1)
					|
					((
						RangeInRange(
							_insWallTemp.y + lengthdir_y(_toWallDisLT, _toWallDirLT),
							_insWallTemp.y + lengthdir_y(_toWallDisRB, _toWallDirRB),
							_insWallTemp.bbox_top, _insWallTemp.bbox_bottom
						) | RangeInRange(
							_insWallTemp.y + lengthdir_y(_toWallDisLB, _toWallDirLB),
							_insWallTemp.y + lengthdir_y(_toWallDisRT, _toWallDirRT),
							_insWallTemp.bbox_top, _insWallTemp.bbox_bottom
						)
					)/* << 0 */);
					
					_insWallTemp.image_angle = _finalDir;
					
					if(_side == 0b10) {
						// "|" | 在 上下 | On Top & Bottom
						
						// 啥也不干 | Do nothing
						
					} else if(_side == 0b01) {
						// "-" | 在 左右 | On Left & Right
						
						_finalDir += 90;
						
					} else {
						// 在 凸出的直角 | At right angles protruding
						
						_xTemp = _x;
						_yTemp = _y;
						
						_x = __ZMovementCollideX(_x, _y, _z, _xDir * _remainStep, _xDir, _objWall);
						_y = __ZMovementCollideY(_x, _y, _z, _yDir * _remainStep, _yDir, _objWall);
						
						_remainStep -= point_distance(_x, _y, _xTemp, _yTemp);
						
						if(_remainStep < 0) {
							_remainStep = 0;
						}
						
						continue;
						// 不参与后续的计算 | Not participating in subsequent calculations
						
					}
					
					/* -------------------------------------- */
					
					_finalStep = lengthdir_x(_remainStep, point_direction(0, 0, _xDir, _yDir) - _finalDir);
					_finalStepSign = sign(_finalStep);
					
					if(_finalStepSign == 0) {
						break;
					}
				
					_xTemp = _x + lengthdir_x(_finalStep, _finalDir);
					_yTemp = _y + lengthdir_y(_finalStep, _finalDir);
				
					_finalStep *= _finalStepSign; // abs()
				
					if(ZInstancePlace(_xTemp, _yTemp, _z, _objWall) == noone) {
						_x = _xTemp;
						_y = _yTemp;
					
						_remainStep = 0;
					} else {
					
						_finalXDir = lengthdir_x(_finalStepSign, _finalDir);
						_finalYDir = lengthdir_y(_finalStepSign, _finalDir);
					
						while(ZInstancePlace(_x + _finalXDir, _y + _finalYDir, _z, _objWall) == noone) {
							_x += _finalXDir;
							_y += _finalYDir;
						
							_finalStep -= 1;
							if(_finalStep <= 0) {
								_finalStep = 0;
								break;
							}
						}
					
						_remainStep = _finalStep;
						
					}
				
				} else {
					_x = __ZMovementCollideX(_x, _y, _z, _xCurrStep, _xDir, _objWall);
					_y = __ZMovementCollideY(_x, _y, _z, _yCurrStep, _yDir, _objWall);
					
					_remainStep = 0;
				}
			
			}
			
		} else {
			_x = __ZMovementCollideX(_x, _y, _z, _xCurrStep, _xDir, _objWall);
			_y = __ZMovementCollideY(_x, _y, _z, _yCurrStep, _yDir, _objWall);
		}
		
		_z = __ZMovementCollideZ(_x, _y, _z, _zCurrStep, _zDir, _objWall);
		
		_movedDis += _steplen;
		
	__ZMovement_BASIC_TAIL
	
	x = _x;
	y = _y;
	z = _z;
	
	// show_debug_message(point_distance(x, y, xprevious, yprevious));
}

/* Others */

function InRange(val, n1, n2) {
	if(n1 > n2) {
		return val >= n2 && val <= n1;
	}
	return val <= n2 && val >= n1;
}

function RangeInRange(n1, n2, m1, m2) {
	return abs((n1 + n2) / 2 - (m1 + m2) / 2) <= abs((n1 - n2) / 2) + abs((m1 - m2) / 2);
}

#macro _do_while_ until !
