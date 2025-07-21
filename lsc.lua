-- ========================================================================= --
-- IMPORTS
--  Imports are ways to leverage code that has already been written ("libraries"),
--  either by us or by others. In this case, the imports all come from the standard
--  Windower library folder at: Windower4/addons/libs
-- ========================================================================= --

---------------------------------------------------------------------
-- Our own imports go here

require('addon-info')

---------------------------------------------------------------------
-- Imports of standard Windower things go here

require('sets')         -- Gives us some extra helpers for finding specific elements within a set

resources   = require('resources')  -- Provides data on many different game object types
files       = require('files')      -- Lets us work with files
json        = require('json')       -- Lets us work with JSON
config      = require('config')     -- Gives us the ability to easily read and write standard Windower config files

require('cylibs/ui/cylibs-ui-includes')

require('helpers')
require('chat')

-- ========================================================================= --
-- CUSTOM CODE
--  This is where you can implement some custom code for your addon.
-- ========================================================================= --

-- ========================================================================= --
-- EVENT HANDLERS
--  Event handlers code that gets executed when certain events occur.
--  In this case, I opted to follow a naming convention that is standard
--  in some other languages. The names don't matter (so long as they match
--  with what's used in event registration further down), but it's helpful
--  to keep them in sync with what they actually are.
-- ========================================================================= --

function addon_onLoad()
    Chat:init()

    local player = windower.ffxi.get_player()
    if player then
        Chat.commands.show(Chat)
    else
        Chat.commands.hide(Chat)
    end
end

function addon_onUnload()
    return
end

function addon_onLogin(name)
    Chat:init()
    Chat.commands.show(Chat)
end

function addon_onLogout(name)
    Chat.commands.hide(Chat)
end

function addon_onAddonCommand(command, ...)
    if Chat.commands[command] then
        Chat.commands[command](Chat, ...)
    else
        Chat.commands.help(Chat, ...)
    end
end

function addon_onIncomingText(original_message, modified_message, original_mode, modified_mode, blocked)
    if ChatModesById[original_mode] then
        Chat:append(original_mode, original_message)
    end
end

-- ========================================================================= --
-- EVENT REGISTRATION
--      Windower 
-- ========================================================================= --

windower.register_event('load', addon_onLoad)
windower.register_event('login', addon_onLogin)
windower.register_event('logout', addon_onLogout)
windower.register_event('unload', addon_onUnload)
windower.register_event('addon command', addon_onAddonCommand)
windower.register_event('incoming text', addon_onIncomingText)