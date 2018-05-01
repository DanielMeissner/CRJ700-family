#
# EFIS for CRJ700 family (Rockwell Collins Proline 4)
# EICAS messages as found in a manual. Messages for systems not simulated in 
# FG are left as comments for now.
#

var EICASAural = [
    "firebell",
    "cfg_trim",
    "apu",
    "anti_ice_duct",
    "brakes",
    "cfg_ap",
    "cfg_brakes",
    "cfg_flaps",
    "cfg_spoiler",
    "door",
    "nose_door",
    "smoke",
    "wing_overheat",
];

var EICASWarningMessages = [
    {msg: "AFCS MSG FAIL", prop: ""},
    {msg: "ANTI-ICE DUCT", prop: "", aural: "anti_ice_duct"},
    {msg: "APU FIRE", prop: "engines/engine[2]/on-fire", aural: "firebell"},
    {msg: "APU OVERSPEED", prop: "", aural: "apu"},
    {msg: "APU OVERTEMP", prop: "", aural: "apu"},
    {msg: "BRAKE OVHT", prop: "", aural: "brakes"},
#    {msg: "CABIN ALT", prop: ""},
    {msg: "CONFIG AILERON", prop: "instrumentation/eicas/warning/cfg-aileron", aural: "cfg_trim"},
    {msg: "CONFIG AP", prop: "instrumentation/eicas/warning/cfg-ap", aural: "cfg_ap"},
    {msg: "CONFIG FLAPS", prop: "instrumentation/eicas/warning/cfg-flaps", aural: "cfg_flaps"},
    {msg: "CONFIG RUDDER", prop: "instrumentation/eicas/warning/cfg-rudder", aural: "cfg_trim"},
    {msg: "CONFIG SPLRS", prop: "instrumentation/eicas/warning/cfg-spoilers", aural: "cfg_spoiler"},
    {msg: "CONFIG STAB", prop: "instrumentation/eicas/warning/cfg-stab", aural: "cfg_trim"},
#    {msg: "DIFF PRESS", prop: ""},
    {msg: "EMER PWR ONLY", prop: ""},
#    {msg: "ENGINE OVERSPD", prop: ""},
    {msg: "GEAR DISAGREE", prop: "", aural: "gear_disagree"},
    {msg: "L BLEED DUCT", prop: ""},
    {msg: "L COWL A/I DUCT", prop: "", aural: "anti_ice_duct"},
    {msg: "L ENG FIRE", prop: "engines/engine[0]/on-fire", aural: "firebell"},
    {msg: "L ENG OIL PRESS", prop: ""},
    {msg: "L REV DEPLOYED", prop: ""},
    {msg: "MLG BAY OVHT", prop: ""},
    {msg: "NOSE DOOR OPEN", prop: "", aural: "nose_door"},
    {msg: "PARKING BRAKE", prop: "instrumentation/eicas/warning/cfg-brakes", aural: "cfg_brakes"},
    {msg: "PASSENGER DOOR", prop: "sim/model/door-positions/pax-left/position-norm", aural: "door"},
    {msg: "R BLEED DUCT", prop: ""},
    {msg: "R COWL A/I DUCT", prop: "", aural: "anti_ice_duct"},
    {msg: "R ENG FIRE", prop: "engines/engine[1]/on-fire", aural: "firebell"},
    {msg: "R ENG OIL PRESS", prop: ""},
    {msg: "R REV DEPLOYED", prop: ""},
    # {msg: "SMOKE AFT CARGO", prop: "", aural: "smoke"},
    # {msg: "SMOKE AFT LAV", prop: ""},
    # {msg: "SMOKE FWD CARGO", prop: "", aural: "smoke"},
    # {msg: "SMOKE FWD LAV", prop: ""},
    {msg: "WING OVHT", prop: "", aural: "wing_overheat"},
];

