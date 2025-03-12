local json = require("./json")
local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local CFG = {}
CFG.__index = CFG

---@param key string
---@param script_name string
---@param default_data table | string | integer
function CFG:new(key, script_name, default_data)
    local instance = setmetatable({}, self)
    self.key = key
    self.default_data = default_data
    self.file_name = string.format("%s.save", script_name)
    if not io.exists(self.file_name) then
        self:save(self.default_data)
    end
    return instance
end

function CFG:b64_encode(input)
    local output = {}
    local n = #input

    for i = 1, n, 3 do
        local a = input:byte(i) or 0
        local b = input:byte(i + 1) or 0
        local c = input:byte(i + 2) or 0
        local triple = (a << 16) | (b << 8) | c
        output[#output + 1] = b64chars:sub(((triple >> 18) & 63) + 1, ((triple >> 18) & 63) + 1)
        output[#output + 1] = b64chars:sub(((triple >> 12) & 63) + 1, ((triple >> 12) & 63) + 1)
        output[#output + 1] = (i + 1 <= n) and b64chars:sub(((triple >> 6) & 63) + 1, ((triple >> 6) & 63) + 1) or "="
        output[#output + 1] = (i + 2 <= n) and b64chars:sub((triple & 63) + 1, (triple & 63) + 1) or "="
    end

    return table.concat(output)
end

function CFG:b64_decode(input)
    local b64lookup = {}

    for i = 1, #b64chars do
        b64lookup[b64chars:sub(i, i)] = i - 1
    end

    input = input:gsub("%s", ""):gsub("=", "")
    local output = {}

    for i = 1, #input, 4 do
        local a = b64lookup[input:sub(i, i)] or 0
        local b = b64lookup[input:sub(i + 1, i + 1)] or 0
        local c = b64lookup[input:sub(i + 2, i + 2)] or 0
        local d = b64lookup[input:sub(i + 3, i + 3)] or 0
        local triple = (a << 18) | (b << 12) | (c << 6) | d
        output[#output + 1] = string.char((triple >> 16) & 255)
        if i + 2 <= #input then
            output[#output + 1] = string.char((triple >> 8) & 255)
        end
        if i + 3 <= #input then
            output[#output + 1] = string.char(triple & 255)
        end
    end

    return table.concat(output)
end

function CFG:xor_(input)
    local output = {}
    local key_len = #self.key
    for i = 1, #input do
        local input_byte = input:byte(i)
        local key_byte = self.key:byte((i - 1) % key_len + 1)
        output[i] = string.char(input_byte ~ key_byte)
    end
    return table.concat(output)
end

function CFG:save(data)
    local json_str = json.encode(data)
    local xord = self:xor_(json_str)
    local encoded = self:b64_encode(xord)
    local file, err = io.open("NoHesi.save", "w")

    if not file then
        error(err, 2)
    end

    file:write(encoded)
    file:flush()
    file:close()
end

function CFG:read()
    local file, err = io.open("NoHesi.save", "r")

    if not file then
        error(err, 2)
    end

    local data = file:read("a")
    file:close()
    if not data or #data == 0 then
        return self.default_data
    end

    local decoded = self:b64_decode(data)
    local decrypted = self:xor_(decoded)
    return json.decode(decrypted)
end

---@param item_name string
function CFG:read_item(item_name)
    local data = self:read()

    if type(data) ~= "table" then
        error("Invalid data type", 2)
    end

    return data[item_name]
end

---@param item_name string
---@param value any
function CFG:save_item(item_name, value)
    local data = self:read()

    if type(data) ~= "table" then
        error("Invalid data type", 2)
    end

    data[item_name] = value
    self:save(data)
end

return CFG
