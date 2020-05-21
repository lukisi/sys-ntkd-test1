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
            if (! (caller_info.source_id is WholeNodeSourceID)) abort_tasklet(@"Bad caller_info.source_id");
            if (! (caller_info.broadcast_id is EveryWholeNodeBroadcastID)) abort_tasklet(@"Bad caller_info.broadcast_id");
            Gee.List<IAddressManagerSkeleton> ret = new ArrayList<IAddressManagerSkeleton>();
            ret.add(node_skeleton);
            return ret;
        }

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
        public NodeArc?
        from_caller_get_nodearc(CallerInfo rpc_caller)
        {
            return null; // no arcs in this testsuite.
            /*
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
                foreach (NodeArc node_arc in arc_list)
                {
                    INeighborhoodArc neighborhood_arc = node_arc.neighborhood_arc;
                    PseudoNetworkInterface arc_my_pseudonic = pseudonic_map[neighborhood_arc.nic.dev];
                    // check listen_pathname
                    if (arc_my_pseudonic.st_listen_pathname != listen_pathname) continue;
                    // check neighbour_mac
                    if (neighborhood_arc.neighbour_nic_addr != neighbour_mac) continue;
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
            */
        }

        // from_caller_get_identityarc not in this test

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
                error("not in this test");
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
    }
}
