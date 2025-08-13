-- 文件名: lbsLoc.lua

local lbsLoc = {}

-- 默认使用合宙 LBS 接口
local url = "http://bs.openluat.com/cps"

function lbsLoc.request(cb)
    mobile.getCellInfo(function(info)
        if not info or not info.mcc then
            cb(false)
            return
        end

        local data = {
            ver = 1,
            mcc = info.mcc,
            mnc = info.mnc,
            imei = mobile.imei(),
            imsi = mobile.imsi(),
            ci = info.ci,
            lac = info.lac,
            [info.cell and "cell" or ""] = info.cell or nil
        }

        http.request("POST", url, {["Content-Type"]="application/json"}, json.encode(data))
        :next(function(resp)
            local j = json.decode(resp.body or "")
            if j and j.lat and j.lng then
                cb(true, j.lat, j.lng, j.addr or "")
            else
                cb(false)
            end
        end)
        :catch(function()
            cb(false)
        end)
    end)
end

return lbsLoc
