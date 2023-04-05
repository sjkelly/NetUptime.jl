module NetUptime

using Plots
using Dates
using Printf
using CSV
using DataFrames
using ArgParse
using SnoopPrecompile

function parse_commandline_args()
    s = ArgParseSettings()
    @add_arg_table! s begin
        "--url"
            help = "The URL to ping"
            default = "example.com"
        "--interval"
            help = "The ping interval in seconds"
            default = 1.0
            arg_type = Float64
        "--outfile"
            help = "The output CSV file name"
            default = "ping_results.csv"
        "--plotfile"
            help = "The output plot file name"
            default = "ping_results.png"
    end
    return parse_args(s)
end

function ping_website(url::String)
    output = IOBuffer()
    cmd = `ping -c 1 $url`
    process = run(pipeline(cmd, stdout=output, stderr=output), wait=false)

    wait(process)
    result = String(take!(output))

    success = occursin("1 packets transmitted, 1 received", result)
    return success
end

function plot_results_from_file(infile, outfile)
    data = CSV.read(infile, DataFrame)
    plot(data.DateTime, data.Success, xlabel="Time", ylabel="Pass/Fail (1/0)", title="Ping Results", legend=false)
    savefig(outfile)
end

function on_shutdown(results_file, plot_file)
    println("Saving results in $plot_file ...")
    plot_results_from_file(results_file, plot_file)
end

function log_ping_result(url, results_file, ping_interval)
    start_time = time_ns()
    result = ping_website(url)
    current_time = Dates.now()
    
    @printf("Ping %s at %s\n", result ? "succeeded" : "failed", current_time)

    new_row = DataFrame(DateTime=[current_time], Success=[result])
    CSV.write(results_file, new_row, writeheader=false, append=true)

    end_time = time_ns()
    elapsed_time = (end_time - start_time) / 1e9

    sleep_duration = max(0, ping_interval - elapsed_time)
    sleep(sleep_duration)
end

function julia_main()::Cint

    args = parse_commandline_args()

    url = args["url"]
    ping_interval = args["interval"]
    results_file = args["outfile"]
    plot_file = args["plotfile"]

    atexit(() -> on_shutdown(results_file, plot_file))

    results = DataFrame(DateTime=DateTime[], Success=Bool[])

    CSV.write(results_file, results, writeheader=true)

    # cleanly handle InterruptException
    Base.exit_on_sigint(false)

    try
        # special case the if we are precompiling
        if ccall(:jl_generating_output, Cint, ()) == 1
            log_ping_result(url, results_file, ping_interval)
            return 0
        else
            while true
                log_ping_result(url, results_file, ping_interval)
            end
        end
    catch
        exit()
        return 0
    end
end

# Precompiles

@precompile_setup begin
    @precompile_all_calls begin
        julia_main()
    end
end

end
