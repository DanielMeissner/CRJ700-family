#
# EICAS message system
# inital version by jsb 5/2018
#

# simple pager to get a sub vector of messages
var Pager = {
    new: func(page_length, prop_path) {
        var obj = {
            parents: [Pager],
            page_length: 1,
            lengthN: props.getNode(prop_path~"/page_length",1),
            current_page: 1,
            pageN: props.getNode(prop_path~"/page",1),
            last_result: 0,
            prop_path: prop_path,
            line_count: 0,
            changed: 0,
        };
        obj.setPageLength(page_length);
        obj.setPage(1);
        setlistener(obj.pageN.getPath(), func(n) {
            obj.current_page = n.getValue();
            obj.changed = 1;
        });
        return obj;
    },

    isChanged: func() {
        var c = me.changed;
        me.changed = 0;
        return c;
    },
    
    setPageLength: func(n) {
        me.page_length = int(n) or 1;
        me.lengthN.setIntValue(me.page_length);
        return me;
    },

    setPage: func(p) {
        me.current_page = int(p) or 1;
        me.pageN.setIntValue(me.current_page);
        return me;
    },
    
    getPageCount: func() { 
        return me.page_count; 
    },
    
    getCurrentPage: func() {
        return me.current_page;
    },

    # lines: vector of all messages
    # returns lines of current page
    page: func(lines) {
        me.line_count = size(lines);
        me.current_page = getprop(me.prop_path~"/page") or 1;
        me.page_count = int(me.line_count / me.page_length) + 1;
        setprop(me.prop_path~"/pages", me.page_count);
        var start = me.page_length * (me.current_page-1);
        if (me.line_count < start) {
            # default to first page if page is invalid
            me.setPage(1);
            start = 0;
        }
        var end = start + me.page_length - 1;
        if (end >= me.line_count)
            end = me.line_count-1;
        #print("page l:"~me.line_count~" start "~start~" end "~end);
        if (start <= end)
            return lines[start:end];
        else return[];
    },
};

var MessageClass = {
    #static, increased by new()
    prio: 0,

    new: func(name, pageable, prio=0) {
        var obj = {
            parents: [MessageClass],
            name: name,
            pageable: pageable,
            disabled: 0,
            color: [1,1,1],
        };
        if (prio)
            obj.prio = prio;
        else {
            obj.prio = me.prio;
            me.prio += 1;
        }
        return obj;
    },

    setColor: func(color) {
        if (color != nil)
            me.color = color;
        return me;
    },

    setPrio: func(prio) {
        me.prio = int(prio);
        return me;
    },
    
    enable: func { me.disabled = 0; },
    disable: func(bool = 1) { me.disabled = bool; },
    disabled: func { return me.disabled; },
};

var Message = {
    msg: "",
    prop: "",
    aural: "",
    condition: {
        eq: "equals",
        ne: "not equals",
        lt: "less than",
        gt: "greater than",
    },
};

