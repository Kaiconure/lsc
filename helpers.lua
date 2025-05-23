-- ========================================================================= --
-- HELPERS
--  These are things that we might find ourselves using in more than one place,
--  but which are not part of any library.
-- ========================================================================= --

DEFAULT_COLOR     = 89  -- This will be a lavender/violet color

---------------------------------------------------------------------
-- FFXI uses an "index based" coloring scheme. This function inserts
-- the correct data before and after the specified string to ensure 
-- that it will be rendered in the requested color in-game.
function colorize(color, message, returnColor)
    color = tonumber(color) or DEFAULT_COLOR
    returnColor = tonumber(returnColor) or DEFAULT_COLOR

    return string.char(0x1E, color) 
        .. (message or '')
        .. string.char(0x1E, returnColor)
end

---------------------------------------------------------------------
-- Writes a message that only you can see to the ffxi chat, using
-- the provided color index.
function writeColoredMessage(color, format, ...)
    windower.add_to_chat(1, colorize(color, string.format(format, ...)))
 end

---------------------------------------------------------------------
-- Writes a message that only you can see to the FFXI chat, using
-- the default color index.
function writeMessage(format, ...)
    writeColoredMessage(DEFAULT_COLOR, format, ...)
end

---------------------------------------------------------------------
-- Gets the index of a given search item within an array, or nil
-- if not found. An optional comparison function can be used if
-- the default equality operator is not appropriate.
function arrayIndexOf(array, search, fn)
    if type(array) == 'table' and #array > 0 then
        if type(fn) ~= 'function' then
            fn = function(a, b) return a == b end
        end

        for i = 1, #array do
            if fn(array[i], search) then
                return i
            end
        end
    end
end