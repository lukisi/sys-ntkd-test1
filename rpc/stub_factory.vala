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
    class StubFactory : Object
    {
        public StubFactory()
        {
        }

        /* Get a stub for a whole-node unicast request.
         */
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
    }
}
