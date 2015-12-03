// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2015 elementary LLC.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 * Authored by: Corentin Noël <corentin@elementary.io>
 */

public class ProjectManager.Launchpad.Malone : Bug {
    public Malone (Platform platform, Project project, string uid, string summary) {
        Object (platform: platform, project: project, uid: uid, summary: summary);
    }

    public override Gee.TreeSet<string> get_possible_states () {
        var states = new Gee.TreeSet<string> ();
        states.add ("New");
        states.add ("Incomplete");
        states.add ("Opinion");
        states.add ("Invalid");
        states.add ("Won't Fix");
        states.add ("Confirmed");
        states.add ("Triaged");
        states.add ("In Progress");
        states.add ("Fix Committed");
        states.add ("Fix Released");
        return states;
    }

    public override Gee.TreeSet<string> get_hidden_states () {
        var states = new Gee.TreeSet<string> ();
        states.add ("Invalid");
        states.add ("Won't Fix");
        states.add ("Fix Released");
        return states;
    }

    public override int compare (Bug other) {
        var heat1 = get_state_heat (status);
        var heat2 = get_state_heat (other.status);
        if (heat1 > heat2) {
            return 1;
        } else if (heat1 < heat2) {
            return -1;
        } else {
            return summary.collate (other.summary);
        }
    }
    
    private static int get_state_heat (string state) {
        switch (state) {
            case "New":
                return 0;
            case "Triaged":
                return 1;
            case "Confirmed":
                return 2;
            case "Incomplete":
                return 3;
            case "Opinion":
                return 4;
            case "In Progress":
                return 5;
            case "Fix Committed":
                return 6;
            case "Fix Released":
                return 7;
            case "Invalid":
                return 8;
            case "Won't Fix":
                return 9;
            default:
                warning (state);
                return 0;
        }
    }
}
