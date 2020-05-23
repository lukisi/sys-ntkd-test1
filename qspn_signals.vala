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
        try {
            // TODO
        } catch (QspnBootstrapInProgressError e) {assert_not_reached();}
    }

    void per_identity_qspn_destination_added(IdentityData id, HCoord h)
    {
        // TODO
    }

    void per_identity_qspn_destination_removed(IdentityData id, HCoord h)
    {
        // TODO
    }

    void per_identity_qspn_path_added(IdentityData id, IQspnNodePath p)
    {
        // TODO
    }

    void per_identity_qspn_path_changed(IdentityData id, IQspnNodePath p)
    {
        // TODO
    }

    void per_identity_qspn_path_removed(IdentityData id, IQspnNodePath p)
    {
        // TODO
    }

    void per_identity_qspn_changed_fp(IdentityData id, int l)
    {
        // TODO
    }

    void per_identity_qspn_changed_nodes_inside(IdentityData id, int l)
    {
        // TODO
    }

    void per_identity_qspn_presence_notified(IdentityData id)
    {
        // TODO
    }

    void per_identity_qspn_remove_identity(IdentityData id)
    {
        // TODO
    }

    void per_identity_qspn_arc_removed(IdentityData id, IQspnArc arc, bool bad_link)
    {
        // TODO
    }

    void per_identity_qspn_gnode_splitted(IdentityData id, IQspnArc a, HCoord d, IQspnFingerprint fp)
    {
        // TODO
    }
}