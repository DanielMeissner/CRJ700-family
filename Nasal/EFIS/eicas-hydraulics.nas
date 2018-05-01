# EFIS for CRJ700 familiy
# EICAS primary page
# Author:  jsb
# Created: 03/2018
#

var EICASHydraulicsCanvas = {

    new: func(name, file) {
        var obj = {
            parents: [EICASHydraulicsCanvas , EFISCanvas.new(name)],
            prefix: "systems/hydraulic/",
            svg_keys: [
                "value0", "value1", "value2", 
                "rudder", "aileron", "elevator",
                "ob-spoileron", "ob-flight-spoiler", "ob-ground-spoiler", "left-reverser",
                "ib-spoileron", "ib-flight-spoiler", "landing-gear-alt", "right-reverser", "ob-brakes",
                "ib-ground-spoiler", "landing-gear", "nwsteering", "ib-brakes",
                "pump1a", "pump1b", "pump2a", "pump2b", "pump3a", "pump3b",
                ],

        };
        obj.loadsvg(file);
        obj.init();
        obj.addUpdateFunction(obj.update, 0.2);
        return obj;
    },

    init: func() {
        foreach (var key; ["rudder", "aileron", "elevator", "ob-spoileron",
            "ob-flight-spoiler", "ob-ground-spoiler", "left-reverser",
            "ib-spoileron", "ib-flight-spoiler", "landing-gear-alt", "right-reverser",
            "ob-brakes", "ib-ground-spoiler", "landing-gear", "nwsteering", "ib-brakes"])
            setlistener(me.prefix~"outputs/"~key, me._setColorL(key, "white", "amber"), 1, 0);
        foreach (var sys; [0,1,2]) {
            foreach (var pump; ["a","b"])
                setlistener(me.prefix~"system["~sys~"]/pump"~pump, me._setColorL("pump"~(sys+1)~pump, "green", "white"), 1, 0);
        }
        me.update();
    },

    update: func() {
        foreach (var i; [0,1,2]) {
            var value = int(getprop(me.prefix~"system["~i~"]/value")/100)*100;
            me.updateTextElement("value"~i, sprintf("%4d", value), (value < 1800) ? "amber" : "green");
        }
    },
};
