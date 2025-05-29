-- The full chat log history
local ChatLog = { 
    events = {
        all = {},
        party = {},
        linkshell = {},
        linkshell2 = {},
        tell = {}
    }
}

ChatLog.__index = ChatLog

function ChatLog.new(settings)
    local self = setmetatable({}, ChatLog)

    self.settings = settings
    
    return self
end

function ChatLog:append(mode, message)
    local entry = {
        tick = os.clock(),
        timestamp = os.date('%Y-%m-%dT%H:%M:%S'),
        time = os.date('%H:%M:%S'),
        type = '',
        color = 67,
        mode = mode,
        message = message
    }

    -- Store all messages into the "all" list
    self.events.all[#self.events.all + 1] = entry

    -- Store specific types of messages in their respective lists
    if mode == ChatModes.SelfParty or mode == ChatModes.OtherParty then
        entry.type = 'party'
        entry.color = 6
        self.events.party[#self.events.party + 1] = entry        
    elseif mode == ChatModes.TellIncoming or mode == ChatModes.TellOutgoing then
        entry.type = 'tell'
        entry.color = 73
        self.events.tell[#self.events.tell + 1] = entry
    elseif mode == ChatModes.LsIncoming or mode == ChatModes.LsOutgoing then
        entry.type = 'linkshell'
        entry.color = 88
        self.events.linkshell[#self.events.linkshell + 1] = entry
    elseif mode == ChatModes.Ls2Incoming or mode == ChatModes.Ls2Outgoing then
        entry.type = 'linkshell2'
        entry.color = 110
        self.events.linkshell2[#self.events.linkshell2 + 1] = entry
    end

    return entry
end

function ChatLog:getEvents()
    return self.events
end

function ChatLog:clear()
    self.events = {
        all = {},
        party = {},
        linkshell = {},
        linkshell2 = {},
        tell = {}
    }
end

return ChatLog