var EICASCautionMessages = [
    {msg: "A/SKID INBD", prop: ""},
    {msg: "A/SKID OUTBD", prop: ""},
    {msg: "AC 1 AUTOXFER", prop: "systems/AC/system[1]/serviceable", conditions: {eq: 0}},
    {msg: "AC 2 AUTOXFER", prop: "systems/AC/system[2]/serviceable", conditions: {eq: 0}},
    {msg: "AC BUS 1", prop: "systems/AC/outputs/bus1", conditions: {lt: 100}},
    {msg: "AC BUS 2", prop: "systems/AC/outputs/bus2", conditions: {lt: 100}},
    {msg: "AC ESS BUS", prop: "systems/AC/outputs/bus3", conditions: {lt: 90}},
    {msg: "AC SERV BUS", prop: "systems/AC/outputs/bus4", conditions: {lt: 100}},
    {msg: "AFT CARGO DET", prop: ""},
    {msg: "AFT CARGO DOOR", prop: "sim/model/door-positions/aft-cargo/position-norm"},
    {msg: "AFT CARGO OVERHEAT", prop: ""},
    {msg: "AFT CARGO SQB 1", prop: ""},
    {msg: "AFT CARGO SQB 2", prop: ""},
#    {msg: "AFT SERVICE DOOR", prop: ""},
    {msg: "ALT LIMITER", prop: ""},
    {msg: "ANTI-ICE DUCT", prop: ""},
    {msg: "ANTI-ICE LOOP", prop: ""},
    {msg: "AP PITCH TRIM", prop: ""},
    {msg: "AP TRIM IS LWD", prop: ""},
    {msg: "AP TRIM IS ND", prop: ""},
    {msg: "AP TRIM IS NU", prop: ""},
    {msg: "AP TRIM IS RWD", prop: ""},
    {msg: "APR CMD SET", prop: ""},
    {msg: "APU BATT OFF", prop: ""},
    {msg: "APU BLEED ON", prop: ""},
    {msg: "APU BTL LO", prop: ""},
    {msg: "APU DOOR OPEN", prop: ""},
    {msg: "APU ECU FAIL", prop: ""},
    {msg: "APU FAULT", prop: ""},
    {msg: "APU FIRE FAIL", prop: ""},
    {msg: "APU GEN OFF", prop: "instrumentation/eicas/caution/apu-gen-off"},
    {msg: "APU GEN OVLD", prop: ""},
    {msg: "APU LCV CLSD", prop: ""},
    {msg: "APU LCV OPEN", prop: ""},
    {msg: "APU PUMP", prop: ""},
    {msg: "APU SOV FAIL", prop: ""},
    {msg: "APU SOV OPEN", prop: ""},
    {msg: "APU SQB", prop: ""},
    {msg: "AUTO PRESS", prop: ""},
    {msg: "AV BAY DOOR", prop: "sim/model/door-positions/av-bay/position-norm"},
    {msg: "AVIONICS FAN", prop: ""},
    {msg: "BATTERY BUS", prop: ""},
    {msg: "BLEED MISCONFIG", prop: ""},
    {msg: "BULK FUEL TEMP", prop: ""},
    {msg: "CABIN ALT", prop: ""},
    {msg: "CARGO BTL LO", prop: ""},
    {msg: "CTR CARGO DOOR", prop: "sim/model/door-positions/ctr-cargo/position-norm"},
    {msg: "DC BUS 1", prop: "systems/DC/outputs/bus1", conditions: {lt: 18}},
    {msg: "DC BUS 2", prop: "systems/DC/outputs/bus2", conditions: {lt: 18}},
    {msg: "DC EMER BUS", prop: ""},
    {msg: "DC ESS BUS", prop: "systems/DC/outputs/bus3", conditions: {lt: 18}},
    {msg: "DC SERV BUS", prop: "systems/DC/outputs/bus4", conditions: {lt: 18}},
    {msg: "DISPLAY COOL", prop: ""},
    {msg: "EFIS COMP INOP", prop: ""},
    {msg: "EFIS COMP MON", prop: ""},
    {msg: "ELEVATOR SPLIT", prop: ""},
    {msg: "ELT ON", prop: ""},
    {msg: "EMER DEPRESS", prop: ""},
    {msg: "EMER LTS OFF", prop: ""},
    {msg: "FIRE SYS FAULT", prop: ""},
    {msg: "FLAPS FAIL", prop: ""},
    {msg: "FLT SPLR DEPLOY", prop: ""},
    {msg: "FUEL CH 1/2 FAIL", prop: ""},
    {msg: "FUEL IMBALANCE", prop: "systems/fuel/imbalance"},
    {msg: "FWD CARGO SQB 1", prop: ""},
    {msg: "FWD CARGO SQB 2", prop: ""},
    {msg: "FWD SERVICE DOOR", prop: "sim/model/door-positions/pax-right/position-norm"},
    {msg: "GEN 1 OFF", prop: "controls/electric/engine[0]/generator", conditions: {eq: 0}},
    {msg: "GEN 1 OVLD", prop: ""},
    {msg: "GEN 2 OFF", prop: "controls/electric/engine[1]/generator", conditions: {eq: 0}},
    {msg: "GEN 2 OVLD", prop: ""},
    {msg: "GLD NOT ARMED", prop: ""},
    {msg: "GLD UNSAFE", prop: ""},
    {msg: "GND SPLR DEPLOY", prop: ""},
    {msg: "HYD 1 HI TEMP", prop: ""},
    {msg: "HYD 1 LO PRESS", prop: "systems/hydraulic/system[0]/value", conditions: {lt: 1800}},
    {msg: "HYD 2 HI TEMP", prop: ""},
    {msg: "HYD 2 LO PRESS", prop: "systems/hydraulic/system[1]/value", conditions: {lt: 1800}},
    {msg: "HYD 3 HI TEMP", prop: ""},
    {msg: "HYD 3 LO PRESS", prop: "systems/hydraulic/system[2]/value", conditions: {lt: 1800}},
    {msg: "HYD EDP 1A", prop: ""},
    {msg: "HYD EDP 2A", prop: ""},
    {msg: "HYD PUMP 1B", prop: ""},
    {msg: "HYD PUMP 2B", prop: ""},
    {msg: "HYD PUMP 3A", prop: ""},
    {msg: "HYD PUMP 3B", prop: ""},
    {msg: "HYD SOV 1 OPEN", prop: ""},
    {msg: "HYD SOV 2 OPEN", prop: ""},
    {msg: "IB BRAKE PRESS", prop: ""},
    {msg: "IB FLT SPLRS", prop: ""},
    {msg: "IB GND SPLRS", prop: ""},
    {msg: "IB SPOILERONS", prop: ""},
    {msg: "ICE DET FAIL", prop: ""},
    {msg: "ICE", prop: ""},
    {msg: "IDG 1", prop: "controls/electric/idg1-disc"},
    {msg: "IDG 2", prop: "controls/electric/idg2-disc"},
    {msg: "ISOL FAIL", prop: ""},
    {msg: "L AOA HEAT", prop: ""},
    {msg: "L BLEED DUCT", prop: ""},
    {msg: "L BLEED LOOP", prop: ""},
    {msg: "L COWL A/I OPEN", prop: ""},
    {msg: "L COWL A/I", prop: ""},
    {msg: "L COWL LOOP", prop: ""},
    {msg: "L ENG BLEED", prop: ""},
#    {msg: "L ENG DEGRADED", prop: ""},
    {msg: "L ENG FLAMEOUT", prop: ""},
    {msg: "L ENG SOV CLSD", prop: ""},
    {msg: "L ENG SOV FAIL", prop: ""},
    {msg: "L ENG SOV OPEN", prop: ""},
    {msg: "L ENG SQB", prop: ""},
#    {msg: "L ENG SRG CLSD", prop: ""},
#    {msg: "L ENG SRG OPEN", prop: ""},
    {msg: "L ENG TAT HEAT", prop: ""},
#    {msg: "L FADEC OVHT", prop: ""},
#    {msg: "L FADEC", prop: ""},
    {msg: "L FIRE FAIL", prop: ""},
#    {msg: "L FUEL FILTER", prop: ""},
    {msg: "L FUEL LO PRESS", prop: "systems/fuel/circuit[0]/powered", conditions: {eq: 0}},
#    {msg: "L FUEL LO TEMP", prop: ""},
    {msg: "L FUEL PUMP", prop: "systems/fuel/boost-pump[1]/failed"},
#    {msg: "L MAIN EJECTOR", prop: ""},
    {msg: "L PACK AUTOFAIL", prop: ""},
    {msg: "L PACK TEMP", prop: ""},
    {msg: "L PACK", prop: ""},
    {msg: "L PITOT HEAT", prop: ""},
    {msg: "L REV INOP", prop: ""},
    {msg: "L REV UNLOCKED", prop: ""},
    {msg: "L REV UNSAFE", prop: ""},
#    {msg: "L SCAV EJECTOR", prop: ""},
    {msg: "L START ABORT", prop: ""},
    {msg: "L START VALVE", prop: ""},
    {msg: "L STATIC HEAT", prop: ""},
    {msg: "L THROTTLE", prop: ""},
    {msg: "L WINDOW HEAT", prop: ""},
    {msg: "L WING A/I", prop: ""},
    {msg: "L WSHLD HEAT", prop: ""},
    {msg: "L XFER SOV", prop: ""},
    {msg: "LOW FUEL", prop: ""},
    {msg: "MACH TRIM", prop: ""},
    {msg: "MAIN BATT OFF", prop: ""},
    {msg: "MLG OVHT FAIL", prop: ""},
    {msg: "NO STRTR CUTOUT", prop: ""},
    {msg: "OB BRAKE PRESS", prop: ""},
    {msg: "OB FLT SPLRS", prop: ""},
    {msg: "OB GND SPLRS", prop: ""},
    {msg: "OB SPOILERONS", prop: ""},
    {msg: "OVBD COOL", prop: ""},
    {msg: "OXY LO PRESS", prop: ""},
    {msg: "PARK BRAKE SOV", prop: ""},
    {msg: "PASS OXY ON", prop: ""},
    {msg: "PAX DR LATCH", prop: ""},
    {msg: "PAX DR OUT HNDL", prop: ""},
    {msg: "PITCH FEEL", prop: ""},
    {msg: "PROX SYS CHAN", prop: ""},
    {msg: "PROX SYSTEM", prop: ""},
    {msg: "R AOA HEAT", prop: ""},
    {msg: "R BLEED DUCT", prop: ""},
    {msg: "R BLEED LOOP", prop: ""},
    {msg: "R COWL A/I OPEN", prop: ""},
    {msg: "R COWL A/I", prop: ""},
    {msg: "R COWL LOOP", prop: ""},
    {msg: "R ENG BLEED", prop: ""},
#    {msg: "R ENG DEGRADED", prop: ""},
#    {msg: "R ENG FLAMEOUT", prop: ""},
    {msg: "R ENG SOV CLSD", prop: ""},
    {msg: "R ENG SOV FAIL", prop: ""},
    {msg: "R ENG SOV OPEN", prop: ""},
    {msg: "R ENG SQB", prop: ""},
#    {msg: "R ENG SRG CLSD", prop: ""},
#    {msg: "R ENG SRG OPEN", prop: ""},
    {msg: "R ENG TAT HEAT", prop: ""},
#    {msg: "R FADEC OVHT", prop: ""},
#    {msg: "R FADEC", prop: ""},
    {msg: "R FIRE FAIL", prop: ""},
#    {msg: "R FUEL FILTER", prop: ""},
    {msg: "R FUEL LO PRESS", prop: "systems/fuel/circuit[1]/powered", conditions: {eq: 0}},
#    {msg: "R FUEL LO TEMP", prop: ""},
    {msg: "R FUEL PUMP", prop: "systems/fuel/boost-pump[1]/failed"},
#    {msg: "R MAIN EJECTOR", prop: ""},
    {msg: "R PACK AUTOFAIL", prop: ""},
    {msg: "R PACK TEMP", prop: ""},
    {msg: "R PACK", prop: ""},
    {msg: "R PITOT HEAT", prop: ""},
    {msg: "R REV INOP", prop: ""},
    {msg: "R REV UNLOCKED", prop: ""},
    {msg: "R REV UNSAFE", prop: ""},
#    {msg: "R SCAV EJECTOR", prop: ""},
    {msg: "R START ABORT", prop: ""},
    {msg: "R START VALVE", prop: ""},
    {msg: "R STATIC HEAT", prop: ""},
    {msg: "R THROTTLE", prop: ""},
    {msg: "R WINDOW HEAT", prop: ""},
    {msg: "R WING A/I", prop: ""},
    {msg: "R WSHLD HEAT", prop: ""},
    {msg: "R XFER SOV", prop: ""},
    {msg: "RUD LIMITER", prop: ""},
    {msg: "SLATS FAIL", prop: ""},
    {msg: "SPOILERONS ROLL", prop: ""},
    {msg: "STAB TRIM LIMIT", prop: ""},
    {msg: "STAB TRIM", prop: ""},
    {msg: "STALL FAIL", prop: ""},
    {msg: "STBY PITOT HEAT", prop: ""},
    {msg: "STEERING INOP", prop: ""},
    {msg: "TAT PROBE HEAT", prop: ""},
    {msg: "WD CARGO DET", prop: ""},
    {msg: "WING A/I SNSR", prop: ""},
    {msg: "WING XBLEED", prop: ""},
    {msg: "WOW INPUT", prop: ""},
    {msg: "WOW OUTPUT", prop: ""},
    {msg: "XFLOW PUMP", prop: ""},
    {msg: "YAW DAMPER", prop: ""},
];

