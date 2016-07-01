using BinDeps

@BinDeps.setup

deps = [ pcap = library_dependency("Pcap", aliases = ["libpcap"]) ]

@linux_only begin
    prefix = joinpath(BinDeps.depsdir(pcap), "usr")
    pcapsrcdir = joinpath(BinDeps.depsdir(pcap), "src", "pcap-lib")
    pcapbuilddir = joinpath(BinDeps.depsdir(pcap), "builds", "pcap-lib")
    provides(BuildProcess,
            (@build_steps begin
                CreateDirectory(pcapbuilddir)
                CreateDirectory("$prefix/lib")
                @build_steps begin
                    ChangeDirectory(pcapbuilddir)
                    FileRule(joinpath(prefix, "lib", "libpcap.so"), @build_steps begin
                        `gcc -c -O -W -Wall -fpic -std=gnu99 $pcapsrcdir/pcap-lib.c -lpcap`
                        `gcc -shared -o libpcap.so pcap-lib.o`
                        `cp libpcap.so $prefix/lib`
                        `cp $pcapsrcdir/pcap-lib.h $prefix/include`
                    end)
                end
            end), pcap, os = :Linux)
end

@BinDeps.install
