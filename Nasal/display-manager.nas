#
# EFIS display manager
# Author: Henning Stahlke
# created: Feb. 2018
#
print("-- EFIS display manager --");
var reloadFlag = "/instrumentation/efis/reload";
props.getNode(reloadFlag,1).setIntValue(0);

# identifiers for display units
var display_names = ["PFD1", "MFD1", "EICAS1", "EICAS2", "MFD2", "PFD2"];
# names of 3D objects that will take the canvas texture
var display_objects = ["EFIS1", "EFIS2", "EFIS3", "EFIS4", "EFIS5", "EFIS6"];
var power_props = [ 
    "/systems/DC/outputs/pfd1",
    "/systems/DC/outputs/mfd1",
    "/systems/DC/outputs/eicas-disp",
    "/systems/DC/outputs/eicas-disp",
    "/systems/DC/outputs/mfd2",
    "/systems/DC/outputs/pfd2"
];

#-- EICAS pages --
# page 3 ECS 
# page 4 HYD
# page 5 AC 
# page 6 DC 
# page 7 FUEL 
# page 8 F/CTL 
# page 9 A/ICE 
# page 10 Doors 

var efis = EFIS.new(display_names, display_objects, power_props);
# efis will create one "page" canvas per display unit automatically
# more pages can be added e.g. for EICAS, see below
var sources = efis.getSources();
#var eicas_sources = [sources[2], sources[3]];
#append (eicas_sources, efis.addSource);
#FIXME: add EICAS pages

# display selectors allow to re-route certain displays
# e.g. each MFD can be set to display the adjacent PFD or EICAS
# values 0,1,2 1=default
var src_selector_base = "/controls/efis/";
var src_selectors = ["src-mfd-pilot", "src-mfd-copilot", "src-eicas"];
# mappings per src_selector
var mappings = [ 
        [[-1,0,nil,nil,nil,nil], [0,1,nil,nil,nil,nil], [0,3,nil,nil,nil,nil]],
        [[nil,nil,nil,nil,5,-1], [nil,nil,nil,nil,4,5], [nil,nil,nil,nil,3,5]],
        [[nil,nil,3,-1,nil,nil], [nil,nil,2,3,nil,nil], [nil,nil,-1,2,nil,nil]],
    ];


io.include("Models/Instruments/EFIS/pfd.nas");
io.include("Models/Instruments/EFIS/eicas-doors.nas");
#io.include("Models/Instruments/EFIS/EICAS.nas");
#io.include("Models/Instruments/EFIS/EICAS2.nas");

var DM_init = func() {
    forindex (var i; display_names) {
        efis.getDU(i).setPower(power_props[i], 22);
    }    
    var pfd1 = PFDCanvas.new(sources[0].root, "Models/Instruments/EFIS/PFD.svg",0);
    var pfd2 = PFDCanvas.new(sources[5].root, "Models/Instruments/EFIS/PFD.svg",1);
    var eicas = EICASDoorsCanvas.new(sources[3].root, "Models/Instruments/EFIS/doors.svg");

    var timer_pfd1 = maketimer(0.05, pfd1.update);
    var timer_pfd2 = maketimer(0.05, pfd2.update);
    
    foreach (var i; [1,2,4]) {
        sources[i].root.createChild("text")
            .setText(display_names[i] ~ " dummy")
            .setFontSize(70)
            .setColor(1,1,1,1).setAlignment("left-center")
            .setTranslation(150,150);
    }
    #-- add display routing controls
    forindex (var i; src_selectors) {
        var prop_path = src_selector_base~src_selectors[i];
        # init to default=1 (3D model knobs in middle position)
        setprop(prop_path,1);
        efis.addDisplayControl(prop_path, mappings[i]);
    }
};

setlistener("sim/signals/fdm-initialized", func(p)
{
    if (p.getValue()) {
        print("Init EFIS...");
        DM_init();
    }
}, 1, 0);