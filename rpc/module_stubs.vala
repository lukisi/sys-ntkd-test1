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
//using Netsukuku.Identities;
//using Netsukuku.Qspn;
//using Netsukuku.Coordinator;
//using Netsukuku.Hooking;
//using Netsukuku.Andna;
using TaskletSystem;

namespace Netsukuku
{
    class NeighborhoodManagerStubHolder : Object, INeighborhoodManagerStub
    {
        public NeighborhoodManagerStubHolder(IAddressManagerStub addr)
        {
            this.addr = addr;
        }
        private IAddressManagerStub addr;

        public bool can_you_export(bool i_can_export)
        throws StubError, DeserializeError
        {
            return addr.neighborhood_manager.can_you_export(i_can_export);
        }

        public void here_i_am(INeighborhoodNodeIDMessage my_id, string my_mac, string my_nic_addr)
        throws StubError, DeserializeError
        {
            addr.neighborhood_manager.here_i_am(my_id, my_mac, my_nic_addr);
        }

        public void nop()
        throws StubError, DeserializeError
        {
            addr.neighborhood_manager.nop();
        }

        public void remove_arc
        (INeighborhoodNodeIDMessage your_id, string your_mac, string your_nic_addr,
        INeighborhoodNodeIDMessage my_id, string my_mac, string my_nic_addr)
        throws StubError, DeserializeError
        {
            addr.neighborhood_manager.remove_arc(your_id, your_mac, your_nic_addr,
                my_id, my_mac, my_nic_addr);
        }

        public void request_arc(INeighborhoodNodeIDMessage your_id, string your_mac, string your_nic_addr,
        INeighborhoodNodeIDMessage my_id, string my_mac, string my_nic_addr)
        throws StubError, DeserializeError
        {
            addr.neighborhood_manager.request_arc(your_id, your_mac, your_nic_addr,
                my_id, my_mac, my_nic_addr);
        }
    }

    class IdentityManagerStubHolder : Object, IIdentityManagerStub
    {
        public IdentityManagerStubHolder(IAddressManagerStub addr)
        {
            this.addr = addr;
        }
        private IAddressManagerStub addr;

        public IIdentityID get_peer_main_id()
        throws StubError, DeserializeError
        {
            return addr.identity_manager.get_peer_main_id();
        }

        public IDuplicationData? match_duplication
        (int migration_id, IIdentityID peer_id, IIdentityID old_id,
        IIdentityID new_id, string old_id_new_mac, string old_id_new_linklocal)
        throws StubError, DeserializeError
        {
            return addr.identity_manager.match_duplication
                (migration_id, peer_id, old_id,
                 new_id, old_id_new_mac, old_id_new_linklocal);
        }

        public void notify_identity_arc_removed(IIdentityID peer_id, IIdentityID my_id)
        throws StubError, DeserializeError
        {
            addr.identity_manager.notify_identity_arc_removed(peer_id, my_id);
        }
    }

    class QspnManagerStubHolder : Object, IQspnManagerStub
    {
        public QspnManagerStubHolder(IAddressManagerStub addr, IdentityArc ia)
        {
            this.addr = addr;
            this.ia = ia;
        }
        private IAddressManagerStub addr;
        private IdentityArc ia;

        public IQspnEtpMessage get_full_etp(IQspnAddress requesting_address)
        throws QspnNotAcceptedError, QspnBootstrapInProgressError, StubError, DeserializeError
        {
            print(@"Qspn: Identity #$(ia.identity_data.local_identity_index): [$(printabletime())] calling unicast get_full_etp to nodeid $(ia.id_arc.get_peer_nodeid().id).\n");
            return addr.qspn_manager.get_full_etp(requesting_address);
        }

        public void got_destroy()
        throws StubError, DeserializeError
        {
            print(@"Qspn: Identity #$(ia.identity_data.local_identity_index): [$(printabletime())] calling unicast got_destroy to nodeid $(ia.id_arc.get_peer_nodeid().id).\n");
            addr.qspn_manager.got_destroy();
        }

        public void got_prepare_destroy()
        throws StubError, DeserializeError
        {
            print(@"Qspn: Identity #$(ia.identity_data.local_identity_index): [$(printabletime())] calling unicast got_prepare_destroy to nodeid $(ia.id_arc.get_peer_nodeid().id).\n");
            addr.qspn_manager.got_prepare_destroy();
        }

        public void send_etp(IQspnEtpMessage etp, bool is_full)
        throws QspnNotAcceptedError, StubError, DeserializeError
        {
            print(@"Qspn: Identity #$(ia.identity_data.local_identity_index): [$(printabletime())] calling unicast send_etp to nodeid $(ia.id_arc.get_peer_nodeid().id).\n");
            addr.qspn_manager.send_etp(etp, is_full);
        }
    }

    class QspnManagerStubBroadcastHolder : Object, IQspnManagerStub
    {
        public QspnManagerStubBroadcastHolder(Gee.List<IAddressManagerStub> addr_list)
        {
            this.addr_list = addr_list;
        }
        private Gee.List<IAddressManagerStub> addr_list;

        public IQspnEtpMessage get_full_etp(IQspnAddress requesting_address)
        throws QspnNotAcceptedError, QspnBootstrapInProgressError, StubError, DeserializeError
        {
            assert_not_reached();
        }

        public void got_destroy()
        throws StubError, DeserializeError
        {
            foreach (var addr in addr_list)
            addr.qspn_manager.got_destroy();
        }

        public void got_prepare_destroy()
        throws StubError, DeserializeError
        {
            foreach (var addr in addr_list)
            addr.qspn_manager.got_prepare_destroy();
        }

        public void send_etp(IQspnEtpMessage etp, bool is_full)
        throws QspnNotAcceptedError, StubError, DeserializeError
        {
            foreach (var addr in addr_list)
            addr.qspn_manager.send_etp(etp, is_full);
        }
    }

    class QspnManagerStubVoid : Object, IQspnManagerStub
    {
        public IQspnEtpMessage get_full_etp(IQspnAddress requesting_address)
        throws QspnNotAcceptedError, QspnBootstrapInProgressError, StubError, DeserializeError
        {
            assert_not_reached();
        }

        public void got_destroy()
        throws StubError, DeserializeError
        {
        }

        public void got_prepare_destroy()
        throws StubError, DeserializeError
        {
        }

        public void send_etp(IQspnEtpMessage etp, bool is_full)
        throws QspnNotAcceptedError, StubError, DeserializeError
        {
        }
    }
}