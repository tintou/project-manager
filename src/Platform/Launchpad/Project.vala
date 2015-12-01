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

public class ProjectManager.LaunchpadProject : Project {
    public LaunchpadProject (string uid) {
        Object (uid: uid);
    }

    public override bool load_project () {
        var session = new Soup.Session ();
        var msg = new Soup.Message ("GET", "%s%s".printf (LAUNCHPAD_ROOT, uid));
        session.send_message (msg);
        if (msg.status_code != Soup.Status.OK) {
            return false;
        }

        var parser = new Json.Parser ();
        try {
            parser.load_from_data ((string) msg.response_body.data);
            warning ((string) msg.response_body.data);
            process_info_node (parser.get_root ());
        } catch (Error e) {
            critical (e.message);
            return false;
        }

        return true;
    }

    private void process_info_node (Json.Node node) {
        
    }

    public override Gee.TreeSet<Bug> get_bugs () {
        return new Gee.TreeSet<Bug> ();
    }
}
