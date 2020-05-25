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
using Netsukuku.Qspn;
using TaskletSystem;

namespace Netsukuku
{
    void per_identity_qspn_qspn_bootstrap_complete(IdentityData id)
    {
        print(@"Qspn: [$(printabletime())]: Signal qspn_bootstrap_complete.\n");
        try {
            foreach (HCoord hc in id.bootstrap_phase_pending_updates) UpdateGraph.update_destination(id, hc);
            // TODO
        } catch (QspnBootstrapInProgressError e) {assert_not_reached();}
    }

    void per_identity_qspn_destination_added(IdentityData id, HCoord h)
    {
        print(@"Qspn: [$(printabletime())]: Signal destination_added.\n");
        // TODO
    }

    void per_identity_qspn_destination_removed(IdentityData id, HCoord h)
    {
        print(@"Qspn: [$(printabletime())]: Signal destination_removed.\n");
        // TODO
    }

    void per_identity_qspn_path_added(IdentityData id, IQspnNodePath p)
    {
        print(@"Qspn: [$(printabletime())]: Signal path_added.\n");
        per_identity_qspn_map_update(id, p);
    }

    void per_identity_qspn_path_changed(IdentityData id, IQspnNodePath p)
    {
        print(@"Qspn: [$(printabletime())]: Signal path_changed.\n");
        per_identity_qspn_map_update(id, p);
    }

    void per_identity_qspn_path_removed(IdentityData id, IQspnNodePath p)
    {
        print(@"Qspn: [$(printabletime())]: Signal path_removed.\n");
        per_identity_qspn_map_update(id, p);
    }

    void per_identity_qspn_map_update(IdentityData id, IQspnNodePath p)
    {
        HCoord hc = p.i_qspn_get_hops().last().i_qspn_get_hcoord();
        per_identity_qspn_map_update_hc(id, hc);
    }

    void per_identity_qspn_map_update_hc(IdentityData id, HCoord hc)
    {
        if (hc in id.dest_ip_set.gnode.keys)
        {
            QspnManager qspn_mgr = (QspnManager)identity_mgr.get_identity_module(id.nodeid, "qspn");
            try {
                qspn_mgr.get_paths_to(hc);
            } catch (QspnBootstrapInProgressError e) {
                id.bootstrap_phase_pending_updates.add(hc);
                return;
            }
            UpdateGraph.update_destination(id, hc);
        }
    }

    void per_identity_qspn_map_update_hc_reserve(IdentityData id, HCoord hc)
    {
        if (hc in id.dest_ip_set.gnode.keys)
        {
            id.bootstrap_phase_pending_updates.add(hc);
        }
    }

    void per_identity_qspn_changed_fp(IdentityData id, int l)
    {
        print(@"Qspn: [$(printabletime())]: Signal changed_fp.\n");
        // TODO
    }

    void per_identity_qspn_changed_nodes_inside(IdentityData id, int l)
    {
        print(@"Qspn: [$(printabletime())]: Signal changed_nodes_inside.\n");
        // TODO
    }

    void per_identity_qspn_presence_notified(IdentityData id)
    {
        print(@"Qspn: [$(printabletime())]: Signal presence_notified.\n");
        // TODO
    }

    void per_identity_qspn_remove_identity(IdentityData id)
    {
        print(@"Qspn: [$(printabletime())]: Signal remove_identity.\n");
        // TODO
    }

    void per_identity_qspn_arc_removed(IdentityData id, IQspnArc arc, bool bad_link)
    {
        print(@"Qspn: [$(printabletime())]: Signal arc_removed.\n");
        // TODO
    }

    void per_identity_qspn_gnode_splitted(IdentityData id, IQspnArc a, HCoord d, IQspnFingerprint fp)
    {
        print(@"Qspn: [$(printabletime())]: Signal gnode_splitted.\n");
        // TODO
    }
}