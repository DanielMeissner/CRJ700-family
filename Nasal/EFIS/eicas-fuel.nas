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
                "xflowPump", "xflowline0", "xflowline1", "manualXflow",
                "scavengeEjector0", "scavengeEjector1", 
                "xferSOV0", "xferEjector0", "xferline01", "xferline02", "xferline03",
                "xferSOV1", "xferEjector1", "xferline11", "xferline12", "xferline13",
                "mainEjector0", "mainEjector1",
                "pump0", "pump1", "pump2",
                "sov0", "sov1", "sov2",
                "filter0", "filter1",
                "lopress0", "lopress1",
            ],
            unusable: [],
        };
        obj.loadsvg(source_record.root, file);
        obj.init();
        obj.addUpdateFunction(obj.update, 0.8);
        return obj;
    },

    #-- listeners for rare events --
    
    init: func() {
        foreach (var i; [0,1,2]) {
            append(me.unusable, getprop("consumables/fuel/tank["~i~"]/unusable-gal_us"));
            me._addPumpL(i);
            #me._addSOVL(i);
        }
        foreach (var i; [0,1]) {
            me._addXferValveL(i);
            me._addPressL(i);
            me["lopress"~i].setColor(me.colors["amber"]);
        }
        setlistener("controls/fuel/xflow-manual", func(n) {
            if (n.getValue()) me["manualXflow"].show();
            else me["manualXflow"].hide();
        }, 1, 0);
        setlistener("controls/fuel/gravity-xflow", func(n) {
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
        }, 1, 0);
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
    
    _addPressL: func(i) {
        setlistener("systems/fuel/circuit["~i~"]/powered", func(n) {
            if (n.getValue()) {
                me["lopress"~i].hide();
            }
            else {
                me["lopress"~i].show();
            }
        }, 1, 0);
    },

    getTank: func(idx) {
        var lbs = getprop("consumables/fuel/tank["~idx~"]/level-lbs") or 0;
        return lbs * LB2KG;
    },    
    update: func() {
        if (me.updateN == nil or !me.updateN.getValue()) return;
        #setprop(me.updateCountP, getprop(me.updateCountP)+1);
        var fuelQty = [0,0,0];
        foreach (var i; [0,1,2]) {
            fuelQty[i] = me.getTank(i);
            me["fuelQty"~i].setText(sprintf("%3d", fuelQty[i]));

        }
        var totalFuel = getprop("consumables/fuel/total-fuel-lbs");
        me["fuelTotal"].setText(sprintf("%3d", totalFuel*LB2KG));
        if (fuelQty[2])
    }, 
};
