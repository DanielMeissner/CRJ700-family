#
# EFIS for CRJ700 family (Rockwell Collins Proline 4)
# Author:  jsb
# Created: Feb. 2018
#
print("-- EFIS --");
var reloadFlag = "/instrumentation/efis/reload";
props.getNode(reloadFlag,1).setIntValue(0);

var svg_path = "Models/Instruments/EFIS/";
var nasal_path = "Nasal/EFIS/";
io.include(nasal_path~"efis.nas");
io.include(nasal_path~"pfd.nas");
io.include(nasal_path~"eicas-pri.nas");
io.include(nasal_path~"eicas-stat.nas");
io.include(nasal_path~"eicas-hydraulics.nas");
io.include(nasal_path~"eicas-ac.nas");
io.include(nasal_path~"eicas-dc.nas");
io.include(nasal_path~"eicas-fuel.nas");
io.include(nasal_path~"eicas-fctl.nas");
io.include(nasal_path~"eicas-aice.nas");
io.include(nasal_path~"eicas-doors.nas");

# identifiers for display units
var display_names = ["PFD1", "MFD1", "EICAS1", "EICAS2", "MFD2", "PFD2"];
# names of 3D objects that will take the canvas texture
var display_objects = ["EFIS1", "EFIS2", "EFIS3", "EFIS4", "EFIS5", "EFIS6"];
# power source for each display unit
var power_props = [ 
    "/systems/DC/outputs/pfd1",
    "/systems/DC/outputs/mfd1",
    "/systems/DC/outputs/eicas-disp",
    "/systems/DC/outputs/eicas-disp",
    "/systems/DC/outputs/mfd2",
    "/systems/DC/outputs/pfd2"
];
var minimum_power = 22;

var efis = EFIS.new(display_names, display_objects, power_props);
forindex (var i; display_names) {
    efis.getDU(i).setPowerSource(power_props[i], minimum_power);
}  

# efis will create one display canvas and one source canvas per display unit automatically
# more pages can be added e.g. for EICAS
var EICASpages = ["ECS", "HYD", "AC", "DC", "FUEL", "F-CTL", "A-ICE", "Doors"];
# get the two sources created by efis module automatically
var eicas_sources = [2,3]; 
# add more sources for the remaining pages
foreach (var name; EICASpages) {
    append(eicas_sources, efis.addSource(name));
}
var sources = efis.getSources();

# control panel selector prop 
var eicas_pageP = "instrumentation/eicas/page";
var ecp_targetN = props.globals.getNode("instrumentation/eicas/ecp-target",1);
ecp_targetN.setIntValue(3);
var dev_targetN = props.globals.getNode("/dev/efis-target",1);
dev_targetN.setIntValue(4);
efis.addSourceSelector(eicas_pageP, ecp_targetN, eicas_sources);

# display selectors allow to re-route certain displays
# e.g. each MFD can be set to display the adjacent PFD or EICAS
# values 0,1,2 1=default
var src_selector_base = "/controls/efis/";
var src_selectors = ["src-mfd-pilot", "src-mfd-copilot", "src-eicas"];
var callbacks = [
    func(val) { 
        if (val == 2) ecp_targetN.setValue(1);
        elsif (getprop(src_selector_base~src_selectors[2]) == 0)
            ecp_targetN.setValue(2); 
        else ecp_targetN.setValue(3);
    },
    func(val) { 
        if (val == 2) ecp_targetN.setValue(4); 
        elsif (getprop(src_selector_base~src_selectors[2]) == 0)
            ecp_targetN.setValue(2); 
        else ecp_targetN.setValue(3);
    },
    func(val) { 
        if (val == 0) ecp_targetN.setValue(2); 
        else ecp_targetN.setValue(3);
    },
];
# mappings per src_selector
var mappings = [ 
        [ {PFD1: -1, MFD1: 0}, {PFD1: 0, MFD1: 1}, {PFD1: 0, MFD1: 3} ],
        [ {PFD2: -1, MFD2: 5}, {PFD2: 5, MFD2: 4}, {PFD2: 5, MFD2: 3} ],
        [ {EICAS1: 3, EICAS2: -1}, {EICAS1: 2, EICAS2: 3}, {EICAS1: -1, EICAS2: 2} ],
    ];


var pfd1 = nil;
var pfd2 = nil;
var eicas = nil;

var EFISSetup = func() {
    pfd1 = PFDCanvas.new(sources[0].root, svg_path~"PFD.svg",0);
    pfd2 = PFDCanvas.new(sources[5].root, svg_path~"PFD.svg",1);
    eicas1 = EICASPriCanvas.new(sources[eicas_sources[0]].root, svg_path~"eicas-pri.svg");
    eicas2 = EICASStatCanvas.new(sources[eicas_sources[1]].root, svg_path~"eicas-stat.svg");
    p3 = EFISCanvas.new(sources[eicas_sources[2]].root, svg_path~"ecs.svg");
    hydr = EICASHydraulicsCanvas.new(sources[eicas_sources[3]].root, svg_path~"hydraulics.svg");
    ac = EICASACCanvas.new(sources[eicas_sources[4]].root, svg_path~"eicas-ac.svg");
    dc = EICASDCCanvas.new(sources[eicas_sources[5]].root, svg_path~"eicas-dc.svg");
    fuel = EICASFuelCanvas.new(sources[eicas_sources[6]].root, svg_path~"fuel.svg");
    fctl = EICASFctlCanvas.new(sources[eicas_sources[7]].root, svg_path~"eicas-fctl.svg");
    aice = EICASAIceCanvas.new(sources[eicas_sources[8]].root, svg_path~"template.svg");
    doors = EICASDoorsCanvas.new(sources[eicas_sources[9]].root, svg_path~"eicas-doors.svg");

    #-- add display routing controls
    forindex (var i; src_selectors) {
        var prop_path = src_selector_base~src_selectors[i];
        # init to default=1 (3D model knobs in middle position)
        setprop(prop_path,1);
        efis.addDisplaySwapControl(prop_path, mappings[i], callbacks[i]);
    }
};

var initL = setlistener("sim/signals/fdm-initialized", func(p)
{
    if (p.getValue()) {
        print("Init EFIS...");
        EFISSetup();
    }
}, 1, 0);

var cleanup = setlistener(reloadFlag, func(p)
{
    if (p.getValue()) {
        print("DM cleanup");
        removelistener(initL);
        removelistener(cleanup);
    }
});