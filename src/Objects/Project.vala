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

public abstract class ProjectManager.Project : GLib.Object {
    internal Gee.HashMap<string, Bug> bugs;
    public string uid { public get; construct; }
    public string name { public get; public set; }
    public string summary { public get; public set; }
    public string description { public get; public set; }
    public string platform { public get; construct; }
    public GLib.Icon icon { public get; public set; }
    public GLib.Icon logo { public get; public set; }
    public bool loaded { public get; internal set; default=false; }

    construct {
        bugs = new Gee.HashMap<string, Bug> ();
    }

    public abstract bool load_project ();
    public abstract Gee.TreeSet<Bug> get_bugs ();
    public Gee.TreeSet<Bug> get_saved_bugs () {
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
                platform_value.set_string (platform);
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

    public void save () {
        try {
            var builder = new Gda.SqlBuilder (Gda.SqlStatementType.INSERT);
            builder.set_table ("projects");
            var name_val = Value (typeof (string));
            name_val.set_string (name);
            var uid_val = Value (typeof (string));
            uid_val.set_string (uid);
            var platform_val = Value (typeof (string));
            platform_val.set_string (platform);
            builder.add_field_value_as_gvalue ("name", name_val);
            builder.add_field_value_as_gvalue ("uid", uid_val);
            builder.add_field_value_as_gvalue ("platform", platform_val);
            var statement = builder.get_statement ();
            Database.get_default ().get_db_connection ().statement_execute_non_select (statement, null, null);
        } catch (Error e) {
            critical (e.message);
        }
    }
}
