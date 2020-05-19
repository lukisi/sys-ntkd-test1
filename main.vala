using Gee;
using TaskletSystem;
using Netsukuku.Neighborhood;

namespace Netsukuku
{

    [CCode (array_length = false, array_null_terminated = true)]
    string[] interfaces;
    int pid;

    ITasklet tasklet;
    Commander cm;
    FakeCommandDispatcher fake_cm;
    NeighborhoodManager? neighborhood_mgr;
    SkeletonFactory skeleton_factory;
    StubFactory stub_factory;

    HashMap<string,PseudoNetworkInterface> pseudonic_map;

    int main(string[] _args)
    {

        return 0;
    }

    bool do_me_exit = false;
    void safe_exit(int sig)
    {
        // We got here because of a signal. Quick processing.
        do_me_exit = true;
    }

    void stop_monitor(string dev)
    {
        PseudoNetworkInterface pseudonic = pseudonic_map[dev];
        skeleton_factory.stop_stream_system_listen(pseudonic.st_listen_pathname);
        print(@"stopped stream_system_listen $(pseudonic.st_listen_pathname).\n");
        neighborhood_mgr.stop_monitor(dev);
        skeleton_factory.stop_datagram_system_listen(pseudonic.listen_pathname);
        print(@"stopped datagram_system_listen $(pseudonic.listen_pathname).\n");
    }

    class PseudoNetworkInterface : Object
    {
        public PseudoNetworkInterface(string dev, string listen_pathname, string send_pathname, string mac)
        {
            this.dev = dev;
            this.listen_pathname = listen_pathname;
            this.send_pathname = send_pathname;
            this.mac = mac;
            nic = new NeighborhoodNetworkInterface(this);
        }
        public string mac {get; private set;}
        public string send_pathname {get; private set;}
        public string listen_pathname {get; private set;}
        public string dev {get; private set;}
        public string linklocal {get; set;}
        public string st_listen_pathname {get; set;}
        public INeighborhoodNetworkInterface nic {get; set;}
    }
}