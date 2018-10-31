# EFIS for CRJ700 familiy 
# EICAS doors status page
# Author:  jsb
# Created: 03/2018
#

var EICASACCanvas = {
    AC_MIN_VOLTS: 108,
    
    new: func(name, file) {
        var obj = { 
            parents: [EICASACCanvas , EFISCanvas.new(name)],
            svg_keys: ["gen0", "gen1", "gen2", "gen3", "gen4", #2:apu, 3: ext, 4: adg
                    "eng0", "eng1", "eng2", 
                    "idg1", "idg2", "idgdisc1", "idgdisc2",
                    "bus1","bus2","bus3", "bus4", "bus5", #3: ess, 4: serv, 5: adg
                    "line13", "line23", "line24", #bus2bus
                    "line1", "line2", "line31", "line32", #apu2bus
                    "gADG", "gExternal",
                    "axfail1", "axfail2", "axoff1", "axoff2", "shed", "servicecfg",
                ],
            prop_base: "systems/ac/",
            prop_names: [],
            engRunning: [0,0,0,0,0],
            gen: [0,0,0,0,0], 
            volts: [0,0,0,0,0],
        };
        foreach (var i; [0,1,2,3,4]) {
            append(obj.svg_keys,"gen"~i~"line0");
            append(obj.svg_keys,"gen"~i~"line1");
        }
        foreach (var i; [1,2,3,4,5]) {        
            append(obj.svg_keys,"load"~i);
            append(obj.svg_keys,"freq"~i);
            append(obj.svg_keys,"value"~i);
        }
        obj.loadsvg(file);
        obj.init();
        obj.addUpdateFunction(obj.update, 0.51);
        return obj;
    },

    getKeys: func() {
        return me.svg_keys;
    },

    init: func() {
        foreach (var key; ["gADG", "gExternal", "shed", "servicecfg"])
            me[key].hide();
        foreach (var i; [1,2,31,32])
            me["line"~i].hide();
        foreach (var i; [13,23,24])
            me["line"~i].set("fill", "none");
        setlistener("controls/electric/idg1-disc", me._idgdiscL(1), 1);
        setlistener("controls/electric/idg2-disc", me._idgdiscL(2), 1);
        foreach (var i; [1,2,3,4,5]) {
            setlistener("systems/AC/system/gen"~i~"-value", me._readOutVoltsL(i), 1);
            setlistener("systems/AC/system/gen"~i~"-freq", me._readOutHzL(i), 1);
            setlistener("systems/AC/outputs/bus"~i, me._busL(i), 1);
        }
        var fdm = getprop("/sim/flight-model");
        foreach (var i; [0,1,2]) {
            if (fdm == "yasim")
                setlistener("engines/engine["~i~"]/running-nasal", me._engL(i), 1);
            else setlistener("engines/engine["~i~"]/running", me._engL(i), 1);
            setlistener("controls/electric/engine["~i~"]/generator", me._genL(i), 1, 1);
        }
        # ground power
        setlistener("controls/electric/ac-service-avail", func(n) { me.engRunning[3] = n.getValue(); }, 1);
        setlistener("controls/electric/ac-service-in-use", func(n) { me["acext"] = (n.getValue()) ? 1 : 0; }, 1, 0);
        
        foreach (var i; [1,2]) {
            me["axfail"~i].setColor(me.colors["amber"]);
            me["axfail"~i].hide();
            me["axoff"~i].hide();
            setlistener("controls/electric/auto-xfer"~i, me._showHideL(["axoff"~i], 0), 1);
            setlistener("systems/AC/system["~i~"]/serviceable", me._showHideL(["axfail"~i], 0), 1);
        }
        setlistener("controls/electric/ADG", me._showHideL("gADG"), 1, 0);
        setlistener("systems/AC/outputs/bus4", me._shedL, 1, 0);
    },
    
    _shedL: func() {
        return func(n) {
            if (n.getValue() < me.AC_MIN_VOLTS) me["shed"].show();
            else me["shed"].hide();
        };
    },
    
    _busL: func(i) {
        return func(n) {
            var volts = n.getValue() or 0;
            if (volts > 108 and volts < 130) me["bus"~i].setColor(me.colors["green"]);
            else me["bus"~i].setColor(me.colors["amber"]);
            
        };
    },
    
    _idgdiscL: func(i) { 
        return func(n) {
            if (n.getValue()) {
                me["idgdisc"~i].show();
                me["idg"~i].setColor(me.colors["white"]);
            }
            else
                me["idgdisc"~i].hide();
        };
    },
    
    _readOutVoltsL: func(i) {
        return func(n) {
            var j=i-1;
            me.volts[j] = n.getValue() or 0;
            me.updateTextElement("value"~i, sprintf("%3d", me.volts[j]), (me.volts[j] > 108 and me.volts[j] < 130) ? "green" : "white");
        };
    },
    
    _readOutHzL: func(i) {
        return func(n) {
            var v = n.getValue() or 0;
            me.updateTextElement("freq"~i, sprintf("%3d", v), (v > 360 and v < 440) ? "green" : "white");
        };
    },
    
    _engL: func(i) { 
        return func(n) {
                me.engRunning[i] = n.getValue();
                if (me.engRunning[i]) me["eng"~i].setColor(me.colors["blue"]);
                else me["eng"~i].setColor(me.colors["white"]);
                setprop("controls/electric/engine["~i~"]/generator", 
                    getprop("controls/electric/engine["~i~"]/generator"));
            };
    },
    
    #gen0..2 (engine+apu)
    _genL: func(i) { 
        return func(n) {
            me.gen[i] = n.getValue();
            if (me.engRunning[i]) {
                if (me.gen[i]) {
                    me["gen"~i].setColor(me.colors["green"]);
                    me["gen"~i~"line0"].setColorFill(me.colors["green"]);
                }
                else {
                    me["gen"~i].setColor(me.colors["amber"]);
                    me["gen"~i~"line0"].set("fill", "none");
                }
            }
            else {
                me["gen"~i].setColor(me.colors["white"]);
                me["gen"~i~"line0"].set("fill", "none");
            }
        };
    },

    update: func() {
        if (me.engRunning[3]) {
            me["gExternal"].show();
            if (getprop("controls/electric/ac-service-selected-ext"))
                me["servicecfg"].show();
            if (me["acext"]) me["gen3line1"].setColorFill(me.colors["green"]);
            else me["gen3line1"].set("fill", "none");
        }
        else {
            me["gExternal"].hide();
            me["servicecfg"].hide();
        }
        # APU gen online (or ground power)
        if (me.volts[2] > me.AC_MIN_VOLTS or me["acext"]) {
            if (me.volts[2] > me.AC_MIN_VOLTS) me["gen2line1"].setColorFill(me.colors["green"]);
            else me["gen2line1"].set("fill", "none");
            me["line1"].show();
            me["line2"].show();
            if (me.volts[0] > me.AC_MIN_VOLTS) {
                me["gen0line1"].show();
                me["line31"].hide();
            }
            else {
                me["gen0line1"].hide();
                me["line31"].show();
            }
            if (me.volts[1] > me.AC_MIN_VOLTS) {
                me["gen1line1"].show();
                me["line32"].hide();
            }
            else {
                me["gen1line1"].hide();
                me["line32"].show();
            }
        } 
        # APU gen offline
        else {
            me["line31"].hide();
            me["line32"].hide();
            me["gen2line1"].set("fill", "none");
            if (me.volts[0] > me.AC_MIN_VOLTS) { 
                me["line1"].show();
                me["gen0line1"].show();
            }
            else {
                me["line1"].hide(); 
                me["gen0line1"].hide(); 
            }
            if (me.volts[1] > me.AC_MIN_VOLTS) {
                me["line2"].show();
                me["gen1line1"].show();
            }
            else {
                me["line2"].hide();
                me["gen1line1"].hide();
            }
        }
    }, 
};