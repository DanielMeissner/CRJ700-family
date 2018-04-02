# EFIS for CRJ700 familiy 
# EICAS doors status page
# Author:  jsb
# Created: 03/2018
#

var EICASDoorsCanvas = {
    new: func(source_record, file) {
        var obj = { 
            parents: [EICASDoorsCanvas , EFISCanvas.new(source_record)],
            svg_keys: ["passenger", "fwdservice", "av-bay", "fwdcargo", "ctrcargo",
                    "aftcargo", "lfwdemer", "rfwdemer", "laftemer","raftemer"],
            prop_base: "sim/model/door-positions/",
            prop_names: ["pax-left", "pax-right", "av-bay", "fwd-cargo", "ctr-cargo", 
                "aft-cargo", "emer-l1", "emer-r1", "emer-l2", "emer-r2"],
            prop_sufix: "/position-norm",
        };
        obj.loadsvg(source_record.root, file);
        obj.init();
        obj.addUpdateFunction(obj.update, 0.9);
        return obj;
    },

    getKeys: func() {
        return me.svg_keys;
    },

    init: func() {
        if (substr(getprop("sim/aero"), 0,6) == "CRJ700") {
            me["laftemer"].hide();
            me["raftemer"].hide();
            me["fwdcargo"].hide();
        }
    },
        
    update: func() {
        if (me.updateN == nil or !me.updateN.getValue()) return;
        #setprop(me.updateCountP, getprop(me.updateCountP)+1);
        var color_warn = me.colors["red"];
        forindex (var i; me.prop_names) {
            if (i > 0) color_warn = me.colors["amber"];
            var prop = me.prop_base~me.prop_names[i]~me.prop_sufix;
            var element = me.svg_keys[i];
            if (getprop(prop) == 0) me[element].setColor(me.colors["green"]);
            else me[element].setColor(color_warn);
        }
    }, 
};
