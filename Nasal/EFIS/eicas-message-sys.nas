#
# EICAS message system
#

# simple pager to get a sub vector of messages
var Pager = {
    new: func(page_length, prop_path) {
        var obj = {
            parents: [Pager],
            page_length: 1,
            last_result: 0,
            prop_path: prop_path,
            length: 0,
        };
        obj.setPageLength(page_length);
        return obj;
    },

    setPageLength: func(l) {
        me.page_length = int(l) or 1;
        setprop(me.prop_path~"/page_length", me.page_length);
        return me;
    },

    setPage: func(p) {
        me.current_page = int(p) or 0;
        setprop(me.prop_path~"/page", me.current_page);
        return me;
    },

    #lines: vector
    page: func(lines) {
        me.length = size(lines);
        me.current_page = getprop(me.prop_path~"/page");
        setprop(me.prop_path~"/pages", int(me.length / me.page_length) + 1);
        var start = me.page_length * me.current_page;
        if (me.length < start) {
            # default to first page if page is invalid
            me.setPage(0);
            start = 0;
        }
        var end = start + me.page_length - 1;
        if (end >= me.length)
            end = me.length-1;
        return lines[start:end];
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
};

var MessageSystem = {
    new: func(page_length, prop_path) {
        var obj = {
            parents: [MessageSystem],
            rootN : props.getNode(prop_path,1),
            pager: Pager.new(page_length, prop_path),
            classes: [],
            messages: [],       # vector of vector of messages
            active: [],         # lists of active message IDs per class
            msg_list: [],       # active message list (flat, sorted by class)
            first_upd: 0,       # for later optimisation: first changed line in msg_list
            update_flag: 1,
        };
        return obj;
    },

    addMessages: func(name, messages, pageable, color = nil) {
        var class = size(me.classes);
        me["new-msg"~class] = me.rootN.getNode("new-msg-"~name,1);
        me["new-msg"~class].setIntValue(0);
        append(me.classes, MessageClass.new(name, pageable).setColor(color));
        append(me.messages, messages);
        append(me.active, []);
        var eqL = func(i) {
            return func(n) {
                        if (n.getValue() == messages[i]["value"])
                            me.set(class, i, 1);
                        else me.set(class, i, 0);
                    }
            
        };
        var simpleL = func(i){
            return func(n) {
                        #if (n.getValue())
                            me.set(class, i, n.getValue());
                        #else me.set(class, i, 0);
                    }
        };
        forindex (var i; messages) {
            if (messages[i].prop) {
                #print("addMessage "~i~" t:"~messages[i].msg~" p:"~messages[i].prop);
                var prop = props.getNode(messages[i].prop);
                while (prop.getAttribute("alias")) {
                    prop = prop.getAliasTarget();
                }
                var L = nil;
                if (messages[i]["value"] != nil) L = eqL(i);
                else L = simpleL(i);
                setlistener(prop, L, 1, 0);
            }
        }
        return me;
    },

    _updateList: func() {
        me.msg_list = [];
        forindex (var class; me.active) {
            foreach (var id; me.active[class]) {
                append(me.msg_list, { text: me.messages[class][id].msg, color: me.classes[class].color});
            }
        }
        me.update_flag = 1;
    },

    _remove: func(class, msg) {
        var tmp = [];
        for (var i = 0; i < size(me.active[class]); i += 1) {
            if (me.active[class][i] != msg) {
                append(tmp, me.active[class][i]);
            }
        }
        return tmp;
    },

    _isActive: func(class, msg) {
        foreach (var m; me.active[class]) {
            if (m == msg) {
                return 1;
            }
        }
        return 0;
    },

    set: func(class, msg, visible) {
        if (class >= size(me.classes))
            return;
        var isActive = me._isActive(class, msg);
        if ((isActive and visible) or (!isActive and !visible))
            return;
        if (!me.update_flag)
            me.first_upd = me.pager.page_length;

        #add message at head of list
        if (visible) {
            me.active[class] = [msg]~me.active[class];
            #-- set new-msg flag in prop tree, e.g. to trigger sounds
            me["new-msg"~class].setIntValue(1);
        }
        else me.active[class] = me._remove(class, msg);
        var unchanged = 0;
        for (var i = 0; i < class; i += 1)
            unchanged += size(me.active[i]);
        if (me.first_upd > unchanged) me.first_upd = unchanged;
        print("set c:"~class~" m:"~msg~" v:"~visible~ " fu:"~me.first_upd);
        me._updateList();
    },

    needsUpdate: func {
        return me.update_flag;
    },

    getFirstUpdateIdx: func {
        return me.first_upd;
    },

    get: func {
        me.update_flag = 0;
        return me.msg_list;
    },

};