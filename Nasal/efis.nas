#------------------------------------------
# efis.nas
# author:       jsb 
# created:      12/2016
# last update:  12/2016
#------------------------------------------

# class DisplayUnit
# handels a 3D object in the cockpit
var DisplayUnit = 
{
	# name: string, identifier
	# canvas_settings: vector
	# screen_obj: string, name of 3D object for canvas placement
	# parent_obj: string, optional parent 3D object for placement
	new: func(name, canvas_settings, screen_obj, parent_obj = nil) {
		var obj = {	
			parents : [DisplayUnit],
			_cs : canvas_settings,
			_placement_node : screen_obj,
			_placement_parent : parent_obj,
			_c : nil,
			_r : nil,
			name : name,         
			img : nil,     # canvas image element, shall use other canvas as source 
			src : nil,     # index of canvas used as image source
		};
		return obj.init();
	},
	
	init: func()
	{
		me._c = canvas.new(me._cs).setColorBackground(0.01, 0.01, 0.01, 1);
		me._r = me._c.createGroup();
		var x = num(me._cs.size[0])/2 or 20;
		var y = num(me._cs.size[1])/2 or 20;
		me._r.createChild("text").setText(me.name ~ " -- no source").setColor(1,1,1,1).setAlignment("center-center").setTranslation(x, y);
		me.img = me._r.createChild("image", "DisplayUnit");
		me._c.addPlacement({ parent : me._placement_parent, node : me._placement_node });
		return me;
	},
	
	# src: int, index of canvas to use as image source
	setSource: func(src) {
		me.src = num(src);
		if (me.src > 0)
		{
			img.set("src", "canvas://by-index/texture[" ~ src ~ "]");
		}
		else
		{
			img.set("src", "");
		}
		return me;
	},
	
	asWindow: func {
		var w = canvas.Window.new(me._cs.size, "dialog").set('title', "EFIS " ~ me.name);
		w.setCanvas(me._c);		
		return w
	},
};

# class EFIS
# manage cockpit displays (=outputs) and sources (image generators for PFD, MFD, EICAS...)
# allow redirection of sources to alternate displays (e.g. in case of cockpit display hardware fault)
var EFIS = {};

EFIS._default_canvas_settings = 
{
	"name" : "EFIS_display",
	"size" : [512,512],
	"view" : [512,512],
	"mipmapping" : 1
};


EFIS.new = func(display_names, object_names = nil)
{
	var obj = 
		{ 
			parents  : [EFIS],
			_du : [],	# DisplayUnits
			display_names : [],
			_sources  : [],	#int, canvas index
			_routing  : [], #int, index to _sources 
			_L : {},		#listeners for display controls
		};
	if (typeof(display_names) != "vector") {
		print("EFIS.new: 'display_names' not a vector!");
		return;
	}
	obj.display_names = display_names;
	if () {
		print("EFIS.new: 'display_names' not a vector!");
		return;
	}
	if (object_names != nil and typeof(object_names) == "vector" and size(display_names) == size(object_names)) {
		forindex (var id; display_names)
		{
			obj.addDisplay(id, object_names[id]);
		}
	}
	return obj;
}

EFIS.addDisplay = func(id, object_name)
{
	id = num(id);
	if (id < 0 or id >= size(me.display_names))
	{
		print("EFIS.addDisplay: invalid id");
		return
	}
	while (size(me._du) <= id) append(me._du, {});
	me._du[id] = DisplayUnit.new(me.display_names[id], me._default_canvas_settings, object_name);
	return me;
}

EFIS.getDisplayName = func(id) me.display_names[num(id)];

#add display source (canvas) 
EFIS.addSource = func(id, src, display_id = nil)
{
	me.sources[id] = src;
	return me;
}

# ctrl: string, property path
EFIS.addDisplayControl = func(ctrl)
{
	if (me.controls[ctrl] == nil)
		me.controls[ctrl] = [];
}

EFIS.updateRouting = func()
{
	forindex (var id; me.display_names)
	{
		if (me._routing[id] != nil)
			me._du[id].setSource(me._sources[me._routing[id]]);
	}
}

EFIS.displayWindow = func(id)
{
	id = num(id);
	if (id < 0 or id > size(me._du))
	{
		print("EFIS.displayWindow: invalid id");
		return
	}
	return me._du[id].asWindow();
}
