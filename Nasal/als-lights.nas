#
# CRJ700 familiy - ALS landing lights
#
var LL_MIN_VOLTS = 24;

var update_als_landinglights = func () 
{
	var cv = getprop("sim/current-view/view-number");
	var tl = getprop("/systems/DC/outputs/taxi-lights");
	var ll = getprop("/systems/DC/outputs/landing-lights");
	var lr = getprop("/systems/DC/outputs/landing-lights[2]");
	var ln = getprop("/systems/DC/outputs/landing-lights[1]");
	
	if (cv == 0 or cv == view_indices[101]) {
		if (ll >= LL_MIN_VOLTS) setprop("/sim/rendering/als-secondary-lights/landing-light1-offset-deg", -4);
		elsif (ln >= LL_MIN_VOLTS) setprop("/sim/rendering/als-secondary-lights/landing-light1-offset-deg", -1);
		else setprop("/sim/rendering/als-secondary-lights/landing-light1-offset-deg", 0);
		if (lr >= LL_MIN_VOLTS) setprop("/sim/rendering/als-secondary-lights/landing-light2-offset-deg", 4);
		elsif (ln >= LL_MIN_VOLTS) setprop("/sim/rendering/als-secondary-lights/landing-light2-offset-deg", 1);
		else setprop("/sim/rendering/als-secondary-lights/landing-light2-offset-deg", 0);
		setprop("/sim/rendering/als-secondary-lights/use-landing-light", (ll >= LL_MIN_VOLTS or ln >= LL_MIN_VOLTS or tl >= LL_MIN_VOLTS));
		setprop("/sim/rendering/als-secondary-lights/use-alt-landing-light", (lr >= LL_MIN_VOLTS or ll >= LL_MIN_VOLTS and ln >= LL_MIN_VOLTS));
		
		#setprop("/sim/rendering/als-secondary-lights/use-landing-light", (ln >= LL_MIN_VOLTS));
	}
	else {
		setprop("/sim/rendering/als-secondary-lights/use-landing-light", 0);
		setprop("/sim/rendering/als-secondary-lights/use-alt-landing-light", 0);
	}
}

settimer(func {
	props.globals.initNode("/systems/DC/outputs/taxi-lights", 0, "DOUBLE");
	props.globals.initNode("/systems/DC/outputs/landing-lights", 0, "DOUBLE");
	props.globals.initNode("/systems/DC/outputs/landing-lights[1]", 0, "DOUBLE");
	props.globals.initNode("/systems/DC/outputs/landing-lights[2]", 0, "DOUBLE");

	setlistener("/systems/DC/outputs/taxi-lights", update_als_landinglights, 1, 0);
	setlistener("/systems/DC/outputs/landing-lights", update_als_landinglights, 0, 0);
	setlistener("/systems/DC/outputs/landing-lights[1]", update_als_landinglights, 0, 0);
	setlistener("/systems/DC/outputs/landing-lights[2]", update_als_landinglights, 0, 0);
	setlistener("/sim/current-view/view-number", update_als_landinglights, 0, 0);
}, 1);