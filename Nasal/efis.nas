#------------------------------------------
# efis.nas
# author:       jsb
# created:      12/2017
#------------------------------------------
print("BEGIN efis.nas");
var orig_setlistener = setlistener;

var DEG2RAD=0.0174533;
var FT2M=0.3048;

# Class DisplayUnit (DU)
# handels a named display 3D object in the cockpit
var DisplayUnit =
{
    #-- static members
    _instances: [],
    bgcolor: [0.01, 0.01, 0.01, 1],

    del: func() {
        foreach (var i; DisplayUnit._instances) {
            i.cleanup();
        }
        DisplayUnit._instances = [];
    },

    asWindow: func(window_size) {
        me.window = canvas.Window.new(window_size, "dialog");
        me.window.set('title', "EFIS " ~ me.name)
            .setCanvas(me.canvas);
        me.window.del = func() { call(canvas.Window.del, [], me); }
        return me.window
    },

    # set a new source path for canvas image element
    setSource: func(path) {
        print("DisplayUnit.setSource for "~me.canvas.getPath()~" ("~me.name~") to "~path);
        if (path == "")
            me.img.hide();
        else {
            me.img.set("src", path);
            me.img.show();
        }
        return me;
    },

    setPower: func(prop, min) {
        me.powerN = props.getNode(prop,1);
        me.setlistener(me.powerN, func(n) {
            if (n.getValue() > min) me.root.show();
            else me.root.hide();
        }, 1,0);
    },

    # name: string, used in canvas window title and on DU test canvas
    # canvas_settings: vector
    # screen_obj: string, name of 3D object for canvas placement
    # parent_obj: string, optional parent 3D object for placement
    new: func(name, canvas_settings, screen_obj, parent_obj = nil) {
        var obj = {
            parents: [DisplayUnit],
            _listeners: [],
            cleanup: func() {
                foreach (var id; obj._listeners) {
                    print("DU remove L: "~id);
                    removelistener(id);
                }
                obj._listeners = [];
                if (obj.window != nil) {
                    obj.window.del();
                    obj.window = nil;
                }
                if (obj.canvas != nil) {
                    print("DU del "~obj.canvas.getPath());
                    obj.canvas.del();
                    obj.canvas = nil;
                }
            },

            setlistener: func(p, f, s=0, r=1) {
                var handle = orig_setlistener(p,f,s,r);
                append(obj._listeners, handle);
            },

            canvas_settings: canvas_settings,
            placement_node: screen_obj,
            placement_parent: parent_obj,
            canvas: nil,
            root: nil,
            window: nil,

            name: name,
            img: nil,     # canvas image element, shall use other canvas as source
            powerN: nil
        };
        append(DisplayUnit._instances, obj);
        return obj.init();
    },

    init: func() {
        me.canvas = canvas.new(me.canvas_settings).setColorBackground(DisplayUnit.bgcolor);
        #creat test image
        me.root = me.canvas.createGroup();
        var x = num(me.canvas_settings.size[0])/2 or 20;
        var y = num(me.canvas_settings.size[1])/2 or 20;
        me.root.createChild("text").setText(me.name ~ " -- no source").setColor(1,1,1,1).setAlignment("center-center").setTranslation(x, y);
        me.root.createChild("path", "outline")
            .rect(0, 0, me.canvas_settings.size[0], me.canvas_settings.size[1])
            .setStrokeLineWidth(2)
            .setColor(1,1,1,1);
        var L = 80;
        me.root.createChild("path", "square")
            .rect(x-L, y-L, 2*L, 2*L)
            .setStrokeLineWidth(2)
            .setColor(0,1,0,1);
        me.root.createChild("path", "square")
            .rect(0, 0, L, L)
            .setStrokeLineWidth(2)
            .setColor(1,0,0,1);
        x = me.canvas_settings.size[0]-L;
        y = me.canvas_settings.size[1]-L;
        me.root.createChild("path", "square")
            .rect(x, y, L, L)
            .setStrokeLineWidth(2)
            .setColor(0,0,1,1);

        me.img = me.root.createChild("image", "DisplayUnit "~me.name);
        me.canvas.addPlacement({ parent: me.placement_parent, node: me.placement_node });
        return me;
    },
};

