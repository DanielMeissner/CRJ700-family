#------------------------------------------
# efis.nas
# author:       jsb
# created:      12/2017
#------------------------------------------


# Class DisplayUnit (DU) - handels a named display 3D object in the cockpit
# creates a canvas that is placed on the 3D object once
# creates an image element on canvas to 'receive' source input
# handels power on/off by (un-)hiding canvas root group
var DisplayUnit =
{
    #-- static members
    _instances: [],
    bgcolor: [0.01, 0.01, 0.01, 1],
    del: func() {
        foreach (var instance; DisplayUnit._instances) {
            instance.cleanup();
        }
        DisplayUnit._instances = [];
    },

    # name: string, used in canvas window title and on DU test canvas
    # canvas_settings: hash
    # screen_obj: string, name of 3D object for canvas placement
    # parent_obj: string, optional parent 3D object for placement
    new: func(name, canvas_settings, screen_obj, parent_obj = nil) {
        var obj = {
            parents: [DisplayUnit],
            _listeners: [],
            cleanup: func() {
                foreach (var id; obj._listeners) {
                    removelistener(id);
                }
                obj._listeners = [];
                if (obj.window != nil) {
                    obj.window.del();
                    obj.window = nil;
                }
                if (obj.canvas != nil) {
                    obj.canvas.del();
                    obj.canvas = nil;
                }
            },

            setlistener: func(p, f, s=0, r=1) {
                append(obj._listeners, setlistener(p,f,s,r));
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
        me.canvas_settings["name"] = "DisplayUnit " ~ size(DisplayUnit._instances);
        me.canvas = canvas.new(me.canvas_settings).setColorBackground(DisplayUnit.bgcolor);
        me.root = me.canvas.createGroup();
        
        #-- for development: create test image
        var x = num(me.canvas_settings.view[0])/2 or 20;
        var y = num(me.canvas_settings.view[1])/2 or 20;
        me.root.createChild("text").setText(me.name ~ " -- no source").setColor(1,1,1,1).setAlignment("center-center").setTranslation(x, y);
        me.root.createChild("path", "outline")
            .rect(0, 0, me.canvas_settings.view[0], me.canvas_settings.view[1])
            .setStrokeLineWidth(2)
            .setColor(1,1,1,1);
        var L = 80;
        var grp = me.root.createChild("group","mygroup");
        grp.createChild("path", "square-center").rect(x-L, y-L, 2*L, 2*L)
            .setStrokeLineWidth(2)
            .setColor(0,1,0,1);
        me.root.createChild("path", "square-top-left").rect(0, 0, L, L)
            .setStrokeLineWidth(2)
            .setColor(1,0,0,1);
        x = me.canvas_settings.view[0]-L;
        y = me.canvas_settings.view[1]-L;
        me.root.createChild("path", "square-btm-right").rect(x, y, L, L)
            .setStrokeLineWidth(2)
            .setColor(0,0,1,1);
        #-- end test image --
        me.img = me.root.createChild("image", "DisplayUnit "~me.name);
        me.canvas.addPlacement({ parent: me.placement_parent, node: me.placement_node });
        return me;
    },

    # set a new source path for canvas image element
    setSource: func(path) {
        #print("DisplayUnit.setSource for "~me.canvas.getPath()~" ("~me.name~") to "~path);
        if (path == "")
            me.img.hide();
        else {
            me.img.set("src", path);
            me.img.show();
        }
        return me;
    },

    setPowerSource: func(prop, min) {
        me.powerN = props.getNode(prop,1);
        me.setlistener(me.powerN, func(n) {
            if ((n.getValue() or 0) > min) me.root.show();
            else me.root.hide();
        }, 1,0);
    },
    
    asWindow: func(window_size) {
        me.window = canvas.Window.new(window_size, "dialog");
        me.window.set('title', "EFIS " ~ me.name)
            .setCanvas(me.canvas);
        me.window.del = func() { call(canvas.Window.del, [], me); }
        return me.window
    },    
};

# class EFIS
# manage cockpit displays (=outputs) and sources (image generators for PFD, MFD, EICAS...)
# allow redirection of sources to alternate displays (in case of simulated display fault)
var EFIS = {
    _instances: [],
    del: func() {
        EFISCanvas.del();
        DisplayUnit.del();
        foreach (var instance; EFIS._instances) {
            instance.cleanup();
        }
        EFIS._instances = [];
    },
    _defaultcanvas_settings: {
        "name": "EFIS_display",
        "size": [1024,1024],
        "view": [1000,1200],
        "mipmapping": 1
    },
    window_size: [500,600],

    new: func(display_names, object_names, power_props) {
        if (typeof(display_names) != "vector") {
            print("EFIS.new: 'display_names' not a vector!");
            return;
        }
        var obj = {
                parents: [EFIS],
                _listeners: [],
                display_units: [],
                sources: [],        #[] of canvas
                display_names: display_names,
                controls: {},
                source_records: [], 

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
                    append(obj._listeners, setlistener(p,f,s,r));
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
                obj.display_units[id] = DisplayUnit.new(obj.display_names[id],
                    obj._defaultcanvas_settings, object_names[id]);
                obj._setDisplaySource(id, obj.addSource(display_names[id]));
            }
        }
        append(EFIS._instances, obj);
        return obj;
    }, #new

    #-- private methods ----------------------
    #add display source (canvas), returns source_id
    _addSourceCanvas: func(mycanvas)
    {
        append(me.sources, mycanvas);
        return size(me.sources) - 1;
    },

    #switch display unit du_id to source source_id
    _setDisplaySource: func(du_id, source_id)
    {
        var path = "";
        if (source_id >= 0)
            path = me.sources[source_id].getPath();
        me.display_units[du_id].setSource(path);
    },
    
    # mapping: 
    #  - vector of source ids, size must equal size(display_units)
    #    values nil = do nothing, 0..N select source, -1 no source
    #  - hash {<unit_name>: source_id}
    _activateRouting: func(mapping)
    {
        if (typeof(mapping) == "vector") {
            forindex (var unit_id; me.display_units)
            {
                if (mapping[unit_id] != nil)
                    me._setDisplaySource(unit_id, mapping[unit_id]);
            }
        }
        elsif (typeof(mapping) == "hash") {
            foreach (var unit_name; keys(mapping))
            {
                forindex (var unit_id; me.display_names) {
                    if (me.display_names[unit_id] == unit_name) {
                        me._setDisplaySource(unit_id, mapping[unit_name]);
                    }
                }
            }
        }
    },
    
    #-- public methods -----------------------
    addSource: func(name) {
    var settings = me._defaultcanvas_settings;
        settings["name"] = name;
        var _canvas = canvas.new(settings);
        var _root = _canvas.createGroup();
        var srcID = me._addSourceCanvas(_canvas);
        append(me.source_records, {id: srcID, name: name, canvas: _canvas, root: _root});
        return srcID;
    },


    # ctrl: property path to integer prop
    # mappings: vector of display mappings
    # callback: optional function that will be called with current ctrl value
    addDisplaySwapControl: func(ctrl, mappings, callback=nil)
    {
        if (me.controls[ctrl] != nil) return;
        ctrlN = props.getNode(ctrl,1);
        if (typeof(mappings) != "vector") {
            print("EFIS addDisplayControl: mappings must be a vector.");
            return;
        }
        var listener = func(p) {
                var ctlValue = p.getValue();
                if (ctlValue >= 0 and ctlValue < size(me.controls[ctrl].mappings))
                    me._activateRouting(me.controls[ctrl].mappings[ctlValue]);
                else debug.warn("Invalid value for display selector "~ctrl~": "~ctlValue);
                if (callback != nil) {
                    call(callback, [ctlValue], nil, nil, var err = []);
                    debug.printerror(err);
                }
            }
        #print("addDisplayControl "~ctrl);
        me.controls[ctrl] = {L: me.setlistener(ctrlN, listener, 0, 0), mappings: mappings};
    },
    
    # creates a listener for selection which contains the source number (integer)
    # targetN: contains the display unit number on which the source will be mapped
    # sources: optional vector mapping selection to source IDs returned by addSource
    addSourceSelector: func(selection, targetN, sources=nil){
        selection = props.getNode(selection,1);
        if (selection.getValue() == nil)
            selection.setIntValue(0);
        if (sources == nil) {
            sources = [];
            for (var i = 0; i < size(me.sources); i += 1)
                append(sources, i);
        }
        me.setlistener(selection, func(node){
            var src = node.getValue();
            var destination = targetN.getValue();
            if (src >= 0 and src < size(sources))
                me._setDisplaySource(destination, sources[src]);
        });
    },

    getDU: func(i) {return me.display_units[i]},
    
    getSources: func()
    {
        return me.source_records;
    },
    
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
            debug.warn("EFIS.displayWindow: invalid id");
            return
        }
        return me.display_units[id].asWindow(me.window_size);
    },
};

