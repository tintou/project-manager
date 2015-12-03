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

public class ProjectManager.Launchpad.LPProject : Project {
    public LPProject (Platform platform, string uid) {
        Object (uid: uid, platform: platform);
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

    public override Bug create_bug_object (string bug_uid, string bug_name) {
        return new Malone (platform, this, bug_uid, bug_name);
    }

    public override Gee.TreeSet<Bug> get_bugs () {
        var given_bugs = new Gee.TreeSet<Bug> ();
        given_bugs.add_all (get_saved_bugs ());

        var session = new Soup.Session ();
        var uri = new Soup.URI (LAUNCHPAD_ROOT);
        uri.set_path (uri.path + uid);
        uri.set_query_from_fields ("ws.op", "searchTasks");
        var msg = new Soup.Message.from_uri ("GET", uri);
        session.send_message (msg);
        if (msg.status_code != Soup.Status.OK) {
            return given_bugs;
        }

        var parser = new Json.Parser ();
        try {
            parser.load_from_data ((string) msg.response_body.data);
            List<unowned Json.Node> elements = parser.get_root ().get_object ().get_array_member ("entries").get_elements ();
            foreach (unowned Json.Node val in elements) {
                weak Json.Object object = val.get_object ();
                var bug_uid = object.get_string_member ("bug_link").replace (LAUNCHPAD_ROOT+"bugs/", "");
                if (bugs.get (bug_uid) == null) {
                    string bug_description = object.get_string_member ("title");
                    var start = bug_description.index_of_char ('"');
                    var end = bug_description.last_index_of_char ('"');
                    if (start >= 0 && end >= 0) {
                        bug_description = bug_description.slice (start+1, end);
                    }

                    string bug_status = object.get_string_member ("status");
                    string bug_owner = object.get_string_member ("owner_link").replace (LAUNCHPAD_ROOT, "");

                    var bug = create_bug_object (bug_uid, bug_description);
                    bug.status = bug_status;
                    bug.owner = platform.get_person (bug_owner);
                    bugs.set (bug_uid, bug);
                    given_bugs.add (bug);
                }
            }
        } catch (Error e) {
            critical (e.message);
            return given_bugs;
        }

        return given_bugs;
    }
}
