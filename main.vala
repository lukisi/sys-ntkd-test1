/*
 *  This file is part of Netsukuku.
 *  Copyright (C) 2020 Luca Dionisi aka lukisi <luca.dionisi@gmail.com>
 *
 *  Netsukuku is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Netsukuku is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Netsukuku.  If not, see <http://www.gnu.org/licenses/>.
 */

using Gee;
using TaskletSystem;
using Netsukuku.Neighborhood;
using Netsukuku.Identities;
using Netsukuku.Qspn;

namespace Netsukuku
{
    string json_string_object(Object obj)
    {
        Json.Node n = Json.gobject_serialize(obj);
        Json.Generator g = new Json.Generator();
        g.root = n;
        string ret = g.to_data(null);
        return ret;
    }

    string printabletime()
    {
        TimeVal now = TimeVal();
        now.get_current_time();
        string s_usec = @"$(now.tv_usec + 1000000)";
        s_usec = s_usec.substring(1);
        string s_sec = @"$(now.tv_sec)";
        s_sec = s_sec.substring(s_sec.length-3);
        return @"$(s_sec).$(s_usec)";
    }

    string topology;
    string firstaddr;
    int pid;
    [CCode (array_length = false, array_null_terminated = true)]
    string[] interfaces;
    bool accept_anonymous_requests;
    bool no_anonymize;
    int subnetlevel;

    ITasklet tasklet;
    Commander real_cm;
    FakeCommandDispatcher fake_cm;
    TableNames tn;
    ArrayList<int> gsizes;
    ArrayList<int> g_exp;
    ArrayList<int> hooking_epsilon;
    int levels;

    NeighborhoodManager? neighborhood_mgr;
    IdentityManager? identity_mgr;
    // not used in this test
    /*HashMap<int,NodeArc> arc_map;*/
    HashMap<string,HandledNic> handlednic_map;
    SkeletonFactory skeleton_factory;
    StubFactory stub_factory;
    HashMap<string,PseudoNetworkInterface> pseudonic_map;
    HashMap<int,IdentityData> local_identities;
    int next_local_identity_index = 0;

    IdentityData find_or_create_local_identity(NodeID nodeid)
    {
        if (local_identities == null) local_identities = new HashMap<int,IdentityData>();
        if (nodeid.id in local_identities.keys) return local_identities[nodeid.id];
        IdentityData ret = new IdentityData(nodeid, next_local_identity_index++);
        local_identities[nodeid.id] = ret;
        return ret;
    }

    IdentityData? find_local_identity(NodeID nodeid)
    {
        assert(local_identities != null);
        if (nodeid.id in local_identities.keys) return local_identities[nodeid.id];
        return null;
    }

    IdentityData? find_local_identity_by_index(int local_identity_index)
    {
        assert(local_identities != null);
        foreach (IdentityData id in local_identities.values)
            if (id.local_identity_index == local_identity_index)
            return id;
        return null;
    }

    void remove_local_identity(NodeID nodeid)
    {
        assert(local_identities != null);
        assert(nodeid.id in local_identities.keys);
        local_identities.unset(nodeid.id);
    }

    IdentityArc? find_identity_arc(IIdmgmtIdentityArc id_arc)
    {
        foreach (IdentityData id in local_identities.values) foreach (IdentityArc ia in id.identity_arcs)
        {
            if (ia.id_arc == id_arc)
            {
                return ia;
            }
        }
        return null;
    }

    IdentityArc? find_identity_arc_by_peer_nodeid(IdentityData identity_data, IIdmgmtArc arc, NodeID peer_nodeid)
    {
        foreach (IdentityArc ia in identity_data.identity_arcs)
        {
            if (ia.arc == arc)
             if (ia.id_arc.get_peer_nodeid().equals(peer_nodeid))
                return ia;
        }
        return null;
    }

    const int max_paths = 5;
    const double max_common_hops_ratio = 0.6;
    const int arc_timeout = 10000;

