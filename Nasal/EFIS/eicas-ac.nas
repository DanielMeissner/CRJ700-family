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
                    "gen1line", "gen2line", "gen3line", "gen4line", "gen5line",
                    "line1", "line2", "line31", "line32", #apu2bus
                    "load1", "load2", "load3", "load4", "load5", 
                    "value1", "value2", "value3", "value4", "value5", 
                    "freq1", "freq2", "freq3", "freq4", "freq5", 
                    "gADG", "gExternal",
                    "axfail1", "axfail2", "axoff1", "axoff2", "shed", "servicecfg",
                ],
            prop_base: "systems/ac/",
            prop_names: [],
            engRunning: [0,0,0],
            
        };
        obj.loadsvg(file);
        obj.init();
        obj.addUpdateFunction(obj.update, 0.1);
        return obj;
    },

    getKeys: func() {
        return me.svg_keys;
    },

    init: func() {
        foreach (var key; ["gADG", "gExternal", "shed", "servicecfg"])
            me[key].hide();
        foreach (var i; [1,2,13,23,24,31,32])
            me["line"~i].hide();
        setlistener("controls/electric/idg1-disc", me._idgdiscL(1), 1);
        setlistener("controls/electric/idg2-disc", me._idgdiscL(2), 1);
        foreach (var i; [1,2,3,4,5]) {
            setlistener("systems/AC/system/gen"~i~"-value", me._readOutVoltsL(i), 1);
            setlistener("systems/AC/system/gen"~i~"-freq", me._readOutHzL(i), 1);
        }
        var fdm = getprop("/sim/flight-model");
        foreach (var i; [0,1,2]) {
            if (fdm == "yasim")
                setlistener("engines/engine["~i~"]/running-nasal", me._engL(i), 1);
            else setlistener("engines/engine["~i~"]/running", me._engL(i), 1);
            setlistener("controls/electric/engine["~i~"]/generator", me._genL(i), 1, 1);
        }
        foreach (var i; [1,2]) {
            me["axfail"~i].setColor(me.colors["amber"]);
            me["axfail"~i].hide();
            me["axoff"~i].hide();
            setlistener("controls/electric/auto-xfer"~i, me._showHideL(["axoff"~i], 0), 1);
            setlistener("systems/AC/system["~i~"]/serviceable", me._showHideL(["axfail"~i], 0), 1);
        }
        setlistener("controls/electric/ADG", me._showHideL("gADG"), 1, 0);
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
            var v = n.getValue();
            me.updateTextElement("value"~i, sprintf("%3d", v), (v > 108 and v < 130) ? "green" : "white");
        };
    },
    
    _readOutHzL: func(i) {
        return func(n) {
            var v = n.getValue();
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
            if (me.engRunning[i]) {
                if (n.getValue()) me["gen"~i].setColor(me.colors["green"]);
                else me["gen"~i].setColor(me.colors["amber"]);
            }
            else me["gen"~i].setColor(me.colors["white"]);
        };
    },

    update: func() {
        foreach (var i; [1,2,3,4,5]) {
            var volts = getprop("systems/AC/outputs/bus"~i) or 0;
            if (volts > 108 and volts < 130) me["bus"~i].setColor(me.colors["green"]);
            else me["bus"~i].setColor(me.colors["amber"]);
        }
        if (getprop("systems/AC/system/gen4-value") > me.AC_MIN_VOLTS) {
            me["gExternal"].show();
            if (getprop("controls/electric/ac-service-selected-ext"))
                me["servicecfg"].show();
        }
        else {
            me["gExternal"].hide();
            me["servicecfg"].hide();
        }
        if (getprop("systems/AC/outputs/bus4") < me.AC_MIN_VOLTS)
            me["shed"].show();
        else me["shed"].hide();

    }, 
};
