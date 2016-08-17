# EFIS for CRJ700 familiy
# EICAS primary page
# Author:  jsb
# Created: 03/2018
#

var EICASAIceCanvas = {

    new: func(name, file) {
        var obj = {
            parents: [EICASAIceCanvas , EFISCanvas.new(name)],
            svg_keys: [
                "tIce", "ovht0", "ovht1",
                "line0", "line1", "line2", "line3",
                "wing0", "wing01", "wing1", "wing11",
                "cowl0", "cowl1",
                "cowlsov0", "cowlsov1", "cowlsov0line", "cowlsov1line",
                "wingsov0", "wingsov1", "wingsov0line", "wingsov1line",
                "sov0", "sov1", "sov0line", "sov1line",
                "sov4", "sov4line",
                "xbleed",
                "xbleedline",
                "eng0", "eng1",
            ],

        };
        obj.loadsvg(file);
        obj.init();
        #obj.addUpdateFunction(obj.update, 1);
        return obj;
    },

    #-- listeners for rare events --

    init: func() {
        foreach (var i; [0,1]) {
            me["ovht"~i].hide();
            setlistener("systems/pneumatic/sov"~i, func(n){me._updateSov(i, n.getValue());}, 1, 0);
            setlistener("engines/engine["~i~"]/running-nasal", me._lineL(i), 1, 0);
        }
        foreach (var key; [ "wing0", "wing01", "wing1", "wing11"])
            me[key].setColorFill(me.colors["green"]);
        me["tIce"].setColor(me.colors["green"]).hide();
        setlistener("systems/pneumatic/sov4", func(n) {me._updateSov(4, n.getValue());}, 1, 0);
        setlistener("systems/pneumatic/pressure-left", me._lineL(2), 1, 0);
        setlistener("systems/pneumatic/pressure-right", me._lineL(3), 1, 0);
        setlistener("systems/pneumatic/wingsov0", me._wingsovL(0), 1, 0);
        setlistener("systems/pneumatic/wingsov1", me._wingsovL(1), 1, 0);
        setlistener("systems/pneumatic/xbleed", func(n) {me._updateXbleed(n.getValue());} , 1, 0);
        setlistener("systems/pneumatic/wing-left", me._showHideL(["wing0"]), 1, 0);
        setlistener("systems/pneumatic/wing-right", me._showHideL(["wing1"]), 1, 0);
        setlistener("systems/pneumatic/wing-anti-ice", me._wingAIL(), 1, 0);
    },

    _updateSov: func(i, val) {
#        return func(n) {
            if (val) {
                me["sov"~i].setRotation(90*D2R);
                if (i < 2 and CRJ700.engines[i].running)
                    me["sov"~i~"line"].setColorFill(me.colors["green"]);
                if (i == 4 and
                    (getprop("systems/pneumatic/pressure-left") or getprop("systems/pneumatic/pressure-right"))
                )
                    me["sov4line"].setColorFill(me.colors["green"]);
            }
            else {
                me["sov"~i].setRotation(0);
                me["sov"~i~"line"].set("fill", "none");
            }
#        };
    },

    _wingsovL: func(i) {
        return func(n) {
            if (n.getValue()) {
                me["wingsov"~i].setRotation(90*D2R);
                if (i == 0 and getprop("systems/pneumatic/pressure-left") or
                    i == 1 and getprop("systems/pneumatic/pressure-right"))
                    me["wingsov"~i~"line"].setColorFill(me.colors["green"]);
            }
            else {
                me["wingsov"~i].setRotation(0);
                me["wingsov"~i~"line"].set("fill", "none");
            }
        };
    },

    _updateXbleed: func(val) {
#        return func(n) {
            if (val) {
                me["xbleed"].setRotation(90*D2R);
                if (getprop("systems/pneumatic/wing-left") or
                    getprop("systems/pneumatic/wing-right"))
                    me["xbleedline"].setColorFill(me.colors["green"]);
            }
            else {
                me["xbleed"].setRotation(0);
                me["xbleedline"].set("fill", "none");
            }
 #       };
    },

    _wingAIL: func() {
        return func(n) {
            var val = n.getValue();
            me._updateXbleed(val);
            
            if (val) {
                me["wing01"].show();
                me["wing11"].show();
            }
            else {
                me["wing01"].hide();
                me["wing11"].hide();
            }
        };
    },

    _lineL: func(i) {
        #engines/apu
        return func(n) {
            var val = n.getValue();
            if (val) {
                me["line"~i].setColorFill(me.colors["green"]);
                if (i < 2  and getprop("systems/pneumatic/sov"~i))
                    me["sov"~i~"line"].setColorFill(me.colors["green"]);
                else {
                    if (getprop("systems/pneumatic/sov4"))
                        me["sov4line"].setColorFill(me.colors["green"]);
                    if (getprop("systems/pneumatic/xbleed"))
                        me["xbleedline"].setColorFill(me.colors["green"]);
                    if (i == 2 and getprop("systems/pneumatic/wing-left"))
                        me["wingsov0line"].set("fill", "none");
                    if (i == 3 and getprop("systems/pneumatic/wing-right"))
                        me["wingsov1line"].set("fill", "none");
                }
            }
            else {
                me["line"~i].set("fill", "none");
                if (i < 2) me["sov"~i~"line"].set("fill", "none");
                me["sov4line"].set("fill", "none");
                me["xbleed"].set("fill", "none");
                if (i == 2) me["wingsov0line"].set("fill", "none");
                if (i == 3) me["wingsov1line"].set("fill", "none");
            }
        };
    },
};
