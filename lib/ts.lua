local t = {}

function t.type(typeName)
	return function(value)
		local valueType = type(value)

		if valueType == typeName then
			return true
		else
			return false
		end
	end
end
function t.typeof(typeName)
	return function(value)
		local valueType = typeof(value)

		if valueType == typeName then
			return true
		else
			return false
		end
	end
end
function t.any(value)
	if value ~= nil then
		return true
	else
		return false
	end
end

t.boolean = t.typeof("boolean")
t.thread = t.typeof("thread")
t.callback = t.typeof("function")
t["function"] = t.callback
t.none = t.typeof("nil")
t["nil"] = t.none
t.string = t.typeof("string")
t.table = t.typeof("table")
t.userdata = t.type("userdata")

function t.number(value)
	local valueType = typeof(value)

	if valueType == "number" then
		if value == value then
			return true
		else
			return false
		end
	else
		return false
	end
end
function t.nan(value)
	local valueType = typeof(value)

	if valueType == "number" then
		if value ~= value then
			return true
		else
			return false
		end
	else
		return false
	end
end

t.Axes = t.typeof("Axes")
t.BrickColor = t.typeof("BrickColor")
t.CatalogSearchParams = t.typeof("CatalogSearchParams")
t.CFrame = t.typeof("CFrame")
t.Color3 = t.typeof("Color3")
t.ColorSequence = t.typeof("ColorSequence")
t.ColorSequenceKeypoint = t.typeof("ColorSequenceKeypoint")
t.DateTime = t.typeof("DateTime")
t.DockWidgetPluginGuiInfo = t.typeof("DockWidgetPluginGuiInfo")
t.Enum = t.typeof("Enum")
t.EnumItem = t.typeof("EnumItem")
t.Enums = t.typeof("Enums")
t.Faces = t.typeof("Faces")
t.Instance = t.typeof("Instance")
t.NumberRange = t.typeof("NumberRange")
t.NumberSequence = t.typeof("NumberSequence")
t.NumberSequenceKeypoint = t.typeof("NumberSequenceKeypoint")
t.PathWaypoint = t.typeof("PathWaypoint")
t.PhysicalProperties = t.typeof("PhysicalProperties")
t.Random = t.typeof("Random")
t.Ray = t.typeof("Ray")
t.RaycastParams = t.typeof("RaycastParams")
t.RaycastResult = t.typeof("RaycastResult")
t.RBXScriptConnection = t.typeof("RBXScriptConnection")
t.RBXScriptSignal = t.typeof("RBXScriptSignal")
t.Rect = t.typeof("Rect")
t.Region3 = t.typeof("Region3")
t.Region3int16 = t.typeof("Region3int16")
t.TweenInfo = t.typeof("TweenInfo")
t.UDim = t.typeof("UDim")
t.UDim2 = t.typeof("UDim2")
t.Vector2 = t.typeof("Vector2")
t.Vector2int16 = t.typeof("Vector2int16")
t.Vector3 = t.typeof("Vector3")
t.Vector3int16 = t.typeof("Vector3int16")

function t.literal(...)
	local size = select("#", ...)

	if size == 1 then
		local literal = ...

		return function(value)
			if value ~= literal then
				return false
			end

			return true
		end
	else
		local literals = {}

		for i = 1, size do
			local value = select(i, ...)

			literals[i] = t.literal(value)
		end

		return t.union(table.unpack(literals, 1, size))
	end
end

t.exactly = t.literal

function t.keyOf(keyTable)
	local keys = {}
	local length = 0

	for key in pairs(keyTable) do
		length = length + 1
		keys[length] = key
	end

	return t.literal(table.unpack(keys, 1, length))
end
function t.valueOf(valueTable)
	local values = {}
	local length = 0

	for _, value in pairs(valueTable) do
		length = length + 1
		values[length] = value
	end

	return t.literal(table.unpack(values, 1, length))
end
function t.integer(value)
	local success = t.number(value)

	if not success then
		return false
	end
	if value % 1 == 0 then
		return true
	else
		return false
	end
