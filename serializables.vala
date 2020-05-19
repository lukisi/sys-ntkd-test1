/*
 *  This file is part of Netsukuku.
 *  Copyright (C) 2018-2019 Luca Dionisi aka lukisi <luca.dionisi@gmail.com>
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

using Netsukuku;
using Netsukuku.Neighborhood;

namespace Netsukuku
{
    public class WholeNodeSourceID : Object, ISourceID
    {
        public WholeNodeSourceID(NeighborhoodNodeID id)
        {
            this.id = id;
        }
        public NeighborhoodNodeID id {get; set;}
    }

    public class WholeNodeUnicastID : Object, IUnicastID
    {
        public WholeNodeUnicastID(NeighborhoodNodeID neighbour_id)
        {
            this.neighbour_id = neighbour_id;
        }
        public NeighborhoodNodeID neighbour_id {get; set;}
    }

    public class EveryWholeNodeBroadcastID : Object, IBroadcastID
    {
    }

    public class NeighbourSrcNic : Object, ISrcNic
    {
        public NeighbourSrcNic(string mac)
        {
            this.mac = mac;
        }
        public string mac {get; set;}
    }
}