# EFIS for CRJ700 familiy 
# EICAS DC electrical page
# Author:  jsb
# Created: 03/2018
#

var EICASDCCanvas = {

    new: func(canvas_group, file) {
        var obj = { 
            parents: [EICASDCCanvas , EFISCanvas.new()],
            loop: 0,
            svg_keys: [
                    #"eng1", "eng2", "apu", 
                    #"idg1", "idg2", "idgdisc1", "idgdisc2",
                    
                ],
                prop_base: "systems/dc/",
            prop_names: [],
            
        };
        obj.loadsvg(canvas_group, file);
        obj.init();
        obj.setupUpdate("instrumentation/efis/update/dc", 0.1);
        return obj;
    },

    getKeys: func() {
        return me.svg_keys;
    },
    
    #-- listeners for rare events --
    init: func() {
    },
    
    update: func() {
        if (me._updateN == nil or !me._updateN.getValue()) return;
        #me.loop += 1;
        #print("d "~me.loop);
    }, 
};
