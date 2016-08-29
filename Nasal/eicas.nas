#
# CRJ700 family - EICAS message system
#

var Eicas_messages =
{
    messages: [],
    new: func(node, file, lines)
    {
        var m = { parents: [Eicas_messages] };
        m.lines = lines;
        m.node = aircraft.makeNode(node);
        m.file = file;
        m._line_number = 0;
        m._current_level = 0;
        m._current_message = 0;
        m._last_used_line = 0;
        m.reload();
        return m;
    },
    reload: func(file = nil)
    {
        me.file = file == nil ? me.file : file;
        me.root = io.read_properties(me.file);
        me.messages = [];
        var messages = me.root.getChildren("message");
        foreach (var message; messages)
        {
            var message_object =
            {
                line_id: nil,
                text: string.uc(message.getNode("text", 1).getValue()),
                color:
                [
                    message.getNode("color/red", 1).getValue(),
                    message.getNode("color/green", 1).getValue(),
                    message.getNode("color/blue", 1).getValue()
                ],
                condition: message.getNode("condition", 1)
            };
            var priority = message.getNode("priority", 1).getValue() or 0;
            while (size(me.messages) <= priority)
            {
                append(me.messages, []);
            }
            append(me.messages[priority], message_object);
        }
    },
    update: func
    {
        # loop through one message each frame
        # this makes updates less responsive, but doesn't kill the framerate like the old system

        # first, acquire the current message element
        var this_priority_level = me.messages[me._current_level];
        var this_message = this_priority_level[me._current_message];
	
        # decide whether or not to display it
        if (props.condition(this_message.condition))
        {
            this_message.line_id = me._line_number;
            me._display_line (me._line_number, this_message.text, this_message.color);
            me._line_number += 1;
        }
        else
        {
            this_message.line_id = nil;
        }

        # finally increment variables and ensure we're not out-of-range
        me._current_message += 1;
        if (me._current_message >= size(this_priority_level))
        {
            me._current_message = 0;
            me._current_level += 1;
            if (me._current_level >= size(me.messages))
            {
                me._current_level = 0;
                # FIXME: this is probably the bottleneck at this point
                var i = me._line_number;
                while (i <= me._last_used_line)
                {
                    me._hide_line(i);
                    i += 1;
                }
                me._last_used_line = me._line_number;
                me._line_number = 0;
            }
        }
    },
    _display_line: func(index, text, color)
    {
        if (index < me.lines)
        {
            var line = me.node.getChild("line", index, 1);
            line.getNode("message", 1).setValue(text);
            line.getNode("enabled", 1).setBoolValue(1);
            line.getNode("color-red-norm", 1).setDoubleValue(color[0]);
            line.getNode("color-green-norm", 1).setDoubleValue(color[1]);
            line.getNode("color-blue-norm", 1).setDoubleValue(color[2]);
            return 1;
        }
        else
        {
            return 0;
        }
    },
    _hide_line: func(index)
    {
        if (index < me.lines)
        {
            var line = me.node.getChild("line", index, 1);
            line.getNode("enabled", 1).setBoolValue(0);
            return 1;
        }
        else
        {
            return 0;
        }
    }
};
var eicas_messages_page1 = Eicas_messages.new("instrumentation/eicas-messages/page[0]", "Systems/CRJ700-EICAS-1.xml", 12);
var eicas_messages_page2 = Eicas_messages.new("instrumentation/eicas-messages/page[1]", "Systems/CRJ700-EICAS-2.xml", 13);