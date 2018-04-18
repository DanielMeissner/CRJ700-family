# EFIS for CRJ700 familiy 
# EICAS DC electrical page
# Author:  jsb
# Created: 03/2018
#

var EICASDCCanvas = {

    new: func(name, file) {
        var obj = { 
            parents: [EICASDCCanvas , EFISCanvas.new(name)],
            svg_keys: [
                "input4", "line51",
                "gEmerBus", "dc2toserv",
                "xtie", "esstie", "maintie", "utilconnect",
                "tCharger0", "tCharger1", "tBattOff0", "tBattOff1",
            ],
            prop_base: "systems/DC/",
            prop_names: [],
            inputN: [],
            outputN: [],            
        };
        foreach (var i; [0,1,2,3]) {
            append(obj.svg_keys, "input"~i);
            append(obj.svg_keys, "output"~i);
            append(obj.svg_keys, "volts"~i);
            append(obj.svg_keys, "load"~i);
        }
        foreach (var i; [1,2,3,4,5,6]) {
            append(obj.svg_keys, "bus"~i);
            append(obj.svg_keys, "line"~i);
        }
        obj.loadsvg(file);
        obj.init();
        obj.addUpdateFunction(obj.update, 0.1);
        return obj;
    },

    getKeys: func() {
        return me.svg_keys;
    },
    
    #-- listeners for rare events --
    init: func() {
        append(me.inputN, props.getNode("systems/AC/outputs/tru1",1));
        append(me.inputN, props.getNode("systems/AC/outputs/tru2",1));
        append(me.inputN, props.getNode("systems/AC/outputs/esstru1",1));
        append(me.inputN, props.getNode("systems/AC/outputs/esstru2",1));
        append(me.outputN, props.getNode("systems/DC/system/tru1-value",1));
        append(me.outputN, props.getNode("systems/DC/system/tru2-value",1));
        append(me.outputN, props.getNode("systems/DC/system/esstru1-value",1));
        append(me.outputN, props.getNode("systems/DC/system/esstru2-value",1));
        foreach (var key; ["xtie", "esstie", "maintie", "utilconnect"])
            me[key].setColorFill(me.colors["green"]);
        foreach (var key; ["gEmerBus", "input4", "xtie","esstie","maintie"])
            me[key].hide();
        setlistener("systems/DC/system/esstie", me._showHideL("esstie"), 1,0);
        setlistener("systems/DC/system/maintie", me._showHideL("maintie"), 1,0);
        setlistener("systems/DC/system/xtie", me._showHideL("xtie"), 1,0);
        me["tBattOff0"].setColor(me.colors["amber"]);
        me["tBattOff1"].setColor(me.colors["amber"]);
        foreach (var i; [1,2,3,4,5]) {
            setlistener(me.prop_base~"outputs/bus"~i, me._busL(i), 1, 0);
        }
    },
    
    _busL : func(i) {
        return func(n) {
            if (num(n.getValue()) >= 18) {
                me["bus"~i].setColor(me.colors["green"]);
                me["line"~i].setColorFill(me.colors["green"]);
                if (i == 5) {
                    me["line"~i~"1"].setColorFill(me.colors["green"]);
                }
            } else {
                me["bus"~i].setColor(me.colors["amber"]);                
                me["line"~i].set("fill", "none");
                if (i == 5) {
                    me["line"~i~"1"].set("fill", "none");
                }
            }
        };
    },
    
    update: func() {
        foreach (var i; [0,1,2,3]) {
            var in = me.inputN[i].getValue();
            var volts = me.outputN[i].getValue();
            me["volts"~i].setText(sprintf("%2d", volts));
            if (in > 40) {
                me["input"~i].setColorFill(me.colors["green"]);
            } else {
                me["input"~i].set("fill", "none");
            }
            if (volts > 0) {
                me["output"~i].setColorFill(me.colors["green"]);
                me["load"~i].setText(sprintf("%2d", 20+i));
            } else {
                me["output"~i].set("fill", "none");
                me["load"~i].setText(sprintf("%2d", 0));
            }
        }
        if (getprop("systems/DC/system/maintie"))
            me["utilconnect"].hide();
        else
            me["utilconnect"].show();

    }, 
};
