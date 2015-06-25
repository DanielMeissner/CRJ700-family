## Hydraulic system for CRJ700 family ##
## Author:		Henning Stahlke
## Created:		May 2015

# CRJ700 has three (3) independent hydraulic system, each with a nominal 
# pressure of 3000psi (206.85 bar). 
# System 1 and 2 are identical, each consisting of engine driven pump (EDP) 
# (1A, 2A), AC motor pump (ACMP) (1B, 2B), shut of valve (SOV) and other parts.
# Pumps 1B,2B each are powered by the AC bus of the other side engine 
# (1B - AC bus 2, 2B - AC bus 1) and are controlled via switches in OHP, where 
# AUTO will run the pump if flaps > 0 (and AC power avail).
# SOV can be closed manually via the corresponding OHP switchlights or by 
# pushing ENG FIRE PUSH switchlight. For simplification, the SOV switches will
# be used as switches for pumps 1A,2A which are EDP and thus have no AC switch.  
# System 3 consists of two ACMP (3A,3B) controlled by OHP switches. 3A shall
# run always so the switch has no auto position. 3B will run in auto pos, if 
# flaps > 0 and either IDG provides AC power. 3B will run irrespectively of 
# switch position if ADG (ram air turbine) is deployed.

# Rudder and elevators are driven by all three system.
# Sys 1 (left engine): left aileron, left reverser, 
#		outboard (spoilerons, flight spoilers, ground spoilers)
# Sys 2 (right engine): right aileron, right reverser, outboard brakes,
#		inboard (spoilerons, flight spoilers), assist landing gear actu.
# Sys 3 (AC): l+r aileron, landing gear, inboard brakes, inboard gnd.spoil.
#		nose wheel steering

## FG properties used
# controls/hydraulic/system[n]/
#		pump-a	OHP switches for SOV
#		pump-a, pump-b 	OHP switches for pumps (0, 1, 2 = auto)
# systems/hydraulic/system[0..2]/* 
#		system state
# systems/hydraulic/outputs/*	
#		computed effective hyd. states, this props enable hydraulics
#


var HydraulicPump = {
	new: func (bus, name, input, input_min, input_max) {
		var obj = {
			parents: [HydraulicPump, EnergyConv.new(bus, name, 3000, 1800, input, input_min, input_max) ],
			sw2: 0,
		};
		return obj;
	},
	
	#switch 0,1,2 : off, on, automatic mode (use 2nd switch input)
	#store signal for pump automatic mode, called by hydraulic system class
	set_switch2:  func (on) {
		me.sw2 = (on > 0) ? 1 : 0;
		print("sw:"~me.switch);
		if (me.switch == 2) me._update_output();
		return me.sw2;
	},	

	_update_output: func {
		#print("Hydraulic.update");
		me.input = me.inputN.getValue();
		me.serviceable = me.serviceableN.getValue();
		if (me.input == nil) me.input = 0;
		if (me.serviceable and (me.switch == 1 or me.switch == 2 and me.sw2)) {
			me.output = me.output_nominal;
			if (me.input_min > 0 and me.input < me.input_min) {
				me.output = me.output_nominal * me.input / me.input_min;
				me.output = int(me.output / 100) * 100;		
			}
			if (me.input_max > 0 and me.input > me.input_max) {
				me.output = me.output_nominal * me.input / me.input_max;
				me.output = int(me.output / 100) * 100;		
			}
		}
		else me.output = 0;
		me.outputN.setValue(me.output);		
		me.isRunning();
		return me.output;
	},
};

var HydraulicSystem = {
	new: func (sysid, pa, pb, outputs_multi, outputs ) {
		
		obj = { parents : [HydraulicSystem, EnergyBus.new("hydraulic", sysid, outputs, 1, 1800)],
			outputs_multi: [],
		};		
		foreach (elem; outputs_multi) {
			append(obj.outputs_multi, props.globals.getNode(obj.outputs_path~elem, 1));
		}
		obj.addInput(pa[0], pa[1], pa[2], pa[3]);
		obj.addInput(pb[0], pb[1], pb[2], pb[3]);
		setlistener("controls/flight/flaps", func(v) {obj._auto_pump(v);}, 1, 1);
		#setlistener("systems/hydraulic/system["~sysid~"]", func {obj.update();}, 1, 2);
		return obj;
	},
	
	addInput: func() {
		var s = HydraulicPump.new(me, arg[0], arg[1], arg[2], arg[3]);
		if (s != nil) append(me.inputs, s);
	},
	
	#set on-off-signal for pump B automatic mode
	_auto_pump: func (v) {
		print(me.type~"."~me.index~".auto");
		me.inputs[1].set_switch2(v.getBoolValue());
	},

	update: func {
		me.parents[1].update();
		if (me.serviceable) {			
			foreach (out; me.outputs_multi) {
				var hsys = props.globals.getNode("systems/hydraulic").getChildren("system");
				var pmax = 0;
				foreach (s; hsys) {
					p = s.getNode("value").getValue();
					pmax = (p > pmax) ? p : pmax;
				}
				if (pmax >= me.output_min)
					out.setValue(1);
				else out.setValue(0);
			}		
		}
	},
};

print("Creating hydraulic system ...");
#ACMPs have to be fixed after rework of electrical system
var hydraulics = [ 
	HydraulicSystem.new(0,
		["pump-a", "/engines/engine[0]/rpm", 21, 93],
		["pump-b", "/systems/electrical/right-bus", 24, 28],
		["rudder", "elevator", "aileron"],
		["ob-spoileron", "ob-flight-spoiler", "ob-ground-spoiler", "left-reverser"],
	),
	HydraulicSystem.new(1,
		["pump-a", "/engines/engine[1]/rpm", 21, 93],
		["pump-b", "/systems/electrical/left-bus", 24, 28],
		["rudder", "elevator", "aileron"], 
		["ib-spoileron", "ib-flight-spoiler", "landing-gear-alt", "right-reverser", "ob-brakes"],
	),
	HydraulicSystem.new(2,
		["pump-a", "/systems/electrical/right-bus", 24, 28],
		["pump-b", "/systems/electrical/left-bus", 24, 28],
		["rudder", "elevator", "aileron"], 
		["ib-ground-spoiler", "landing-gear", "nwsteering", "ib-brakes"],
	),
];

foreach (h; hydraulics)
	h.init();

print("Hydraulic done.");
