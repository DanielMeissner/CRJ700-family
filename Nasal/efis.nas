#------------------------------------------
# efis.nas
# author:       jsb
# created:      12/2016
# last update:  12/2016
#------------------------------------------

# class DisplayUnit (DU)
# handels a named display 3D object in the cockpit
var DisplayUnit =
{
    # name: string, used in canvas window title and on DU test canvas
    # canvas_settings: vector
    # screen_obj: string, name of 3D object for canvas placement
    # parent_obj: string, optional parent 3D object for placement
    new: func(name, canvas_settings, screen_obj, parent_obj = nil) {
        var obj = {
            parents : [DisplayUnit],
            _canvas_settings : canvas_settings,
            _placement_node : screen_obj,
            _placement_parent : parent_obj,
            _canvas : nil, 
            _root : nil,
            name : name,
            img : nil,     # canvas image element, shall use other canvas as source
            src : nil,     # index of canvas used as image source
        };
        return obj.init();
    },

    init: func()
    {
        me._canvas = canvas.new(me._canvas_settings).setColorBackground(0.01, 0.01, 0.01, 1);
        #creat test image
        me._root = me._canvas.createGroup();
        var x = num(me._canvas_settings.size[0])/2 or 20;
        var y = num(me._canvas_settings.size[1])/2 or 20;
        me._root.createChild("text").setText(me.name ~ " -- no source").setColor(1,1,1,1).setAlignment("center-center").setTranslation(x, y);
        me._root.createChild("path", "outline").moveTo(0,0)
            .lineTo(me._canvas_settings.size[0],0)
            .lineTo(me._canvas_settings.size[0],me._canvas_settings.size[1])
            .lineTo(0, me._canvas_settings.size[1])
            .lineTo(0,0)
            .lineTo(me._canvas_settings.size[0],me._canvas_settings.size[1])
            .setStrokeLineWidth(2)
            .setColor(1,1,1,1);
        var l = 40;
        me._root.createChild("path", "square").moveTo(x-l,y-l)
            .line(2*l,0)
            .line(0,-2*l)
            .line(-2*l,0)
            .line(0,2*l)
            .lineTo(x,y)
            .setStrokeLineWidth(2)
            .setColor(0.5,1,1,1);
        
        me.img = me._root.createChild("image", "DisplayUnit");
        me._canvas.addPlacement({ parent : me._placement_parent, node : me._placement_node });
        return me;
    },

    # src: int, index of canvas to use as image source
    setSource: func(path) {
        me.src = path;
        me.img.set("src", path);
        return me;
    },

    asWindow: func {
        var w = canvas.Window.new(me._canvas_settings.size, "dialog");
        w.set('title', "EFIS " ~ me.name);
        w.setCanvas(me._canvas);
        return w
    },
};

# class EFIS
# manage cockpit displays (=outputs) and sources (image generators for PFD, MFD, EICAS...)
# allow redirection of sources to alternate displays (in case of simulated display fault)
var EFIS = {};

EFIS._default_canvas_settings =
{
    "name" : "EFIS_display",
    "size" : [1024,1280],
    "view" : [1024,1280],
    "mipmapping" : 1
};


EFIS.new = func(display_names, object_names = nil)
{
    var obj = {
            parents  : [EFIS],
            _display_unit : [],
            _sources  : [], #int, canvas index
            _routing  : [], #int, index to _sources
            _listeners : {},
            display_names : [],
            rt_config : {},
            controls : {},
        };
    if (typeof(display_names) != "vector") {
        print("EFIS.new: 'display_names' not a vector!");
        return;
    }
    obj.display_names = display_names;
    if (object_names != nil and typeof(object_names) == "vector" and size(display_names) == size(object_names)) {
    while (size(obj._display_unit) <= size(display_names)) {
            append(obj._display_unit, {});
        }
        forindex (var id; display_names)
        {
            obj._display_unit[id] = DisplayUnit.new(obj.display_names[id], obj._default_canvas_settings, object_names[id]);
        }
    }
    return obj;
}

EFIS.getDisplayName = func(id) {
    return me.display_names[num(id)]; 
}

#open a canvas window for display unit <id>
EFIS.displayWindow = func(id)
{
    id = num(id);
    if (id < 0 or id > size(me._display_unit))
    {
        print("EFIS.displayWindow: invalid id");
        return
    }
    return me._display_unit[id].asWindow();
}


#add display source (canvas)
EFIS.addSource = func(src, display_id = nil)
{
    append(me._sources, src);
    return size(me._sources) - 1;
}

EFIS.setDisplaySource = func(du_id, source_id) 
{
    me._display_unit[du_id].setSource(me._sources[source_id].getPath());
}

# ctrl: string, property path to int prop
EFIS.addDisplayControl = func(ctrl, configs)
{
    if (me.controls[ctrl] != nil) return;
    var l = func(p)
    {
        var rt = p.getIntValue();
        if (rt < 0 or rt >= size(me.controls[ctrl].configs))
            return;
        print("EFIS display control listener: " ~ ctrl ~ " " ~ rt ~ "/" ~ size(me.controls[ctrl].configs));
        me._activateDC(me.controls[ctrl].configs[rt]);
    }
    me.controls[ctrl] = {L: setlistener(ctrl, l, 0, 1), configs: configs};
}

# add a display routing configuration
# used by control listeners to switch display routing
# returns config ID
EFIS.addDisplayConfig = func(mapping)
{
    append(me.rt_config, mapping);
    return size(me.rt_config) - 1;
}

EFIS._activateDC = func(id)
{
    id = num(id);
    if (id < 0 or id >= size(me.rt_config))
    {
        print("EFIS._activateDC: invalid config ID!");
        return;
    }
    me._routing = me.rt_config[id];
    me.updateRouting();
}

EFIS.updateRouting = func()
{
    forindex (var id; me.display_names)
    {
        if (me._routing[id] != nil)
            me._display_unit[id].setSource(me._sources[me._routing[id]]);
    }
}