if (substr(getprop("sim/aero"), 0,6) == "CRJ700") {
    EICASCautionMessages ~= [
        {msg: "L EMER DOOR", prop: "sim/model/door-positions/emer-l1/position-norm"},
        {msg: "R EMER DOOR", prop: "sim/model/door-positions/emer-r1/position-norm"},
    ];
}
else {
    EICASCautionMessages ~= [
        {msg: "FWD CARGO DOOR", prop: "sim/model/door-positions/fwd-cargo/position-norm"},
        {msg: "L FWD EMER DOOR", prop: "sim/model/door-positions/emer-l1/position-norm"},
        {msg: "L AFT EMER DOOR", prop: "sim/model/door-positions/emer-l2/position-norm"},
        {msg: "R FWD EMER DOOR", prop: "sim/model/door-positions/emer-r1/position-norm"},
        {msg: "R AFT EMER DOOR", prop: "sim/model/door-positions/emer-r2/position-norm"},
    ];
}

var EICASAdvisoryMessages = [
    {msg: "ADS HEAT TEST OK", prop: ""},
    {msg: "APU SOV CLSD", prop: ""},
    {msg: "COWL A/I ON", prop: ""},
    {msg: "CPLT ROLL CMD", prop: ""},
    {msg: "ENGS HI PWR SCHED", prop: ""},
    {msg: "FDR EVENT", prop: ""},
    {msg: "FIRE SYS OK", prop: ""},
    {msg: "FLAPS EMER", prop: ""},
    {msg: "FLT SPLR DEPLOY", prop: "surface"},
    {msg: "GLD MAN ARM", prop: "controls/flight/ground-lift-dump", conditions: {eq: 2}},
    {msg: "GND SPLR DEPLOY", prop: ""},
    {msg: "GRAV XFLOW OPEN", prop: "controls/fuel/gravity-xflow"},
    {msg: "HYD SOV 1 CLOSED", prop: "controls/hydraulic/system[0]/pump-a", conditions: {eq: 0}},
    {msg: "HYD SOV 2 CLOSED", prop: "controls/hydraulic/system[1]/pump-a", conditions: {eq: 0}},
    {msg: "ICE", prop: ""},
    {msg: "L AUTO IGNITION", prop: ""},
    {msg: "L COWL A/I ON", prop: "controls/anti-ice/engine[0]/inlet-heat"},
    {msg: "L ENG SOV CLSD", prop: ""},
    {msg: "L FUEL PUMP ON", prop: "systems/fuel/boost-pump[0]/running"},
    {msg: "L REV ARMED", prop: "controls/engines/engine[0]/reverser-armed"},
    {msg: "PARKING BRAKE ON", prop: "controls/gear/brake-parking"},
    {msg: "PLT ROLL CMD", prop: ""},
    {msg: "R AUTO IGNITION", prop: ""},
    {msg: "R COWL A/I ON", prop: "controls/anti-ice/engine[1]/inlet-heat"},
    {msg: "R ENG SOV CLSD", prop: ""},
    {msg: "R FUEL PUMP ON", prop: "systems/fuel/boost-pump[1]/running"},
    {msg: "R REV ARMED", prop: "controls/engines/engine[1]/reverser-armed"},
    {msg: "SPLR/STAB IN TEST", prop: ""},
    {msg: "T/O CONFIG OK", prop: "instrumentation/eicas/advisory/to-cfg-ok"},
    {msg: "WING A/I ON", prop: "controls/anti-ice/wing-heat"},
    {msg: "WING/COWL A/I ON", prop: ""},
];

