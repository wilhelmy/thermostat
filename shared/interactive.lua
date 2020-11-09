function cat(f)
    local fd=file.open(f)
    print(fd:read())
    fd:close()
end

function ls(a) for k,v in pairs(a) do print(k,v) end end

function fappend(f, s)
    local fd=file.open(f,"a")
    fd:write("\n"..s)
    fd:close()
end
