/*
 *  This file is part of Netsukuku.
 *  Copyright (C) 2018-2019 Luca Dionisi aka lukisi <luca.dionisi@gmail.com>
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
using Netsukuku;
using Netsukuku.Neighborhood;
//using Netsukuku.Identities;
//using Netsukuku.Qspn;
//using Netsukuku.Coordinator;
//using Netsukuku.Hooking;
//using Netsukuku.Andna;
using TaskletSystem;

namespace Netsukuku
{
    class SkeletonFactory : Object
    {
        public SkeletonFactory()
        {
            this.node_skeleton = new NodeSkeleton();
            dlg = new ServerDelegate(this);
        }

        private NodeSkeleton node_skeleton;
        public NeighborhoodNodeID whole_node_id {
            get {
                return node_skeleton.id;
            }
            set {
                node_skeleton.id = value;
            }
        }
        // private List<IdentitySkeleton>...

        private ServerDelegate dlg;
        HashMap<string,IListenerHandle> handles_by_listen_pathname;

        public void start_stream_system_listen(string listen_pathname)
        {
            IErrorHandler stream_system_err = new ServerErrorHandler(@"for stream_system_listen $(listen_pathname)");
            if (handles_by_listen_pathname == null) handles_by_listen_pathname = new HashMap<string,IListenerHandle>();
            handles_by_listen_pathname[listen_pathname] = stream_system_listen(dlg, stream_system_err, listen_pathname);
        }
        public void stop_stream_system_listen(string listen_pathname)
        {
            assert(handles_by_listen_pathname != null);
            assert(handles_by_listen_pathname.has_key(listen_pathname));
            IListenerHandle lh = handles_by_listen_pathname[listen_pathname];
            lh.kill();
            handles_by_listen_pathname.unset(listen_pathname);
        }

        public void start_datagram_system_listen(string listen_pathname, string send_pathname, ISrcNic src_nic)
        {
            IErrorHandler datagram_system_err = new ServerErrorHandler(@"for datagram_system_listen $(listen_pathname) $(send_pathname) TODO SrcNic.tostring()");
            if (handles_by_listen_pathname == null) handles_by_listen_pathname = new HashMap<string,IListenerHandle>();
            handles_by_listen_pathname[listen_pathname] = datagram_system_listen(dlg, datagram_system_err, listen_pathname, send_pathname, src_nic);
        }
        public void stop_datagram_system_listen(string listen_pathname)
        {
            assert(handles_by_listen_pathname != null);
            assert(handles_by_listen_pathname.has_key(listen_pathname));
            IListenerHandle lh = handles_by_listen_pathname[listen_pathname];
            lh.kill();
            handles_by_listen_pathname.unset(listen_pathname);
        }

        [NoReturn]
        private void abort_tasklet(string msg_warning)
        {
            warning(msg_warning);
            tasklet.exit_tasklet();
        }

        private Gee.List<IAddressManagerSkeleton> get_dispatcher_set(DatagramCallerInfo caller_info)
        {
            if (caller_info.source_id is IdentityAwareSourceID)
            {
                error("not in this test");
                /*
                IdentityAwareSourceID _source_id = (IdentityAwareSourceID)caller_info.source_id;
                NodeID source_nodeid = _source_id.id;
                if (! (caller_info.broadcast_id is IdentityAwareBroadcastID)) abort_tasklet(@"Bad caller_info.broadcast_id");
                IdentityAwareBroadcastID _broadcast_set = (IdentityAwareBroadcastID)caller_info.broadcast_id;
                Gee.List<NodeID> broadcast_set = _broadcast_set.id_set;
                if (! (caller_info.src_nic is NeighbourSrcNic)) abort_tasklet(@"Bad caller_info.src_nic");
                string peer_mac = ((NeighbourSrcNic)caller_info.src_nic).mac;
                if (! (caller_info.listener is DatagramSystemListener)) abort_tasklet(@"Bad caller_info.listener");
                string caller_listen_pathname = ((DatagramSystemListener)caller_info.listener).listen_pathname;
                string my_dev = null;
                foreach (string dev in pseudonic_map.keys)
                {
                    if (pseudonic_map[dev].listen_pathname == caller_listen_pathname)
                    {
                        my_dev = dev;
                        break;
                    }
                }
                if (my_dev == null) abort_tasklet(@"Bad caller_info.listener.listen_pathname=$(caller_listen_pathname)");
                return get_identity_skeleton_set(source_nodeid, broadcast_set, peer_mac, my_dev);
                */
            }
            else if (caller_info.source_id is WholeNodeSourceID)
            {
                if (! (caller_info.broadcast_id is EveryWholeNodeBroadcastID)) abort_tasklet(@"Bad caller_info.broadcast_id");
                Gee.List<IAddressManagerSkeleton> ret = new ArrayList<IAddressManagerSkeleton>();
                ret.add(node_skeleton);
                return ret;
            }
            else
            {
                abort_tasklet(@"Bad caller_info.source_id");
            }
        }

        /*
        private Gee.List<IAddressManagerSkeleton>
        get_identity_skeleton_set(
            NodeID source_nodeid,
            Gee.List<NodeID> broadcast_set,
            string peer_mac,
            string my_dev)
        {
            ArrayList<IAddressManagerSkeleton> ret = new ArrayList<IAddressManagerSkeleton>();
            foreach (IdentityData local_identity_data in local_identities.values)
            {
                NodeID local_nodeid = local_identity_data.nodeid;
                if (local_nodeid in broadcast_set)
                {
                    foreach (IdentityArc ia in local_identity_data.identity_arcs)
                    {
                        if (ia.arc.get_peer_mac() == peer_mac
                            && ia.arc.get_dev() == my_dev)
                        {
                            if (ia.id_arc.get_peer_nodeid().equals(source_nodeid))
                            {
                                ret.add(new IdentitySkeleton(local_identity_data.local_identity_index));
                            }
                        }
                    }
                }
            }
            return ret;
        }
        */

        public string?
        from_caller_get_mydev(CallerInfo _rpc_caller)
        {
            if (_rpc_caller is StreamCallerInfo)
            {error("not implemented yet");}
            else if (_rpc_caller is DatagramCallerInfo)
            {
                DatagramCallerInfo rpc_caller = (DatagramCallerInfo)_rpc_caller;
                assert(rpc_caller.listener is DatagramSystemListener);
                DatagramSystemListener _listener = (DatagramSystemListener)rpc_caller.listener;
                foreach (string dev in pseudonic_map.keys)
                {
                    PseudoNetworkInterface pseudonic = pseudonic_map[dev];
                    if (pseudonic.listen_pathname != _listener.listen_pathname) continue;
                    if (pseudonic.send_pathname != _listener.send_pathname) continue;
                    return dev;
                }
                assert_not_reached();
            }
            else abort_tasklet(@"Unknown caller_info: $(_rpc_caller.get_type().name())");
        }

        /* Get NodeArc where a received message has transited. For whole-node requests.
         */
        // no arcs in this testsuite.
        /*
        public NodeArc?
        from_caller_get_nodearc(CallerInfo rpc_caller)
        {
            if (rpc_caller is StreamCallerInfo)
            {
                // in this test we have only WholeNodeSourceID
                StreamCallerInfo caller_info = (StreamCallerInfo)rpc_caller;
                ISourceID _source_id = caller_info.source_id;
                if (! (_source_id is WholeNodeSourceID)) return null;
                NeighborhoodNodeID peer_node_id = ((WholeNodeSourceID)_source_id).id;
                Listener listener = caller_info.listener;
                assert(listener is StreamSystemListener);
                string listen_pathname = ((StreamSystemListener)listener).listen_pathname;
                assert(caller_info.src_nic is NeighbourSrcNic);
                NeighbourSrcNic src_nic = (NeighbourSrcNic)caller_info.src_nic;
                string neighbour_mac = src_nic.mac;
                foreach (int id in arc_map.keys)
                {
                    NodeArc node_arc = arc_map[id];
                    INeighborhoodArc neighborhood_arc = node_arc.neighborhood_arc;
                    PseudoNetworkInterface arc_my_pseudonic = pseudonic_map[neighborhood_arc.nic.dev];
                    // check listen_pathname
                    if (arc_my_pseudonic.st_listen_pathname != listen_pathname) continue;
                    // check neighbour_mac
                    if (neighborhood_arc.neighbour_mac != neighbour_mac) continue;
                    // check peer_node_id
                    if (neighborhood_arc.neighbour_id.equals(peer_node_id)) return node_arc;
                }
                return null;
            }
            else
            {
                // unexpected class.
                return null;
            }
        }
        */

        // from_caller_get_identityarc not in this test (there will be no arcs)

        private class ServerErrorHandler : Object, IErrorHandler
        {
            private string name;
            public ServerErrorHandler(string name)
            {
                this.name = name;
            }

            public void error_handler(Error e)
            {
                error(@"ServerErrorHandler '$(name)': $(e.message)");
            }
        }

        private class ServerDelegate : Object, IDelegate
        {
            public ServerDelegate(SkeletonFactory skeleton_factory)
            {
                this.skeleton_factory = skeleton_factory;
            }
            private SkeletonFactory skeleton_factory;

            public Gee.List<IAddressManagerSkeleton> get_addr_set(CallerInfo caller_info)
            {
                if (caller_info is StreamCallerInfo)
                {
                    error("not in this test");
                    /*
                    StreamCallerInfo c = (StreamCallerInfo)caller_info;
                    var ret = new ArrayList<IAddressManagerSkeleton>();
                    IAddressManagerSkeleton? d = skeleton_factory.get_dispatcher(c);
                    if (d != null) ret.add(d);
                    return ret;
                    */
                }
                else if (caller_info is DatagramCallerInfo)
                {
                    DatagramCallerInfo c = (DatagramCallerInfo)caller_info;
                    return skeleton_factory.get_dispatcher_set(c);
                }
                else
                {
                    error(@"Unexpected class $(caller_info.get_type().name())");
                }
            }
        }

        /* A skeleton for the whole-node remotable methods
         */
        private class NodeSkeleton : Object, IAddressManagerSkeleton
        {
            public NeighborhoodNodeID id;

            public unowned INeighborhoodManagerSkeleton
            neighborhood_manager_getter()
            {
                // global var neighborhood_mgr is NeighborhoodManager, which is a INeighborhoodManagerSkeleton
                return neighborhood_mgr;
            }

            protected unowned IIdentityManagerSkeleton
            identity_manager_getter()
            {
                // global var identity_mgr is IdentityManager, which is a IIdentityManagerSkeleton
                return identity_mgr;
            }

            public unowned IQspnManagerSkeleton
            qspn_manager_getter()
            {
                error("not in this test");
            }

            public unowned IPeersManagerSkeleton
            peers_manager_getter()
            {
                error("not in this test");
            }

            public unowned ICoordinatorManagerSkeleton
            coordinator_manager_getter()
            {
                error("not in this test");
            }

            public unowned IHookingManagerSkeleton
            hooking_manager_getter()
            {
                error("not in this test");
            }

            /* TODO in ntkdrpc
            public unowned IAndnaManagerSkeleton
            andna_manager_getter()
            {
                error("not in this test");
            }
            */
        }

        /* A skeleton for the identity remotable methods
         */
        class IdentitySkeleton : Object, IAddressManagerSkeleton
        {
            public IdentitySkeleton(int local_identity_index)
            {
                this.local_identity_index = local_identity_index;
            }
            private int local_identity_index;
            private IdentityData? _identity_data;
            public IdentityData identity_data {
                get {
                    _identity_data = find_local_identity_by_index(local_identity_index);
                    if (_identity_data == null) tasklet.exit_tasklet();
                    return _identity_data;
                }
            }

            public unowned INeighborhoodManagerSkeleton
            neighborhood_manager_getter()
            {
                warning("IdentitySkeleton.neighborhood_manager_getter: not for identity");
                tasklet.exit_tasklet(null);
            }

            protected unowned IIdentityManagerSkeleton
            identity_manager_getter()
            {
                warning("IdentitySkeleton.identity_manager_getter: not for identity");
                tasklet.exit_tasklet(null);
            }

            public unowned IQspnManagerSkeleton
            qspn_manager_getter()
            {
                // member qspn_mgr of identity_data is QspnManager, which is a IQspnManagerSkeleton
                if (identity_data.qspn_mgr == null)
                {
                    print(@"IdentitySkeleton.qspn_manager_getter: id $(identity_data.nodeid.id) has qspn_mgr NULL. Might be too early, wait a bit.\n");
                    bool once_more = true; int wait_next = 5;
                    while (once_more)
                    {
                        once_more = false;
                        if (identity_data.qspn_mgr == null)
                        {
                            //  let's wait a bit and try again a few times.
                            if (wait_next < 3000) {
                                wait_next = wait_next * 10; tasklet.ms_wait(wait_next); once_more = true;
                            }
                        }
                        else
                        {
                            print(@"IdentitySkeleton.qspn_manager_getter: id $(identity_data.nodeid.id) now has qspn_mgr valid.\n");
                        }
                    }
                }
                if (identity_data.qspn_mgr == null)
                {
                    print(@"IdentitySkeleton.qspn_manager_getter: id $(identity_data.nodeid.id) has qspn_mgr NULL yet. Might be too late, abort responding.\n");
                    tasklet.exit_tasklet(null);
                }
                return identity_data.qspn_mgr;
            }

            public unowned IPeersManagerSkeleton
            peers_manager_getter()
            {
                // member peers_mgr of identity_data.
                if (identity_data.peers_mgr == null)
                {
                    warning(@"IdentitySkeleton.peers_manager_getter: id $(identity_data.nodeid.id) has peers_mgr NULL yet. Abort responding.");
                    tasklet.exit_tasklet(null);
                }
                return identity_data.peers_mgr;
            }

            public unowned ICoordinatorManagerSkeleton
            coordinator_manager_getter()
            {
                error("not in this test");
            }

            public unowned IHookingManagerSkeleton
            hooking_manager_getter()
            {
                error("not in this test");
            }

            /* TODO in ntkdrpc
            public unowned IAndnaManagerSkeleton
            andna_manager_getter()
            {
                error("not in this test");
            }
            */
        }
    }
}
