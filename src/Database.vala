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

public class ProjectManager.Database : GLib.Object {
    private static Database database;
    public static Database get_default () {
        if (database == null) {
            database = new Database ();
        }

        return database;
    }

    private Gda.Connection connection;
    private Gee.TreeSet<Platform> platforms;
    private Gee.TreeSet<Project> projects;

    private Database () {
        
    }

    construct {
        platforms = new Gee.TreeSet<Platform> ();
        platforms.add (new Launchpad.LPPlatform ());
        init_database ();
    }

    public Gee.Collection<Platform> get_supported_platforms () {
        return platforms.read_only_view;
    }

    public Gee.TreeSet<Project> get_saved_projects () {
        if (projects == null) {
            projects = new Gee.TreeSet<Project> ();
            try {
                var builder = new Gda.SqlBuilder (Gda.SqlStatementType.SELECT);
                builder.select_add_target ("projects", null);
                builder.select_add_field ("*", null, null);
                var data_model = connection.statement_execute_select (builder.get_statement (), null);
                for (int i = 0; i < data_model.get_n_rows (); i++) {
                    var platform_val = data_model.get_value_at (data_model.get_column_index ("platform"), i).get_string ();
                    var uid_val = data_model.get_value_at (data_model.get_column_index ("uid"), i).get_string ();
                    var name_val = data_model.get_value_at (data_model.get_column_index ("name"), i).get_string ();
                    foreach (var platform in get_supported_platforms ()) {
                        if (platform.name == platform_val) {
                            projects.add (platform.get_project (uid_val, new GLib.Cancellable (), name_val));
                        }
                    }
                }
            } catch (Error e) {
                critical ("Could not query table 'projects' : %s", e.message);
            }
            
        }

        return projects;
    }

    public unowned Gda.Connection get_db_connection () {
        return connection;
    }

    private void init_database () {
        string data_dir = Environment.get_user_data_dir ();
        string dir_path = Path.build_path (Path.DIR_SEPARATOR_S, data_dir, "project-manager");
        var database_dir = File.new_for_path (dir_path);
        try {
            database_dir.make_directory_with_parents (null);
        } catch (GLib.Error err) {
            if (err is IOError.EXISTS == false)
                error ("Could not create data directory: %s", err.message);
        }

        var db_file = database_dir.get_child ("project-manager-1.db");
        bool new_db = !db_file.query_exists ();
        if (new_db) {
            try {
                db_file.create (FileCreateFlags.PRIVATE);
            } catch (Error e) {
                critical ("Error: %s", e.message);
            }
        }

        try {
            connection = new Gda.Connection.from_string ("SQLite", "DB_DIR=%s;DB_NAME=%s".printf (database_dir.get_path (), "project-manager-1"), null, Gda.ConnectionOptions.NONE);
            connection.open ();
        } catch (Error e) {
            error (e.message);
        }

        create_projects_table ();
        create_bugs_table ();
        create_persons_table ();
    }

    private void create_projects_table () {
        Error e = null;
        var operation = Gda.ServerOperation.prepare_create_table (connection, "projects", e,
                        "platform", typeof (string), Gda.ServerOperationCreateTableFlag.NOTHING_FLAG,
                        "uid", typeof (string), Gda.ServerOperationCreateTableFlag.NOTHING_FLAG,
                        "name", typeof (string), Gda.ServerOperationCreateTableFlag.NOTHING_FLAG,
                        "rowid", typeof (int64), Gda.ServerOperationCreateTableFlag.PKEY_AUTOINC_FLAG);
        if (e != null) {
            critical (e.message);
        } else {
            try {
                operation.perform_create_table ();
            } catch (Error e) {
                // e.code == 1 is when the table already exists.
                if (e.code != 1) {
                    critical (e.message);
                }
            }
        }
    }

    private void create_bugs_table () {
        Error e = null;
        var operation = Gda.ServerOperation.prepare_create_table (connection, "bugs", e,
                        "platform", typeof (string), Gda.ServerOperationCreateTableFlag.NOTHING_FLAG,
                        "project", typeof (string), Gda.ServerOperationCreateTableFlag.NOTHING_FLAG,
                        "uid", typeof (string), Gda.ServerOperationCreateTableFlag.NOTHING_FLAG,
                        "name", typeof (string), Gda.ServerOperationCreateTableFlag.NOTHING_FLAG,
                        "status", typeof (string), Gda.ServerOperationCreateTableFlag.NOTHING_FLAG,
                        "owner", typeof (string), Gda.ServerOperationCreateTableFlag.NOTHING_FLAG,
                        "rowid", typeof (int64), Gda.ServerOperationCreateTableFlag.PKEY_AUTOINC_FLAG);
        if (e != null) {
            critical (e.message);
        } else {
            try {
                operation.perform_create_table ();
            } catch (Error e) {
                // e.code == 1 is when the table already exists.
                if (e.code != 1) {
                    critical (e.message);
                }
            }
        }
    }

    private void create_persons_table () {
        Error e = null;
        var operation = Gda.ServerOperation.prepare_create_table (connection, "persons", e,
                        "platform", typeof (string), Gda.ServerOperationCreateTableFlag.NOTHING_FLAG,
                        "uid", typeof (string), Gda.ServerOperationCreateTableFlag.NOTHING_FLAG,
                        "name", typeof (string), Gda.ServerOperationCreateTableFlag.NOTHING_FLAG,
                        "avatar", typeof (string), Gda.ServerOperationCreateTableFlag.NOTHING_FLAG,
                        "rowid", typeof (int64), Gda.ServerOperationCreateTableFlag.PKEY_AUTOINC_FLAG);
        if (e != null) {
            critical (e.message);
        } else {
            try {
                operation.perform_create_table ();
            } catch (Error e) {
                // e.code == 1 is when the table already exists.
                if (e.code != 1) {
                    critical (e.message);
                }
            }
        }
    }
}
