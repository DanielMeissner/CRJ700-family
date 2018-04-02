# EFIS for CRJ700 familiy 
# EICAS status page
# Author:  jsb
# Created: 03/2018
#

var EICASFctlCanvas = {

    new: func(source_record, file) {
        var obj = { 
            parents: [EICASFctlCanvas , EFISCanvas.new(source_record)],
            svg_keys: [
                    "ail0", "ail1", "ailTrim",
                    "slats0", "slats1",
                    "FltSpOB0", "FltSpIB0", 
                    "FltSpOB1", "FltSpIB1", 
                    "GndSpOB0", "GndSpIB0", 
                    "GndSpOB1", "GndSpIB1",
                    "spoilerIndL1", "spoilerIndL2", "spoilerIndL3", "spoilerIndL4",
                    "spoilerIndR1", "spoilerIndR2", "spoilerIndR3", "spoilerIndR4",
                    "flaps0", "flaps1", 
                    "elev0",  "elev1", "elevTrim", "elevTrimValue",
                    "rudder", "rudderTrim", "rudderLimit0", "rudderLimit1",
                ],
        };
        obj.loadsvg(source_record.root, file);
        obj.init();
        obj.addUpdateFunction(obj.update, 0.07);
        return obj;
    },

    #-- listeners for rare events --
    
    init: func() {
        me._addGndSpoilerL();
    },
    
    _addGndSpoilerL: func(){
        setlistener("/surface-positions/spoiler-ob-ground-pos-norm", func(n) {
            var v = n.getValue() or 0;
            me["spoilerIndL3"].setTranslation(0, -139.46 * v);
            me["spoilerIndR3"].setTranslation(0, -139.46 * v);
        
        }, 1, 0);
        setlistener("/surface-positions/spoiler-ib-ground-pos-norm", func(n) {
            var v = n.getValue() or 0;
            me["spoilerIndL4"].setTranslation(0, -139.46 * v);
            me["spoilerIndR4"].setTranslation(0, -139.46 * v);
        
        }, 1, 0);
    },
    
    getSurf: func(name) {
        return (getprop("/surface-positions/"~name) or 0);
    },
    
    update: func() {
        if (me.updateN == nil or !me.updateN.getValue()) return;
        setprop(me.updateCountP, getprop(me.updateCountP)+1);
        var flaps_deg = math.round(me.getSurf("flap-pos-norm")*45);
        var slats_deg = math.round(me.getSurf("slat-pos-norm")*25);
        var ail = [0,0];
        ail[0] = me.getSurf("left-aileron-pos-norm");
        ail[1] = me.getSurf("right-aileron-pos-norm");
        var elev = me.getSurf("elevator-pos-norm"); # modelled as only one ctrl.srf.
        if (elev > 0) elev *= 55; #push
        else elev *= 83; #pull

        foreach (var i; [0,1]) {
            me["flaps"~i].setText(sprintf("%2d", flaps_deg));
            me["slats"~i].setText(sprintf("%2d", slats_deg));
            if (ail[i] > 0) ail[i] *= 55;
            else ail[i] *= 81.5;
            me["ail"~i].setTranslation(0, ail[i]);
            me["elev"~i].setTranslation(0,elev);
        }

        #-- spoilers --

        me["spoilerIndL1"].setTranslation(0, -153.53 * me.getSurf("left-ob-mfs-pos-norm"));
        me["spoilerIndL2"].setTranslation(0, -144.47 * me.getSurf("left-ib-mfs-pos-norm"));
        me["spoilerIndR2"].setTranslation(0, -144.47 * me.getSurf("right-ib-mfs-pos-norm"));
        me["spoilerIndR1"].setTranslation(0, -153.53 * me.getSurf("right-ob-mfs-pos-norm"));

        #-- rudder: full = 33deg, may be limited by SCCU 4deg - 33deg (not yet implemented)
        me["rudder"].setTranslation(-162.71 * me.getSurf("rudder-pos-norm"), 0);
        me["rudderTrim"].setRotation(-getprop("controls/flight/rudder-trim"));
        me["ailTrim"].setRotation(getprop("controls/flight/aileron-trim"));
        var trim = getprop("/instrumentation/eicas/hstab-trim");
        me["elevTrim"].setTranslation(0, 9.4785 * trim);
        me["elevTrimValue"].setText(sprintf("%1.1f", trim));
    }, 
};
