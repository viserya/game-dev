local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
        {
            x = 0,
            y = 0,
            width = 60,
            height = 40,

        },
        {
            x = 62,
            y = 0,
            width = 60,
            height = 42,

        },
        {
            x = 125,
            y = 0,
            width = 60,
            height = 42,

        },
        {
            x = 194,
            y = 0,
            width = 60,
            height = 40,

        },
		 {
            x = 300,
            y = 0,
            width = 60,
            height = 40,

        },
    }
}

function SheetInfo:getSheet()
    return self.sheet;
end

return SheetInfo
