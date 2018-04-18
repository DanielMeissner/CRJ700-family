# EFIS for CRJ700 familiy
# EICAS status page
# Author:  jsb
# Created: 03/2018
#

var EICASStatCanvas = {
    MAX_MSG: 16,    #number of message lines

    new: func(name, file) {
        var obj = {
            parents: [EICASStatCanvas , EFISCanvas.new(name)],
            svg_keys: [
                "elevTrim", "elevTrimValue", "ailTrim", "rudderTrim",
                "gAPU", "rpm", "rpmPointer", "egt", "egtPointer",
                "doorMsg", "apuoff",
            ],
            msgsys: MessageSystem.new(me.MAX_MSG, "instrumentation/eicas/msgsys2"),
        };
        for (var i = 0; i < me.MAX_MSG; i += 1) append(obj.svg_keys, "message"~i);
        obj.loadsvg(file);
        obj.init();
        obj.addUpdateFunction(obj.update, 0.100);
        obj.addUpdateFunction(obj.updateMessages, 0.500);
        return obj;
    },

    init: func() {
        me._addApuL();
        me._addApuDoorL();
        me.clsAdvisory = me.msgsys.addMessages("advisory", EICASAdvisoryMessages, 0, efis.colors["green"]);
        me.clsStatus = me.msgsys.addMessages("status", EICASStatusMessages, 1);
    },

    _addApuL: func() {
        setlistener("controls/APU/electronic-control-unit", func(n) {
            if (n.getValue()) {
                me["gAPU"].show();
                me["apuoff"].hide();
            }
            else {
                me["gAPU"].hide();
                me["apuoff"].show();
            }
        }, 1);
    },

    _addApuDoorL: func() {
        setlistener("engines/engine[2]/door-msg", func(n) {
            var value = n.getValue();
            me["doorMsg"].setText(value);
            if (value == "----") me["doorMsg"].setColor(me.colors["amber"]);
            else me["doorMsg"].setColor(me.colors["white"]);
        }, 1);
    },

    getEng: func(idx, prop) {
        return (getprop("engines/engine["~idx~"]/"~prop) or 0);
    },

    getSurf: func(name) {
        return (getprop("/surface-positions/"~name) or 0);
    },
    
    updateMessages: func() {
        if (me.updateN == nil or !me.updateN.getValue()) return;
        if (!me.msgsys.needsUpdate())
            return;
        var messages = me.msgsys.getActiveMessages();
        for (var i = me.msgsys.getFirstUpdateIndex(); i < size(messages); i += 1) {
            me.updateTextElement("message"~i, messages[i].text, messages[i].color);
        }
        for (i; i < me.MAX_MSG; i += 1) {
            me.updateTextElement("message"~i, "");
        }
    },
    
    #-- listeners for rare events --
    update: func() {
        value = me.getEng(2, "rpm");
        me["rpm"].setText(sprintf("%3.0f", value));
        me["rpmPointer"].setRotation(value * 0.04189);
        value = me.getEng(2, "egt-degc");
        me["egt"].setText(sprintf("%3.0f", value));
        me["egtPointer"].setRotation(value * 0.003696);

        me["rudderTrim"].setRotation(-getprop("controls/flight/rudder-trim"));
        me["ailTrim"].setRotation(getprop("controls/flight/aileron-trim"));
        var trim = getprop("/instrumentation/eicas/hstab-trim");
        me["elevTrim"].setTranslation(0, 9.4785*trim);
        me["elevTrimValue"].setText(sprintf("%1.1f", trim));
    },
};
