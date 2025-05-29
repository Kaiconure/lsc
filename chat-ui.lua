Color.linkshell     = Color.new(255,    140,    248,   198)
Color.linkshell2    = Color.new(255,    15,     215,    15)
Color.party         = Color.new(255,    81,     248,    249)
Color.tell          = Color.new(255,    253,    168,    253)

local PANEL_WIDTH   = 600
local PANEL_HEIGHT  = 400

-- local MAX_CHARS     = 65
-- local MAX_LINES     = 22

local CHAT_FONT_FAMILY   = "Consolas"
local CHAT_FONT_SIZE     = 12


-- ---
-- -- Creates a new TextStyle instance.
-- --
-- -- @tparam Color selectedBackgroundColor The selected background color.
-- -- @tparam Color defaultBackgroundColor The default background color.
-- -- @tparam string fontName The font name.
-- -- @tparam number fontSize The font size.
-- -- @tparam Color fontColor The font color.
-- -- @tparam Color highlightColor The highlighted font color.
-- -- @tparam number padding The padding on each side.
-- -- @tparam number strokeWidth The stroke width.
-- -- @tparam number strokeAlpha The stroke alpha.
-- -- @tparam boolean bold Whether the text should be bolded.
-- -- @treturn TextStyle The newly created TextStyle instance.
-- --
local CHAT_STYLE_DEFAULT    = TextStyle.new(Color.clear, Color.clear, CHAT_FONT_FAMILY, CHAT_FONT_SIZE, Color.white, Color.white, 2, 0, 1, 0, true)
local CHAT_STYLE_HEAD       = TextStyle.new(Color.clear, Color.clear, "Arial", CHAT_FONT_SIZE, Color.white, Color.white, 2, 0, 1, 0, true)
local CHAT_STYLE_LS         = TextStyle.new(Color.clear, Color.clear, CHAT_FONT_FAMILY, CHAT_FONT_SIZE, Color.linkshell, Color.linkshell, 2, 0, 1, 0, true)
local CHAT_STYLE_LS2        = TextStyle.new(Color.clear, Color.clear, CHAT_FONT_FAMILY, CHAT_FONT_SIZE, Color.linkshell2, Color.linkshell2, 2, 0, 1, 0, true)
local CHAT_STYLE_PARTY      = TextStyle.new(Color.clear, Color.clear, CHAT_FONT_FAMILY, CHAT_FONT_SIZE, Color.party, Color.party, 2, 0, 1, 0, true)
local CHAT_STYLE_TELL       = TextStyle.new(Color.clear, Color.clear, CHAT_FONT_FAMILY, CHAT_FONT_SIZE, Color.tell, Color.tell, 2, 0, 1, 0, true)

local ChatUI = {}
ChatUI.__index = ChatUI

local function _setPositioning(self)
    local info = windower.get_windower_settings()

    -- We won't let the window get smaller than 300x200
    self.settings.w = math.max(self.settings.w, 300)
    self.settings.h = math.max(self.settings.h, 200)

    self.CollectionView:setSize(self.settings.w, self.settings.h)

    if
        self.settings.anchor ~= 'sw'and
        self.settings.anchor ~= 'nw' and
        self.settings.anchor ~= 'ne' and
        self.settings.anchor ~= 'se'
    then
        self.settings.anchor = 'se'
    end

    local info = windower.get_windower_settings()
    local x, y

    if self.settings.anchor == 'sw' or self.settings.anchor == 'nw' then
        x = self.settings.mh
    else
        x = info.ui_x_res - self.settings.w - self.settings.mh
    end

    if self.settings.anchor == 'nw' or self.settings.anchor == 'ne' then
        y = self.settings.mv
    else
        y = info.ui_y_res - self.settings.h - self.settings.mv
    end

    self.maxLines = math.floor(self.settings.h / 17) - 1
    self.maxChars = math.floor(self.settings.w / 9) - 1

    self.CollectionView:setSize(self.settings.w, self.settings.h)
    self.CollectionView:setPosition(x, y)
end

