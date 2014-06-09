local vector2 = require("vector2")
local _M = {}

function _M.signum(x)
	if x < 0 then return -1 end
	if x > 0 then return 1 end
	return 0
end

function _M.doBounceAnimation(args)
	args = args or {}
	local obj = args.obj
	local field = args.field
	local startval = args.startval
	local endval = args.endval
	local ttime = args.ttime
	local offset = args.offset
	local delay = args.delay or 1
	local seg1ratio = args.seg1ratio or 0.8
	local seg2ratio = args.seg2ratio or 0.2
	local flag = args.flag
	
	obj[field] = startval
	local sig = _M.signum(endval-startval)
	if args.pre_call then
		args.pre_call()
	end
	if args.flag then
		obj[flag] = true
	end
	if args.inverse then
		seg1ratio, seg2ratio = seg2ratio, seg1ratio
		sig = sig*-1
		do
			local args = {
				time = ttime*seg1ratio,
				transition = easing.outQuad,
				delay = delay
			}
			args[field] = startval + sig*offset
			transition.to(obj, args)
		end
		do
			local args = {
				time = ttime*seg2ratio,
				delay = delay+ttime*seg1ratio,
				transition = easing.inQuad,
				onComplete = function()
					if args.post_call then
						args.post_call()
					end
					if args.flag then
						obj[flag] = false
					end
				end
			}
			args[field] = endval
			transition.to(obj, args)
		end
	else
		do
			local args = {
				time = ttime*seg1ratio,
				transition = easing.outQuad,
				delay = delay
			}
			args[field] = endval + sig*offset
			transition.to(obj, args)
		end
		do
			local args = {
				time = ttime*seg2ratio,
				delay = delay+ttime*seg1ratio,
				transition = easing.inQuad,
				onComplete = function()
					if args.post_call then
						args.post_call()
					end
					if args.flag then
						obj[flag] = false
					end
				end
			}
			args[field] = endval
			transition.to(obj, args)
		end
	end
end

function _M.applyWalls(pt, disp, wallpts)
	local WALLS = {
		--left
		{
			x1 = wallpts.minx,
			y1 = wallpts.miny,
			x2 = wallpts.minx,
			y2 = wallpts.maxy
		},
		--right
		{
			x1 = wallpts.maxx,
			y1 = wallpts.miny,
			x2 = wallpts.maxx,
			y2 = wallpts.maxy
		},
		--top
		{
			x1 = wallpts.minx,
			y1 = wallpts.miny,
			x2 = wallpts.maxx,
			y2 = wallpts.miny
		},
		--bottom
		{
			x1 = wallpts.minx,
			y1 = wallpts.maxy,
			x2 = wallpts.maxx,
			y2 = wallpts.maxy
		},
	}
	local seg = {
		x1 = pt.x,
		y1 = pt.y,
		x2 = pt.x + disp.x,
		y2 = pt.y + disp.y
	}
	for i=1, #WALLS do
		local w = WALLS[i]
		local intersection = _M.segToSegIntersection(seg.x1, seg.y1, seg.x2, seg.y2,
													 w.x1, w.y1, w.x2, w.y2)
		if intersection then
			return intersection
		end
	end
	return pt:add(disp)
end

function _M.segToSegIntersection(x1, y1, x2, y2, x3, y3, x4, y4)
	--taken from mathlib.lua by horacebury
	--http://developer.coronalabs.com/code/maths-library
	
	 -- parameter conversion
	local L1 = {X1=x1,Y1=y1,X2=x2,Y2=y2}
	local L2 = {X1=x3,Y1=y3,X2=x4,Y2=y4}
	
	-- Denominator for ua and ub are the same, so store this calculation
	local d = (L2.Y2 - L2.Y1) * (L1.X2 - L1.X1) - (L2.X2 - L2.X1) * (L1.Y2 - L1.Y1)
	
	-- Make sure there is not a division by zero - this also indicates that the lines are parallel.
	-- If n_a and n_b were both equal to zero the lines would be on top of each
	-- other (coincidental).  This check is not done because it is not
	-- necessary for this implementation (the parallel check accounts for this).
	if (d == 0) then
		return nil
	end
	
	-- n_a and n_b are calculated as seperate values for readability
	local n_a = (L2.X2 - L2.X1) * (L1.Y1 - L2.Y1) - (L2.Y2 - L2.Y1) * (L1.X1 - L2.X1)
	local n_b = (L1.X2 - L1.X1) * (L1.Y1 - L2.Y1) - (L1.Y2 - L1.Y1) * (L1.X1 - L2.X1)
	
	-- Calculate the intermediate fractional point that the lines potentially intersect.
	local ua = n_a / d
	local ub = n_b / d
	
	-- The fractional point will be between 0 and 1 inclusive if the lines
	-- intersect.  If the fractional calculation is larger than 1 or smaller
	-- than 0 the lines would need to be longer to intersect.
	if (ua >= 0 and ua <= 1 and ub >= 0 and ub <= 1) then
			local x = L1.X1 + (ua * (L1.X2 - L1.X1))
			local y = L1.Y1 + (ua * (L1.Y2 - L1.Y1))
			return vector2:createFromTable({x=x, y=y})
	end
	return nil
end

function _M.sqrDist(x1, y1, x2, y2)
	return (x1-x2)*(x1-x2) + (y1-y2)*(y1-y2)
end

