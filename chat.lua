



ChatModes = {
    SelfParty = 5,
    OtherParty = 13,

    TellOutgoing = 4,
    TellIncoming = 12,

    LsOutgoing = 6,
    LsIncoming = 14,

    Ls2Outgoing = 213,
    Ls2Incoming = 214
}

-- Supported modes, indexed by their id
ChatModesById = {}
for key, value in pairs(ChatModes) do
    ChatModesById[value] = key
end

AUTOTRANSLATE_START   = string.char(239, 39)
AUTOTRANSLATE_END     = string.char(239, 40)

AUTOTRANSLATE_START_GSUB  = AUTOTRANSLATE_START
AUTOTRANSLATE_END_GSUB    = string.char(239) .. '%('   -- Character 40 is a control character for gsub (open paren), so it needs special handling

ChatUI    = require('chat-ui')
ChatLog   = require('chat-log')

Chat = {
    commands = {},
    ui = nil,
    log = nil,
    type_mappings = {
        ['linkshell'] = 'linkshell',
        ['l'] = 'linkshell',
        ['ls'] = 'linkshell',
        
        ['linkshell2'] = 'linkshell2',
        ['l2'] = 'linkshell2',
        ['ls2'] = 'linkshell2',

        ['party'] = 'party',
        ['p'] = 'party',

        ['tell'] = 'tell',
        ['t'] = 'tell',
    }
}

function Chat:init()
    local player = windower.ffxi.get_player()
    if player then
        self.ui     = self.ui or ChatUI.new()
        self.log    = self.log or ChatLog.new()
    end
end

function Chat:isInitialized()
    return self.ui and self.log
end

function Chat:append(mode, text)
    if self:isInitialized() then
        local sanitized_text = text
        
        -- We'll strip off the control characters used to mark autotranslate
        sanitized_text = string.gsub(text, AUTOTRANSLATE_START_GSUB, '{')
        sanitized_text = string.gsub(sanitized_text, AUTOTRANSLATE_END_GSUB, '}')

        --
        -- TODO: This effectively prevents Japanese characters from showing up.
        -- I need to find a better character stripping mechanism.
        --
        sanitized_text = string.gsub(sanitized_text, '[^%a%d%p ]', '')

        local entry = self.log:append(mode, sanitized_text)

        -- TODO: Consider using the entry metadata for the UI

        self.ui:append(mode, sanitized_text)
        
    end
end

Chat.commands['show'] = function(self, ...)
    local args = {...}
    if self.ui then self.ui:show() end
end

Chat.commands['hide'] = function(self, ...)
    local args = {...}
    if self.ui then self.ui:hide() end
end

Chat.commands['replay'] = function(self, ...)
    local args = {...}

    if not self.log then return end

    local type = arrayIndexOf(args, '-type') or arrayIndexOf(args, '-t')
    if type then 
        type = tostring(args[type + 1])
        if type then
            type = Chat.type_mappings[type]
        end
    end

    local max = arrayIndexOf(args, '-max')
    if max then max = tonumber(args[max + 1]) end

    type = string.lower(type or 'all')
    if not self.log.events[type] then
        type = 'all'
    end

    if not max then max = 10 end

    local log = self.log.events[type]

    local _end      = #log
    local _start    = math.max(1, _end - max)

    --
    -- TODO: A bunch of this should be moved into the ChatLog class itself
    --

    if _end > 0 then
        for i = _start, _end do
            local entry = log[i]
            writeMessage("%s %s":format(
                colorize(67, '[%s][lsc]':format(entry.time, entry.type)),
                colorize(entry.color, '%s':format(entry.message))
            ))
        end
    end
end

Chat.commands['help'] = function(self, ...)
    local args = {...}
    
    writeColoredMessage(2, 'Welcome to %s v%s':format(ADDON_NAME, ADDON_VERSION))
    writeMessage(' %s Shows the recent chats overlay.':format(colorize(6, 'show')))
    writeMessage(' %s Hides the recent chats overlay.':format(colorize(6, 'hide')))
    writeMessage(' %s %s':format(colorize(6, 'replay'), colorize(70, '[-type <all|l|l2|p|t>] [-max <count>]')))
    writeMessage('   Replays the most recent <count> messages of the specified type.')
    writeMessage('   Type can be all, l(linkshell), l2(linkshell2), p(party) or t(tell).')
    writeMessage('   Max controls how many messages back to replay.')
    writeMessage('   If not specified, type will default to all and max will default to 10.')
    writeMessage('')
end

Chat.commands['?'] = Chat.commands['help']