# EFIS for CRJ700 familiy 
# EICAS doors status page
# Author:  jsb
# Created: 03/2018
#

var EICASACCanvas = {

    new: func(source_record, file) {
        var obj = { 
            parents: [EICASACCanvas , EFISCanvas.new(source_record)],
            svg_keys: ["gen1", "gen2", "gen3", "gen4", "gen5",
                    "eng1", "eng2", "apu", 
                    "idg1", "idg2", "idgdisc1", "idgdisc2",
                    "bus1","bus2","essbus", "adgbus", "servbus",
                ],
            prop_base: "systems/ac/",
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
    _idgdiscL: func(idx) { 
        return func(n) {
            if (n.getValue()) {
                me["idgdisc"~idx].show();
                me["idg"~idx].setColor(me.colors["white"]);
            }
            else
                me["idgdisc"~idx].hide();
        };
    },
    
    init: func() {
        print("Init AC ...");
        setlistener("controls/electric/idg1-disc", me._idgdiscL(1), 1);
        setlistener("controls/electric/idg2-disc", me._idgdiscL(2), 1);
        print("Init AC done.");
    },
    
    update: func() {
        if (me.updateN == nil or !me.updateN.getValue()) return;
        setprop(me.updateCountP, getprop(me.updateCountP)+1);
        
    }, 
};
