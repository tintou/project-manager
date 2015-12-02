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
        Object (uid: uid, platform: "Launchpad");
    }

    public override bool load_project () {
        if (loaded) {
            return true;
        }

        var session = new Soup.Session ();
        var msg = new Soup.Message ("GET", "%s%s".printf (LAUNCHPAD_ROOT, uid));
        session.send_message (msg);
        if (msg.status_code != Soup.Status.OK) {
            return false;
        }

        var parser = new Json.Parser ();
        try {
            parser.load_from_data ((string) msg.response_body.data);
            weak Json.Object root_object = parser.get_root ().get_object ();
            name = root_object.get_string_member ("display_name");
            summary = root_object.get_string_member ("summary");
            description = root_object.get_string_member ("description");
            var icon_file = File.new_for_uri (root_object.get_string_member ("icon_link"));
            icon = new FileIcon (icon_file);
            var logo_file = File.new_for_uri (root_object.get_string_member ("logo_link"));
            logo = new FileIcon (logo_file);
        } catch (Error e) {
            critical (e.message);
            return false;
        }

        loaded = true;
        return true;
    }

    public override Gee.TreeSet<Bug> get_bugs () {
        var given_bugs = new Gee.TreeSet<Bug> ();
        given_bugs.add_all (get_saved_bugs ());

        var session = new Soup.Session ();
        var msg = new Soup.Message ("GET", "%s%s?ws.op=searchTasks".printf (LAUNCHPAD_ROOT, uid));
        session.send_message (msg);
        if (msg.status_code != Soup.Status.OK) {
            return given_bugs;
        }

        var parser = new Json.Parser ();
        try {
            parser.load_from_data ((string) msg.response_body.data);
            warning ((string) msg.response_body.data);
            List<unowned Json.Node> elements = parser.get_root ().get_object ().get_array_member ("entries").get_elements ();
            foreach (unowned Json.Node val in elements) {
                weak Json.Object object = val.get_object ();
                unowned string bug_link = object.get_string_member ("bug_link");
                unowned string bug_status = object.get_string_member ("status");
                unowned string bug_importance = object.get_string_member ("importance");
                var bug = get_bug_from_infos (bug_link, bug_status, bug_importance);
                if (bug != null) {
                    Idle.add (() => {
                        project.bug_added (bug);
                        return false;
                    });
                }
            }
        } catch (Error e) {
            critical (e.message);
            return given_bugs;
        }

        return given_bugs;
    }
}
