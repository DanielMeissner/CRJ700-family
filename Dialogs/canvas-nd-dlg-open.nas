#
# Nasal code for dialog canvas-nd.xml (open)
# this file is included via io.include() in the XML
#

var getWidgetTemplate = func(root, identifier) {
	var target = globals.gui.findElementByName(root,  identifier );
	if(target == nil) die("Target node not found for identifier:"~identifier);
	return target;
}

var populateSelectWidget = func(widget, label, attribute, index, property, values)  {
	# make up an identifier to be used for the object-name (fgcommands dialog-apply and -update)
	# format: ND[x].attribute
	var objectName = "ND["~index~"]."~attribute; # attribute~index;
	
	widget.getNode("label",1).setValue(label);
	widget.getNode("name",1).setValue(objectName);
	widget.getNode("binding/object-name",1).setValue(objectName);
	
	var list = nil;
	
	if (typeof(values) == 'hash') {
		# we have a hash with key/value pairs
		list = keys(values);
		print("FIXME: key/value mapping missing for value hash map:", attribute);
		# widget.getNode("property",1).setValue(property~"value-to-key");				
	}
	else {
		list = values;
		widget.getNode("property",1).setValue(property);
	}
	# for vectors with values
	forindex(var c; list) {
		widget.getChild("value",c,1).setValue(list[c]);
	}
};

###
# locate required templates
var WidgetTemplates = {};

# populate a hash with templates that we will need later on
foreach(var t; ['canvas-placeholder', 'canvas-mfd', 'checkbox-template']) {
	WidgetTemplates[t]=getWidgetTemplate(root:cmdarg(), identifier: t);
	#print("Dump:\n");
	#props.dump( WidgetTemplates[t] );
}

var initialize_nd = func(index) {
	var my_canvas = canvas.get( cmdarg() );
	
	# FIXME: use the proper root here
	var myND = setupND(mfd_root: "/instrumentation/efis["~index~"]", my_canvas: my_canvas, index:index);
};

# not currently used, but could be used for validating the mfd/styles files before using them
var errors = [];

# NOTE: this requires changes to navdisplay.mfd (see the wiki article for details)
# call(func[, args[, me[, locals[, error]]]);
# call(
# actually include the navdisplay.mfd file so that this gets reloaded whenever the dialog is closed/reopened
io.include('Nasal/canvas/map/navdisplay.mfd');
#, nil, closure(initialize_nd), var errors=[]);

if (size(errors)) {
	canvas.MessageBox.critical(
	"$FG_ROOT/Nasal/canvas/map/navdisplay.mfd",
	"Error reloading navdisplay.mfd and/or navdisplay.styles:\n",
	cb = nil,
	buttons = canvas.MessageBox.Ok
	);
	# TODO: close dialog on error
}

var ND = NavDisplay;

# TODO: this info could also be added to the GUI dialog
print("Number of ND Styles found:", size(keys(NDStyles)));


# http://wiki.flightgear.org/Canvas_ND_Framework#Cockpit_switches
var resolve_adf_vor_mode = func(num) {
	if (num == -1) return 'ADF';
	if (num == 1) return 'VOR';
	return 'OFF';
}

var getSwitchesForND = func(index) {
	var style_property = "/fgcanvas/nd["~index~"]/selected-style";
	var style = getprop(style_property);
	
	# make sure that the style  is exposed via the property tree
	if (style == nil) {
		print("Ooops, style was undefined, using default");
		style = 'Boeing'; # our default style
		setprop(style_property, style);
	}
	
	var switches = NDStyles[style].default_switches;
	# print("Using ND style/switches:", style);
	
	if (switches == nil) print("Unknown ND style: ", style);
	return switches;
}

var setupND = func(mfd_root, my_canvas, index) {
	var style = getprop("/fgcanvas/nd["~index~"]/selected-style") or 'Boeing';
	
	# set up a  new ND instance, under mfd_root and use the
	# myCockpit_switches hash to map ND specific control properties
	var switches = getSwitchesForND(index);
	var myND= ND.new(mfd_root, switches, style);
	var group = my_canvas.createGroup();
	myND.newMFD(group, my_canvas);
	myND.update();
	# store the new instance for later cleanup
	var handle = "ND["~index~"]";
	MFDInstances[handle] = myND; 
	# return {nd: myND, property_root: mfd_root};
} # setupND()

# this determines how many NDs will be added to the dialog, and where their controls live in the property tree
# TODO: support default style per ND, different dimensions ?
# persistent config/profiles
var canvas_areas = [
	{name: 'captain.ND', property_root:'/instrumentation/efis[0]',},
	{name: 'copilot.ND', property_root:'/instrumentation/efis[1]',},
	# you can add more entries below, for example: 
	#{name: 'engineer.ND', property_root:'/instrumentation/efis[2]',},
];