end
function t.numberMin(min)
	return function(value)
		local success = t.number(value)

		if not success then
			return false
		end
		if value >= min then
			return true
		else
			return false
		end
	end
end
function t.numberMax(max)
	return function(value)
		local success = t.number(value)

		if not success then
			return false
		end
		if value <= max then
			return true
		else
			return false
		end
	end
end
function t.numberMinExclusive(min)
	return function(value)
		local success = t.number(value)

		if not success then
			return false
		end
		if min < value then
			return true
		else
			return false
		end
	end
end
function t.numberMaxExclusive(max)
	return function(value)
		local success = t.number(value)

		if not success then
			return false
		end
		if value < max then
			return true
		else
			return false
		end
	end
end

t.numberPositive = t.numberMinExclusive(0)
t.numberNegative = t.numberMaxExclusive(0)

function t.numberConstrained(min, max)
	assert(t.number(min))
	assert(t.number(max))

	local minCheck = t.numberMin(min)
	local maxCheck = t.numberMax(max)

	return function(value)
		local minSuccess = minCheck(value)

		if not minSuccess then
			return false
		end

		local maxSuccess = maxCheck(value)

		if not maxSuccess then
			return false
		end

		return true
	end
end
function t.numberConstrainedExclusive(min, max)
	assert(t.number(min))
	assert(t.number(max))

	local minCheck = t.numberMinExclusive(min)
	local maxCheck = t.numberMaxExclusive(max)

	return function(value)
		local minSuccess = minCheck(value)

		if not minSuccess then
			return false
		end

		local maxSuccess = maxCheck(value)

		if not maxSuccess then
			return false
		end

		return true
	end
end
function t.match(pattern)
	assert(t.string(pattern))

	return function(value)
		local stringSuccess = t.string(value)

		if not stringSuccess then
			return false
		end
		if string.match(value, pattern) == nil then
			return false
		end

		return true
	end
end
function t.optional(check)
	assert(t.callback(check))

	return function(value)
		if value == nil then
			return true
		end

		local success = check(value)

		if success then
			return true
		else
			return false
		end
	end
end
function t.tuple(...)
	local checks = { ... }

	return function(...)
		local args = { ... }

		for i, check in ipairs(checks) do
			local success = check(args[i])

			if success == false then
				return false
			end
		end

		return true
	end
end
function t.keys(check)
	assert(t.callback(check))

	return function(value)
		local tableSuccess = t.table(value)

		if tableSuccess == false then
			return false
		end

		for key in pairs(value) do
			local success = check(key)

			if success == false then
				return false
			end
		end

		return true
	end
end
function t.values(check)
	assert(t.callback(check))

	return function(value)
		local tableSuccess = t.table(value)

		if tableSuccess == false then
			return false
		end

		for _, val in pairs(value) do
			local success = check(val)

			if success == false then
				return false
			end
		end

		return true
	end
end
function t.map(keyCheck, valueCheck)
	assert(t.callback(keyCheck))
	assert(t.callback(valueCheck))

	local keyChecker = t.keys(keyCheck)
	local valueChecker = t.values(valueCheck)

	return function(value)
		local keySuccess = keyChecker(value)

		if not keySuccess then
			return false
		end

		local valueSuccess = valueChecker(value)

		if not valueSuccess then
			return false
		end

		return true
	end
end
function t.set(valueCheck)
	return t.map(valueCheck, t.literal(true))
end

do
	local arrayKeysCheck = t.keys(t.integer)

	function t.array(check)
		assert(t.callback(check))

		local valuesCheck = t.values(check)

		return function(value)
			local keySuccess = arrayKeysCheck(value)

			if keySuccess == false then
				return false
			end

			local arraySize = 0

			for _ in ipairs(value) do
				arraySize = arraySize + 1
			end
			for key in pairs(value) do
				if key < 1 or key > arraySize then
					return false
				end
			end

			local valueSuccess = valuesCheck(value)

			if not valueSuccess then
				return false
			end

			return true
		end
	end
	function t.strictArray(...)
		local valueTypes = { ... }

		assert(t.array(t.callback)(valueTypes))

		return function(value)
			local keySuccess = arrayKeysCheck(value)

			if keySuccess == false then
				return false
			end
			if #valueTypes < #value then
				return false
			end

			for idx, typeFn in pairs(valueTypes) do
				local typeSuccess = typeFn(value[idx])

				if not typeSuccess then
					return false
				end
			end

			return true
		end
	end
