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
using Netsukuku.Qspn;
using TaskletSystem;

namespace Netsukuku
{
    void identities_identity_arc_added(IIdmgmtArc arc, NodeID id, IIdmgmtIdentityArc id_arc, IIdmgmtIdentityArc? prev_id_arc)
    {
        // no arcs in this testsuite.
        /*
        print(@"Identities: [$(printabletime())]: Signal identity_arc_added:\n");
        print(@"    arc: dev $(arc.get_dev()) peer_mac $(arc.get_peer_mac()) peer_linklocal $(arc.get_peer_linklocal())\n");
        print(@"    my identity: nodeid $(id.id)\n");
        print(@"    id_arc: nodeid $(id_arc.get_peer_nodeid().id) peer_mac $(id_arc.get_peer_mac()) peer_linklocal $(id_arc.get_peer_linklocal())\n");
        if (prev_id_arc == null)
            print(@"    prev_id_arc: null\n");
        else
            print(@"    prev_id_arc: nodeid $(prev_id_arc.get_peer_nodeid().id) peer_mac $(prev_id_arc.get_peer_mac()) peer_linklocal $(prev_id_arc.get_peer_linklocal())\n");

        // Retrieve my identity.
        IdentityData identity_data = find_or_create_local_identity(id);
        // Create IdentityArc.
        IdentityArc ia = new IdentityArc(identity_data.local_identity_index, arc, id_arc);
        // Add to the list.
        identity_data.identity_arcs.add(ia);

        // If needed, pass it to the Hooking module.
        if (prev_id_arc == null)
        {
            print(@" [will be] Passing it to the module Hooking.\n");
            //while (identity_data.hook_mgr == null) tasklet.ms_wait(10);
            //ia.hooking_arc = new HookingIdentityArc(ia);
            //identity_data.hook_mgr.add_arc(ia.hooking_arc);
        }

        // If we know the previous id-arc, copy the network_id
        if (prev_id_arc != null)
        {
            // Retrieve previous IdentityArc.
            IdentityArc prev_ia = find_identity_arc(prev_id_arc);
            if (ia == null) debug(@"Could not find IdentityArc.");
            else ia.network_id = prev_ia.network_id;
        }
        */
    }

    void identities_identity_arc_changed(IIdmgmtArc arc, NodeID id, IIdmgmtIdentityArc id_arc, bool only_neighbour_migrated)
    {
        // no arcs in this testsuite.
        /*
        print(@"Identities: [$(printabletime())]: Signal identity_arc_changed:\n");
        print(@"    arc: dev $(arc.get_dev()) peer_mac $(arc.get_peer_mac()) peer_linklocal $(arc.get_peer_linklocal())\n");
        print(@"    my identity: nodeid $(id.id)\n");
        print(@"    id_arc: nodeid $(id_arc.get_peer_nodeid().id) peer_mac $(id_arc.get_peer_mac()) peer_linklocal $(id_arc.get_peer_linklocal())\n");
        print(@"    only_neighbour_migrated: $(only_neighbour_migrated)\n");

        // Retrieve my identity.
        IdentityData identity_data = find_or_create_local_identity(id);
        // Retrieve IdentityArc.
        IdentityArc ia = identity_data.identity_arcs_find(arc, id_arc);

        // Modify properties.
        ia.prev_peer_mac = ia.peer_mac;
        ia.prev_peer_linklocal = ia.peer_linklocal;
        ia.peer_mac = ia.id_arc.get_peer_mac();
        ia.peer_linklocal = ia.id_arc.get_peer_linklocal();

        // TODO If a Qspn arc exists for it, change routes in kernel tables.

        // This signal might happen when the module Identities of this system is doing `add_identity` on
        //  this very identity (identity_data).
        //  In this case the program does some further operations on its own (see EnterNetwork.enter or Migrate.migrate).
        //  But this might also happen when only our neighbour is doing `add_identity`.
        if (only_neighbour_migrated)
        {
            // TODO In this case we must do some work if we have a qspn_arc on this identity_arc.

            // After that, we need no more to keep old values.
            ia.prev_peer_mac = null;
            ia.prev_peer_linklocal = null;
        }
        */
    }

    void identities_identity_arc_removing(IIdmgmtArc arc, NodeID id, NodeID peer_nodeid)
    {
        // no arcs in this testsuite.
        /*
        print(@"Identities: [$(printabletime())]: Signal identity_arc_removing:\n");
        print(@"    arc: dev $(arc.get_dev()) peer_mac $(arc.get_peer_mac()) peer_linklocal $(arc.get_peer_linklocal())\n");
        print(@"    my identity: nodeid $(id.id)\n");
        print(@"    peer_nodeid: nodeid $(peer_nodeid.id)\n");

        // Retrieve my identity.
        IdentityData identity_data = find_or_create_local_identity(id);
        // Retrieve IdentityArc.
        IdentityArc ia = find_identity_arc_by_peer_nodeid(identity_data, arc, peer_nodeid);
        if (ia == null) debug(@"Could not find IdentityArc.");
        else
        {
            if (ia.qspn_arc != null)
            {
                // Remove Qspn arc.
                QspnManager qspn_mgr = (QspnManager)identity_mgr.get_identity_module(id, "qspn");
                qspn_mgr.arc_remove(ia.qspn_arc);
            }
        }
        */
    }

    void identities_identity_arc_removed(IIdmgmtArc arc, NodeID id, NodeID peer_nodeid)
    {
        // no arcs in this testsuite.
        /*
        print(@"Identities: [$(printabletime())]: Signal identity_arc_removed:\n");
        print(@"    arc: dev $(arc.get_dev()) peer_mac $(arc.get_peer_mac()) peer_linklocal $(arc.get_peer_linklocal())\n");
        print(@"    my identity: nodeid $(id.id)\n");
        print(@"    peer_nodeid: nodeid $(peer_nodeid.id)\n");

        // Retrieve my identity.
        IdentityData identity_data = find_or_create_local_identity(id);
        // Retrieve IdentityArc.
        IdentityArc ia = find_identity_arc_by_peer_nodeid(identity_data, arc, peer_nodeid);
        if (ia == null) debug(@"Could not find IdentityArc.");
        else
        {
            if (ia.qspn_arc != null)
            {
                ia.qspn_arc = null;
                // Remove from the list.
                identity_data.identity_arcs.remove(ia);
                // Then remove kernel tables.
                IpCommands.removed_arc(identity_data, ia.peer_mac);
            }
        }
        */
    }

    void identities_arc_removed(IIdmgmtArc arc)
    {
        // no arcs in this testsuite.
        /*
        // The module Identities has removed an arc. Remove the arc from Neighborhood.
        print(@"Identities: [$(printabletime())]: Signal arc_removed: dev $(arc.get_dev()) peer_mac $(arc.get_peer_mac()) peer_linklocal $(arc.get_peer_linklocal())\n");
        IdmgmtArc _arc = (IdmgmtArc)arc;
        NodeArc node_arc = arc_map[_arc.id];
        neighborhood_mgr.remove_my_arc(node_arc.neighborhood_arc);
        arc_map.unset(_arc.id);

        // TODO
        */
    }
}
