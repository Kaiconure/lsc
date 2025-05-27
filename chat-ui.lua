Color.linkshell     = Color.new(255,    140,    248,   198)
Color.linkshell2    = Color.new(255,    15,     215,    15)
Color.party         = Color.new(255,    81,     248,    249)
Color.tell          = Color.new(255,    253,    168,    253)

local PANEL_WIDTH   = 600
local PANEL_HEIGHT  = 400

local MAX_CHARS     = 65
local MAX_LINES     = 22

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

function ChatUI.new()
    local self = setmetatable({}, ChatUI)

    self.DataSource = CollectionViewDataSource.new(
        function(item)
            local cell = TextCollectionViewCell.new(item)
            cell:setItemSize(CHAT_STYLE_LS.fontSize + 5)
            return cell
        end
    )
    self.Layout = VerticalFlowLayout.new(0, Padding.new(4, 4, 0, 0), 0)
    self.CollectionView = CollectionView.new(self.DataSource, self.Layout)

    local info = windower.get_windower_settings()

    self.CollectionView:setSize(PANEL_WIDTH, PANEL_HEIGHT)
    self.CollectionView:setPosition(info.ui_x_res - PANEL_WIDTH, info.ui_y_res - PANEL_HEIGHT - 200)
    self.CollectionView:setBackgroundColor(Color.black:withAlpha(192))

    self.CollectionView:updateContentView()
    self.CollectionView:layoutIfNeeded()

    local heading = TextItem.new('Chat Log', CHAT_STYLE_HEAD)
    self.DataSource:addItem(heading, IndexPath.new(1, 1))

    return self
end

function ChatUI:append(mode, message)
    

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

    message = '[%s] ':format(os.date('%H:%M:%S')) .. message

    local full_message = message
    local texts = {}

    -- Break up the text into lines that will fit horizontally in the window
    local hasBreaks = false
    if #message > MAX_CHARS then
        while #message > MAX_CHARS do
            local location = MAX_CHARS
            local found = false

            -- Look back from the end to try and find a suitable break point
            while location > 0 and location > (MAX_CHARS - 30) do
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
        (num_lines_ui + num_lines_added) > MAX_LINES 
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
    self.CollectionView:setSize(PANEL_WIDTH, PANEL_HEIGHT)
    self.CollectionView:updateContentView()
    self.CollectionView:layoutIfNeeded()
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

return ChatUI