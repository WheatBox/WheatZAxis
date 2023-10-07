if(init_y_from_z) {
	y = ZtoY(y, -z);
}

if(!instance_exists(obj_ZDraw)) {
	instance_create_depth(0, 0, -99999, obj_ZDraw);
}
