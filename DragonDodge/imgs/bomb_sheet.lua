--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:87310b973d277768e8503e7e72c038b8:1/1$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            x = 21,
            y = 8,
            width = 34,
            height = 35,

        },
        {
            x = 90,
            y = 8,
            width = 37,
            height = 35,

        },
        {
            x = 230,
            y = 8,
            width = 37,
            height = 38,

        },
    },
    sheetContentWidth = 300,
    sheetContentHeight = 50
}

function SheetInfo:getSheet()
    return self.sheet;
end

return SheetInfo
