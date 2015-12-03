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

public abstract class ProjectManager.Platform : GLib.Object {
    public string name { public get; construct; }
    internal Gee.HashMap<string, Person> persons;
    public abstract Project? get_project (string project_id, GLib.Cancellable cancellable, string? name = null);
    public abstract Person get_person (string person_id);
    public abstract Person create_person_object (string person_id);
    public Gee.TreeSet<Person> get_saved_persons () {
        var returned_persons = new Gee.TreeSet<Person> ();
        if (persons == null) {
            persons = new Gee.HashMap<string, Person> ();
            try {
                var builder = new Gda.SqlBuilder (Gda.SqlStatementType.SELECT);
                builder.select_add_target ("persons", null);
                builder.select_add_field ("*", null, null);

                // The platform value has to correspond to the current platform.
                var id_field = builder.add_id ("platform");
                var platform_value = GLib.Value (typeof (string));
                platform_value.set_string (name);
                var id_param = builder.add_expr_value (null, platform_value);
                var id_cond = builder.add_cond (Gda.SqlOperatorType.LIKE, id_field, id_param, 0);
                builder.set_where (id_cond);
                unowned Gda.Connection connection = Database.get_default ().get_db_connection ();
                var data_model = connection.statement_execute_select (builder.get_statement (), null);
                for (int i = 0; i < data_model.get_n_rows (); i++) {
                    var uid_val = data_model.get_value_at (data_model.get_column_index ("uid"), i).get_string ();
                    var name_val = data_model.get_value_at (data_model.get_column_index ("name"), i).get_string ();
                    var avatar_val = data_model.get_value_at (data_model.get_column_index ("avatar"), i).get_string ();
                    var person = create_person_object (uid_val);
                    person.name = name_val;
                    if (avatar_val != null) {
                        var file = File.new_for_uri (avatar_val);
                        person.avatar = new FileIcon (file);
                    }

                    persons.set (uid_val, person);
                }
            } catch (Error e) {
                critical ("Could not query table 'persons' : %s", e.message);
            }
            
        }

        returned_persons.add_all (persons.values);
        return returned_persons;
    }
}
