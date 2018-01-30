# EFIS display manager

var dev_canvas_idx = "/dev/canvas_idx";
setprop(dev_canvas_idx, 1);

var display_names = ["PFD1", "MFD1", "EICAS1", "EICAS2", "MFD2", "PFD2"];
var display_objects = ["EFIS1", "EFIS2", "EFIS3", "EFIS4", "EFIS5", "EFIS6"];

# display selectors allow to re-route certain displays
# e.g. each MFD can be set to display the adjacent PFD or EICAS
# values 0,1,2 1=default
# /instrumentation/efis/controls/
var source_selectors = ["pilot_mfd", "copilot_mfd", "eicas"];

var efis = EFIS.new(display_names, display_objects);
    
print("-- display manager --");
io.include("Models/Instruments/EFIS/pfdL.nas");
io.include("Models/Instruments/EFIS/EICAS.nas");
io.include("Models/Instruments/EFIS/EICAS2.nas");

setlistener("sim/signals/fdm-initialized", func {
    pfd_canvas = canvas.new({
        "name": "PFD1",
        "size": [1024, 1280],
        "view": [1024, 1280],
        "mipmapping": 1
    });

    var groupPfd = pfd_canvas.createGroup();

    PFD_pfd = canvas_PFD_pfd.new(groupPfd, "Models/Instruments/EFIS/PFD.svg");
    PFD_pfd.update();
    canvas_PFD_base.update();
    var pfd_src = efis.addSource(pfd_canvas);
    efis.setDisplaySource(0, pfd_src);
});


var demo = func {
    var lines = [0,1,2,3,4,5,6];
    var windows = {};
    var i = 0;
    foreach (var name; screens) {
        print(name);
        windows[name] = canvas.Window.new([375,450], "dialog").set('title', name).move(i*250,0);
        i = i+1;
        #var c = windows[name].createCanvas();
        var c = canvas.new({"name" : name, "size" : [1024,1024], "view" : [375,450], "mipmapping" : 1 });
        c.setColorBackground(0.03, 0.03, 0.03, 1);
        windows[name].setCanvas(c);
        var root = c.createGroup();

        root.createChild("text", "heading")
            .setText("EFIS Test")
            .setFontSize(20, 0.9)          
            .setColor(1, 1, 1, 1)             
            .setAlignment("center-top") 
            .setTranslation(160, 10); 
        root.createChild("text", "ident")
            .setText("Display "~name)
            .setFontSize(20, 0.9)          
            .setColor(0.1, 1.0 , 0.1, 1)             
            .setAlignment("left-top") 
            .setTranslation(10, 50); 
        foreach (var l; lines)
            root.createChild("text").setText("Line "~l).setTranslation(20*l,100+20*l);
        var d = DisplayUnit.new(name, "EFIS_Screen");
        displays[name] = d;
        sources[name] = c;
        d.setSource(c);
    }
    var apu = root.createChild("group","svg");
    canvas.parsesvg(apu, "Aircraft/CRJ700-family/_dev/eicas-apu-dummy.svg");

    windows["test"] = canvas.Window.new([375,450], "dialog").set('title', "Test").move(250,90);
    c = canvas.new({"name" : name, "size" : [1024,1024], "view" : [375,450], "mipmapping" : 1 });
    windows["test"].setCanvas(c);
    root = c.createGroup();
    root.createChild("text", "heading")
            .setText("EFIS Source Test")
            #.setFontSize(20, 0.9)          
            .setColor(1, 1, 1, 1)             
            .setAlignment("center-top") 
            .setTranslation(60, 10); 
    var img = root.createChild("image");


    var switchCanvas = func (i) {
        img.set("src", "canvas://by-index/texture["~i~"]");
    }

    setlistener(dev_canvas_idx, func(n) {
        switchCanvas(n.getValue());
    }, 0,1);
}
