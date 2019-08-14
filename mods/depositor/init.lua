
depositor = depositor or {}
depositor.modpath = minetest.get_modpath("depositor")
depositor.datafile = minetest.get_worldpath() .. "/shops.txt"
depositor.shops = depositor.shops or {}
depositor.dirty = true



function depositor.load()
	-- Custom file format. minetest.serialize() is unusable for large tables.
	depositor.shops = {}
	local file, err = io.open(depositor.datafile, "r")
	if not file or err then
		return
	end
	local datastring = file:read("*all")
	if not datastring or datastring == "" then
		return
	end
	file:close()

	local records = string.split(datastring, "\n")
	for _, record in ipairs(records) do
		local data = string.split(record, ",")
		if #data >= 7 then
			local x = tonumber(data[1])
			local y = tonumber(data[2])
			local z = tonumber(data[3])
			local o = tostring(data[4])
			local i = tostring(data[5])
			local c = tonumber(data[6])
			local t = tonumber(data[7])

			if x and y and z and o and i and c and t then
				table.insert(depositor.shops, {pos={x=x, y=y, z=z}, owner=o, item=i, cost=c, type=t})
			end
		end
	end
end



function depositor.save()
	-- Custom file format. minetest.serialize() is unusable for large tables.
	local datastring = ""
	for k, v in ipairs(depositor.shops) do
		if v.pos then
			local x = v.pos.x
			local y = v.pos.y
			local z = v.pos.z
			local t = v.type
			local o = v.owner
			local i = v.item
			local c = v.cost

			if x and y and z and t and o and i and c then
				-- x,y,z,owner,item,cost,type
				datastring = datastring ..
					x .. "," .. y .. "," .. z .. "," .. o .. "," .. i .. "," .. c .. "," .. t .. "\n"
			end
		end
	end
	local file, err = io.open(depositor.datafile, "w")
	if err then
		return
	end
	file:write(datastring)
	file:close()
end



-- Called for vending & delivery booths.
function depositor.check_machine(pos)
	pos = vector.round(pos)
	for i, dep in ipairs(depositor.shops) do
		if vector.equals(dep.pos, pos) then
			return
		end
	end
	table.insert(depositor.shops, {pos={x=pos.x, y=pos.y, z=pos.z}})
	depositor.save()
end



-- Called for vending & delivery booths.
function depositor.on_construct(pos)
	pos = vector.round(pos)
	table.insert(depositor.shops, {pos={x=pos.x, y=pos.y, z=pos.z}})
	depositor.save()
end



-- Called for vending & delivery booths.
function depositor.on_destruct(pos)
	pos = vector.round(pos)
	for i, dep in ipairs(depositor.shops) do
		if vector.equals(dep.pos, pos) then
			table.remove(depositor.shops, i)
			depositor.save()
		end
	end
end



function depositor.update_info(pos, owner, itemname, cost, bsb)
	pos = vector.round(pos)
	local needsave = false

	for k, dep in ipairs(depositor.shops) do
		if vector.equals(dep.pos, pos) then
			dep.owner = owner or "server"
			dep.item = itemname or "none"
			dep.cost = cost or 0

			dep.type = 0
			if bsb == "sell" then
				dep.type = 1
			elseif bsb == "buy" then
				dep.type = 2
			elseif bsb == "info" then
				dep.type = 3
			end

			needsave = true
			break
		end
	end

	if needsave then
		depositor.dirty = true
	end
end



function depositor.on_mapsave()
	if depositor.dirty then
		depositor.save()
	end
	depositor.dirty = false
end



if not depositor.run_once then
	depositor.load()

	minetest.register_on_mapsave(function() depositor.on_mapsave() end)

	local c = "depositor:core"
	local f = depositor.modpath .. "/init.lua"
	reload.register_file(c, f, false)

	depositor.run_once = true
end
