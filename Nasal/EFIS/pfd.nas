#
# EFIS PFD (Primary Flight Display) for CRJ700 familiy
#


var PFDCanvas = {
    # index: {0,1,...} used to select instrumentation, assumes that all instruments
    # for a certain PDF instance share the same index number
    new: func(name, file, index) {
        var obj = {
            parents: [PFDCanvas , EFISCanvas.new(name)],
            index: index,
            svg_keys: [
                "horizon","rollpointer","rollpointer2","asi.tape","vmo.tape",
                "lowspeed.tape","predict.up","predict.down",
                "iasref.text","iasref.bug",
                "compass","vsi.needle","vsi.text","qnh.text","halfbank",
                "alt.tape","alt.1000",
                "preselected.meter","ind.meter","metricalt",
                "radioalt.text","radioalt.tape",
                "radioalt.number","radioalt","dh.text","dh.flag",
                "ADF1.flag","ADF1.needle","ADF2.flag","ADF2.needle",
                "FMS","FMS.text","FMS.crs.text","FMS.dst.text",
                "FMS.name.text","FMS.needle","FMS.deviation",
                "marker","marker.text","marker.box","mda.flag","mda.text",
                "selected_heading","selected_heading2","selected_heading.text",
                "preselected.1000","preselected.100","lat.act","vert.act",
                "ap.flag","vert.arm","lat.arm"
            ],
            getInstr: func(sys, prop, default=0) {
                    var p = getprop("instrumentation/"~sys~"["~me.index~"]/"~prop);
                    if (p != nil) return p;
                    else return default;
                }
        };
        obj.loadsvg(file);
        obj.init();
        obj.addUpdateFunction(obj.update, 0.033);
        obj.addUpdateFunction(obj.updateSlow, 0.1);
        return obj;
    },

    init: func(){
        me.h_trans = me["horizon"].createTransform();
        me.h_rot = me["horizon"].createTransform();
        setlistener("instrumentation/adc["~me.index~"]/reference/dh", me._dhL);
        setlistener("instrumentation/adc["~me.index~"]/reference/mda", me._mdaL);
    },

    _dhL: func(n) {
        me["dh.text"].setText(sprintf("%3d", n.getValue()));
    },

    _mdaL: func(n) {
        me["mda.text"].setText(sprintf("%4d", n.getValue()));
    },

    updateSlow: func() {
    },
    
    update: func() {
        #AI
        var pitch = me.getInstr("attitude-indicator", "indicated-pitch-deg");
        var roll =  me.getInstr("attitude-indicator", "indicated-roll-deg") * -D2R;

        me.h_trans.setTranslation(0,13.3 * pitch);
        me.h_rot.setRotation(roll, me["horizon"].getCenter());

        me["rollpointer"].setRotation(roll);
        me["rollpointer2"].setTranslation(math.round(me.getInstr("slip-skid-ball", "indicated-slip-skid",0))*5, 0);

        #ASI
        var asi = me.getInstr("airspeed-indicator", "indicated-speed-kt");
        me["asi.tape"].setTranslation(0,asi*6.55);
        var vmo = me.getInstr("pfd", "vmo",0);
        me["vmo.tape"].setTranslation(0,vmo*(-6.55));
        if(getprop("/gear/gear[1]/wow")==0){
            me["lowspeed.tape"].show();
            me["lowspeed.tape"].setTranslation(0,-120*6.55);
        }else{
            me["lowspeed.tape"].hide();
        }
        var predict = me.getInstr("pfd", "asi-predict-diff-damped");
        if(predict>0){
            me["predict.up"].show();
            if(predict<39){
                me["predict.up"].setTranslation(0,-predict*6.55);
            }else{
                me["predict.up"].setTranslation(0,-39*6.55);
            }
            me["predict.down"].hide();
        }else if(predict<0){
            me["predict.up"].hide();
            me["predict.down"].show();
            if(predict>-39){
                me["predict.down"].setTranslation(0,-predict*6.55);
            }else{
                me["predict.down"].setTranslation(0,39*6.55);
            }
        }else{
            me["predict.up"].hide();
            me["predict.down"].hide();
        }
        var speed_selected=getprop("/controls/autoflight/speed-select");
        me["iasref.text"].setText(sprintf("%d", speed_selected));
        var ias_ref_diff= me.getInstr("pfd","ias-ref-diff");
        if(ias_ref_diff>-40 and ias_ref_diff<40){
            me["iasref.bug"].setTranslation(0,-ias_ref_diff*6.55);
        }else if(ias_ref_diff>40){
            me["iasref.bug"].setTranslation(0,-40*6.55);
        }else if(ias_ref_diff<-40){
            me["iasref.bug"].setTranslation(0,40*6.55);
        }


        #Compass
        var mgh=getprop("/orientation/heading-deg");
        me["compass"].setRotation(mgh*(-D2R));
        var sh=getprop("/controls/autoflight/heading-select");
        if(sh>mgh){
            var shdiff=mgh-sh;
        }else{
            mgh=mgh-360;
            var shdiff=mgh-sh;
        }
        if(shdiff<138 and shdiff>-138){
            me["selected_heading"].show();
            me["selected_heading"].setRotation(sh*D2R);
            me["selected_heading2"].hide();
        }else{
            me["selected_heading"].hide();
            me["selected_heading2"].show();
            me["selected_heading2"].setRotation(sh*D2R);
        }

        me["selected_heading.text"].setText(sprintf("%3d",sh));

        #VSI
        var vsi = me.getInstr("pfd", "vsi");
        me["vsi.needle"].setRotation(vsi*D2R);
        var vsi_value = me.getInstr("vertical-speed-indicator","indicated-speed-fpm");
        if(vsi<1000 and vsi>-1000){
            me["vsi.text"].setText(sprintf("%.1f", vsi_value/1000));
        }else{
            me["vsi.text"].setText(sprintf("%2d", vsi_value/1000));
        }

        #Altimeter
        var altitude = me.getInstr("altimeter", "indicated-altitude-ft");
        me["alt.tape"].setTranslation(0,math.mod(altitude,1000)*1.22);
        me["alt.1000"].setText(sprintf("%2d", math.floor(altitude/1000)));
        me["qnh.text"].setText(sprintf("%d", me.getInstr("altimeter","setting-hpa")));
        var metric=getprop("/instrumentation/use-metric-altitude");
        var preselected_alt=getprop("/controls/autoflight/altitude-select");
        if(metric==1){
            me["metricalt"].show();
            me["preselected.meter"].setText(sprintf("%5d", preselected_alt*FT2M));
            me["ind.meter"].setText(sprintf("%5d", altitude*FT2M));
        }else{
            me["metricalt"].hide();
        }

        #Radio Altimeter
        var radioalt = getprop("/position/gear-agl-ft") or 0;
        var radio_altitude = me.getInstr("radar-altimeter", "radio-altitude-ft");
        var dh = me.getInstr("adc", "reference/dh");
        var wow1 = getprop("/gear/gear[1]/wow");
        if(radioalt<2500 and wow1==0){
            me["radioalt"].show();
            if(radioalt<1225){
                me["radioalt.tape"].show();
                me["radioalt.tape"].setTranslation(0,radio_altitude*0.934);
            }else{
                me["radioalt.tape"].hide();
            }
            me["radioalt.number"].setText(sprintf("%4d",radioalt));
            if(radioalt<dh){
                me["radioalt.text"].setColor(1,1,0);
                me["dh.flag"].show();
            }else{
                me["radioalt.text"].setColor(0,1,0);
                me["dh.flag"].hide();
            }
        }else{
            me["radioalt"].hide();
        }

        #MDA
        var mda = me.getInstr("adc", "reference/mda");
        me["mda.text"].setText(sprintf("%4d", mda));
        if(wow1==0 and altitude<mda){
            me["mda.flag"].show();
        }else{
            me["mda.flag"].hide();
        }

        #Autopilot
        #AP Flag
        if((getprop("/autopilot/internal/autoflight-engaged"))==1){
            me["ap.flag"].show();
        }else{
            me["ap.flag"].hide();
        }
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

        if((getprop("/controls/autoflight/half-bank"))==1){
            me["halfbank"].show();
        }else{
            me["halfbank"].hide();
        }

        me["preselected.1000"].setText(sprintf("%2d",math.floor(preselected_alt/1000)));
        me["preselected.100"].setText(sprintf("%03d",math.mod(preselected_alt, 1000)));

        #ADF
        #Flags
        var ADF1_inrange=getprop("/instrumentation/adf[0]/in-range");
        var ADF2_inrange=getprop("/instrumentation/adf[1]/in-range");
        if(ADF1_inrange){
            me["ADF1.flag"].show();
            me["ADF1.needle"].show();
            me["ADF1.needle"].setRotation((getprop("/instrumentation/adf[0]/indicated-bearing-deg"))*-D2R);
        }else{
            me["ADF1.flag"].hide();
            me["ADF1.needle"].hide();
        }
        if(ADF2_inrange){
            me["ADF2.flag"].show();
            me["ADF2.needle"].show();
            me["ADF2.needle"].setRotation((getprop("/instrumentation/adf[1]/indicated-bearing-deg"))*-D2R);
        }else{
            me["ADF2.flag"].hide();
            me["ADF2.needle"].hide();
        }

        #FMS 1/2, NAV 1/2
        var ns = getprop("/controls/autoflight/nav-source");
        if (ns == nil or ns < 0 or ns > 2) {
            me["FMS"].hide();
            me["FMS.needle"].hide();
        }
        else {
            me["FMS"].show();
            me["FMS.needle"].show();
            if (ns == 2){
                var bearing = getprop("autopilot/route-manager/wp[0]/bearing-deg") or 0;
                me["FMS.text"].setText("FMS1");
                me["FMS.crs.text"].setText(sprintf("%03d", bearing));
                me["FMS.dst.text"].setText(sprintf("%3.1f",getprop("autopilot/route-manager/wp[0]/dist") or 0));
                me["FMS.name.text"].setText(getprop("autopilot/route-manager/wp[0]/id") or "");
                me["FMS.needle"].setRotation(bearing*D2R);
                me["FMS.deviation"].setTranslation((getprop("/autopilot/route-manager/deviation-deg")or 0)*32.5,0);
            }
            else {
                me["FMS.text"].setText("NAV"~ns);
                me["FMS.crs.text"].setText(sprintf("%03d",getprop("instrumentation/nav["~ns~"]/radials/selected-deg")  or "XX"));
                me["FMS.dst.text"].setText(sprintf("%3.1f",getprop("instrumentation/nav["~ns~"]/distance-nm") or "XX"));
                me["FMS.name.text"].setText(getprop("instrumentation/nav["~ns~"]/nav-id") or "");
                me["FMS.needle"].setRotation((getprop("instrumentation/nav["~ns~"]/radials/selected-deg") or 0)*D2R);
                me["FMS.deviation"].setTranslation((getprop("/instrumentation/nav["~ns~"]/heading-needle-deflection-norm")or 0)*130,0);
            }
        }

        #Marker beacon
        var om=getprop("/instrumentation/marker-beacon/outer");
        var mm=getprop("/instrumentation/marker-beacon/middle");
        var im=getprop("/instrumentation/marker-beacon/inner");
        if(om==1){
            me["marker"].show();
            me["marker.text"].setText("OM");
            me["marker.box"].setColorFill(0,0,0,0);
            me["marker.text"].setColor(1,1,1);
        }else if(mm==1){
            me["marker"].show();
            me["marker.text"].setText("MM");
            me["marker.box"].setColorFill(0,0,0,0);
            me["marker.text"].setColor(1,1,1);
        }else if(im==1){
            me["marker"].show();
            me["marker.text"].setText("IM");
            me["marker.box"].setColorFill(1,1,1,1);
            me["marker.text"].setColor(0,0,0);
        }else{
            me["marker"].hide();
        }
    }, #end update()
};
