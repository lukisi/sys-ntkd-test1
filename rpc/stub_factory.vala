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
using Netsukuku.Identities;
using Netsukuku.Qspn;
//using Netsukuku.Coordinator;
//using Netsukuku.Hooking;
//using Netsukuku.Andna;
using TaskletSystem;

namespace Netsukuku
{
    interface IIdentityAwareMissingArcHandler : Object
    {
        public abstract void missing(IdentityData identity_data, IdentityArc identity_arc);
    }

    class StubFactory : Object
    {
        public StubFactory()
        {
        }

        /* Get a stub for a whole-node unicast request.
         */
        // no arcs in this testsuite.
        /*
        public IAddressManagerStub
        get_stub_whole_node_unicast(
            INeighborhoodArc arc,
            bool wait_reply=true)
        {
            WholeNodeSourceID source_id = new WholeNodeSourceID(skeleton_factory.whole_node_id);
            WholeNodeUnicastID unicast_id = new WholeNodeUnicastID(arc.neighbour_id);
            NeighbourSrcNic src_nic = new NeighbourSrcNic(arc.nic.mac);
            string send_pathname = @"conn_$(arc.neighbour_nic_addr)";
            return get_addr_stream_system(send_pathname, source_id, unicast_id, src_nic, wait_reply);
        }
        */

        /* Get a stub for a whole-node broadcast request.
         */
        public IAddressManagerStub
        get_stub_whole_node_broadcast_for_radar(INeighborhoodNetworkInterface nic)
        {
            WholeNodeSourceID source_id = new WholeNodeSourceID(skeleton_factory.whole_node_id);
            EveryWholeNodeBroadcastID broadcast_id = new EveryWholeNodeBroadcastID();
            NeighbourSrcNic src_nic = new NeighbourSrcNic(nic.mac);
            string send_pathname = @"send_$(pid)_$(nic.dev)";
            return get_addr_datagram_system(send_pathname, source_id, broadcast_id, src_nic);
        }

        /* Get a stub for a identity unicast request.
         */
        public IAddressManagerStub
        get_stub_identity_aware_unicast(
            INeighborhoodArc arc,
            IdentityData identity_data,
            NodeID unicast_node_id,
            bool wait_reply=true)
        {
            string send_pathname = @"conn_$(arc.neighbour_nic_addr)";
            NodeID source_node_id = identity_data.nodeid;
            IdentityAwareSourceID source_id = new IdentityAwareSourceID(source_node_id);
            IdentityAwareUnicastID unicast_id = new IdentityAwareUnicastID(unicast_node_id);
            string my_dev_mac = arc.nic.mac;
            NeighbourSrcNic src_nic = new NeighbourSrcNic(my_dev_mac);
            return get_addr_stream_system(send_pathname, source_id, unicast_id, src_nic, wait_reply);
        }

        public IAddressManagerStub
        get_stub_identity_aware_unicast_from_ia(IdentityArc ia, bool wait_reply=true)
        {
            IdentityData identity_data = ia.identity_data; // if identity has been removed this will exit_tasklet
            IIdmgmtArc _arc = ia.arc;
            IdmgmtArc __arc = (IdmgmtArc)_arc;
            INeighborhoodArc arc = __arc.neighborhood_arc;
            NodeID unicast_node_id = ia.id_arc.get_peer_nodeid();
            return get_stub_identity_aware_unicast(arc, identity_data, unicast_node_id, wait_reply);
        }


        /* Get a stub for a identity broadcast request.
         */
        public IAddressManagerStub
        get_stub_identity_aware_broadcast(
            string my_dev,
            IdentityData identity_data,
            Gee.List<NodeID> broadcast_node_id_set,
            IIdentityAwareMissingArcHandler? identity_missing_handler=null)
        {
            NodeID source_node_id = identity_data.nodeid;
            IdentityAwareSourceID source_id = new IdentityAwareSourceID(source_node_id);
            IdentityAwareBroadcastID broadcast_id = new IdentityAwareBroadcastID(broadcast_node_id_set);
            string my_dev_mac = handlednic_map[my_dev].mac;
            NeighbourSrcNic src_nic = new NeighbourSrcNic(my_dev_mac);
            string send_pathname = @"send_$(pid)_$(my_dev)";

            IAckCommunicator? ack_com = null;
            if (identity_missing_handler != null)
            {
                NodeMissingArcHandlerForIdentityAware node_missing_handler
                    = new NodeMissingArcHandlerForIdentityAware(identity_missing_handler, identity_data.local_identity_index);
                ack_com = new AcknowledgementsCommunicator(this, my_dev, node_missing_handler);
            }

            return get_addr_datagram_system(send_pathname, source_id, broadcast_id, src_nic, ack_com);
        }

