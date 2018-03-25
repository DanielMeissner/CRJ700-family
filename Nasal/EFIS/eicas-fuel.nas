# EFIS for CRJ700 familiy 
# EICAS primary page
# Author:  jsb
# Created: 03/2018
#

var EICASFuelCanvas = {

    new: func(source_record, file) {
        var obj = { 
            parents: [EICASFuelCanvas , EFISCanvas.new(source_record)],
            svg_keys: [
                                       
                ],
           
        };
        obj.loadsvg(source_record.root, file);
        obj.init();
        obj.setUpdateInterval(0.8);
        return obj;
    },

    #-- listeners for rare events --
    
    init: func() {
    },
    
    update: func() {
        if (me.updateN == nil or !me.updateN.getValue()) return;
        setprop(me.updateCountP, getprop(me.updateCountP)+1);
    }, 
};
