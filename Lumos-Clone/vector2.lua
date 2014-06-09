local Vector2 = {
	x = 0.0,
	y = 0.0
}

local math_sqrt = math.sqrt
local math_sin = math.sin
local math_cos = math.cos
local math_rad = math.rad

function Vector2:create(tab)
	tab = tab or {}
	setmetatable(tab, self)
	self.__index = self
	
	return tab
end

function Vector2:createXY(mx,my)
	return Vector2:create{x=mx, y=my}
end
function Vector2:createFromTable(tab)
	local mx = tab.x or 0
	local my = tab.y or 0
	--include +0 to automatically convert strings to numbers
	return Vector2:create{x=mx+0, y=my+0}
end

function Vector2:add(v)
	local ret = Vector2:create{x=self.x+v.x, y=self.y+v.y}
	return ret
end

function Vector2:subtract(v)
	return self:add(v:negate())
end

function Vector2:negate()
	return Vector2:create{x=-1*self.x, y=-1*self.y}
end

function Vector2:dot(v)
	return Vector2:create{x=self.x*v.x, y=self.y*v.y}
end

function Vector2:cmult(num)
	return Vector2:create{x=self.x*num, y=self.y*num}
end

function Vector2:magnitude()
	return math_sqrt(self:sqrMagnitude())
end

function Vector2:sqrMagnitude()
	return self.x*self.x + self.y*self.y
end

function Vector2:normalized()
	local m = self:magnitude()
	if m == 0 then return Vector2:create{x=0,y=0} end
	return Vector2:create{x=self.x/m, y=self.y/m}
end

function Vector2:rotate(angle)
	local rad_angle = math_rad(angle)
	local cos_angle = math_cos(rad_angle)
	local sin_angle = math_sin(rad_angle)
	local rx = self.x*cos_angle + -1*self.y*sin_angle
	local ry = self.x*sin_angle + self.y*cos_angle
	return Vector2:create{x=rx,y=ry}
end

function Vector2:right()
	return Vector2:create{x=1,y=0}
end
function Vector2:up()
	return Vector2:create{x=0,y=1}
end
function Vector2:left()
	return Vector2:create{x=-1,y=0}
end
function Vector2:down()
	return Vector2:create{x=0,y=-1}
end
function Vector2:zero()
	return Vector2:create{x=0,y=0}
end

function Vector2:copyContentsTo(tab)
	tab.x = self.x
	tab.y = self.y
end

function Vector2:toString()
	return "<"..self.x..", "..self.y..">"
end

function Vector2:s_reset()
	self.x, self.y = 0, 0
end

function Vector2:s_updateFromTable(tbl)
	tbl = tbl or {x=0,y=0}
	self.x, self.y = tbl.x, tbl.y
end

function Vector2:s_add(vec)
	vec = vec or {x=0, y=0}
	self.x = self.x + vec.x
	self.y = self.y + vec.y
	return self
end

function Vector2:s_subtract(vec)
	vec = vec or {x=0, y=0}
	self.x = self.x - (vec.x or 0)
	self.y = self.y - (vec.y or 0)
	return self
end

function Vector2:s_normalized()
	local m = self:magnitude()
	if m == 0 then 
		self.x, self.y = 0, 0
	else
		self.x, self.y = self.x/m, self.y/m
	end
	return self
end

function Vector2:s_cmult(c)
	self.x, self.y = c*self.x, c*self.y
	return self
end

function Vector2:s_rotate(angle)
	local rad_angle = math_rad(angle)
	local cos_angle = math_cos(rad_angle)
	local sin_angle = math_sin(rad_angle)
	local rx = self.x*cos_angle + -1*self.y*sin_angle
	local ry = self.x*sin_angle + self.y*cos_angle
	self.x, self.y = rx, ry
	return self
end

return Vector2