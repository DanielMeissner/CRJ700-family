# EFIS for CRJ700 familiy
# EICAS primary page
# Author:  jsb
# Created: 03/2018
#

var EICASPriCanvas = {
    MAX_MSG: 16,    #number of message lines

    new: func(source_record, file) {
        var obj = {
            parents: [EICASPriCanvas , EFISCanvas.new(source_record)],
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
                "gGear", "gear0", "gear1", "gear2", "tGear0", "tGear1", "tGear2", "gearInTransit0", "gearInTransit1", "gearInTransit2",
                "slatsBar", "slatsBar_clip", "flapsBar", "flapsPos",
                "gFuelValues", "fuelQty0", "fuelQty1", "fuelQty2", "fuelTotal",
            ],
            msgsys: MessageSystem.new(me.MAX_MSG, "instrumentation/eicas/msgsys1"),
        };
        for (var i = 0; i < me.MAX_MSG; i += 1) append(obj.svg_keys, "message"~i);
        obj.loadsvg(source_record.root, file);
        obj.init();
        obj.addUpdateFunction(obj.update, 0.050);
        obj.addUpdateFunction(obj.updateSlow, 0.500);
        obj.addUpdateFunction(obj.updateMessages, 0.300);
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
        me.clsWarning = me.msgsys.addMessages("warning", EICASWarningMessages, 0, efis.colors["red"]);
        me.clsCaution = me.msgsys.addMessages("caution", EICASCautionMessages, 1, efis.colors["amber"]);
        me.msgOil0 = me.msgsys.getMessageID(me.clsWarning, "L ENG OIL PRESS");
        me.msgOil1 = me.msgsys.getMessageID(me.clsWarning, "R ENG OIL PRESS");
    },

    #-- listeners for rare events --
    _addThrustModeL: func(engine) {
        var apr = "apr"~engine;
        setlistener("controls/engines/engine["~engine~"]/thrust-mode", func(n) {
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
        setlistener("engines/engine["~engine~"]/reverser-pos-norm", func(n) {
            var pos = n.getValue();
            if (pos == 0) me[rev].hide();
            else me[rev].show();
        }, 1);
    },

    _addFlapsL: func() {
        setlistener("surface-positions/slat-pos-norm", func(n) {
            me["slatsBar_clip"].setTranslation(-100 * n.getValue(), 0);
            me._updateClip("slatsBar");
        }, 1, 0);
        setlistener("surface-positions/flap-pos-norm", func(n) {
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

    updateGear: func(idx, pos) {
        if (pos == 0) {
            me["tGear"~idx].setText("UP");
            me["gear"~idx].setColor(me.colors["white"]);
            me["gearInTransit"~idx].hide();
        }
        elsif (pos == 1) {
            me["tGear"~idx].setText("DN");
            me["gear"~idx].setColor(me.colors["green"]);
            me["gearInTransit"~idx].hide();
        }
        else {
            me["gearInTransit"~idx].show();
            me["tGear"~idx].setText("");
        }
    },

    updateGearIndicators: func() {
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
    },

    updateFuel: func() {
        me["fuelQty0"].setText(sprintf("%3d", me.getTank(0)));
        me["fuelQty1"].setText(sprintf("%3d", me.getTank(1)));
        me["fuelQty2"].setText(sprintf("%3d", me.getTank(2)));
        var totalFuel = getprop("consumables/fuel/total-fuel-lbs");
        var imba = getprop("systems/fuel/imbalance");
        me["fuelTotal"].setText(sprintf("%3d", totalFuel*LB2KG));
        if (imba or totalFuel < 900) {
            me["gFuelValues"].setColor(me.colors["amber"]);
        }
        else me["gFuelValues"].setColor(me.colors["green"]);
    },

    updateMessages: func() {
        if (me.updateN == nil or !me.updateN.getValue())
            return;
        if (!me.msgsys.needsUpdate())
            return;
        var messages = me.msgsys.getActiveMessages();
        #print("M1 "~size(messages)~" "~me.msgsys.getFirstUpdateIndex());        
        for (var i = me.msgsys.getFirstUpdateIndex(); i < size(messages); i += 1) {
            me.updateTextElement("message"~i, messages[i].text, messages[i].color);
        }
        for (i; i < me.MAX_MSG; i += 1) {
            me.updateTextElement("message"~i, "");
        }
    },

    updateSlow: func() {
        if (me.updateN == nil or !me.updateN.getValue())
            return;
        me.updateGearIndicators();
        me.updateFuel();
        if (CRJ700.engines[0].running and CRJ700.engines[1].running) {
            if(me.oilp[0] > 24 and me.oilp[1] > 24)
            {
                me["gOil"].hide();
                me["gFanVib"].show();
            }
        }
        else {
            me["gOil"].show();
            me["gFanVib"].hide();
        }
    },

    update: func() {
        if (me.updateN == nil or !me.updateN.getValue()) return;
        #setprop(me.updateCountP, getprop(me.updateCountP)+1);
        me.oilp = [0,0];
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
            me["fuelFlow"~i].setText(sprintf("%4d", getprop("engines/engine["~i~"]/fuel-flow-pph")));
            me["oilTemp"~i].setText(sprintf("%3d", me.getEng(i, "oilt-norm")*163));
            me.oilp[i] = me.getEng(i, "oilp-norm")*780;
            me["oilPress"~i].setText(sprintf("%3d", me.oilp[i]));
            if (me.oilp[i] < 24) me.msgsys.set(me.clsWarning, me["msgOil"~i], 1);
            else me.msgsys.set(me.clsWarning, me["msgOil"~i], 0);
            me.updateOilGauge(i, me.oilp[i]);
        }
    },
};
