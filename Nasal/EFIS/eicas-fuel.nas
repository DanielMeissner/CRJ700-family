# EFIS for CRJ700 familiy 
# EICAS primary page
# Author:  jsb
# Created: 03/2018
#

var EICASFuelCanvas = {

    new: func(source_record, file) {
        var obj = { 
            parents: [EICASFuelCanvas , EFISCanvas.new(source_record)],
            svg_keys: [
                "fuelTotal", "fuelUsed",
                "fuelQty0", "fuelQty1", "fuelQty2",
                "gravXflow", "gxflowline0", "gxflowline1", "gxflowline2",
                "xflowPump", "xfpumptxt", "xfpumparrow", "xflowline0", "xflowline1", "manualXflow",
                "scavengeEjector0", "scavengeEjector1", 
                "xferSOV0", "xferEjector0", "xferline01", "xferline02", "xferline03",
                "xferSOV1", "xferEjector1", "xferline11", "xferline12", "xferline13",
                "mainEjector0", "mainEjector1",
                "pump0", "pump1", "pump2",
                "sov0", "sov1", "sov2",
                "sov0line", "sov1line", "sov2line",
                "line23", "line26", "line27",
                "filter0", "filter1",
                "lopress0", "lopress1",
                "eng0", "eng1", "eng2",
            ],
            unusable: [],
            engRunning: [0,0,0],
        };
        foreach (var i; [0,1]) {
            foreach (var n; [0,1,2,3,4,5,6,7])
                append(obj.svg_keys, "line"~i~n);
        }
        obj.loadsvg(source_record.root, file);
        obj.init();
        obj.addUpdateFunction(obj.update, 0.8);
        return obj;
    },

    #-- listeners for rare events --
    
    init: func() {
        var fdm = getprop("/sim/flight-model");
        foreach (var i; [0,1,2]) {
            append(me.unusable, getprop("consumables/fuel/tank["~i~"]/unusable-gal_us"));
            me._addPumpL(i);
            me._addSOVL(i);
            if (fdm == "yasim")
                setlistener("engines/engine["~i~"]/running-nasal", me._engL(i), 1);
            else setlistener("engines/engine["~i~"]/running", me._engL(i), 1);
            me["line"~i~"6"].setColorFill(me.colors["green"]);
        }
        foreach (var i; [0,1]) {
            me._addXferValveL(i);
            me._addPressL(i);
            me["lopress"~i].setColor(me.colors["amber"]);
            me["line"~i~"1"].setColorFill(me.colors["green"]);
        }
        setlistener("controls/fuel/xflow-manual", me._showHideL("manualXflow"), 1, 0);
        setlistener("controls/fuel/gravity-xflow", me._gxflowL(), 1, 0);
        setlistener("systems/fuel/xflow-pump/running", me._xferpumpL(), 1, 0);
        
    },
    
     _engL: func(i) { 
        return func(n) {
                me.engRunning[i] = n.getValue();
                if (me.engRunning[i]) me["eng"~i].setColor(me.colors["blue"]);
                else me["eng"~i].setColor(me.colors["white"]);
        };
    },
       
    _gxflowL: func() {
        return func(n) {
            var serviceable = getprop("systems/fuel/gravity-xflow/serviceable");
            if (serviceable) {
                if (n.getValue()) {
                    me["gravXflow"].setRotation(90*D2R);
                    me["gxflowline0"].setColorFill(me.colors["green"]);
                    me["gxflowline1"].setColorFill(me.colors["green"]);
                    me["gxflowline2"].setColorFill(me.colors["green"]);
                }
                else {
                    me["gravXflow"].setRotation(0);
                    me["gxflowline0"].set("fill", "none");
                    me["gxflowline1"].set("fill", "none");
                    me["gxflowline2"].set("fill", "none");
                }
            }
            else {
                me["gravXflow"].setRotation(45*D2R);
                me["gxflowline0"].set("fill", "none");
                me["gxflowline1"].set("fill", "none");
                me["gxflowline2"].set("fill", "none");
            }
        };
    },
    
    _xferpumpL: func() {
        return func(n) {
            var state = n.getValue();
            if (state != 0) {
                me["xfpumparrow"].show();
                me["xfpumptxt"].hide();
                if (state < 0) me["xfpumparrow"].setRotation(180*D2R);
                else me["xfpumparrow"].setRotation(0);
            } else {
                me["xfpumparrow"].hide();
                me["xfpumptxt"].show();
            }
        };
    },
        
    _addXferValveL: func(i) {
        setlistener("consumables/fuel/tank["~i~"]/xfer-valve", func(n) {
            if (n.getValue()) {
                me["xferSOV"~i].setRotation(90*D2R);
                me["xferEjector"~i].setColor(me.colors["green"]);
                me["xferline"~i~"1"].setColorFill(me.colors["green"]);
                me["xferline"~i~"2"].setColorFill(me.colors["green"]);
                me["xferline"~i~"3"].setColorFill(me.colors["green"]);
            }
            else {
                me["xferSOV"~i].setRotation(0);
                me["xferEjector"~i].setColor(me.colors["white"]);
                me["xferline"~i~"1"].set("fill", "none");
                me["xferline"~i~"2"].set("fill", "none");
                me["xferline"~i~"3"].set("fill", "none");
            }
        }, 1, 0);
    },
    
    _addPumpL: func(i) {
        setlistener("systems/fuel/boost-pump["~i~"]/running", func(n) {
            if (n.getValue()) {
                me["pump"~i].setColor(me.colors["green"]);
            }
            else {
                me["pump"~i].setColor(me.colors["white"]);
            }
        }, 1, 0);
    },

    _addSOVL: func(i) {
        setlistener("engines/engine["~i~"]/sov", func(n) {
            if (n.getValue()) {
                me["sov"~i].setRotation(90*D2R);
            }
            else {
                me["sov"~i].setRotation(0);
                me["sov"~i~"line"].set("fill", "none");
            }
        }, 1, 0);
    },
    
    
    _addPressL: func(i) {
        setlistener("systems/fuel/circuit["~i~"]/powered", func(n) {
            if (n.getValue()) {
                me["lopress"~i].hide();
                me["scavengeEjector"~i].setColor(me.colors["green"]);
                me["mainEjector"~i].setColor(me.colors["green"]);
                if (getprop("engines/engine["~i~"]/sov")) {
                    foreach (var n; [3,4,5]) {
                        print("line"~i~n);
                        me["line"~i~n].setColorFill(me.colors["green"]);
                    }
                }
                me["line"~i~"4"].setColorFill(me.colors["green"]);
            }
            else {
                me["lopress"~i].show();
                me["scavengeEjector"~i].setColor(me.colors["white"]);
                me["mainEjector"~i].setColor(me.colors["white"]);
                foreach (var n; [0,2,3,4,5])
                    me["line"~i~n].set("fill", "none");
            }
        }, 1, 0);
    },

    getTank: func(idx) {
        var lbs = getprop("consumables/fuel/tank["~idx~"]/level-lbs") or 0;
        return lbs * LB2KG;
    },
    
    update: func() {
        var fuelQty = [0,0,0];
        foreach (var i; [0,1,2]) {
            fuelQty[i] = me.getTank(i);
            me["fuelQty"~i].setText(sprintf("%3d", fuelQty[i]));

        }
        var totalFuel = getprop("consumables/fuel/total-fuel-lbs");
        me["fuelTotal"].setText(sprintf("%3d", totalFuel*LB2KG));
        
    }, 
};
