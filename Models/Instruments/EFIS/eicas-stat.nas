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
                                       
                ],
           
        };
        obj.loadsvg(canvas_group, file);
        obj.init();
        obj.setupUpdate("instrumentation/efis/update/stat", 0.1);
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