function ChatUI.new(settings)
    local self = setmetatable({}, ChatUI)

    self.settings = settings

    self.DataSource = CollectionViewDataSource.new(
        function(item)
            local cell = TextCollectionViewCell.new(item)
            cell:setItemSize(CHAT_STYLE_LS.fontSize + 5)
            return cell
        end
    )
    self.Layout = VerticalFlowLayout.new(0, Padding.new(4, 4, 0, 0), 0)
    self.CollectionView = CollectionView.new(self.DataSource, self.Layout)

    self.CollectionView:setBackgroundColor(Color.black:withAlpha(192))

    local heading = TextItem.new('Chat Log', CHAT_STYLE_HEAD)
    self.DataSource:addItem(heading, IndexPath.new(1, 1))

    self:resizeFromSettings()

    return self
end

function ChatUI:append(mode, message, timestamp)
    local style = CHAT_STYLE_DEFAULT
    if mode == ChatModes.SelfParty or mode == ChatModes.OtherParty then
        style = CHAT_STYLE_PARTY
    elseif mode == ChatModes.TellIncoming or mode == ChatModes.TellOutgoing then
        style = CHAT_STYLE_TELL
    elseif mode == ChatModes.LsIncoming or mode == ChatModes.LsOutgoing then
        style = CHAT_STYLE_LS
    elseif mode == ChatModes.Ls2Incoming or mode == ChatModes.Ls2Outgoing then
        style = CHAT_STYLE_LS2
    end

    message = '[%s] ':format(timestamp or os.date('%H:%M:%S')) .. message

    local full_message = message
    local texts = {}

    -- Break up the text into lines that will fit horizontally in the window
    local hasBreaks = false
    if #message > self.maxChars then
        while #message > self.maxChars do
            local location = self.maxChars
            local found = false

            -- Look back from the end to try and find a suitable break point
            while location > 0 and location > (self.maxChars - 30) do
                if string.match(message[location], '[%s%p]') then
                    found = true
                    break
                end

                location = location - 1
            end

            hasBreaks = true

            -- If we found no breakpoints, we'll just add whatever's left and call it done
            if not found then
                break
            end

            -- Append the next segment, and march the remaining text forward
            texts[#texts + 1] = string.sub(message, 1, location)
            message = '  ' .. string.sub(message, location + 1)

            if #message < 3 then
                message = ''
            end
        end

        if #message > 0 then
            texts[#texts + 1] = message
        end
    else
        texts[1] = full_message
    end

    -- Remove enough lines that we won't go over the configured limit with the lines we're about to add
    local num_lines_ui = self.DataSource:numberOfItemsInSection(2)
    local num_lines_added = #texts
    while 
        num_lines_ui > 0 and
        (num_lines_ui + num_lines_added) > self.maxLines 
    do
        self.DataSource:removeItem(IndexPath.new(2, 1))
        num_lines_ui = self.DataSource:numberOfItemsInSection(2)
    end

    -- Append the new lines
    for i = 1, #texts do
        local current = texts[i]
        local item = TextItem.new(current, style)
        local count = self.DataSource:numberOfItemsInSection(2)

        self.DataSource:addItem(item, IndexPath.new(2, count + 1))
    end
end

function ChatUI:show()
    self.CollectionView:setVisible(true)
    self:resizeFromSettings()
end

function ChatUI:hide()
    self.CollectionView:setVisible(false)
    self.CollectionView:setSize(0, 0)
    self.CollectionView:updateContentView()
    self.CollectionView:layoutIfNeeded()
end

function ChatUI:clear()
    -- Hide while we work
    self:hide()

    -- Clear all content
    self.DataSource:removeAllItems()

    -- Re-add the heading
    local heading = TextItem.new('Chat Log', CHAT_STYLE_HEAD)
    self.DataSource:addItem(heading, IndexPath.new(1, 1))

    -- Show the UI again
    self:show()
end

function ChatUI:resizeFromSettings()
    _setPositioning(self)

    self.CollectionView:updateContentView()
    self.CollectionView:layoutIfNeeded()
end

return ChatUI