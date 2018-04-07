# EFIS for CRJ700 familiy 
# EICAS primary page
# Author:  jsb
# Created: 03/2018
#

var EICASECSCanvas = {

    new: func(source_record, file) {
        var obj = { 
            parents: [EICASECSCanvas , EFISCanvas.new(source_record)],
            svg_keys: [
                "line0", "line1", "line2", 
                "line30", "line31",
                "line40", "line41", "line42", "line43",
                "line50", "line51", "line52", "line53",
                "bleedmanual", "manualL", "manualR", "psiL", "psiR",
            ],
        };
        foreach (var i; [0,1,2,3,4]) {
            append(obj.svg_keys, "sov"~i);
            append(obj.svg_keys, "sov"~i~"line");
        }
        obj.loadsvg(source_record.root, file);
        obj.init();
        obj.addUpdateFunction(obj.update, 0.2);
        return obj;
    },


    
    init: func() {
        foreach (var i; [0,1,2,3,4]) {
            setlistener("systems/pneumatic/sov"~i, me._sovL(i), 1, 0);
        }
        foreach (var i; [0,1,2]) {
            setlistener("engines/engine["~i~"]/running-nasal", me._lineL(i), 1, 0);
        }
        setlistener("systems/pneumatic/sov3", me._lineL(3), 1,0);
        setlistener("systems/pneumatic/pressure-left", me._lineL(4), 1, 0);
        setlistener("systems/pneumatic/pressure-right", me._lineL(5), 1, 0);
        setlistener("controls/ECS/pack-l-man", me._showHideL("manualL"), 1, 0);
        setlistener("controls/ECS/pack-r-man", me._showHideL("manualR"), 1, 0);
    },
    
    _sovL: func(i) {
        return func(n) {
            if (n.getValue()) {
                me["sov"~i].setRotation(90*D2R);
                me["sov"~i~"line"].setColorFill(me.colors["green"]);
            }
            else {
                me["sov"~i].setRotation(0);
                me["sov"~i~"line"].set("fill", "none");
            }
        };
    },
    
    _lineL: func(i) {
        return func(n) {
            if (n.getValue()) {
                if (i < 3)
                    me["line"~i].setColorFill(me.colors["green"]);
                elsif (i == 3) {
                    me["line30"].setColorFill(me.colors["green"]);
                    me["line31"].setColorFill(me.colors["green"]);
                }
                else {
                    foreach (var ii; [0,1,2,3]) 
                        me["line"~(10*i+ii)].setColorFill(me.colors["green"]);
                    if (i == 4) me["psiL"].setText("54");
                    if (i == 5) me["psiR"].setText("54");
                }
            }
            else {
                if (i < 3)
                    me["line"~i].set("fill", "none");
                elsif (i == 3) {
                    me["line30"].set("fill", "none");
                    me["line31"].set("fill", "none");
                }
                else {
                    foreach (var ii; [0,1,2,3])
                        me["line"~(10*i+ii)].set("fill", "none");
                    if (i == 4) me["psiL"].setText("0");
                    if (i == 5) me["psiR"].setText("0");
                }
            }
        };
    },

    update: func() {
    }, 
};