var EICASStatusMessages = [
    {msg: "A/SKID FAULT", prop: ""},
    {msg: "AC 1 AUTOXFER OFF", prop: "controls/electric/auto-xfer1", conditions: {eq: 0}},
    {msg: "AC 2 AUTOXFER OFF", prop: "controls/electric/auto-xfer2", conditions: {eq: 0}},
    {msg: "AC ESS ALTN", prop: ""},
    {msg: "ADG AUTO FAIL", prop: ""},
    {msg: "ADG FAIL", prop: ""},
    {msg: "AFT CARGO SOV", prop: ""},
    {msg: "APU ALT LIMIT", prop: ""},
    {msg: "APU BATT CHGR", prop: ""},
    {msg: "APU FAULT", prop: ""},
    {msg: "APU IN BITE", prop: ""},
    {msg: "APU LCV OPEN", prop: ""},
    {msg: "APU SOV OPEN", prop: ""},
    {msg: "APU START", prop: "engines/engine[2]/starting"},
    {msg: "AUTO PRESS 1 FAIL", prop: ""},
    {msg: "AUTO PRESS 2 FAIL", prop: ""},
    {msg: "AUTO PRS 1/2 FAIL", prop: ""},
    {msg: "AUTO XFLOW INHIB", prop: ""},
    {msg: "BLEED CLOSED", prop: "systems/pneumatic/bleed-closed"},
    {msg: "BLEED MANUAL", prop: "controls/pneumatic/bleed-valve", conditions: { eq: 2}},
    {msg: "CABIN ALT WARN HI", prop: ""},
    {msg: "CABIN PRESS MAN", prop: ""},
    {msg: "CABIN TEMP MAN", prop: ""},
    {msg: "CAS MISCOMP", prop: ""},
    {msg: "CKPT TEMP MAN", prop: ""},
    {msg: "CONT IGNITION", prop: ""},
    {msg: "CPAM FAIL", prop: ""},
    {msg: "DC CROSS TIE CLSD", prop: "systems/DC/xtie"},
    {msg: "DC ESS TIE CLSD", prop: "systems/DC/esstie"},
    {msg: "DC MAIN TIE CLSD", prop: "systems/DC/maintie"},
    {msg: "DCU 1 AURAL INOP", prop: ""},
    {msg: "DCU 1 INOP", prop: ""},
    {msg: "DCU 2 AURAL INOP", prop: ""},
    {msg: "DCU 2 INOP", prop: ""},
    {msg: "DUCT MON FAULT", prop: ""},
    {msg: "EMER LTS ON", prop: ""},
    {msg: "ENG SYNC OFF", prop: ""},
    {msg: "ESS TRU 1 FAIL", prop: ""},
    {msg: "ESS TRU 2 FAIL", prop: ""},
    {msg: "ESS TRU 2 XFER", prop: ""},
    {msg: "FD 1 FAIL", prop: ""},
    {msg: "FD 2 FAIL", prop: ""},
    {msg: "FDR ACCEL FAIL", prop: ""},
    {msg: "FDR FAIL", prop: ""},
    {msg: "FIRE SYS FAULT", prop: ""},
    {msg: "FLAP FAULT", prop: ""},
    {msg: "FLAPS HALFSPEED", prop: ""},
    {msg: "FLUTTER DAMPER", prop: ""},
    {msg: "FUEL CH 1 FAIL", prop: ""},
    {msg: "FUEL CH 2 FAIL", prop: ""},
    {msg: "FUEL QTY DEGRADED", prop: ""},
    {msg: "GLD MAN DISARM", prop: ""},
    {msg: "GPWS FAIL", prop: ""},
    {msg: "GRAV XFLOW FAIL", prop: "systems/fuel/gravity-xflow/fail"},
    {msg: "GS CANCEL", prop: ""},
    {msg: "HGS FAIL", prop: ""},
    {msg: "HORN MUTED", prop: ""},
    {msg: "IAPS DEGRADED", prop: ""},
    {msg: "IAPS OVERTEMP", prop: ""},
    {msg: "IB FLT SPLR FAULT", prop: ""},
    {msg: "IB GND SPLR FAULT", prop: ""},
    {msg: "IB SPLRONS FAULT", prop: ""},
    {msg: "ICE DET 1 FAIL", prop: ""},
    {msg: "ICE DET 2 FAIL", prop: ""},
    {msg: "IDG 1 DISC", prop: ""},
    {msg: "IDG 2 DISC", prop: ""},
    {msg: "ISOL CLOSED", prop: ""},
    {msg: "ISOL OPEN", prop: "systems/pneumatic/sov4"},
    {msg: "ITT EXCEEDED C", prop: ""},
    {msg: "L AUTO XFLOW ON", prop: "systems/fuel/xflow-pump/running", conditions: {eq: -2}},
    {msg: "L COWL A/I DUCT", prop: ""},
    {msg: "L ENG BLEED CLSD", prop: "systems/pneumatic/sov0", conditions: {eq: 0}},
#    {msg: "L ENG BLEED SNSR", prop: ""},
    {msg: "L ENG SHUTDOWN", prop: ""},
    {msg: "L ENG SQB", prop: ""},
    {msg: "L ENGINE START", prop: "engines/engine[0]/starter"},
#    {msg: "L FADEC FAULT 1", prop: ""},
#    {msg: "L FADEC FAULT 2", prop: ""},
#    {msg: "L IGN A FAULT", prop: ""},
#    {msg: "L IGN B FAULT", prop: ""},
#    {msg: "L ITT EXCEED B", prop: ""},
#    {msg: "L ITT EXCEED B1", prop: ""},
#    {msg: "L ITT EXCEED C", prop: ""},
    {msg: "L MLG FAULT", prop: ""},
#    {msg: "L OIL LEVEL LO", prop: ""},
    {msg: "L PACK FAULT", prop: "systems/pneumatic/pressure-left", conditions: { eq: 0}},
    {msg: "L PACK OFF", prop: "controls/ECS/pack-l-off"},
#    {msg: "L RARV FAULT", prop: ""},
    {msg: "L REV FAULT", prop: ""},
    {msg: "L THROTTLE FAULT", prop: ""},
    {msg: "L VIB FAULT", prop: ""},
    {msg: "L XFLOW ON", prop: "systems/fuel/xflow-pump/running", conditions: {eq: -1}},
    {msg: "MAIN BATT CHGR", prop: ""},
    {msg: "MAN XFLOW", prop: "controls/fuel/xflow-manual"},
    {msg: "MDC FAULT", prop: ""},
    {msg: "MLG FAULT", prop: ""},
    {msg: "NO SMOKING", prop: "sim/model/lights/no-smoking-sign"},
    {msg: "OB FLT SPLR FAULT", prop: ""},
    {msg: "OB GND SPLR FAULT", prop: ""},
    {msg: "OB SPLRONS FAULT", prop: ""},
#    {msg: "OUTFLOW VLV OPEN", prop: ""},
#    {msg: "OVBD COOL FAIL", prop: ""},
#    {msg: "PITCH FEEL FAULT", prop: ""},
    {msg: "PROX SYS FAULT 1", prop: ""},
    {msg: "PROX SYS FAULT 2", prop: ""},
    {msg: "R AUTO XFLOW ON", prop: "systems/fuel/xflow-pump/running", conditions: {eq: 2}},
    {msg: "R COWL A/I DUCT", prop: ""},
    {msg: "R ENG BLEED CLSD", prop: "systems/pneumatic/sov1", conditions: {eq: 0}},
#    {msg: "R ENG BLEED SNSR", prop: ""},
    {msg: "R ENG SHUTDOWN", prop: ""},
    {msg: "R ENG SQB", prop: ""},
    {msg: "R ENGINE START", prop: "engines/engine[1]/starter"},
#    {msg: "R FADEC FAULT 1", prop: ""},
#    {msg: "R FADEC FAULT 2", prop: ""},
#    {msg: "R IGN A FAULT", prop: ""},
#    {msg: "R IGN B FAULT", prop: ""},
#    {msg: "R ITT EXCEEDED B", prop: ""},
#    {msg: "R ITT EXCEEDED B1", prop: ""},
    {msg: "R MLG FAULT", prop: ""},
#    {msg: "R OIL LEVEL LO", prop: ""},
    {msg: "R PACK FAULT", prop: "systems/pneumatic/pressure-right", conditions: { eq: 0}},
    {msg: "R PACK OFF", prop: "controls/ECS/pack-r-off"},
    #{msg: "R RARV FAULT", prop: ""},
    {msg: "R REV FAULT", prop: ""},
    {msg: "R THROTTLE FAULT", prop: ""},
    {msg: "R VIB FAULT", prop: ""},
    {msg: "R XFLOW ON", prop: "systems/fuel/xflow-pump/running", conditions: {eq: 1}},
    {msg: "RAM AIR OPEN", prop: "systems/pneumatic/sov3"},
    {msg: "RECIRC FAN FAULT", prop: ""},
    {msg: "RECIRC FAN OFF", prop: ""},
    {msg: "RUD LIMIT FAULT", prop: ""},
    {msg: "SEAT BELTS", prop: "sim/model/lights/seatbelt-sign"},
    {msg: "SLAT FAULT", prop: ""},
    {msg: "SLATS HALFSPEED", prop: ""},
    {msg: "SPEED REFS INDEP", prop: ""},
    {msg: "SPLR/STAB FAULT", prop: ""},
    {msg: "SSCU 1 FAULT", prop: ""},
    {msg: "SSCU 2 FAULT", prop: ""},
    {msg: "STAB CH 1 INOP", prop: ""},
    {msg: "STAB CH 2 INOP", prop: ""},
    {msg: "STAB FAULT", prop: ""},
    {msg: "STEERING DEGRADED", prop: ""},
    {msg: "TERRAIN FAIL", prop: ""},
    {msg: "TERRAIN NOT AVAIL", prop: ""},
    {msg: "TERRAIN OFF", prop: ""},
    {msg: "TRU 1 FAIL", prop: ""},
    {msg: "TRU 2 FAIL", prop: ""},
    {msg: "TRU FAN FAIL", prop: ""},
    {msg: "VHF 3 VOICE", prop: ""},
    {msg: "WINDSHEAR FAIL", prop: ""},
    {msg: "WING A/I FAULT", prop: ""},
    {msg: "WING XBLEED OPEN", prop: "systems/pneumatic/xbleed"},
    {msg: "YD 1 INOP", prop: ""},
    {msg: "YD 2 INOP", prop: ""},
    #for debug
    {msg: "Inhb. init TO", prop: "instrumentation/eicas/inhibits/initial-takeoff"},
    {msg: "Inhb. final TO", prop: "instrumentation/eicas/inhibits/final-takeoff"},
    {msg: "Inhb. landing", prop: "instrumentation/eicas/inhibits/landing"},
    
];
