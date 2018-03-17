# EFIS for CRJ700 familiy 
# EICAS doors status page
# Author:  jsb
# Created: 03/2018
#

var EICASDoorsCanvas = {
    color_red: [1,0,0],
    color_amber: [1,0.682,0],
    color_green : [0.133,0.667,0.133],

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
        obj.setupUpdate("instrumentation/efis/update/doors", 0.9);
        obj.init(canvas_group, file);
        if (substr(getprop("sim/aero"), 0,6) == "CRJ700") {
            obj["laftemer"].hide();
            obj["raftemer"].hide();
            obj["fwdcargo"].hide();
        }
        return obj;
    },

    getKeys: func() {
        return me.svg_keys;
    },

    update: func() {
        if (me._updateN == nil or !me._updateN.getValue()) return;
        #me.loop += 1;
        #print("d "~me.loop);
        var color_warn = me.color_red;
        forindex (var i; me.prop_names) {
            if (i > 0) color_warn = me.color_amber;
            var prop = me.prop_base~me.prop_names[i]~me.prop_sufix;
            var element = me.svg_keys[i];
            if (getprop(prop) == 0) me[element].setColor(me.color_green)
            else me[element].setColor(color_warn);
        }
    }, 
};
