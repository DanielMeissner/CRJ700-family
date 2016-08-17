#
# EFIS PFD (Primary Flight Display) for CRJ700 familiy
#


var PFDCanvas = {
    # index: {0,1,...} used to select instrumentation, assumes that all instruments
    # for a certain PDF instance share the same index number
    new: func(name, file, index) {
        var obj = {
            parents: [PFDCanvas , EFISCanvas.new(name)],
            debug: 0,
            index: index,
            svg_keys: [
                "horizon","rollpointer","rollpointer2","asi.tape","vmo.tape",
                "lowspeed.tape","predict.up","predict.down",
                "iasref.text","iasref.bug",
                "vrefs", "v1.ref", "vr.ref", "v2.ref", "vt.ref",
                "compass","vsi.needle","vsi.text","qnh.text","halfbank",
                "alt.tape","alt1000",
                "preselected.meter","ind.meter","metricalt",
                "radioalt.text","radioalt.tape",
                "radioalt",
                "dh.text","dh.flag",
                "FD", "GS",
                "ADF1.flag","ADF1.needle","ADF2.flag","ADF2.needle",
                "navsrc","nav.src","nav.crs","nav.dist", "nav.distunit",
                "nav.name","FMS.needle","FMS.deviation",
                "marker","marker.text","marker.box",
                "mda.flag","mda.text",
                "selected_heading","selected_heading2","selected_heading.text",
                "preselected.1000","preselected.100","lat.act","vert.act",
                "ap.flag","vert.arm","lat.arm"
            ],
            getInstr: func(sys, prop, default=0) {
                    var p = getprop("instrumentation/"~sys~"["~me.index~"]/"~prop);
                    if (p != nil) return p;
                    else return default;
            },
            
            #for animations
            asi_scale: 6.38,
            alt_scale: 1.188,
            alt_scroll_range: 100,
            
            #cached properties
            dmeh: 0,
            gs: 0,
            dh: 300,
            mda: 3000,
            nav_source: 0,
            alt_sel: 0,
            hdg_sel: 0,
            use_metric: 0,
            wow1: 0,
        };
        obj.alt_scroll_stop = obj.alt_scroll_range * 0.25;
        obj.alt_scroll_start = obj.alt_scroll_range * 0.75;
        obj.loadsvg(file);
        obj.init();
        obj.addUpdateFunction(obj.update, 0.033);
        obj.addUpdateFunction(obj.updateSlow, 0.1);
        return obj;
    },

    init: func(){
        if (me.debug) {
            setprop("/devel/test1",0);
            setprop("/devel/test2",0);
        }
        me.h_trans = me["horizon"].createTransform();
        me.h_rot = me["horizon"].createTransform();
        me["rollpointer"].setCenter(me["horizon"].getCenter());
        var mbtxt = me["marker.text"];
        mbtxt.setDrawMode(mbtxt.TEXT + mbtxt.BOUNDINGBOX);
        me["alt1000"].setText(sprintf("%2d\n%2d", 1, 0));
        var tmp = me["alt1000"].getBoundingBox();
        me.alt1000_scale = 0.5*(tmp[3]-tmp[1]) / me.alt_scroll_range;
        
        me.setlistener("/autopilot/internal/autoflight-engaged", me._showHideL("ap.flag"));
        setlistener("/controls/autoflight/altitude-select", func(n) { me.alt_sel = n.getValue() or 0; }, 1);
        setlistener("/controls/autoflight/nav-source", func(n) { me.nav_source = n.getValue() or 0; }, 1);
        setlistener("/controls/autoflight/heading-select", me._hdgSelL(), 1);
        setlistener("/controls/autoflight/speed-select", func(n) { me.updateTextElement("iasref.text", sprintf("%d", n.getValue() or 0)); }, 1);
        setlistener("/controls/autoflight/flight-director/engage", me._showHideL("FD"), 1);
        setlistener("/controls/autoflight/half-bank", me._showHideL("halfbank"), 1);
        setlistener("/gear/gear[1]/wow", func(n) { me.wow1 = n.getValue() or 0; }, 1);
        setlistener("/instrumentation/adc["~me.index~"]/reference/dh", me._dhL(), 1);
        setlistener("/instrumentation/adc["~me.index~"]/reference/mda", me._mdaL(), 1);
        setlistener("/instrumentation/adf[0]/in-range", me._showHideL(["ADF1.flag", "ADF1.needle"]), 1);
        setlistener("/instrumentation/adf[1]/in-range", me._showHideL(["ADF2.flag", "ADF2.needle"]), 1);
        setlistener("/instrumentation/dme["~me.index~"]/hold", me._dmehL(), 1);
        setlistener("/instrumentation/marker-beacon/outer", me._markerBeaconL(0), 1);
        setlistener("/instrumentation/marker-beacon/middle", me._markerBeaconL(1), 1);
        setlistener("/instrumentation/marker-beacon/inner", me._markerBeaconL(2), 1);
        setlistener("/instrumentation/adc/reference/v1", func(n) { me.updateTextElement("v1.ref", sprintf("V1 %3d", n.getValue() or 0)); }, 1);
        setlistener("/instrumentation/adc/reference/vr", func(n) { me.updateTextElement("vr.ref", sprintf("VR %3d", n.getValue() or 0)); }, 1);
        setlistener("/instrumentation/adc/reference/v2", func(n) { me.updateTextElement("v2.ref", sprintf("V2 %3d", n.getValue() or 0)); }, 1);
        setlistener("/instrumentation/adc/reference/vt", func(n) { me.updateTextElement("vt.ref", sprintf("VT %3d", n.getValue() or 0)); }, 1);
        setlistener("/instrumentation/altimeter/setting-hpa", func(n) { me.updateTextElement("qnh.text", sprintf("%d", n.getValue() or 0)); }, 1);

        setlistener("/instrumentation/use-metric-altitude", func(n) { me.use_metric = n.getValue() or 0; }, 1);
        setlistener("/instrumentation/nav["~me.index~"]/gs-in-range", me._showHideL("GS"), 1);
        setlistener("/instrumentation/nav["~me.index~"]/gs-in-range", func(n) { me.gs = n.getValue() or 0;}, 1);

    },

    getNavSrcColor: func(navsrc) {
        if (navsrc == 0) return me.colors["green"];
        if (navsrc == 1) return me.colors["green"];
        if (navsrc == 2) return me.colors["white"];
    },
        
    _dhL: func {
        return func(n) {
            me.dh = n.getValue() or 0;
            me.updateTextElement("dh.text", sprintf("%3.0f", me.dh));
        };
    },

    _mdaL: func {
        return func(n) {
            me.mda = n.getValue() or 0;
            me.updateTextElement("mda.text", sprintf("%4d", me.mda));
        };
    },

    _dmehL: func {
        return func(n) {
            me.dmeh = n.getValue() or 0;
            if (me.dmeh) {
                me.updateTextElement("nav.distunit", "H", me.colors["yellow"]);
                me["nav.name"].hide();
            }
            else {
                var ns = getprop("/controls/autoflight/nav-source");
                me.updateTextElement("nav.distunit", "NM", me.getNavSrcColor(ns));
                me["nav.name"].show();
            }
        };
    },

    _markerBeaconL: func(type) {
        var beacons = [
            {text: "OM", color: me.colors["cyan"]},
            {text: "MM", color: me.colors["yellow"]},
            {text: "IM", color: me.colors["white"]},
        ];
        return func(n) {
            var value = n.getValue() or 0;
            if (value) me["marker"].show();
            else me["marker"].hide();
            me["marker.text"].setText(beacons[type].text);
            me["marker.text"].setColor(beacons[type].color);
        };
    },

    _hdgSelL: func() {
        return func(n) { 
            me.hdg_sel = n.getValue() or 0; 
            me["selected_heading.text"].setText(sprintf("%3d",me.hdg_sel));
        };
    },
    
    updateSlow: func() {
    },
    
    update: func() {
        #AI
        var pitch = me.getInstr("attitude-indicator", "indicated-pitch-deg");
        var roll =  me.getInstr("attitude-indicator", "indicated-roll-deg") * -D2R;
        if (me.debug) {
            pitch = getprop("/devel/test1");
            roll = getprop("/devel/test2")*-D2R;
        }
        me.h_trans.setTranslation(0, 12.8 * pitch);
        me.h_rot.setRotation(roll, me["horizon"].getCenter());

        me["rollpointer"].setRotation(roll);
        me["rollpointer2"].setTranslation(math.round(me.getInstr("slip-skid-ball", "indicated-slip-skid",0))*5, 0);

        #airspeed indicator
        var asi = me.getInstr("airspeed-indicator", "indicated-speed-kt");        
        var a = (asi < 40) ? 40 : asi;
        
        me["asi.tape"].setTranslation(0, a * me.asi_scale);
        me["vrefs"].setTranslation(0, a * me.asi_scale);
        var vmo = me.getInstr("pfd", "vmo",0);
        me["vmo.tape"].setTranslation(0,vmo*(-me.asi_scale));
        
        #fixme
        if(getprop("/gear/gear[1]/wow")==0){
            me["lowspeed.tape"].show();
            me["lowspeed.tape"].setTranslation(0,-120*me.asi_scale);
        }else{
            me["lowspeed.tape"].hide();
        }
        
        if (asi > 40) {
            var predict = me.getInstr("pfd", "asi-predict-diff-damped");
            if(predict>0){
                me["predict.up"].show();
                if(predict<39){
                    me["predict.up"].setTranslation(0,-predict*me.asi_scale);
                }else{
                    me["predict.up"].setTranslation(0,-39*me.asi_scale);
                }
                me["predict.down"].hide();
            }
            else if(predict<0){
                me["predict.up"].hide();
                me["predict.down"].show();
                if(predict>-39){
                    me["predict.down"].setTranslation(0,-predict*me.asi_scale);
                }else{
                    me["predict.down"].setTranslation(0,39*me.asi_scale);
                }
            }
        }
        else {
            me["predict.up"].hide();
            me["predict.down"].hide();
        }
        var ias_ref_diff = me.getInstr("pfd","ias-ref-diff");
        # if(ias_ref_diff>-40 and ias_ref_diff<40){
            me["iasref.bug"].setTranslation(0,-ias_ref_diff*me.asi_scale);
        # }else if(ias_ref_diff>40){
            # me["iasref.bug"].setTranslation(0,-40*me.asi_scale);
        # }else if(ias_ref_diff<-40){
            # me["iasref.bug"].setTranslation(0,40*me.asi_scale);
        # }


        #Compass
        var mgh=getprop("/orientation/heading-deg");
        me["compass"].setRotation(-mgh * D2R);
        
        var shdiff = mgh - me.hdg_sel;
        if(me.hdg_sel < mgh) shdiff -= 360;

        if(shdiff < 138 and shdiff > -138){
            me["selected_heading"].show();
            me["selected_heading"].setRotation(me.hdg_sel*D2R);
            me["selected_heading2"].hide();
        }else{
            me["selected_heading"].hide();
            me["selected_heading2"].show();
            me["selected_heading2"].setRotation(me.hdg_sel*D2R);
        }

        #VSI
        var vsi = me.getInstr("pfd", "vsi");
        me["vsi.needle"].setRotation(vsi*D2R);
        var vsi_value = me.getInstr("vertical-speed-indicator","indicated-speed-fpm");
        if(vsi < 1000 and vsi > -1000){
            me["vsi.text"].setText(sprintf("%.1f", vsi_value/1000));
        }else{
            me["vsi.text"].setText(sprintf("%2d", vsi_value/1000));
        }

        #Altimeter
        var altitude = me.getInstr("altimeter", "indicated-altitude-ft");
        me["alt.tape"].setTranslation(0, math.mod(altitude, 1000) * me.alt_scale);
        
        #scroll the altitude thousands near 1000-boundary
        var alt_k = math.floor((altitude - me.alt_scroll_stop)/1000);
        me["alt1000"].setText(sprintf("%2d\n%2d", alt_k + 1, alt_k));
        var scroll = math.mod((altitude + me.alt_scroll_start), 1000);
        if (scroll <= me.alt_scroll_range) {
            me["alt1000"].setTranslation(0, me.alt1000_scale * scroll);
        } 
        else {
            me["alt1000"].setTranslation(0,0);
        }
        
        if(me.use_metric){
            me["metricalt"].show();
            me["preselected.meter"].setText(sprintf("%5d", me.alt_sel*FT2M));
            me["ind.meter"].setText(sprintf("%5d", altitude*FT2M));
        }else{
            me["metricalt"].hide();
        }

        #Radio Altimeter
        #var radioalt = getprop("/position/gear-agl-ft") or 0;
        var radio_altitude = me.getInstr("radar-altimeter", "radar-altitude-ft");
        if (radio_altitude < 2500 and me.wow1 == 0) {
            me["radioalt"].show();
            if(radio_altitude < 1225){
                me["radioalt.tape"].show();
                me["radioalt.tape"].setTranslation(0,radio_altitude*0.934);
            }
            else me["radioalt.tape"].hide();

            if(radio_altitude < me.dh){
                me.updateTextElement("radioalt.text", sprintf("%4d FT", radio_altitude) , me.colors["yellow"]);
                me["dh.flag"].show();
            }
            else {
                me.updateTextElement("radioalt.text", sprintf("%4d FT", radio_altitude) , me.colors["green"]);
                me["dh.flag"].hide();
            }
        }
        else me["radioalt"].hide();

        #MDA
        if(me.wow1 == 0 and altitude < me.mda){
            me["mda.flag"].show();
        }
        else me["mda.flag"].hide();

        #Autopilot
        
        #Lateral modes
        var latmode=getprop("/autopilot/annunciators/lat-capture") or "";
        #var navmode=getprop("/controls/autoflight/nav-source") or 99;
        #if(latmode==1){
        #	me["lat.act"].setText("HDG");
        #}else if(latmode==2){
        #	me["lat.act"].setText("LNAV");
        #}else if(latmode==3){
        #	if(navmode==0){
        #		me["lat.act"].setText("LOC1");
        #	}else if(navmode==1){
        #		me["lat.act"].setText("LOC2");
        #	}else{
        #		me["lat.act"].setText("INVLD");
        #	}
        #}
        me["lat.act"].setText(latmode);
        #ALTS annun
        var vertarmed=getprop("/autopilot/annunciators/vert-armed");
        if(vertarmed==1){
            me["vert.arm"].setText("ALTS");
        }else{
            me["vert.arm"].setText("");
        }
        #LAT armed
        var latarmed=getprop("/autopilot/annunciators/lat-armed");
        var nav0hasgs=getprop("/instrumentation/nav[0]/has-gs");
        var nav1hasgs=getprop("/instrumentation/nav[1]/has-gs");
        if(latarmed=="VOR1" and nav0hasgs){
            me["lat.arm"].setText("LOC1");
        }else if(latarmed=="VOR1" and !nav0hasgs){
            me["lat.arm"].setText("VOR1");
        }else if(latarmed=="VOR2" and nav1hasgs){
            me["lat.arm"].setText("LOC2");
        }else if(latarmed=="VOR2" and !nav1hasgs){
            me["lat.arm"].setText("VOR2");
        }else{
            me["lat.arm"].setText("");
        }

        #Vert modes
        var vertmode=getprop("/autopilot/annunciators/vert-capture") or "";
        #if(vertmode==1){
        #	me["vert.act"].setText("ALT");
        #}else if(vertmode==2){
        #	me["vert.act"].setText("V/S");
        #}else if(vertmode==4){
        #	#me["vert.act"].setText(sprint("%3d","IAS "~speed_selected));
        #}
        me["vert.act"].setText(vertmode);

        me["preselected.1000"].setText(sprintf("%2d",math.floor(me.alt_sel/1000)));
        me["preselected.100"].setText(sprintf("%03d",math.mod(me.alt_sel, 1000)));

        #ADF
        #Flags
        # var ADF1_inrange=getprop("/instrumentation/adf[0]/in-range");
        # var ADF2_inrange=getprop("/instrumentation/adf[1]/in-range");
        # if(ADF1_inrange){
            # me["ADF1.flag"].show();
            # me["ADF1.needle"].show();
        # }else{
            # me["ADF1.flag"].hide();
            # me["ADF1.needle"].hide();
        # }
        # if(ADF2_inrange){
            # me["ADF2.flag"].show();
            # me["ADF2.needle"].show();
        # }else{
            # me["ADF2.flag"].hide();
            # me["ADF2.needle"].hide();
        # }
        me["ADF1.needle"].setRotation((getprop("/instrumentation/adf[0]/indicated-bearing-deg"))*-D2R);
        me["ADF2.needle"].setRotation((getprop("/instrumentation/adf[1]/indicated-bearing-deg"))*-D2R);

        #FMS 1/2, NAV 1/2
        var ns = me.nav_source;
        if (ns == nil or ns < 0 or ns > 2) {
            me["navsrc"].hide();
            me["FMS.needle"].hide();
        }
        else {
            me["navsrc"].show();
            me["FMS.needle"].show();
            var color = me.getNavSrcColor(ns);
            if (!me.dmeh) me["nav.distunit"].setColor(color);
            if (ns == 2){
                var bearing = getprop("autopilot/route-manager/wp[0]/bearing-deg") or 0;
                me.updateTextElement("nav.src", "FMS1", color);
                me.updateTextElement("nav.crs", sprintf("CRS %03d", bearing), color);
                me.updateTextElement("nav.dist", sprintf("%3.1f",getprop("autopilot/route-manager/wp[0]/dist") or 0), color);
                me.updateTextElement("nav.name", getprop("autopilot/route-manager/wp[0]/id") or "", color);
                me["FMS.needle"].setRotation(bearing*D2R);
                me["FMS.deviation"].setTranslation((getprop("/autopilot/route-manager/deviation-deg")or 0)*32.5,0);
            }
            else {
                me.updateTextElement("nav.src", "NAV"~(ns+1), color);
                me.updateTextElement("nav.crs", sprintf("CRS %03d",getprop("instrumentation/nav["~ns~"]/radials/selected-deg")  or "XX"), color);
                me.updateTextElement("nav.dist", sprintf("%3.1f",getprop("instrumentation/dme["~ns~"]/indicated-distance-nm") or "XX"), color);
                me.updateTextElement("nav.name", getprop("instrumentation/nav["~ns~"]/nav-id") or "", color);
                me["FMS.needle"].setRotation((getprop("instrumentation/nav["~ns~"]/radials/selected-deg") or 0)*D2R);
                me["FMS.deviation"].setTranslation((getprop("/instrumentation/nav["~ns~"]/heading-needle-deflection-norm")or 0)*130,0);
            }
        }
        if (me.gs) {
            var y = getprop("instrumentation/nav[0]/gs-needle-deflection-deg");
            me["GS"].setTranslation(0,y*98.381/5);
        }

    }, #end update()
};