# class EFIS
# manage cockpit displays (=outputs) and sources (image generators for PFD, MFD, EICAS...)
# allow redirection of sources to alternate displays (in case of simulated display fault)
var EFIS = {
    _instances: [],
    del: func() {
        DisplayUnit.del();
        foreach (var i; EFIS._instances) {
            i.cleanup();
        }
        EFIS._instances = [];
    },
    _defaultcanvas_settings: {
        "name": "EFIS_display",
        "size": [1024,1280],
        "view": [1024,1280],
        "mipmapping": 1
    },
    window_size: [500,600],

    getDU: func(i) {return me.display_units[i]},

    new: func(display_names, object_names, power_props) {
        if (typeof(display_names) != "vector") {
            print("EFIS.new: 'display_names' not a vector!");
            return;
        }
        var obj = {
                parents: [EFIS],
                _listeners: [],
                display_units: [],
                sources: [], #int, canvas index
                activesources: [], #int, index to sources
                display_names: display_names,
                rt_config: {},
                controls: {},
                source_records: [], # vector of hashes {id: , canvas: , root: };

                cleanup: func() {
                    foreach (var id; obj._listeners) {
                        removelistener(id);
                        print("EFIS remove L: "~id);
                    }
                    obj._listeners = [];
                    foreach (var sr; obj.source_records) {
                        sr.canvas.del();
                    }
                    obj.source_records = [];
                },

                setlistener: func(p, f, s=0, r=1) {
                    var handle = orig_setlistener(p,f,s,r);
                    append(obj._listeners, handle);
                },
            };
        if (object_names != nil and typeof(object_names) == "vector"
            and size(display_names) == size(object_names))
        {
            while (size(obj.display_units) < size(display_names)) {
                append(obj.display_units, {});
            }
            var settings = obj._defaultcanvas_settings;
            forindex (var id; display_names)
            {
                settings["name"] = display_names[id];
                obj.display_units[id] = DisplayUnit.new(obj.display_names[id],
                    obj._defaultcanvas_settings, object_names[id]);
                var _canvas = canvas.new(settings);
                var _root = _canvas.createGroup();
                var srcID = obj.addSourceCanvas(_canvas);
                obj.setDisplaySource(id, srcID);
                append(obj.source_records, {id: srcID, canvas: _canvas, root: _root});
            }
        }
        append(EFIS._instances, obj);
        return obj;
    }, #new

    getDisplayName: func(id) {
        id = num(id);
        if (id != nil and id >=0 and id < size(me.display_names))
            return me.display_names[num(id)];
        else return "Invalid display ID."
    },

    #open a canvas window for display unit <id>
    displayWindow: func(id)
    {
        id = num(id);
        if (id < 0 or id >= size(me.display_units))
        {
            print("EFIS.displayWindow: invalid id");
            return
        }
        return me.display_units[id].asWindow(me.window_size);
    },

    #add display source (canvas), returns source_id
    addSourceCanvas: func(mycanvas)
    {
        append(me.sources, mycanvas);
        return size(me.sources) - 1;
    },

    #switch display unit du_id to source source_id
    setDisplaySource: func(du_id, source_id)
    {
        var path = "";
        if (source_id >= 0)
            path = me.sources[source_id].getPath();
        me.display_units[du_id].setSource(path);
    },

    # ctrl: property path to integer prop
    # mappings: vector of display mappings
    addDisplayControl: func(ctrl, mappings)
    {
        if (me.controls[ctrl] != nil) return;
        if (typeof(mappings) != "vector") {
            print("EFIS addDisplayControl: mappings must be a vector.");
            return;
        }
        var listener = func(p) {
                var ctlValue = p.getValue();
                if (ctlValue < 0 or ctlValue >= size(me.controls[ctrl].mappings))
                    return;
                me._activateRouting(me.controls[ctrl].mappings[ctlValue]);
            }
        print("addDisplayControl "~ctrl);
        me.controls[ctrl] = {L: me.setlistener(ctrl, listener, 0, 0), mappings: mappings};
    },

    #
    # mapping: vector of source ids, size must equal size(display_units)
    #       values: nil = do nothing, 0..N select source, -1 no source
    _activateRouting: func(mapping)
    {
        if (typeof(mapping) != "vector") {
            print("EFIS _activateRouting: mapping must be a vector");
            return;
        }
        me.activesources = mapping;
        forindex (var unit_id; me.display_units)
        {
            if (me.activesources[unit_id] != nil)
                me.setDisplaySource(unit_id, me.activesources[unit_id]);
        }
    },

    getSources: func()
    {
        return me.source_records;
    },
};


# Base class for EFIS pages
# loads a SVG file and creates clipping from <name>_clip elements
# based on the work of Joshua Davidson (it0uchpods)
var EFISCanvas = {
    _instances: [],
    del: func() {
        foreach (var i; EFISCanvas._instances) {
            i.cleanup();
        }
        EFISCanvas._instances = [];
    },

    new: func() {
        var obj = {
            parents: [EFISCanvas],
            _listeners: [],

            cleanup: func() {
                foreach (var id; obj._listeners) {
                    removelistener(id);
                    print("EFISCanvas remove L: "~id);
                }
                obj._listeners = [];
            },

            setlistener: func(p, f, s=0, r=1) {
                var handle = orig_setlistener(p,f,s,r);
                print("EFISCanvas add L: "~handle);
                append(obj._listeners, handle);
            },
        };
        append(EFISCanvas._instances, obj);
        return obj;
    },

    init: func(canvas_group, file) {
        var font_mapper = func(family, weight) {
            return "LiberationFonts/LiberationSans-Regular.ttf";
        };

        canvas.parsesvg(canvas_group, file, {'font-mapper': font_mapper});
        var svg_keys = me.getKeys();

        foreach (var key; svg_keys) {
            me[key] = canvas_group.getElementById(key);
            var clip_el = canvas_group.getElementById(key ~ "_clip");
            if (clip_el != nil) {
                clip_el.setVisible(0);
                var tran_rect = clip_el.getTransformedBounds();
                var clip_rect = sprintf("rect(%d,%d, %d,%d)",
                tran_rect[1], # 0 ys
                tran_rect[2], # 1 xe
                tran_rect[3], # 2 ye
                tran_rect[0]); #3 xs
                #   coordinates are top,right,bottom,left (ys, xe, ye, xs) ref: l621 of simgear/canvas/CanvasElement.cxx
                me[key].set("clip", clip_rect);
                me[key].set("clip-frame", canvas.Element.PARENT);
            }
        }
        me.page = canvas_group;
        return me;
    },
    # overload this in derived class! Return all valid SVG element IDs
    getKeys: func() {
        return [];
    },
    update: func() {
    },
};

print("END efis.nas");
