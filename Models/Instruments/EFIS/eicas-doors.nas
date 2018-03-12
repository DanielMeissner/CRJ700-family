#
# EFIS PFD (Primary Flight Display) for CRJ700 familiy 
#

var EICASDoorsCanvas = {
    new: func(canvas_group, file) {
        var obj = { 
            parents: [EICASDoorsCanvas , EFISCanvas.new()],
            prop_base: "sim/model/door-positions/",
            prop_sufix: "/position-norm",
            svg_keys: ["passenger", "fwdservice", "avionics", "fwdcargo", "ctrcargo",
                    "aftcargo", "lfwdemer", "laftemer", "rfwdemer","raftemer"],
            prop_names: ["pax-left", "pax-right", "av-bay", "fwd-cargo", "ctr-cargo", 
                "aft-cargo"],
        };
        obj.init(canvas_group, file);
        var color_green = [0.133,0.667,0.133];
        var color_amber = [1,0.682,0];
        var color_red = [1,0,0];
        var color_warn = color_red;
        forindex (var i; obj.prop_names) {
            var p = obj.prop_base~obj.prop_names[i]~obj.prop_sufix;
            if (i > 0) color_warn = color_amber;
            obj.setlistener(p, func(n) {
                print("EICASDoorsCanvas "~n.getValue());
                if (n.getValue() == 0) obj[obj.svg_keys[i]].setcolor(color_green)
                else obj[obj.svg_keys[i]].setcolor(color_warn);
            });
        }
        return obj;
    },
    getKeys: func() {
        return me.svg_keys;
    },
    
    update: func() {}, 
};
