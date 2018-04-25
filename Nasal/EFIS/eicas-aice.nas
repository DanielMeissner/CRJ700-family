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
                "line0", "line1", "line01", "line11",
                "cowl0", "cowl1",
                "cowlsov0", "cowlsov1", "cowlsov0line", "cowlsov1line", 
                "wingsov0", "wingsov1", "wingsov0line", "wingsov1line",
                "sov0", "sov1", "sov0line", "sov1line",
                "bleedisolation", "xbleed", "bleedisolationline", "xbleedline",
                "eng0", "eng1",
            ],
           
        };
        obj.loadsvg(file);
        obj.init();
        obj.addUpdateFunction(obj.update, 1);
        return obj;
    },

    #-- listeners for rare events --
    
    init: func() {
        foreach (var i; [0,1]) {
            me["ovht"~i].hide();
        }
        me["tIce"].setColor(me.colors["green"]).hide();
    },
    
    update: func() {

    }, 
};