function _M.ptToSegSqDistance(x, y, x1, y1, x2, y2)
	local l2 = _M.sqrDist(x1, y1, x2, y2)
	if l2 == 0 then
		return _M.sqrDist(x, y, x1, y1)
	end
	local t = ((x - x1)*(x2 - x1) + (y - y1)*(y2 - y1))/l2
	if t < 0 then
		return _M.sqrDist(x, y, x1, y1)
	end
	if t > 1 then
		return _M.sqrDist(x, y, x2, y2)
	end
	return _M.sqrDist(x, y, x1 + t*(x2-x1), y1 + t*(y2-y1))
end

function _M.createNumberGroup(num, args)
	args = args or {}
	local ret = display.newGroup()
	local strs = {}
	local n = num
	if n == 0 then
		strs[1] = "0"
	else
		while n > 0 do
			local num = n%10
			table.insert(strs, 1, ""..num)
			n = math.floor(n/10)
		end
	end
	
	if args.add_plus then
		table.insert(strs, 1, "plus")
	end
	if args.x then
		table.insert(strs, 1, "x")
	end
	if args.exclam then
		strs[#strs+1] = "exclam"
	end
	
	local leftmost = -1*21*(#strs-1)/2
	for i=1, #strs do
		local nimg = display.newImage(ret, "imgs/ingame/"..strs[i]..".png", leftmost+(i-1)*21, 0)
	end
	
	if args.limit then
		if #strs > 3 then
			--we need to scale it down
			local needWidth = 3*21
			local actualWidth = #strs*21
			local ratio = needWidth/actualWidth
			if ratio <= 0 then ratio = 0.001 end
			ret.xScale, ret.yScale = ratio, ratio
		end
	end
	
	return ret
end

function _M.rectToRectIntersection(r1, r2)
	local r1_l = r1.x - r1.width/2
	local r1_r = r1.x + r1.width/2
	local r1_t = r1.y - r1.height/2
	local r1_b = r1.y + r1.height/2
	
	local r2_l = r2.x - r2.width/2
	local r2_r = r2.x + r2.width/2
	local r2_t = r2.y - r2.height/2
	local r2_b = r2.y + r2.height/2
	
	local xbet = (r1_l <= r2_l and r2_l <= r1_r) or (r1_l <= r2_r and r2_r <= r1_r) or
				 (r2_l <= r1_l and r1_l <= r2_r) or (r2_l <= r1_r and r1_r <= r2_r)
	local ybet = (r1_t <= r2_t and r2_t <= r1_b) or (r1_t <= r2_b and r2_b <= r1_b) or
				 (r2_t <= r1_t and r1_t <= r2_b) or (r2_t <= r1_b and r1_b <= r2_b)
	
	return (xbet and ybet)
end

local SYMBOLS = {
	["-"] = "dash",
	["!"] = "exclam",
	["."] = "dot",
	[","] = "comma",
	["?"] = "qmark",
	[":"] = "dot",
	["'"] = "comma"
}

function _M.createTextBlock(name, args)
	args = args or {}
	local ret = display.newGroup()
	if args.line_width then
		local curline = display.newGroup()
		curline.anchorX = 0.5
		local left = 0
		local liney = 0
		local splits = name:split(" ")
		for i=1, #splits  do
			local word = splits[i]
			local w = _M.createTextBlock(word)
			w.anchorX = 0
			if left + w.contentWidth <= args.line_width then
				curline:insert(w)
				w.x, w.y = left, 0
				left = left + w.contentWidth + 6
			else
				ret:insert(curline)
				curline.anchorChildren = true
				curline.y = liney
				curline.x = 0
				liney = liney + 28
				
				curline = display.newGroup()
				left = 0
				curline:insert(w)
				w.x, w.y = left, 0
				left = left + w.contentWidth + 6
				curline.anchorX = 0.5
			end
		end
		ret:insert(curline)
		curline.anchorChildren = true
		curline.y = liney
		curline.x = 0
	else
		local leftx = 0
		for i=1, #name do
			local c = name:sub(i,i)
			if c == " " then
				leftx = leftx + 6
			elseif SYMBOLS[c] then
				if c == ":" then
					local cimg = display.newImage(ret, "imgs/font/sym_"..SYMBOLS[c]..".png")
					cimg.anchorX = 0
					cimg.x = leftx
					cimg.y = 10 - cimg.height/2
					local cimg2 = display.newImage(ret, "imgs/font/sym_"..SYMBOLS[c]..".png")
					cimg2.anchorX = 0
					cimg2.x = leftx
					cimg2.y = -10 + cimg2.height/2
					leftx = leftx + cimg.width
				elseif c == "'" then
					local cimg = display.newImage(ret, "imgs/font/sym_"..SYMBOLS[c]..".png")
					cimg.anchorX = 0
					cimg.x = leftx
					cimg.y = -10 + cimg.height/2
					leftx = leftx + cimg.width
				elseif c == "." then
					local cimg = display.newImage(ret, "imgs/font/sym_"..SYMBOLS[c]..".png")
					cimg.anchorX = 0
					cimg.x = leftx
					cimg.y = 10 - cimg.height/2
					leftx = leftx + cimg.width
				elseif c == "," then
					local cimg = display.newImage(ret, "imgs/font/sym_"..SYMBOLS[c]..".png")
					cimg.anchorX = 0
					cimg.x = leftx
					cimg.y = 10.5 - cimg.height/2
					leftx = leftx + cimg.width
				else
					local cimg = display.newImage(ret, "imgs/font/sym_"..SYMBOLS[c]..".png")
					cimg.anchorX = 0
					cimg.x = leftx
					leftx = leftx + cimg.width
				end
			else
				local cimg = display.newImage(ret, "imgs/font/"..c..".png")
				cimg.anchorX = 0
				cimg.x = leftx
				leftx = leftx + cimg.width
			end
		end
	end
	ret.anchorChildren = true
	return ret
end

return _M