    int main(string[] _args)
    {
        pid = 0; // default
        topology = "1,1,1,2"; // default
        firstaddr = ""; // default
        subnetlevel = 0; // default
        accept_anonymous_requests = false; // default
        no_anonymize = false; // default
        OptionContext oc = new OptionContext("<options>");
        OptionEntry[] entries = new OptionEntry[8];
        int index = 0;
        entries[index++] = {"topology", '\0', 0, OptionArg.STRING, ref topology, "Topology in bits. Default: 1,1,1,2", null};
        entries[index++] = {"firstaddr", '\0', 0, OptionArg.STRING, ref firstaddr, "First address. E.g. '0,0,1,3'. Default is random.", null};
        entries[index++] = {"pid", 'p', 0, OptionArg.INT, ref pid, "Fake PID (e.g. -p 1234).", null};
        entries[index++] = {"interfaces", 'i', 0, OptionArg.STRING_ARRAY, ref interfaces, "Interface (e.g. -i eth1). You can use it multiple times.", null};
        entries[index++] = {"subnetlevel", 's', 0, OptionArg.INT, ref subnetlevel, "Level of g-node for autonomous subnet", null};
        entries[index++] = {"serve-anonymous", 'k', 0, OptionArg.NONE, ref accept_anonymous_requests, "Accept anonymous requests", null};
        entries[index++] = {"no-anonymize", 'j', 0, OptionArg.NONE, ref no_anonymize, "Disable anonymizer", null};
        entries[index++] = { null };
        oc.add_main_entries(entries, null);
        try {
            oc.parse(ref _args);
        }
        catch (OptionError e) {
            print(@"Error parsing options: $(e.message)\n");
            return 1;
        }

        ArrayList<string> args = new ArrayList<string>.wrap(_args);

        ArrayList<int> naddr;
        ArrayList<string> devs;

        // Topoplogy of the network.
        gsizes = new ArrayList<int>();
        g_exp = new ArrayList<int>();
        string[] topology_bits_array = topology.split(",");
        foreach (string s_topology_bits in topology_bits_array)
        {
            int64 topology_bits;
            if (! int64.try_parse(s_topology_bits, out topology_bits)) error("Bad arg topology");
            int _g_exp = (int)topology_bits;

            if (_g_exp < 1 || _g_exp > 16) error(@"Bad g_exp $(_g_exp): must be between 1 and 16");
            int gsize = 1 << _g_exp;
            g_exp.add(_g_exp);
            gsizes.add(gsize);
        }
        levels = gsizes.size;
        naddr = new ArrayList<int>();
        // If first address is forced:
        if (firstaddr != "")
        {
            string[] firstaddr_array = firstaddr.split(",");
            if (firstaddr_array.length != levels) error("Bad first address");
            for (int i = 0; i < levels; i++)
            {
                string s_firstaddr_part = firstaddr_array[i];
                int64 i_firstaddr_part;
                if (! int64.try_parse(s_firstaddr_part, out i_firstaddr_part)) error("Bad first address");
                if (i_firstaddr_part < 0 || i_firstaddr_part > gsizes[i]-1) error("Bad first address");
                naddr.add((int)i_firstaddr_part);
            }
        }

        hooking_epsilon = new ArrayList<int>();
        for (int i = 0; i < levels; i++)
        {
            int delta_bits = 5;
            int eps = 0;
            int j = i;
            while (delta_bits > 0 && j < levels)
            {
                eps++;
                delta_bits -= g_exp[j];
                j++;
            }
            eps++;
            hooking_epsilon.add(eps);
        }

        // Names of the network interfaces to monitor.
        devs = new ArrayList<string>();
        foreach (string dev in interfaces) devs.add(dev);

        if (pid == 0) error("Bad usage");
        if (devs.is_empty) error("Bad usage");

        // Initialize tasklet system
        PthTaskletImplementer.init();
        tasklet = PthTaskletImplementer.get_tasklet_system();

        // Initialize modules that have remotable methods (serializable classes need to be registered).
        NeighborhoodManager.init(tasklet);
        IdentityManager.init(tasklet);
        QspnManager.init(tasklet, max_paths, max_common_hops_ratio, arc_timeout, new ThresholdCalculator());
        typeof(WholeNodeSourceID).class_peek();
        typeof(WholeNodeUnicastID).class_peek();
        typeof(EveryWholeNodeBroadcastID).class_peek();
        typeof(NeighbourSrcNic).class_peek();
        typeof(IdentityAwareSourceID).class_peek();
        typeof(IdentityAwareUnicastID).class_peek();
        typeof(IdentityAwareBroadcastID).class_peek();
        typeof(Naddr).class_peek();
        typeof(Fingerprint).class_peek();
        typeof(Cost).class_peek();

        // Initialize pseudo-random number generators.
        string _seed = @"$(pid)";
        uint32 seed_prn = (uint32)_seed.hash();
        PRNGen.init_rngen(null, seed_prn);
        NeighborhoodManager.init_rngen(null, seed_prn);
        IdentityManager.init_rngen(null, seed_prn);
        QspnManager.init_rngen(null, seed_prn);

        // If first address is random:
        if (firstaddr == "")
            for (int i = 0; i < levels; i++)
                naddr.add((int)PRNGen.int_range(0, gsizes[i]));

        // Commander
        real_cm = Commander.get_singleton();
        fake_cm = new FakeCommandDispatcher();
        tn = TableNames.get_singleton();

        // Pass tasklet system to the RPC library (ntkdrpc)
        init_tasklet_system(tasklet);

        // RPC
        skeleton_factory = new SkeletonFactory();
        stub_factory = new StubFactory();

        int bid = fake_cm.begin_block();
        fake_cm.single_command_in_block(bid, new ArrayList<string>.wrap({
            @"sysctl", @"net.ipv4.ip_forward=1"}));
        fake_cm.single_command_in_block(bid, new ArrayList<string>.wrap({
            @"sysctl", @"net.ipv4.conf.all.rp_filter=0"}));
        fake_cm.end_block(bid);

        // Init module Neighborhood
        neighborhood_mgr = new NeighborhoodManager(
            1000 /*very high max_arcs*/,
            new NeighborhoodStubFactory(),
            new NeighborhoodQueryCallerInfo(),
            new NeighborhoodIPRouteManager(),
            () => @"169.254.$(PRNGen.int_range(0, 255)).$(PRNGen.int_range(0, 255))");
        skeleton_factory.whole_node_id = neighborhood_mgr.get_my_neighborhood_id();
        // connect signals
        neighborhood_mgr.nic_address_set.connect(neighborhood_nic_address_set);
        neighborhood_mgr.arc_added.connect(neighborhood_arc_added);
        neighborhood_mgr.arc_changed.connect(neighborhood_arc_changed);
        neighborhood_mgr.arc_removing.connect(neighborhood_arc_removing);
        neighborhood_mgr.arc_removed.connect(neighborhood_arc_removed);
        neighborhood_mgr.nic_address_unset.connect(neighborhood_nic_address_unset);

        handlednic_map = new HashMap<string,HandledNic>();
        pseudonic_map = new HashMap<string,PseudoNetworkInterface>();
        Gee.List<string> if_list_dev = new ArrayList<string>();
        Gee.List<string> if_list_mac = new ArrayList<string>();
        Gee.List<string> if_list_linklocal = new ArrayList<string>();
        foreach (string dev in devs)
        {
            assert(!(dev in pseudonic_map.keys));
            string listen_pathname = @"recv_$(pid)_$(dev)";
            string send_pathname = @"send_$(pid)_$(dev)";
            string mac = @"fe:aa:aa:$(PRNGen.int_range(10, 99)):$(PRNGen.int_range(10, 99)):$(PRNGen.int_range(10, 99))";
            print(@"INFO: mac for $(pid),$(dev) is $(mac).\n");
            PseudoNetworkInterface pseudonic = new PseudoNetworkInterface(dev, listen_pathname, send_pathname, mac);
            pseudonic_map[dev] = pseudonic;

            // Set up NIC
            bid = fake_cm.begin_block();
            fake_cm.single_command_in_block(bid, new ArrayList<string>.wrap({
                @"sysctl", @"net.ipv4.conf.$(dev).rp_filter=0"}));
            fake_cm.single_command_in_block(bid, new ArrayList<string>.wrap({
                @"sysctl", @"net.ipv4.conf.$(dev).arp_ignore=1"}));
            fake_cm.single_command_in_block(bid, new ArrayList<string>.wrap({
                @"sysctl", @"net.ipv4.conf.$(dev).arp_announce=2"}));
            fake_cm.single_command_in_block(bid, new ArrayList<string>.wrap({
                @"ip", @"link", @"set", @"dev", @"$(dev)", @"address", @"$(mac)"}));
            fake_cm.single_command_in_block(bid, new ArrayList<string>.wrap({
                @"ip", @"link", @"set", @"dev", @"$(dev)", @"up"}));
            fake_cm.end_block(bid);

            // Start listen datagram on dev
            skeleton_factory.start_datagram_system_listen(listen_pathname, send_pathname, new NeighbourSrcNic(mac));
            print(@"started datagram_system_listen $(listen_pathname) $(send_pathname) $(mac).\n");
            // Run monitor. This will also set the IP link-local address,
            //  the stream_listener will start and the 'linklocal' field will be compiled.
            neighborhood_mgr.start_monitor(pseudonic_map[dev].nic);
            tasklet.ms_wait(5);
            print(@"INFO: linklocal for $(mac) is $(handlednic_map[dev].linklocal).\n");

            if_list_dev.add(dev);
            if_list_mac.add(mac);
            if_list_linklocal.add(handlednic_map[dev].linklocal);
        }

        // Init module Identities
        identity_mgr = new IdentityManager(
            if_list_dev, if_list_mac, if_list_linklocal,
            new IdmgmtNetnsManager(),
            new IdmgmtStubFactory(),
            () => @"169.254.$(PRNGen.int_range(0, 255)).$(PRNGen.int_range(0, 255))");
        // connect signals
        identity_mgr.identity_arc_added.connect(identities_identity_arc_added);
        identity_mgr.identity_arc_changed.connect(identities_identity_arc_changed);
        identity_mgr.identity_arc_removing.connect(identities_identity_arc_removing);
        identity_mgr.identity_arc_removed.connect(identities_identity_arc_removed);
        identity_mgr.arc_removed.connect(identities_arc_removed);

        // first id
        NodeID first_nodeid = identity_mgr.get_main_id();
        string first_identity_name = @"$(pid)_$(next_local_identity_index)";
        print(@"INFO: nodeid for $(first_identity_name) is $(first_nodeid.id).\n");
        IdentityData first_identity_data = find_or_create_local_identity(first_nodeid);
        main_identity_data = first_identity_data;

        first_identity_data.my_naddr = new Naddr(naddr.to_array(), gsizes.to_array());
        ArrayList<int> elderships = new ArrayList<int>();
        for (int i = 0; i < levels; i++) elderships.add(0);
        first_identity_data.my_fp = new Fingerprint(elderships.to_array());
        print(@"INFO: $(first_identity_name) has address $(json_string_object(first_identity_data.my_naddr))");
        print(@" and fp $(json_string_object(first_identity_data.my_fp)).\n");

        // iproute commands for startup first identity
        IpCompute.new_main_id(first_identity_data);
        IpCompute.new_id(first_identity_data);
        IpCommands.main_start(first_identity_data);

        // First qspn manager
        first_identity_data.qspn_mgr = new QspnManager.create_net(
            first_identity_data.my_naddr,
            first_identity_data.my_fp,
            new QspnStubFactory(first_identity_data.local_identity_index));
        identity_mgr.set_identity_module(first_identity_data.nodeid, "qspn", first_identity_data.qspn_mgr);
        // immediately after creation, connect to signals.
        first_identity_data.qspn_mgr.arc_removed.connect(first_identity_data.arc_removed);
        first_identity_data.qspn_mgr.changed_fp.connect(first_identity_data.changed_fp);
        first_identity_data.qspn_mgr.changed_nodes_inside.connect(first_identity_data.changed_nodes_inside);
        first_identity_data.qspn_mgr.destination_added.connect(first_identity_data.destination_added);
        first_identity_data.qspn_mgr.destination_removed.connect(first_identity_data.destination_removed);
        first_identity_data.qspn_mgr.gnode_splitted.connect(first_identity_data.gnode_splitted);
        first_identity_data.qspn_mgr.path_added.connect(first_identity_data.path_added);
        first_identity_data.qspn_mgr.path_changed.connect(first_identity_data.path_changed);
        first_identity_data.qspn_mgr.path_removed.connect(first_identity_data.path_removed);
        first_identity_data.qspn_mgr.presence_notified.connect(first_identity_data.presence_notified);
        first_identity_data.qspn_mgr.qspn_bootstrap_complete.connect(first_identity_data.qspn_bootstrap_complete);
        first_identity_data.qspn_mgr.remove_identity.connect(first_identity_data.remove_identity);

        // First identity is immediately bootstrapped.
        while (! first_identity_data.qspn_mgr.is_bootstrap_complete()) tasklet.ms_wait(1);

        first_identity_data = null;

        // register handlers for SIGINT and SIGTERM to exit
        Posix.@signal(Posix.Signal.INT, safe_exit);
        Posix.@signal(Posix.Signal.TERM, safe_exit);
        // Main loop
        while (true)
        {
            tasklet.ms_wait(100);
            if (do_me_exit) break;
        }
        print(@"[$(printabletime())]: Shutting down.\n");

        // Remove connectivity identities and their network namespaces and linklocal addresses.
        ArrayList<IdentityData> local_identities_copy = new ArrayList<IdentityData>();
        local_identities_copy.add_all(local_identities.values);
        foreach (IdentityData identity_data in local_identities_copy)
        {
            if (! identity_data.main_id)
            {
                // ... send "destroy" message.
                identity_data.qspn_mgr.destroy();
                // ... disconnect signal handlers of qspn_mgr.
                identity_data.qspn_mgr.arc_removed.disconnect(identity_data.arc_removed);
                identity_data.qspn_mgr.changed_fp.disconnect(identity_data.changed_fp);
                identity_data.qspn_mgr.changed_nodes_inside.disconnect(identity_data.changed_nodes_inside);
                identity_data.qspn_mgr.destination_added.disconnect(identity_data.destination_added);
                identity_data.qspn_mgr.destination_removed.disconnect(identity_data.destination_removed);
                identity_data.qspn_mgr.gnode_splitted.disconnect(identity_data.gnode_splitted);
                identity_data.qspn_mgr.path_added.disconnect(identity_data.path_added);
                identity_data.qspn_mgr.path_changed.disconnect(identity_data.path_changed);
                identity_data.qspn_mgr.path_removed.disconnect(identity_data.path_removed);
                identity_data.qspn_mgr.presence_notified.disconnect(identity_data.presence_notified);
                identity_data.qspn_mgr.qspn_bootstrap_complete.disconnect(identity_data.qspn_bootstrap_complete);
                identity_data.qspn_mgr.remove_identity.disconnect(identity_data.remove_identity);
                identity_data.qspn_mgr.stop_operations();

                // remove namespace
                identity_mgr.remove_identity(identity_data.nodeid);

                // remove from local_identities
                remove_local_identity(identity_data.nodeid);

                // when needed, remove ntk_from_xxx from rt_tables
                error("not in this test");
                /*
                ArrayList<string> peermacs = new ArrayList<string>();
                foreach (IdentityArc id_arc in identity_data.identity_arcs)
                    if (id_arc.qspn_arc != null)
                    peermacs.add(id_arc.peer_mac);
                IpCommands.connectivity_stop(identity_data, peermacs);
                */
            }
        }
        local_identities_copy = null;

        // For main identity...
        assert(local_identities.keys.size == 1);
        IdentityData last_identity_data = local_identities.values.to_array()[0];
        assert(last_identity_data.main_id);

        // ... send "destroy" message.
        last_identity_data.qspn_mgr.destroy();
        // ... disconnect signal handlers of qspn_mgr.
        last_identity_data.qspn_mgr.arc_removed.disconnect(last_identity_data.arc_removed);
        last_identity_data.qspn_mgr.changed_fp.disconnect(last_identity_data.changed_fp);
        last_identity_data.qspn_mgr.changed_nodes_inside.disconnect(last_identity_data.changed_nodes_inside);
        last_identity_data.qspn_mgr.destination_added.disconnect(last_identity_data.destination_added);
        last_identity_data.qspn_mgr.destination_removed.disconnect(last_identity_data.destination_removed);
        last_identity_data.qspn_mgr.gnode_splitted.disconnect(last_identity_data.gnode_splitted);
        last_identity_data.qspn_mgr.path_added.disconnect(last_identity_data.path_added);
        last_identity_data.qspn_mgr.path_changed.disconnect(last_identity_data.path_changed);
        last_identity_data.qspn_mgr.path_removed.disconnect(last_identity_data.path_removed);
        last_identity_data.qspn_mgr.presence_notified.disconnect(last_identity_data.presence_notified);
        last_identity_data.qspn_mgr.qspn_bootstrap_complete.disconnect(last_identity_data.qspn_bootstrap_complete);
        last_identity_data.qspn_mgr.remove_identity.disconnect(last_identity_data.remove_identity);
        last_identity_data.qspn_mgr.stop_operations();

        // Call stop_rpc.
        ArrayList<string> final_devs = new ArrayList<string>();
        final_devs.add_all(pseudonic_map.keys);
        foreach (string dev in final_devs) stop_rpc(dev);

        // iproute commands for cleanup main identity
        ArrayList<string> peermacs = new ArrayList<string>();
        foreach (IdentityArc id_arc in last_identity_data.identity_arcs)
        {
            error("not in this test");
            /*
            if (id_arc.qspn_arc != null)
            {
                peermacs.add(id_arc.peer_mac);
            }
            */
        }
        IpCommands.main_stop(last_identity_data, peermacs);

        remove_local_identity(last_identity_data.nodeid);
        last_identity_data = null;

        // Then we destroy the object NeighborhoodManager.
        neighborhood_mgr = null;
        tasklet.ms_wait(100);

        // print all commands from fake_cm
        print("\n=== all commands ===\n");
        foreach (string c in fake_cm.list_all_commands) print(@"$(c)\n");
        print("=== END all commands ===\n");

        PthTaskletImplementer.kill();

        return 0;
    }

