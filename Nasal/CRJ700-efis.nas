#
# EFIS for CRJ700 family (Rockwell Collins Proline 4)
# Author:  jsb
# Created: Feb. 2018
#

#-- begin development --------------------------------------------------------
print("-- EFIS --");
var reloadFlag = "/efis/reload";
props.getNode(reloadFlag,1).setIntValue(0);
setprop ("/sim/startup/terminal-ansi-colors",0);

var _efis_listeners = [];
var real_setlistener = setlistener;

var setlistener = func(p, f, s=0, r=1) {
    var lid = real_setlistener(p,f,s,r);
    append(_efis_listeners, lid);
    #print("EFIS add listener "~lid~" p:");
    #debug.dump(p);
};

var removelisteners = func() {
    var msg = "Removing listeners ";
    foreach (var id; _efis_listeners) {
        removelistener(id);
        msg = msg~" "~id;
    }
    print(msg);
    _efis_listeners = [];
};

var cleanup = func()
{
        print("EFIS cleanup... ");
        removelisteners();
        efis.del();
};
#-- end development ----------------------------------------------------------

var svg_path = "Models/Instruments/EFIS/";
var nasal_path = "Nasal/EFIS/";
var nasal_files = [
    "efis.nas",
    "pfd.nas",
    "eicas-messages-crj700.nas",
    "eicas-pri.nas",
    "eicas-stat.nas",
    "eicas-ecs.nas",
    "eicas-hydraulics.nas",
    "eicas-ac.nas",
    "eicas-dc.nas",
    "eicas-fuel.nas",
    "eicas-fctl.nas",
    "eicas-aice.nas",
    "eicas-doors.nas",
    ];
foreach (var filename; nasal_files)
{
    io.include(nasal_path~filename);
}
#var EICASMsgSys1 = MessageSystem.new(16, "instrumentation/eicas/msgsys1")
#var EICASMsgSys2 = MessageSystem.new(16, "instrumentation/eicas/msgsys1")

# identifiers for display units
var display_names = ["PFD1", "MFD1", "EICAS1", "EICAS2", "MFD2", "PFD2"];
# names of 3D objects that will take the canvas texture
var display_objects = ["EFIS1", "EFIS2", "EFIS3", "EFIS4", "EFIS5", "EFIS6"];
# power source for each display unit
var display_power_props = [ 
    "/systems/DC/outputs/pfd1",
    "/systems/DC/outputs/mfd1",
    "/systems/DC/outputs/eicas-disp",
    "/systems/DC/outputs/eicas-disp",
    "/systems/DC/outputs/mfd2",
    "/systems/DC/outputs/pfd2"
];
var minimum_power = 22;

# add/override colors for our aircraft
EFIS.colors["green"] = [0.133,0.667,0.133];
EFIS.colors["blue"] = [0.133,0.133,1];

# create EFIS system and add power prop to en-/dis-able efis
var efis = EFIS.new(display_names, display_objects);
efis.setPowerProp("systems/DC/outputs/eicas-disp");
efis.setDUPowerProps(display_power_props, minimum_power);


# control panel selector prop 
var eicas_pageP = "instrumentation/eicas/page";
var ecp_targetN = props.globals.getNode("instrumentation/eicas/ecp-target",1);
ecp_targetN.setIntValue(3); #DU 3

# display selectors allow to re-route certain displays
# e.g. each MFD can be set to display the adjacent PFD or EICAS
# control values 0,1,2 1=default
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


var EFISSetup = func() {
    #-- add primary flight display --
    pfd1 = PFDCanvas.new("PFD1", svg_path~"PFD.svg",0);
    pfd2 = PFDCanvas.new("PFD2", svg_path~"PFD.svg",1);
    #-- add nav display on multi function display --
    # FIXME: replace dummy by ND
    mfd1 = EFISCanvas.new("MFD1");
    mfd2 = EFISCanvas.new("MFD2");

    var eicas_sources = []; 
    append(eicas_sources, EICASPriCanvas.new("PRI", svg_path~"eicas-pri.svg"));
    append(eicas_sources, EICASStatCanvas.new("STAT", svg_path~"eicas-stat.svg"));
    append(eicas_sources, EICASECSCanvas.new("ECS", svg_path~"eicas-ecs.svg"));
    append(eicas_sources, EICASHydraulicsCanvas.new("HYD", svg_path~"hydraulics.svg"));
    append(eicas_sources, EICASACCanvas.new("AC", svg_path~"eicas-ac.svg"));
    append(eicas_sources, EICASDCCanvas.new("DC", svg_path~"eicas-dc.svg"));
    append(eicas_sources, EICASFuelCanvas.new("FUEL", svg_path~"eicas-fuel.svg"));
    append(eicas_sources, EICASFctlCanvas.new("F-CTL", svg_path~"eicas-fctl.svg"));
    append(eicas_sources, EICASAIceCanvas.new("A-ICE", svg_path~"template.svg"));
    append(eicas_sources, EICASDoorsCanvas.new("Doors", svg_path~"eicas-doors.svg"));

    var pfd1_sid = efis.addSource(pfd1);
    var pfd2_sid = efis.addSource(pfd2);
    var mfd1_sid = efis.addSource(mfd1);
    var mfd2_sid = efis.addSource(mfd2);
    var eicas_source_ids = []; 
    foreach (var p; eicas_sources)
        append(eicas_source_ids, efis.addSource(p));

    var default_mapping = {
        PFD1: pfd1_sid, MFD1: mfd1_sid, 
        PFD2: pfd2_sid, MFD2: mfd2_sid,
        EICAS1: 4, EICAS2: 5, 
    };
    efis.setDefaultMapping(default_mapping);

    # mappings per src_selector
    var mappings = [ 
        [ {PFD1: -1, MFD1: pfd1_sid}, {PFD1: pfd1_sid, MFD1: mfd1_sid}, {PFD1: pfd1_sid, MFD1: eicas_source_ids[1] }],
        [ {PFD2: -1, MFD2: pfd2_sid}, {PFD2: pfd2_sid, MFD2: mfd2_sid}, {PFD2: pfd2_sid, MFD2: eicas_source_ids[1]} ],
        [ {EICAS1: eicas_source_ids[1], EICAS2: -1}, {EICAS1: eicas_source_ids[0], EICAS2: eicas_source_ids[1]}, {EICAS1: -1, EICAS2: eicas_source_ids[0]} ],
    ];
    efis.addSourceSelector(eicas_pageP, ecp_targetN, eicas_source_ids);

    #-- add display routing controls
    forindex (var i; src_selectors) {
        var prop_path = src_selector_base~src_selectors[i];
        # init to default=1 (3D model knobs in middle position)
        setprop(prop_path,1);
        efis.addDisplaySwapControl(prop_path, mappings[i], callbacks[i]);
    }
    
    #-- EICAS master warning/caution --
    # reset new-msg flags to trigger sounds again
    setlistener("instrumentation/eicas/msgsys1/new-msg-warning", func(n) {
        if (n.getValue()) {
            settimer(func { n.setIntValue(0); }, 1.7);
            setprop("instrumentation/eicas/master-warning",1);
        }
    },1);
    setlistener("instrumentation/eicas/msgsys1/new-msg-caution", func(n) {
        if (n.getValue()) {
            settimer(func { n.setIntValue(0); }, 0.6);
            setprop("instrumentation/eicas/master-caution",1);
        }
    },1);
};

var initL = setlistener("sim/signals/fdm-initialized", func(p)
{
    if (p.getValue()) {
        print("Init EFIS...");
        EFISSetup();
    }
}, 1, 0);
