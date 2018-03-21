# EFIS for CRJ700 familiy 
# EICAS primary page
# Author:  jsb
# Created: 03/2018
#

var EICASPriCanvas = {

    new: func(canvas_group, file) {
        var obj = { 
            parents: [EICASPriCanvas , EFISCanvas.new()],
            loop: 0,
            svg_keys: [
                                       
                ],
           
        };
        obj.loadsvg(canvas_group, file);
        obj.init();
        obj.setupUpdate("instrumentation/efis/update/pri", 0.05);
        return obj;
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
