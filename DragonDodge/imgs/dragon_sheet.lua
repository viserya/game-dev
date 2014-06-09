local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
        {
            x = 0,
            y = 0,
            width = 44,
            height = 38,

        },
        {
            x = 65,
            y = 7,
            width = 44,
            height = 32,

        },
        {
            x = 130,
            y = 7,
            width = 44,
            height = 32,

        },
        {
            x = 194,
            y = 7,
            width = 44,
            height = 32,

        },
    }
}

function SheetInfo:getSheet()
    return self.sheet;
end

return SheetInfo
