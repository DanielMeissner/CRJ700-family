# EFIS for CRJ700 familiy 
# EICAS status page
# Author:  jsb
# Created: 03/2018
#

var EICASStatCanvas = {

    new: func(canvas_group, file) {
        var obj = { 
            parents: [EICASStatCanvas , EFISCanvas.new()],
            loop: 0,
            svg_keys: [
                "elevTrim", "elevTrimValue", "ailTrim", "rudderTrim",
                "gAPU", "rpm", "rpmPointer", "egt", "egtPointer",
                "doorMsg", "apuoff",
            ],
           
        };
        obj.loadsvg(canvas_group, file);
        obj.init();
        obj.setupUpdate(0.1, "eicas-status");
        return obj;
    },

    
    init: func() {
        me._addApuL();
        me._addApuDoorL();
    },
    
    _addApuL: func() {
        me.setlistener("controls/APU/electronic-control-unit", func(n) {
            if (n.getValue()) {
                me["gAPU"].show();
                me["apuoff"].hide();
            }
            else {
                me["gAPU"].hide();
                me["apuoff"].show();
            }
        }, 1);
    },
    
    _addApuDoorL: func() {
        me.setlistener("engines/engine[2]/door-msg", func(n) {
            var value = n.getValue();
            me["doorMsg"].setText(value);
            if (value == "----") me["doorMsg"].setColor(me.colors["amber"]);
            else me["doorMsg"].setColor(me.colors["white"]);
        }, 1);
    },
        
    getEng: func(idx, prop) {
        return (getprop("engines/engine["~idx~"]/"~prop) or 0);
    },    

    getSurf: func(name) {
        return (getprop("/surface-positions/"~name) or 0);
    },
    
    #-- listeners for rare events --
    update: func() {
        if (me._updateN == nil or !me._updateN.getValue()) return;
        #me.loop += 1;
        #print("d "~me.loop);
        value = me.getEng(2, "rpm");
        me["rpm"].setText(sprintf("%3.0f", value));
        me["rpmPointer"].setRotation(value * 0.04189);
        value = me.getEng(2, "egt-degc");
        me["egt"].setText(sprintf("%3.0f", value));
        me["egtPointer"].setRotation(value * 0.003696);
        
        me["rudderTrim"].setRotation(-getprop("controls/flight/rudder-trim"));
        me["ailTrim"].setRotation(getprop("controls/flight/aileron-trim"));
        var trim = getprop("/instrumentation/eicas/hstab-trim");
        me["elevTrim"].setTranslation(0, 9.4785*trim);
        me["elevTrimValue"].setText(sprintf("%1.1f", trim));
    }, 
};
