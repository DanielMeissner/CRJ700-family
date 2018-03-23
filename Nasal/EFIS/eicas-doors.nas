# EFIS for CRJ700 familiy 
# EICAS doors status page
# Author:  jsb
# Created: 03/2018
#

var EICASDoorsCanvas = {
    new: func(canvas_group, file) {
        var obj = { 
            parents: [EICASDoorsCanvas , EFISCanvas.new()],
            loop: 0,
            svg_keys: ["passenger", "fwdservice", "avionics", "fwdcargo", "ctrcargo",
                    "aftcargo", "lfwdemer", "laftemer", "rfwdemer","raftemer"],
            prop_base: "sim/model/door-positions/",
            prop_names: ["pax-left", "pax-right", "av-bay", "fwd-cargo", "ctr-cargo", 
                "aft-cargo"],
            prop_sufix: "/position-norm",
        };
        obj.loadsvg(canvas_group, file);
        obj.init();
        obj.setupUpdate(0.9);
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
        if (me._updateN == nil or !me._updateN.getValue()) return;
        #me.loop += 1;
        #print("d "~me.loop);
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