        private Gee.List<INeighborhoodArc> get_current_arcs_for_broadcast(string my_dev)
        {
            var ret = new ArrayList<INeighborhoodArc>();
            foreach (NodeArc arc in arc_map.values)
                if (arc.neighborhood_arc.nic.dev == my_dev)
                    ret.add(arc.neighborhood_arc);
            return ret;
        }

        class NodeMissingArcHandlerForIdentityAware : Object
        {
            public NodeMissingArcHandlerForIdentityAware(IIdentityAwareMissingArcHandler identity_missing_handler, int local_identity_index)
            {
                this.identity_missing_handler = identity_missing_handler;
                this.local_identity_index = local_identity_index;
            }
            private IIdentityAwareMissingArcHandler identity_missing_handler;
            private int local_identity_index;
            private IdentityData? _identity_data;
            public IdentityData identity_data {
                get {
                    _identity_data = find_local_identity_by_index(local_identity_index);
                    if (_identity_data == null) tasklet.exit_tasklet();
                    return _identity_data;
                }
            }

            public void missing(INeighborhoodArc arc)
            {
                // from a INeighborhoodArc get a list of identity_arcs
                foreach (IdentityArc ia in identity_data.identity_arcs)
                {
                    // Does `ia` lay on this INeighborhoodArc?
                    if (((IdmgmtArc)ia.arc).neighborhood_arc == arc)
                    {
                        // each identity_arc in its tasklet:
                        ActOnMissingTasklet ts = new ActOnMissingTasklet();
                        ts.identity_missing_handler = identity_missing_handler;
                        ts.identity_data = identity_data;
                        ts.ia = ia;
                        tasklet.spawn(ts);
                    }
                }
            }

            private class ActOnMissingTasklet : Object, ITaskletSpawnable
            {
                public IIdentityAwareMissingArcHandler identity_missing_handler;
                public IdentityData identity_data;
                public IdentityArc ia;
                public void * func()
                {
                    identity_missing_handler.missing(identity_data, ia);
                    return null;
                }
            }
        }

        /* The instance of this class is created when the stub factory is invoked to
         * obtain a stub for a message in broadcast on dev my_dev.
         */
        private class AcknowledgementsCommunicator : Object, IAckCommunicator
        {
            public StubFactory stub_factory;
            public string my_dev;
            public NodeMissingArcHandlerForIdentityAware node_missing_handler;
            public Gee.List<INeighborhoodArc> lst_expected;

            public AcknowledgementsCommunicator(
                                StubFactory stub_factory,
                                string my_dev,
                                NodeMissingArcHandlerForIdentityAware node_missing_handler)
            {
                this.stub_factory = stub_factory;
                this.my_dev = my_dev;
                this.node_missing_handler = node_missing_handler;
                lst_expected = stub_factory.get_current_arcs_for_broadcast(my_dev);
            }

            public void process_src_nics_list(Gee.List<ISrcNic> src_nics_list) // Gee.List<string> responding_macs
            {
                // intersect with current ones now
                Gee.List<INeighborhoodArc> lst_expected_now = stub_factory.get_current_arcs_for_broadcast(my_dev);
                ArrayList<INeighborhoodArc> lst_expected_intersect = new ArrayList<INeighborhoodArc>();
                foreach (var el in lst_expected)
                    if (el in lst_expected_now)
                        lst_expected_intersect.add(el);
                lst_expected = lst_expected_intersect;
                // prepare a list of missed arcs.
                var lst_missed = new ArrayList<INeighborhoodArc>();
                foreach (INeighborhoodArc expected in lst_expected)
                {
                    string expected_peer_mac = expected.neighbour_mac;
                    bool expected_peer_mac_in_src_nics_list = false;
                    foreach (ISrcNic src_nic in src_nics_list)
                    {
                        assert(src_nic is NeighbourSrcNic);
                        if (((NeighbourSrcNic)src_nic).mac == expected_peer_mac)
                        {
                            expected_peer_mac_in_src_nics_list = true;
                            break;
                        }
                    }
                    if (! expected_peer_mac_in_src_nics_list)
                        lst_missed.add(expected);
                }
                // foreach missed arc launch in a tasklet
                // the 'missing' callback.
                foreach (INeighborhoodArc missed in lst_missed)
                {
                    // each neighborhood_arc in its tasklet:
                    ActOnMissingTasklet ts = new ActOnMissingTasklet();
                    ts.node_missing_handler = node_missing_handler;
                    ts.missed = missed;
                    tasklet.spawn(ts);
                }
            }

            private class ActOnMissingTasklet : Object, ITaskletSpawnable
            {
                public NodeMissingArcHandlerForIdentityAware node_missing_handler;
                public INeighborhoodArc missed;
                public void * func()
                {
                    node_missing_handler.missing(missed);
                    return null;
                }
            }
        }
    }
}
