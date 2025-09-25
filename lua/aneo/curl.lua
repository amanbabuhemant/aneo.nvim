--[[ Curl ]]--

local Curl = {}

function Curl.parse_response(response_text)
    local code = 0
    local body = ""
    local body_started = false
    local location_change = 0

    for line in response_text:gmatch("([^\n]*)\n?") do
        if body_started then
            body = body .. line .. "\n"
        else
            if line:match("^HTTP/") then
                code = tonumber(line:match("^HTTP/%d+%.%d+ (%d+)"))
            end

            if line:match("Location:") then
                location_change = location_change + 1
            end

            if line == "\r" then
                if location_change == 0 then
                    body_started = true
                end
                if location_change > 0 then
                    location_change = location_change - 1
                end
            end
        end
    end
    body = body:sub(1, -3)

    return {
        code = code,
        body = body
    }
end

function Curl.get(url)
    local response_text = io.popen("curl -isL " .. url):read("*a")
    local response = Curl.parse_response(response_text)
    return response
end


return Curl
