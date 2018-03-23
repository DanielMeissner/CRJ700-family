# EFIS for CRJ700 familiy
# EICAS primary page
# Author:  jsb
# Created: 03/2018
#

var EICASPriCanvas = {

    new: func(canvas_group, file) {
        var obj = {
            parents: [EICASPriCanvas , EFISCanvas.new()],
            loop: 0,
            svg_keys: [
                "N10", "N11", "N1pointer0", "N1pointer1",
                "rev0", "rev1", "apr0", "apr1", "thrustMode",
                "ITT0", "ITT1", "ITTpointer0", "ITTpointer1",
                "N20", "N21", "N2pointer0", "N2pointer1",
                "fuelFlow0", "fuelFlow1",
                "oilTemp0", "oilTemp1",
                "oilPress0", "oilPress1",
                "gOil", "oilPointer0", "oilPointer1",
                "gFanVib", "fanPointer0", "fanPointer1", "fanArcAmber0", "fanArcAmber1",
                "gGear", "gear0", "gear1", "gear2", "tGear0", "tGear1", "tGear2",
                "slatsBar", "slatsBar_clip", "flapsBar", "flapsPos",
                "gFuelValues", "fuelQty0", "fuelQty1", "fuelQty2", "fuelTotal",
                ],

        };
        for (var i = 1; i <= 16; i += 1) append(obj.svg_keys, "message"~i);
        print("message"~i);
        obj.loadsvg(canvas_group, file);
        obj.init();
        obj.setupUpdate(0.5, "eicas-primary");
        return obj;
    },


    init: func() {
        var amber = me.colors["amber"];
        me["fanArcAmber0"].setColor(amber);
        me["fanArcAmber1"].setColor(amber);
        me["gFanVib"].hide();
        me._addThrustModeL(0);
        me._addThrustModeL(1);
        me._addReverseL(0);
        me._addReverseL(1);
        me._addFlapsL();
        me.hideGearT = maketimer(30, me, func() {me["gGear"].hide();});
        me.hideGearT.singleShot = 1;
    },

    #-- listeners for rare events --
    _addThrustModeL: func(engine) {
        var apr = "apr"~engine;
        me.setlistener("controls/engines/engine["~engine~"]/thrust-mode", func(n) {
            var m = n.getValue();
            if (m == 3) {
                me["thrustMode"].setText("APR");
                me[apr].show();
                return;
            }
            else me[apr].hide();
            if (m == 0) me["thrustMode"].setText("");
            if (m == 1) me["thrustMode"].setText("CLB");
            if (m == 2) me["thrustMode"].setText("TO");
        }, 1);
    },

    _addReverseL: func(engine) {
        var rev = "rev"~engine;
        me.setlistener("engines/engine["~engine~"]/reverser-pos-norm", func(n) {
            var pos = n.getValue();
            if (pos == 0) me[rev].hide();
            else me[rev].show();
        }, 1);
    },

    updateGear: func(idx, pos) {
        if (pos == 0) {
            me["tGear"~idx].setText("UP");
            me["gear"~idx].setColor(me.colors["white"]);
            me["gear"~idx].setColorFill([0,0,0,0]);
        }
        elsif (pos == 1) {
            me["tGear"~idx].setText("DN");
            me["gear"~idx].setColor(me.colors["green"]);
            me["gear"~idx].setColorFill([0,0,0,0]);
        }
        else {
            me["tGear"~idx].setText("");
            me["gear"~idx].setColor(me.colors["yellow"]);
            me["gear"~idx].setColorFill(me.colors["yellow"]);
        }
    },

    _addFlapsL: func() {
        me.setlistener("surface-positions/slat-pos-norm", func(n) {
            me["slatsBar_clip"].setTranslation(-100 * n.getValue(), 0);
            me._updateClip("slatsBar");
        }, 1, 0);
        me.setlistener("surface-positions/flap-pos-norm", func(n) {
            var value = n.getValue();
            me["flapsBar"].setTranslation(296 * value, 0);
            me["flapsPos"].setText(sprintf("%2d", math.round(45*value)));
        }, 1, 0);
    },

    getEng: func(idx, prop) {
        return (getprop("engines/engine["~idx~"]/"~prop) or 0);
    },

    getTank: func(idx) {
        var lbs = getprop("consumables/fuel/tank["~idx~"]/level-lbs") or 0;
        return lbs * LB2KG;
    },

    updateOilGauge: func(i, value) {
        if (value < 25) {
            value *= 0.01396;
            me["oilPointer"~i].setColor(me.colors["red"]);
            me["oilPress"~i].setColor(me.colors["red"]);
        }
        else {
            value *= 0.00959;
            me["oilPointer"~i].setColor(me.colors["green"]);
            me["oilPress"~i].setColor(me.colors["green"]);
        }
        me["oilPointer"~i].setRotation(value);
    },

    updateSlow: func() {
    },

    update: func() {
        if (me._updateN == nil or !me._updateN.getValue()) return;
        #me.loop += 1;
        #print("d "~me.loop);
        #if (both enging oilprssure > 25 psi) hideOilShowFanVib
        var oilp = [0,0];
        foreach (var i; [0,1]) {
            value = me.getEng(i, "rpm");
            me["N1"~i].setText(sprintf("%3.1f", value));
            me["N1pointer"~i].setRotation(value * 0.04189);
            value = me.getEng(i, "itt-norm")*100;
            me["ITT"~i].setText(sprintf("%3d", value*10));
            me["ITTpointer"~i].setRotation(value * 0.04189);
            value = me.getEng(i, "rpm2");
            me["N2"~i].setText(sprintf("%3.1f", value));
            me["N2pointer"~i].setRotation(value * 0.04189);
            me["oilTemp"~i].setText(sprintf("%3d", me.getEng(i, "oilt-norm")*170));
            oilp[i] = me.getEng(i, "oilp-norm")*780;
            me["oilPress"~i].setText(sprintf("%3d", oilp[i]));
            me.updateOilGauge(i, oilp[i]);
        }
        if (CRJ700.engines[0].running and CRJ700.engines[1].running) {
            if( oilp[0] > 24 and oilp[1] > 24)
            {
                me["gOil"].hide();
                me["gFanVib"].show();
            }
        } 
        else {
            me["gOil"].show();
            me["gFanVib"].hide();
        }

        var flapsCtrl = getprop("controls/flight/flaps");
        var gp0 = getprop("gear/gear[0]/position-norm");
        var gp1 = getprop("gear/gear[1]/position-norm");
        var gp2 = getprop("gear/gear[2]/position-norm");
        if (flapsCtrl or gp0 or gp1 or gp2) {
            me.hideGearT.stop();
            me["gGear"].show();
            me.updateGear(0,gp0);
            me.updateGear(1,gp1);
            me.updateGear(2,gp2);
        }
        else if(!me.hideGearT.isRunning) me.hideGearT.start();

        me["fuelQty0"].setText(sprintf("%3d", me.getTank(0)));
        me["fuelQty1"].setText(sprintf("%3d", me.getTank(1)));
        me["fuelQty2"].setText(sprintf("%3d", me.getTank(2)));
        var totalFuel = getprop("consumables/fuel/total-fuel-lbs");
        var imba = getprop("systems/fuel/imbalance-lbs");
        me["fuelTotal"].setText(sprintf("%3d", totalFuel*LB2KG));
        if (imba > 800 or totalFuel < 900) {
            me["gFuelValues"].setColor(me.colors["amber"]);
        }
        else me["gFuelValues"].setColor(me.colors["green"]);

    },
};
