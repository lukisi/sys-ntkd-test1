/*
 *  This file is part of Netsukuku.
 *  Copyright (C) 2017-2019 Luca Dionisi aka lukisi <luca.dionisi@gmail.com>
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
    }

    void neighborhood_arc_changed(INeighborhoodArc neighborhood_arc)
    {
        print(@"signal arc_changed.\n");
    }

    void neighborhood_arc_removing(INeighborhoodArc neighborhood_arc, bool is_still_usable)
    {
        print(@"signal arc_removing.\n");
    }

    void neighborhood_arc_removed(INeighborhoodArc neighborhood_arc)
    {
        print(@"signal arc_removed.\n");
    }

    void neighborhood_nic_address_unset(INeighborhoodNetworkInterface nic, string my_addr)
    {
        print(@"signal nic_address_unset $(my_addr).\n");
    }
}
