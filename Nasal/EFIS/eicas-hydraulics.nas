# EFIS for CRJ700 familiy 
# EICAS primary page
# Author:  jsb
# Created: 03/2018
#

var EICASHydraulicsCanvas = {

    new: func(name, file) {
        var obj = { 
            parents: [EICASHydraulicsCanvas , EFISCanvas.new(name)],
            svg_keys: [
                                       
                ],
           
        };
        obj.loadsvg(file);
        obj.init();
        obj.addUpdateFunction(obj.update, 0.2,);
        return obj;
    },

    #-- listeners for rare events --
    
    init: func() {
    },
    
    update: func() {

    }, 
};
