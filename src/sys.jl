export memory
memory(x) = Base.summarysize(x) / 1024^2

export parseenv
parseenv(key, default::String) = get(ENV, string(key), string(default))

function parseenv(key, default::T) where T
    str = get(ENV, string(key), string(default))
    if hasmethod(parse, (Type{T}, String))
        parse(T, str)
    else
        include_string(Main, str)
    end
end

export getppid
function getppid(pid = getpid())
    try
        @static if Sys.iswindows()
            pip = pipeline(`wmic process where processid=$pid get parentprocessid`, stderr = devnull)
            str = read(pip, String)
            parse(Int, match(r"\d+", str).match)
        else
            pip = pipeline(`ps -o ppid= -p $pid`, stderr = devnull)
            parse(Int, strip(read(pip, String)))
        end
    catch
        nothing
    end
end

function pstree(pid = getpid())
    pids = Int[]
    while !isnothing(pid)
        push!(pids, pid)
        pid = getppid(pid)
    end
    pop!(pids)
    return pids
end

export processname
function processname(pid)
    @static if Sys.iswindows()
        split(read(`wmic process where processid=$pid get executablepath`, String))[end]
    else
        strip(read(`ps -p $pid -o comm=`, String))
    end
end

# """cron("spam.jl", 1)"""
# function cron(fn, repeat)
#     name = splitext(fn)[1]
#     vb = """
#     DIM objShell
#     set objShell=wscript.createObject("wscript.shell")
#     iReturn=objShell.Run("cmd.exe /C $(abspath(fn))", 0, TRUE)
#     """
#     bat = """
#     schtasks /create /tn "$name" /sc minute /mo $repeat /tr "$(abspath("$name.vbs"))"
#     schtasks /run /tn "$name"
#     """
#     write("$name.vbs", vb)
#     write("task.bat", bat)
#     run(`task.bat`)
# end

# function proxy(url)
#     regKey = "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings"
#     run(`powershell Set-ItemProperty -path \"$regKey\" AutoConfigURL -Value $url`)
# end
# cow() = proxy("http://127.0.0.1:7777/pac")

# function linux_backup(dir = "/home/hdd1/YaoLu/Software", user = "luyao")
#     date = string(now())[1:10]
#     sysfile = joinpath(dir, "$date-sys.tar.gz")
#     run(`sudo tar czf $file --exclude=/home --exclude=/media --exclude=/dev --exclude=/mnt --exclude=/proc --exclude=/sys --exclude=/tmp --exclude=/run /`)
#     userfile = joinpath(dir, "$date-$user.tar")
#     run(`sudo 7z a $userfile /home/$user`)
# end
#
# function linux_restore(file)
#     run(`tar xf $(abspath(file)) -C /`)
# end
