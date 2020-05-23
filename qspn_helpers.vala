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
using Netsukuku.Identities;
using Netsukuku.Qspn;
using TaskletSystem;

namespace Netsukuku
{
    class QspnStubFactory : Object, IQspnStubFactory
    {
        public QspnStubFactory(int local_identity_index)
        {
            this.local_identity_index = local_identity_index;
        }
        private int local_identity_index;
        private IdentityData? _identity_data;
        public IdentityData identity_data {
            get {
                _identity_data = find_local_identity_by_index(local_identity_index);
                if (_identity_data == null) tasklet.exit_tasklet();
                return _identity_data;
            }
        }

        public IQspnManagerStub
                        i_qspn_get_broadcast(
                            Gee.List<IQspnArc> arcs,
                            IQspnMissingArcHandler? missing_handler=null
                        )
        {
            if(arcs.is_empty) return new QspnManagerStubVoid();
            error("not in this test");
        }

        public IQspnManagerStub
                        i_qspn_get_tcp(
                            IQspnArc arc,
                            bool wait_reply=true
                        )
        {
            error("not in this test");
        }
    }

    class ThresholdCalculator : Object, IQspnThresholdCalculator
    {
        public int i_qspn_calculate_threshold(IQspnNodePath p1, IQspnNodePath p2)
        {
            var cost_p1 = p1.i_qspn_get_cost();
            assert(cost_p1 is Cost);
            int64 cost_usec_p1 = ((Cost)cost_p1).usec_rtt;
            var cost_p2 = p2.i_qspn_get_cost();
            assert(cost_p2 is Cost);
            int64 cost_usec_p2 = ((Cost)cost_p2).usec_rtt;
            // this equates circa 50 times the latency
            int ms_threshold = ((int)(cost_usec_p1 + cost_usec_p2)) / 20;
            print(@"threshold = $(ms_threshold) msec.\n");
            return ms_threshold;
        }
    }

    class QspnArc : Object, IQspnArc
    {
        public QspnArc(IdentityArc ia)
        {
            this.ia = ia;
            IIdmgmtArc _arc = ia.arc;
            IdmgmtArc __arc = (IdmgmtArc)_arc;
            arc = __arc.neighborhood_arc;
            cost_seed = PRNGen.int_range(0, 1000);
        }
        public weak IdentityArc ia;
        public INeighborhoodArc arc;
        private int cost_seed;

        public IQspnCost i_qspn_get_cost()
        {
            error("not in this test");
            /*
            Cost cost = new Cost(arc.cost + cost_seed);
            return cost;
            */
        }

        public bool i_qspn_equals(IQspnArc other)
        {
            error("not in this test");
            /*
            if (! (other is QspnArc)) return false;
            return ((QspnArc)other).ia == ia;
            */
        }

        public bool i_qspn_comes_from(CallerInfo rpc_caller)
        {
            error("not in this test");
            /*
            IdentityData identity_data = ia.identity_data;
            IdentityArc? caller_ia = skeleton_factory.from_caller_get_identityarc(rpc_caller, identity_data);
            if (caller_ia == null) return false;
            return caller_ia == ia;
            */
        }
    }

    // For IQspnNaddr, IQspnMyNaddr, IQspnCost, IQspnFingerprint see Naddr, Cost, Fingerprint in serializables.vala
}