#-- EFISCanvas --
# loads a SVG file and creates clipping from <name>_clip elements
# based on the work of Joshua Davidson (it0uchpods)
var EFISCanvas = {
    _instances: [],
    _timers: [],
    del: func() {
        foreach (var instance; EFISCanvas._instances) {
            print("EFISCanvas cleanup ");
            instance.cleanup();
        }
        EFISCanvas._instances = [];
        foreach (var timer; EFISCanvas._timers) {
            print("EFISCanvas stop timer");
            timer.stop();
        }
        EFISCanvas._timers = [];
    },

    new: func() {
        var obj = {
            parents: [EFISCanvas],
            _listeners: [],
            _updateN: nil,
            _update_interval: 0.7,
            _timer: nil,
            
            cleanup: func() {
                print("EFISCanvas cleanup");
                foreach (var id; obj._listeners) {
                    removelistener(id);
                    print("EFISCanvas remove L: "~id);
                }
                obj._listeners = [];
            },

            setlistener: func(p, f, s=0, r=1) {
                var handle = setlistener(p,f,s,r);
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

    setupUpdate: func(updateN, interval) {
        me._updateN = props.globals.getNode(updateN,1);
        me._updateN.setBoolValue(1);
        interval = num(interval);
        if (interval == nil or interval < 0.1) 
            me._update_interval = 0.7;
        else me._update_interval = interval;
        var timer = maketimer(me._update_interval, me, me.update);
        append(EFISCanvas._timers, timer);
        timer.start();
    },

    ## overload the following methods in derived class!     
    #Return all valid SVG element IDs
    getKeys: func() {
        return [];
    },
    
    update: func() {
        if (me._updateN == nil or !me._updateN.getValue()) 
            return;
    },
};