end
do
	local callbackArray = t.array(t.callback)

	function t.union(...)
		local checks = { ... }

		assert(callbackArray(checks))

		return function(value)
			for _, check in ipairs(checks) do
				if check(value) then
					return true
				end
			end

			return false
		end
	end

	t.some = t.union

	function t.intersection(...)
		local checks = { ... }

		assert(callbackArray(checks))

		return function(value)
			for _, check in ipairs(checks) do
				local success = check(value)

				if not success then
					return false
				end
			end

			return true
		end
	end

	t.every = t.intersection
end
do
	local checkInterface = t.map(t.any, t.callback)

	function t.interface(checkTable)
		assert(checkInterface(checkTable))

		return function(value)
			local tableSuccess = t.table(value)

			if tableSuccess == false then
				return false
			end

			for key, check in pairs(checkTable) do
				local success = check(value[key])

				if success == false then
					return false
				end
			end

			return true
		end
	end
	function t.strictInterface(checkTable)
		assert(checkInterface(checkTable))

		return function(value)
			local tableSuccess = t.table(value)

			if tableSuccess == false then
				return false
			end

			for key, check in pairs(checkTable) do
				local success = check(value[key])

				if success == false then
					return false
				end
			end
			for key in pairs(value) do
				if not checkTable[key] then
					return false
				end
			end

			return true
		end
	end
end

function t.instanceOf(className, childTable)
	assert(t.string(className))

	local childrenCheck

	if childTable ~= nil then
		childrenCheck = t.children(childTable)
	end

	return function(value)
		local instanceSuccess = t.Instance(value)

		if not instanceSuccess then
			return false
		end
		if value.ClassName ~= className then
			return false
		end
		if childrenCheck then
			local childrenSuccess = childrenCheck(value)

			if not childrenSuccess then
				return false
			end
		end

		return true
	end
end

t.instance = t.instanceOf

function t.instanceIsA(className, childTable)
	assert(t.string(className))

	local childrenCheck

	if childTable ~= nil then
		childrenCheck = t.children(childTable)
	end

	return function(value)
		local instanceSuccess = t.Instance(value)

		if not instanceSuccess then
			return false
		end
		if not value:IsA(className) then
			return false
		end
		if childrenCheck then
			local childrenSuccess = childrenCheck(value)

			if not childrenSuccess then
				return false
			end
		end

		return true
	end
end
function t.enum(enum)
	assert(t.Enum(enum))

	return function(value)
		local enumItemSuccess = t.EnumItem(value)

		if not enumItemSuccess then
			return false
		end
		if value.EnumType == enum then
			return true
		else
			return false
		end
	end
end

do
	local checkWrap = t.tuple(t.callback, t.callback)

	function t.wrap(callback, checkArgs)
		assert(checkWrap(callback, checkArgs))

		return function(...)
			assert(checkArgs(...))

			return callback(...)
		end
	end
end

function t.strict(check)
	return function(...)
		assert(check(...))
	end
end

do
	local checkChildren = t.map(t.string, t.callback)

	function t.children(checkTable)
		assert(checkChildren(checkTable))

		return function(value)
			local instanceSuccess = t.Instance(value)

			if not instanceSuccess then
				return false
			end

			local childrenByName = {}

			for _, child in ipairs(value:GetChildren()) do
				local name = child.Name

				if checkTable[name] then
					if childrenByName[name] then
						return false
					end

					childrenByName[name] = child
				end
			end
			for name, check in pairs(checkTable) do
				local success = check(childrenByName[name])

				if not success then
					return false
				end
			end

			return true
		end
	end
end

return { t = t }
