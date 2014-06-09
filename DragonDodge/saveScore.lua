local _M = {}
_M.score = 0

function _M.init(options)
	local opt = options or {}
	_M.filename = opt.filename or "score.txt"
end

function _M.setHighScore(score)
	_M.score = score
end

function _M.getHighScore()
	return _M.score
end

function _M.saveScore()
	local path = system.pathForFile( _M.filename, system.DocumentsDirectory)
	local file = io.open(path, "w")
	if (file) then
		local contents = tostring(_M.score)
		file:write(contents)
		io.close(file)
		return true
	else
		print("Error: File dne.")
		return false
	end
end

function _M.load()
	local path = system.pathForFile( _M.filename, system.DocumentsDirectory)
	local content = ""
	local file = io.open(path, "r")
	if (file) then
		local content = file:read("*a")
		local score = tonumber(content)
		io.close(file)
		return score
	else
		print("Error in reading from file.")
		return false
	end
end

return _M