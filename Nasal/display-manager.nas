# EFIS display manager

var screens = ["PFD1",  ];#"MFD1", "EICAS1", "EICAS2", "MFD2", "PFD2", ];

var displays = {};
var sources = {};

var noSource = canvas.new({"name" : "EFIS_Off",
			"size" : [256,64],
			"view" : [256,64],
			"mipmapping" : 1
		});
noSource.setColorBackground(0.01, 0.01, 0.01, 1).createGroup()
	.createChild("text", "label").setText("no source").setColor(1,1,1,1)
	.setFontSize(20, 0.9)          
	.setAlignment("center-center") 
	.setTranslation(10, 10); 

#noSource.addPlacement({parent: "EFIS_Screen", node : "MyScreen"});
	
var DisplayUnit = {
	new: func(screenObj, parentObj = nil) {
		var obj = {	parents : [DisplayUnit]};
		obj.canvas_screen = screenObj;
		obj.canvas_parent = parentObj;
		obj.source = nil;
		return obj;
	},
	
	setSource: func(s) {
		me.source = s;
		s.addPlacement({ parent : me.canvas_parent, node : me.canvas_screen });
		return me;
	},
};

var lines = [0,1,2,3,4,5,6];
var windows = {};
var i = 0;
print("-- display manager --");
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
