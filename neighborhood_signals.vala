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
        print(@"signal nic_address_set $(my_addr).\n");
        string dev = nic.dev;
        PseudoNetworkInterface pseudonic = pseudonic_map[dev];
        pseudonic.linklocal = my_addr;
        pseudonic.st_listen_pathname = @"conn_$(my_addr)";
        skeleton_factory.start_stream_system_listen(pseudonic.st_listen_pathname);
        print(@"started stream_system_listen $(pseudonic.st_listen_pathname).\n");
    }

    void neighborhood_arc_added(INeighborhoodArc neighborhood_arc)
    {
        print(@"signal arc_added.\n");
        // Add arc to module Identities and to arc_list
        IdmgmtArc i_arc = new IdmgmtArc(neighborhood_arc);
        arc_list.add(new NodeArc(neighborhood_arc, i_arc));
        identity_mgr.add_arc(i_arc);
    }

    void neighborhood_arc_changed(INeighborhoodArc neighborhood_arc)
    {
        print(@"signal arc_changed.\n");
        // TODO for each identity, for each id-arc, if qspn_arc is present, change cost
    }

    void neighborhood_arc_removing(INeighborhoodArc neighborhood_arc, bool is_still_usable)
    {
        print(@"signal arc_removing.\n");
        // Remove arc from module Identities
        IdmgmtArc? to_del = null;
        foreach (NodeArc arc in arc_list) if (arc.neighborhood_arc == neighborhood_arc) {to_del = arc.i_arc; break;}
        if (to_del == null) return;
        identity_mgr.remove_arc(to_del);
    }

    void neighborhood_arc_removed(INeighborhoodArc neighborhood_arc)
    {
        print(@"signal arc_removed.\n");
        // Remove arc from arc_list
        NodeArc? to_del = null;
        foreach (NodeArc arc in arc_list) if (arc.neighborhood_arc == neighborhood_arc) {to_del = arc; break;}
        if (to_del == null) return;
        arc_list.remove(to_del);
        // TODO ?
    }

    void neighborhood_nic_address_unset(INeighborhoodNetworkInterface nic, string my_addr)
    {
        print(@"signal nic_address_unset $(my_addr).\n");
        // TODO ?
    }
}
