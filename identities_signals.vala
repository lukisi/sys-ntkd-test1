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
using Netsukuku.Identities;
//using Netsukuku.Qspn;
using TaskletSystem;

namespace Netsukuku
{
    void identities_identity_arc_added(IIdmgmtArc arc, NodeID id, IIdmgmtIdentityArc id_arc, IIdmgmtIdentityArc? prev_id_arc)
    {
        // no arcs in this testsuite.
        /*
        print(@"Identities: Signal identity_arc_added:\n");
        print(@"    arc: dev $(arc.get_dev()) peer_mac $(arc.get_peer_mac()) peer_linklocal $(arc.get_peer_linklocal())\n");
        print(@"    my identity: nodeid $(id.id)\n");
        print(@"    id_arc: nodeid $(id_arc.get_peer_nodeid().id) peer_mac $(id_arc.get_peer_mac()) peer_linklocal $(id_arc.get_peer_linklocal())\n");
        if (prev_id_arc == null)
            print(@"    prev_id_arc: null\n");
        else
            print(@"    prev_id_arc: nodeid $(prev_id_arc.get_peer_nodeid().id) peer_mac $(prev_id_arc.get_peer_mac()) peer_linklocal $(prev_id_arc.get_peer_linklocal())\n");

        // Retrieve my identity.
        IdentityData identity_data = find_local_identity(id);
        // Create IdentityArc.
        IdentityArc ia = new IdentityArc(identity_data.local_identity_index, arc, id_arc);
        // Add to the list.
        identity_data.identity_arcs.add(ia);

        // TODO
        */
    }

    void identities_identity_arc_changed(IIdmgmtArc arc, NodeID id, IIdmgmtIdentityArc id_arc, bool only_neighbour_migrated)
    {
        // no arcs in this testsuite.
        /*
        print(@"Identities: Signal identity_arc_changed:\n");
        print(@"    arc: dev $(arc.get_dev()) peer_mac $(arc.get_peer_mac()) peer_linklocal $(arc.get_peer_linklocal())\n");
        print(@"    my identity: nodeid $(id.id)\n");
        print(@"    id_arc: nodeid $(id_arc.get_peer_nodeid().id) peer_mac $(id_arc.get_peer_mac()) peer_linklocal $(id_arc.get_peer_linklocal())\n");
        print(@"    only_neighbour_migrated: $(only_neighbour_migrated)\n");

        // Retrieve my identity.
        IdentityData identity_data = find_local_identity(id);
        // Retrieve IdentityArc.
        IdentityArc ia = identity_data.identity_arcs_find(id_arc);

        // TODO
        */
    }

    void identities_identity_arc_removing(IIdmgmtArc arc, NodeID id, NodeID peer_nodeid)
    {
        // no arcs in this testsuite.
        /*
        print(@"Identities: Signal identity_arc_removing:\n");
        print(@"    arc: dev $(arc.get_dev()) peer_mac $(arc.get_peer_mac()) peer_linklocal $(arc.get_peer_linklocal())\n");
        print(@"    my identity: nodeid $(id.id)\n");
        print(@"    peer_nodeid: nodeid $(peer_nodeid.id)\n");

        // TODO
        */
    }

    void identities_identity_arc_removed(IIdmgmtArc arc, NodeID id, NodeID peer_nodeid)
    {
        // no arcs in this testsuite.
        /*
        print(@"Identities: Signal identity_arc_removed:\n");
        print(@"    arc: dev $(arc.get_dev()) peer_mac $(arc.get_peer_mac()) peer_linklocal $(arc.get_peer_linklocal())\n");
        print(@"    my identity: nodeid $(id.id)\n");
        print(@"    peer_nodeid: nodeid $(peer_nodeid.id)\n");

        // TODO
        */
    }

    void identities_arc_removed(IIdmgmtArc arc)
    {
        // no arcs in this testsuite.
        /*
        // The module Identities has removed an arc. Remove the arc from Neighborhood.
        print(@"Identities: Signal arc_removed: dev $(arc.get_dev()) peer_mac $(arc.get_peer_mac()) peer_linklocal $(arc.get_peer_linklocal())\n");
        IdmgmtArc _arc = (IdmgmtArc)arc;
        NodeArc node_arc = arc_map[_arc.id];
        neighborhood_mgr.remove_my_arc(node_arc.neighborhood_arc);
        arc_map.unset(_arc.id);

        // TODO
        */
    }
}
