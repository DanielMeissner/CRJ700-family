# EFIS for CRJ700 familiy 
# EICAS DC electrical page
# Author:  jsb
# Created: 03/2018
#

var EICASDCCanvas = {

    new: func(source_record, file) {
        var obj = { 
            parents: [EICASDCCanvas , EFISCanvas.new(source_record)],
            svg_keys: [
                    #"eng1", "eng2", "apu", 
                    #"idg1", "idg2", "idgdisc1", "idgdisc2",
                    
                ],
                prop_base: "systems/dc/",
            prop_names: [],
            
        };
        obj.loadsvg(source_record.root, file);
        obj.init();
        obj.addUpdateFunction(obj.update, 0.1);
        return obj;
    },

    getKeys: func() {
        return me.svg_keys;
    },
    
    #-- listeners for rare events --
    init: func() {
    },
    
    update: func() {
        if (me.updateN == nil or !me.updateN.getValue()) return;
        setprop(me.updateCountP, getprop(me.updateCountP)+1);
    }, 
};
