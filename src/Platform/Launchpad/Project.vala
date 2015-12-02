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
    private Gee.HashMap<string, Bug> bugs;

    public LaunchpadProject (string uid) {
        Object (uid: uid);
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
        var returned_bugs = new Gee.TreeSet<Bug> ();
        if (bugs == null) {
            bugs = new Gee.HashMap<string, Bug> ();
            try {
                var builder = new Gda.SqlBuilder (Gda.SqlStatementType.SELECT);
                builder.select_add_target ("bugs", null);
                builder.select_add_field ("*", null, null);

                // The project value has to correspond to the current uid.
                var id_field_1 = builder.add_id ("project");
                var proj_value = GLib.Value (typeof (string));
                proj_value.set_string (uid);
                var id_param_1 = builder.add_expr_value (null, proj_value);
                var id_cond_1 = builder.add_cond (Gda.SqlOperatorType.LIKE, id_field_1, id_param_1, 0);

                // The platform value has to correspond to the current platform.
                var id_field_2 = builder.add_id ("platform");
                var platform_value = GLib.Value (typeof (string));
                platform_value.set_string ("Launchpad");
                var id_param_2 = builder.add_expr_value (null, platform_value);
                var id_cond_2 = builder.add_cond (Gda.SqlOperatorType.LIKE, id_field_2, id_param_2, 0);

                var id_cond = builder.add_cond (Gda.SqlOperatorType.AND, id_cond_1, id_cond_2, 0);
                builder.set_where (id_cond);
                unowned Gda.Connection connection = Database.get_default ().get_db_connection ();
                var data_model = connection.statement_execute_select (builder.get_statement (), null);
                for (int i = 0; i < data_model.get_n_rows (); i++) {
                    var uid_val = data_model.get_value_at (data_model.get_column_index ("uid"), i).get_string ();
                    var name_val = data_model.get_value_at (data_model.get_column_index ("name"), i).get_string ();
                    var bug = new LaunchpadBug (uid_val, name_val);
                    bugs.set (uid_val, bug);
                }
            } catch (Error e) {
                critical ("Could not query table 'bugs' : %s", e.message);
            }
            
        }

        returned_bugs.add_all (bugs.values);
        return returned_bugs;
    }
}
