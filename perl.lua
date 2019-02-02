VERSION = "1.0.0"

function checkSyntax()
    CurView():Save(false)
    doCheck()
end

function doCheck()
    local file     = CurView().Buf.Path
    local fileType = CurView().Buf:FileType()

    if fileType == "perl" then
        check("perl", "perl", {"-c", file}, "%m at %f line %l")
    end
end

function check(checker, cmd, args, errorformat)
    CurView():ClearGutterMessages(checker)
    JobSpawn(cmd, args, "", "", "perl.onCheckerExit", checker, errorformat)
end

function onCheckerExit(output, checker, errorformat)
	messenger:Clear()
	messenger:AddLog(output)
    local lines = split(output, "\n")
    local regex = errorformat:gsub("%%m", "(.+)"):gsub("%%f", "(..-)"):gsub("%%l", "(%d+)")
    for _,line in ipairs(lines) do
        line = line:match("^%s*(.+)%s*$")
        if string.find(line, regex) then
            local msg, file, line = string.match(line, regex)
            if basename(CurView().Buf.Path) == basename(file) then
                CurView():GutterMessage(checker, tonumber(line), msg, 2)
            end
        end
    end
end

function split(str, sep)
    local result = {}
    local regex = ("([^%s]+)"):format(sep)
    for each in str:gmatch(regex) do
        table.insert(result, each)
    end
    return result
end

function basename(file)
    local sep = "/"
    local name = string.gsub(file, "(.*" .. sep .. ")(.*)", "%2")
    return name
end


function checkCriticism()
    local file     = CurView().Buf.Path
    local fileType = CurView().Buf:FileType()

    if fileType == "perl" then
        HandleShellCommand("perlcritic --brutal " .. file, true, true)
    end
end

MakeCommand("pcs", "perl.checkSyntax",    0)
MakeCommand("pcr", "perl.checkCriticism", 0)
