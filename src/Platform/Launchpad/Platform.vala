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

public static const string LAUNCHPAD_ROOT = "https://api.launchpad.net/devel/";

public class ProjectManager.LaunchpadPlatform : Platform {
    public LaunchpadPlatform () {
        Object (name: "Launchpad");
    }

    public override Gee.TreeSet<Project> search_project (string search, GLib.Cancellable cancellable) {
        var projects = new Gee.TreeSet<Project> ();
        var session = new Soup.Session ();
        var msg = new Soup.Message ("GET", "%sprojects".printf (LAUNCHPAD_ROOT));
        msg.request_headers.append ("ws.op", "search");
        msg.request_headers.append ("text", search);
        session.send_message (msg);
        warning ("");
        if (msg.status_code != Soup.Status.OK) {
            return projects;
        }

        var parser = new Json.Parser ();
        try {
            parser.load_from_data ((string) msg.response_body.data);
            warning ((string) msg.response_body.data);
        } catch (Error e) {
            critical (e.message);
            return projects;
        }

        return projects;
    }
}
