#!/usr/bin/env julia

using Pkg
Pkg.activate(dirname(@__FILE__), io=devnull)
Pkg.resolve()
Pkg.instantiate()

using PackageCompiler

create_app("..", "netuptime"; incremental = false, filter_stdlibs=true, force = true)