# procedurally add one canvas for each ND to be shown (requires less code/maintenance, aka DRY)

var totalNDs = getprop("/fgcanvas/total-nd-instances") or 1;

# var index=0;
for(var index=0; index < totalNDs; index+=1) {
	var c = {name: 'ND #'~index, property_root:'/instrumentation/efis['~index~']'};
	print("Setting up ND:", c.name);
	# foreach(var c; canvas_areas) { #}
	var switches = getSwitchesForND(index);
	
	# next, create a new symbol named canvasWidget, create child in target, with the index specified (idx)
	var canvasWidget = WidgetTemplates['canvas-placeholder'].getChild("frame", index, 1);
	# now, copy our template stuff into the new tree 
	props.copy(WidgetTemplates['canvas-mfd'].getChild("frame"), canvasWidget);
	
	# customize the subtree and override a few things
	canvasWidget.getNode("text/label",1).setValue(c.name);
	canvasWidget.getNode("canvas/name").setValue(c.name);
	
	var r = getprop("/fgcanvas/nd-resolution") or 420;
	
	canvasWidget.getNode("canvas/pref-width").setValue(r);
	canvasWidget.getNode("canvas/pref-height").setValue(r);
	
	# instantiate and populate combo widgets
	var selectWidgets= [
		{node: 'combo', label:'Style', attribute: 'Style', property:'/fgcanvas/nd['~index~']/selected-style', values:keys(NDStyles) },
		{node: 'group[1]/combo[2]', label:'nm', attribute: 'RangeNm', property:c.property_root~switches['toggle_range'].path, values:switches['toggle_range'].values },
		{node: 'group[1]/combo', label:'', attribute: 'ndMode', property:c.property_root~switches['toggle_display_mode'].path, values:switches['toggle_display_mode'].values },
	];
	
	foreach(var s; selectWidgets) {
		populateSelectWidget(canvasWidget.getNode(s.node), s.label, s.attribute, index, s.property, s.values);  
	}
	
	# add a single line of code to each canvas/nasal section setting up the ND instance 
	canvasWidget.getNode("canvas/nasal/load").setValue("initialize_nd(index:"~index~");");
	
	# --------------- This whole thing can be simplified by putting it into the previous foreach loop
	# TODO: this should be using VOR/OFF/ADF instead of the numerical values ...
	var leftVORADFSelector = canvasWidget.getNode("group[1]/combo[1]");
	
	# FIXME: shouldn't hard-code this here ...
	var keyValueMap = [1,0,-1]; # switches['toggle_lh_vor_adf'].values; 
	
	# FIXME look up the proper lh/rh values here
	# and use the proper root 
	populateSelectWidget(leftVORADFSelector, "", "VOR/ADF(l)", index, "/instrumentation/efis["~index~"]/inputs/lh-vor-adf", keyValueMap);  
	var rightVORADFSelector = canvasWidget.getNode("group[1]/combo[3]");
	populateSelectWidget(rightVORADFSelector, "", "VOR/ADF(r)",index, "/instrumentation/efis["~index~"]/inputs/rh-vor-adf", keyValueMap);  
	# ---------------
	
	var checkboxArea = getWidgetTemplate(root:canvasWidget, identifier:'mfd-controls'); 
	var cb_index = 0;
	# add checkboxes for each boolean switch
	
	# HACK: get rid of this, it's just an alias for now
	var myCockpit_switches = getSwitchesForND(index); # FIXME: should be using index instead of 0
	foreach(var s; keys(myCockpit_switches)) {
		var switch = s;
		if (myCockpit_switches[switch].type != 'BOOL') continue; # skip non boolean switches for now 
		
		var checkbox = checkboxArea.getChild("checkbox",cb_index, 1);
		props.copy(WidgetTemplates['checkbox-template'].getChild("checkbox"), checkbox);
		cb_index+=1;
		checkbox.getNode("label").setValue(myCockpit_switches[switch].legend);
		checkbox.getNode("property").setValue(c.property_root ~ myCockpit_switches[switch].path);
		# FIXME: use notation ND[x].attribute.toggle
		var object_name = "checkbox["~cb_index~"]("~myCockpit_switches[switch].legend~")";
		checkbox.getNode("name",1).setValue(object_name);
		checkbox.getNode("binding/object-name",1).setValue(object_name);
		
	} # add checkboxes for each boolean ND switch
	
	# index += 1;
} # foreach ND instance

