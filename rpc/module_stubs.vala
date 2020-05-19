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

}