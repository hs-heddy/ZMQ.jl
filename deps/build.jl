using BinDeps
using Compat

@BinDeps.setup

function validate(name, handle)
    try
        fhandle = Libdl.dlsym(handle, :zmq_version)
        major = Vector{Cint}(1)
        minor = Vector{Cint}(1)
        patch = Vector{Cint}(1)
        ccall(fhandle, Void, (Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), major, minor, patch)
        return VersionNumber(major[1], minor[1], patch[1]) >= v"3"
    catch
        return false
    end
end

zmq = library_dependency("zmq", aliases = ["libzmq", "libzmq.so.3", "libzmq.so.4", "libzmq.so.5"], validate = validate)

provides(Sources, URI("https://github.com/zeromq/zeromq3-x/releases/download/v3.2.5/zeromq-3.2.5.tar.gz"), zmq)
provides(BuildProcess, Autotools(libtarget = "src/.libs/libzmq." * Libdl.dlext), zmq)

provides(AptGet, "libzmq3", zmq, os = :Linux)
provides(Yum, "czmq", zmq, os = :Linux)

if Compat.Sys.iswindows()
    using WinRPM
    provides(WinRPM.RPM, "zeromq", [zmq], os = :Windows)
elseif Compat.Sys.isapple()
    using Homebrew
    provides(Homebrew.HB, "staticfloat/juliadeps/zeromq32", zmq, os = :Darwin)
end

@BinDeps.install Dict(:zmq => :zmq)
