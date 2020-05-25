/*
 *  This file is part of Netsukuku.
 *  Copyright (C) 2017-2020 Luca Dionisi aka lukisi <luca.dionisi@gmail.com>
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
using TaskletSystem;

namespace Netsukuku
{
    void neighborhood_nic_address_set(INeighborhoodNetworkInterface nic, string my_addr)
    {
        print(@"Neighborhood: [$(printabletime())]: Signal nic_address_set $(my_addr).\n");
        string dev = nic.dev;
        PseudoNetworkInterface pseudonic = pseudonic_map[dev];

        HandledNic n = new HandledNic(pseudonic.dev, pseudonic.mac, my_addr, nic);
        handlednic_map[pseudonic.dev] = n;

        pseudonic.linklocal = my_addr;
        pseudonic.st_listen_pathname = @"conn_$(my_addr)";
        skeleton_factory.start_stream_system_listen(pseudonic.st_listen_pathname);
        print(@"started stream_system_listen $(pseudonic.st_listen_pathname).\n");
    }

    void neighborhood_arc_added(INeighborhoodArc neighborhood_arc)
    {
        // no arcs in this testsuite.
        /*
        print(@"Neighborhood: [$(printabletime())]: Signal arc_added.\n");
        // Add arc to module Identities and to arc_map
        IdmgmtArc i_arc = new IdmgmtArc(neighborhood_arc);
        arc_map[i_arc.id] = new NodeArc(neighborhood_arc, i_arc);
        identity_mgr.add_arc(i_arc);
        */
    }

    void neighborhood_arc_changed(INeighborhoodArc neighborhood_arc)
    {
        // no arcs in this testsuite.
        /*
        print(@"Neighborhood: [$(printabletime())]: Signal arc_changed.\n");
        // TODO for each identity, for each id-arc, if qspn_arc is present, change cost
        */
    }

    void neighborhood_arc_removing(INeighborhoodArc neighborhood_arc, bool is_still_usable)
    {
        // no arcs in this testsuite.
        /*
        print(@"Neighborhood: [$(printabletime())]: Signal arc_removing.\n");
        // Remove arc from module Identities
        foreach (int id in arc_map.keys)
        {
            NodeArc arc = arc_map[id];
            if (arc.neighborhood_arc == neighborhood_arc)
            {
                identity_mgr.remove_arc(arc.i_arc);
                break;
            }
        }
        */
    }

    void neighborhood_arc_removed(INeighborhoodArc neighborhood_arc)
    {
        // no arcs in this testsuite.
        /*
        print(@"Neighborhood: [$(printabletime())]: Signal arc_removed.\n");
        // Remove arc from arc_map
        foreach (int id in arc_map.keys)
        {
            NodeArc arc = arc_map[id];
            if (arc.neighborhood_arc == neighborhood_arc)
            {
                arc_map.unset(id);
                break;
            }
        }
        // TODO ?
        */
    }

    void neighborhood_nic_address_unset(INeighborhoodNetworkInterface nic, string my_addr)
    {
        print(@"Neighborhood: [$(printabletime())]: Signal nic_address_unset $(my_addr).\n");
        // TODO ?
    }
}