    bool do_me_exit = false;
    void safe_exit(int sig)
    {
        // We got here because of a signal. Quick processing.
        do_me_exit = true;
    }

    void stop_rpc(string dev)
    {
        string linklocal = handlednic_map[dev].linklocal;
        PseudoNetworkInterface pseudonic = pseudonic_map[dev];
        skeleton_factory.stop_stream_system_listen(pseudonic.st_listen_pathname);
        print(@"stopped stream_system_listen $(pseudonic.st_listen_pathname).\n");
        neighborhood_mgr.stop_monitor(dev);
        skeleton_factory.stop_datagram_system_listen(pseudonic.listen_pathname);
        print(@"stopped datagram_system_listen $(pseudonic.listen_pathname).\n");
        pseudonic_map.unset(dev);
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

    class HandledNic : Object
    {
        public HandledNic(string dev, string mac, string linklocal, INeighborhoodNetworkInterface nic)
        {
            this.dev = dev;
            this.mac = mac;
            this.linklocal = linklocal;
            this.nic = nic;
        }

        public string dev {get; private set;}
        public string mac {get; private set;}
        public string linklocal {get; private set;}
        public INeighborhoodNetworkInterface nic {get; private set;}
    }

    // not used in this test
    /*
    class NodeArc : Object
    {
        public NodeArc(INeighborhoodArc neighborhood_arc, IdmgmtArc i_arc)
        {
            this.neighborhood_arc = neighborhood_arc;
            this.i_arc = i_arc;
        }
        public INeighborhoodArc neighborhood_arc;
        public IdmgmtArc i_arc; // for module Identities
    }
    */

    IdentityData main_identity_data;
    class IdentityData : Object
    {
        public IdentityData(NodeID nodeid, int local_identity_index)
        {
            this.local_identity_index = local_identity_index;
            this.nodeid = nodeid;
            identity_arcs = new ArrayList<IdentityArc>();
            connectivity_from_level = 0;
            connectivity_to_level = 0;
            copy_of_identity = null;
            local_ip_set = null;
            dest_ip_set = null;
            bootstrap_phase_pending_updates = new ArrayList<HCoord>();
            qspn_mgr = null;
        }

        public int local_identity_index;

        public NodeID nodeid;
        public Naddr my_naddr;
        public Fingerprint my_fp;
        public int connectivity_from_level;
        public int connectivity_to_level;
        public weak IdentityData? copy_of_identity;
        public Gee.List<HCoord> bootstrap_phase_pending_updates;

        public QspnManager qspn_mgr;

        public ArrayList<IdentityArc> identity_arcs;
        public IdentityArc? identity_arcs_find(IIdmgmtArc arc, IIdmgmtIdentityArc id_arc)
        {
            assert(identity_arcs != null);
            foreach (IdentityArc ia in identity_arcs)
                if (ia.arc == arc && ia.id_arc == id_arc)
                return ia;
            return null;
        }

        public LocalIPSet? local_ip_set;
        public DestinationIPSet? dest_ip_set;

        private string _network_namespace;
        public string network_namespace {
            get {
                _network_namespace = identity_mgr.get_namespace(nodeid);
                return _network_namespace;
            }
        }

        // Use this to signal when a identity (that was main) has become of connectivity.
        public signal void gone_connectivity();

        public bool main_id {
            get {
                return this == main_identity_data;
            }
        }

        // handle signals from qspn_manager

        public void arc_removed(IQspnArc arc, bool bad_link)
        {
            per_identity_qspn_arc_removed(this, arc, bad_link);
        }

        public void changed_fp(int l)
        {
            per_identity_qspn_changed_fp(this, l);
        }

        public void changed_nodes_inside(int l)
        {
            per_identity_qspn_changed_nodes_inside(this, l);
        }

        public void destination_added(HCoord h)
        {
            per_identity_qspn_destination_added(this, h);
        }

        public void destination_removed(HCoord h)
        {
            per_identity_qspn_destination_removed(this, h);
        }

        public void gnode_splitted(IQspnArc a, HCoord d, IQspnFingerprint fp)
        {
            per_identity_qspn_gnode_splitted(this, a, d, fp);
        }

        public void path_added(IQspnNodePath p)
        {
            per_identity_qspn_path_added(this, p);
        }

        public void path_changed(IQspnNodePath p)
        {
            per_identity_qspn_path_changed(this, p);
        }

        public void path_removed(IQspnNodePath p)
        {
            per_identity_qspn_path_removed(this, p);
        }

        public void presence_notified()
        {
            per_identity_qspn_presence_notified(this);
        }

        public void qspn_bootstrap_complete()
        {
            per_identity_qspn_qspn_bootstrap_complete(this);
        }

        public void remove_identity()
        {
            per_identity_qspn_remove_identity(this);
        }
    }

    class IdentityArc : Object
    {
        private int local_identity_index;
        private IdentityData? _identity_data;
        public IdentityData identity_data {
            get {
                _identity_data = find_local_identity_by_index(local_identity_index);
                if (_identity_data == null) tasklet.exit_tasklet();
                return _identity_data;
            }
        }
        public IIdmgmtArc arc;
        public IIdmgmtIdentityArc id_arc;
        public string peer_mac;
        public string peer_linklocal;

        public QspnArc? qspn_arc;
        public int64? network_id;
        public string? prev_peer_mac;
        public string? prev_peer_linklocal;

        public IdentityArc(int local_identity_index, IIdmgmtArc arc, IIdmgmtIdentityArc id_arc)
        {
            this.local_identity_index = local_identity_index;
            this.arc = arc;
            this.id_arc = id_arc;
            peer_mac = id_arc.get_peer_mac();
            peer_linklocal = id_arc.get_peer_linklocal();

            qspn_arc = null;
            network_id = null;
            prev_peer_mac = null;
            prev_peer_linklocal = null;
        }
    }

    class LocalIPSet : Object
    {
        public string global;
        public string anonymizing;
        public HashMap<int,string> intern;
        public string anonymizing_range;
        public string netmap_range1;
        public HashMap<int,string> netmap_range2;
        public HashMap<int,string> netmap_range3;
        public string netmap_range2_upper;
        public string netmap_range3_upper;
        public string netmap_range4;

        public LocalIPSet()
        {
            intern = new HashMap<int,string>();
            netmap_range2 = new HashMap<int,string>();
            netmap_range3 = new HashMap<int,string>();
        }

        public LocalIPSet copy()
        {
            LocalIPSet ret = new LocalIPSet();
            ret.global = this.global;
            ret.anonymizing = this.anonymizing;
            foreach (int k in this.intern.keys) ret.intern[k] = this.intern[k];
            ret.anonymizing_range = this.anonymizing_range;
            ret.netmap_range1 = this.netmap_range1;
            foreach (int k in this.netmap_range2.keys) ret.netmap_range2[k] = this.netmap_range2[k];
            foreach (int k in this.netmap_range3.keys) ret.netmap_range3[k] = this.netmap_range3[k];
            ret.netmap_range2_upper = this.netmap_range2_upper;
            ret.netmap_range3_upper = this.netmap_range3_upper;
            ret.netmap_range4 = this.netmap_range4;
            return ret;
        }
    }

    class DestinationIPSetGnode : Object
    {
        public string global;
        public string anonymizing;
        public HashMap<int,string> intern;

        public DestinationIPSetGnode()
        {
            intern = new HashMap<int,string>();
        }

        public DestinationIPSetGnode copy()
        {
            DestinationIPSetGnode ret = new DestinationIPSetGnode();
            ret.global = this.global;
            ret.anonymizing = this.anonymizing;
            foreach (int k in this.intern.keys) ret.intern[k] = this.intern[k];
            return ret;
        }
    }

    class DestinationIPSet : Object
    {
        public HashMap<HCoord,DestinationIPSetGnode> gnode;

        public DestinationIPSet()
        {
            gnode = new HashMap<HCoord,DestinationIPSetGnode>((x) => 0, (a, b) => a.equals(b));
        }

        private Gee.List<HCoord> _sorted_gnode_keys;
        public Gee.List<HCoord> sorted_gnode_keys
        {
            get {
                ArrayList<HCoord> ret = new ArrayList<HCoord>((a, b) => a.equals(b));
                ret.add_all(gnode.keys);
                ret.sort((a, b) => {
                    if (a.lvl > b.lvl) return -1;
                    if (a.lvl < b.lvl) return 1;
                    return a.pos - b.pos;
                });
                _sorted_gnode_keys = ret;
                return _sorted_gnode_keys;
            }
        }

        public DestinationIPSet copy()
        {
            DestinationIPSet ret = new DestinationIPSet();
            foreach (HCoord hc in gnode.keys)
            {
                ret.gnode[hc] = gnode[hc].copy();
            }
            return ret;
        }
    }
}
