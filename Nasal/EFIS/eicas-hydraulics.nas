# EFIS for CRJ700 familiy
# EICAS primary page
# Author:  jsb
# Created: 03/2018
#

# Hyd. sys. index: on cockpit screen 1,2,3 -> in code 0,1,2
var EICASHydraulicsCanvas = {

    new: func(name, file) {
        var obj = {
            parents: [EICASHydraulicsCanvas , EFISCanvas.new(name)],
            prefix: "systems/hydraulic/",
            svg_keys: [
                "line01", "line11", "line21","line02", "line12", "line22",
                "sov0", "sov1",
                "line1a1", "line1a2", "line1b", 
                "line2a1", "line2a2", "line2b",
                "line3a", "line3b", 
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
            "ib-ground-spoiler", "landing-gear", "nwsteering"])
            setlistener(me.prefix~"outputs/"~key, me._setColorL(key, "white", "amber"), 1, 0);
        
        foreach (var sys; [0,1,2]) {
            me["line"~sys~"1"].setColorFill(me.colors["green"]);
            me["line"~sys~"2"].setColorFill(me.colors["green"]);
            foreach (var pump; ["a","b"]) {
                setlistener(me.prefix~"system["~sys~"]/pump-"~pump~"-running", me._setColorL("pump"~(sys+1)~pump, "green", "white"), 1, 0);
                setlistener(me.prefix~"system["~sys~"]/pump-"~pump~"-value", me._hydLineL(sys, pump), 1, 0);
            }
        }
        me.update();
    },

    _hydLineL: func(sys, pump) {
        if (sys < 2 and pump == "a") return func(n) {
            var val = n.getValue() or 0;
            foreach (var i; [1,2]) {
                var key = "line"~(sys+1)~pump~i;
                if (val > 1800) me[key].setColorFill(me.colors["green"]);
                elsif (val > 0) me[key].setColorFill(me.colors["amber"]);
                else me[key].set("fill", "none");
            }
        };
        else return func(n) {
            var val = n.getValue() or 0;
            var key = "line"~(sys+1)~pump;
            if (val > 1800) me[key].setColorFill(me.colors["green"]);
            elsif (val > 0) me[key].setColorFill(me.colors["amber"]);
            else me[key].set("fill", "none");
        };
    },
    
    update: func() {
        foreach (var i; [0,1,2]) {
            var value = int(getprop(me.prefix~"system["~i~"]/value")/100)*100;
            me.updateTextElement("value"~i, sprintf("%4d", value), (value < 1800) ? "amber" : "green");
            if (i == 1) me.updateTextElement("ob-brakes", sprintf("%4d", value), (value < 1800) ? "amber" : "green");
            if (i == 2) me.updateTextElement("ib-brakes", sprintf("%4d", value), (value < 1800) ? "amber" : "green");
        }
    },
};