var MessageSystem = {
    PAGING: 1,
    NO_PAGING: 0,
    
    new: func(page_length, prop_path) {
        var obj = {
            parents: [MessageSystem],
            rootN : props.getNode(prop_path,1),
            page_length: page_length,
            pager: Pager.new(page_length, prop_path),
            classes: [],
            messages: [],       # vector of vector of messages
            sounds: nil,
            active_messages: [],    # lists of active message IDs per class
            active_aurals: {},      # list of active aural warnings ((un-)set if corresponding message is (in-)active)
            msg_list: [],           # active message list (flat, sorted by class)
            first_changed_line: 0,  # for later optimisation: first changed line in msg_list
            changed: 1,
            powerN: nil,
            canvas_group: nil,
            page_indicator: nil,
            page_indicator_format: "Page %2d/%2d",
        };
        return obj;
    },

    setRootNode: func(n) {
        me.rootN = n;
    },
    
    # set power prop and add listener to start/stop all registered update functions
    setPowerProp: func(p) {
        me.powerN = props.getNode(p,1);
        setlistener(me.powerN, func(n) {
            if (n.getValue()) {
                me.init();
            }
        }, 1, 0);
    },
    
    # classname:  identifier for msg class
    # pageable:     true = normal paging, false = msg class is sticky at top of list
    # returns class id (int)
    addMessageClass: func(classname, pageable, color = nil) {
        var class = size(me.classes);
        me["new-msg"~class] = me.rootN.getNode("new-msg-"~classname,1);
        me["new-msg"~class].setIntValue(0);
        append(me.classes, MessageClass.new(classname, pageable).setColor(color));
        append(me.active_messages, []);
        return class;
    },
    
    # addMessages creates a new msg class and add messages to it
    # class:     class id returned by addMessageClass();
    # messages:  vector of message objects (hashes)
    addMessages: func(class, messages) {
        forindex (var i; messages) {
            messages[i]["_class"] = class;            
        }
        append(me.messages, messages);
        
        var simpleL = func(i){
            return func(n) {
                var val = n.getValue() or 0;
                me.setMessage(class, i, val);
            }
        };
        var eqL = func(i) {
            return func(n) {
                var val = n.getValue() or 0;
                if (val == messages[i].condition["eq"])
                    me.setMessage(class, i, 1);
                else me.setMessage(class, i, 0);
            }
        };
        var neL = func(i) {
            return func(n) {
                var val = n.getValue() or 0;
                if (val != messages[i].condition["ne"])
                    me.setMessage(class, i, 1);
                else me.setMessage(class, i, 0);
            }
        };
        var ltL = func(i) {
            return func(n) {
                var val = n.getValue() or 0;
                if (val  < messages[i].condition["lt"])
                    me.setMessage(class, i, 1);
                else me.setMessage(class, i, 0);
            }
        };
        var gtL = func(i) {
            return func(n) {
                var val = n.getValue() or 0;
                if (val > messages[i].condition["gt"])
                    me.setMessage(class, i, 1);
                else me.setMessage(class, i, 0);
            }
        };
        forindex (var i; messages) {
            if (messages[i].prop) {
                #print("addMessage "~i~" t:"~messages[i].msg~" p:"~messages[i].prop);
                var prop = props.getNode(messages[i].prop,1);
                # listeners won't work on aliases so find real node
                while (prop.getAttribute("alias")) {
                    prop = prop.getAliasTarget();
                }
                if (messages[i]["condition"] != nil) {
                    var c = messages[i]["condition"];
                    if (c["eq"] != nil) setlistener(prop, eqL(i), 1, 0);
                    if (c["ne"] != nil) setlistener(prop, eqL(i), 1, 0);
                    if (c["lt"] != nil) setlistener(prop, ltL(i), 1, 0);
                    if (c["gt"] != nil) setlistener(prop, gtL(i), 1, 0);
                }
                else setlistener(prop, simpleL(i), 1, 0);
            }
        }
    },
    
    addAuralAlerts: func(alert_hash) {
        if (typeof(alert_hash) != "hash") {
            print("MessageSystem.addAuralAlerts: parameter must be a hash!");
            return;
        }
        me.sounds = alert_hash;
        foreach (var k; keys(alert_hash))
            me.active_aurals[k] = 0;
    },

    _updateList: func() {
        me.msg_list = [];
        forindex (var class; me.active_messages) {
            foreach (var id; me.active_messages[class]) {
                if (!me.classes[class].disabled and !me.messages[class][id]["disabled"])
                    append(me.msg_list, { text: me.messages[class][id].msg, color: me.classes[class].color});
            }
        }
    },

    _remove: func(class, msg) {
        var tmp = [];
        for (var i = 0; i < size(me.active_messages[class]); i += 1) {
            if (me.active_messages[class][i] != msg) {
                append(tmp, me.active_messages[class][i]);
            }
        }
        return tmp;
    },

    _isActive: func(class, msg) {
        foreach (var m; me.active_messages[class]) {
            if (m == msg) {
                return 1;
            }
        }
        return 0;
    },

    # (de-)activate message 
    setMessage: func(class, msg_id, visible=1) {
        if (class >= size(me.classes))
            return;
        var isActive = me._isActive(class, msg_id);
        if ((isActive and visible) or (!isActive and !visible)) {
            return;
        }
        if (!me.changed)
            me.first_changed_line = me.pager.page_length;

        #add message at head of list, 2DO: priority handling?!
        var aural = me.messages[class][msg_id]["aural"];
        if (visible) {
            me.active_messages[class] = [msg_id]~me.active_messages[class];
            # set new-msg flag in prop tree, e.g. to trigger sounds; 
            # may be reset from outside this class so we can trigger again here
            me["new-msg"~class].setIntValue(1);
            if (aural != nil) {
                me.active_aurals[aural] = 1;
                me.aural(aural);
            }
        }
        else {
            me.active_messages[class] = me._remove(class, msg_id);
            if (aural != nil) me.active_aurals[aural] = 0;
            # clear new-msg flag if last message is gone
            if (size(me.active_messages[class]) == 0)
                me["new-msg"~class].setIntValue(-1);
        }
        
        var unchanged = 0;
        for (var i = 0; i < class; i += 1)
            unchanged += size(me.active_messages[i]);
        if (me.first_changed_line > unchanged) me.first_changed_line = unchanged;
        #print("set c:"~class~" m:"~msg_id~" v:"~visible~ " 1upd:"~me.first_changed_line);
        me._updateList();
        me.changed = 1;
    },

    aural: func(aural) {
        if (me.sounds != nil and aural != nil ) {
            #print("EICAS Message aural: "~aural);
            if (me.active_aurals[aural])
                fgcommand("play-audio-sample", props.Node.new(me.sounds[aural]));
        }
    },
    
    #-- check for active messages and set new-msg flags. 
    #   can be used on power up to trigger new-msg events.
    init: func {
        forindex (var class; me.active_messages) {
            if (size(me.active_messages[class])) {
                me["new-msg"~class].setIntValue(1);
            }
        }
        me.changed = 1;
        #hack for aural alerts
        print("Enabling EICAS Message System sounds: /sim/sound/efis/enabled = 1");
        setprop("/sim/sound/efis/enabled", 1);
    },
    
    hasUpdate: func {
        return me.changed;
    },

    getPageSize: func { 
        return me.page_length; 
    },
    
    getFirstUpdateIndex: func {
        return me.first_changed_line;
    },

    getActiveMessages: func {
        me.changed = 0;
        return me.msg_list;
    },

    #find message text, return id
    getMessageID: func(class, msgtext) {
        forindex (var id; me.messages[class]) {
            if (me.messages[class][id].msg == msgtext) 
                return id;
        }
        return -1;
    },
    
    # inhibit message id (or all messages in class if no id is given)
    disableMessage: func(class, id = nil) {
        if (id != nil) 
            me.messages[class][id]["disabled"] = 1;
        else forindex (var i; me.messages[class])
            me.messages[class][i]["disabled"] = 1;
    },

    # re-enable message id (or all messages in class if no id is given)
    enableMessage: func(class, id = nil) {
        if (id != nil)
            me.messages[class][id]["disabled"] = 0;
        else forindex (var i; me.messages[class])
            me.messages[class][i]["disabled"] = 0;
    },
    
    #
    #-- following methods are for message output on a canvas --
    #
    
    # pass an existing canvas group to create text elements on
    setCanvasGroup: func(group) {
        me.canvas_group = group;
    },
    
    # create text elements for message lines in canvas group; call setCanvasGroup() first!
    createCanvasTextLines: func(left, top, lineheight, fontsize) {
        me.lines = me.canvas_group.createChildren("text", me.page_length);
        forindex (var i; me.lines) {
            var l = me.lines[i];
            l.setAlignment("left-top").setTranslation(left, top + i*lineheight);
            l.setFont("LiberationFonts/LiberationSans-Regular.ttf");
            l.setFontSize(fontsize);
            l.enableUpdate();
            l.updateText("");
        }
    },
    
    # create text element for "page i of N"; call setCanvasGroup() first!
    createPageIndicator: func(left, top, fontsize, formatstring = nil) {
        me.page_indicator = me.canvas_group.createChild("text");
        me.page_indicator.setAlignment("left-top").setTranslation(left, top);
        me.page_indicator.setFont("LiberationFonts/LiberationSans-Regular.ttf");
        me.page_indicator.setFontSize(fontsize);
        me.page_indicator.enableUpdate();
        me.page_indicator.updateText("");
        if (formatstring != nil)
            me.page_indicator_format = formatstring;
        return me.page_indicator;
    },
    
    # call this regularly to update text lines on canvas
    updateCanvas: func() {
        if (!(me.pager.isChanged() or me.changed))
            return;
        me.changed = 0;
        var messages = me.pager.page(me.msg_list);
        for (var i = me.first_changed_line; i < size(messages); i += 1) {
            me.lines[i].updateText(messages[i].text);
            if (messages[i].color != nil)
                me.lines[i].setColor(messages[i].color);
        }
        for (i; i < me.page_length; i += 1) {
            me.lines[i].updateText("");
        }
        if (me.page_indicator != nil) {
            if (me.pager.getPageCount() > 1) {
                me.page_indicator.show();
                me.updatePageIndicator(me.pager.getCurrentPage(), me.pager.getPageCount());
            }
            else me.page_indicator.hide();
        }
    },

    updatePageIndicator: func(current, total) {
        #print(current~"/"~total);
        me.page_indicator.updateText(sprintf(me.page_indicator_format, current, total));
    },
};