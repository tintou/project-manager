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

public class ProjectManager.ProjectList : Gtk.Popover {
    Gtk.ListBox list_box;
    GLib.Cancellable cancellable;
    public ProjectList () {
        
    }

    construct {
        position = Gtk.PositionType.BOTTOM;
        var grid = new Gtk.Grid ();
        grid.orientation = Gtk.Orientation.VERTICAL;
        var search_entry = new Gtk.SearchEntry ();
        search_entry.margin = 6;
        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.margin_bottom = 6;
        scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
        scrolled.set_size_request (-1, 150);
        list_box = new Gtk.ListBox ();
        scrolled.add (list_box);
        grid.add (search_entry);
        grid.add (scrolled);
        add (grid);
        search_entry.grab_focus ();

        search_entry.activate.connect (() => add_available_project (search_entry.text));
        search_entry.icon_release.connect ((p0, p1) => {
            if (p0 == Gtk.EntryIconPosition.PRIMARY) {
                add_available_project (search_entry.text);
            }
        });

        foreach (var project in Database.get_default ().get_saved_projects ()) {
            var projectrow = new ProjectListRow (project);
            projectrow.show_all ();
            list_box.add (projectrow);
        }
    }

    private void add_available_project (string text) {
        if (cancellable != null)  {
            cancellable.cancel ();
        }

        cancellable = new GLib.Cancellable ();
        Project? project = null;
        foreach (var platform in Database.get_default ().get_supported_platforms ()) {
            project = platform.get_project (text, cancellable);
            if (project != null) {
                break;
            }
        }

        if (project != null) {
            var projectrow = new ProjectListRow (project);
            projectrow.show_all ();
            list_box.add (projectrow);
            project.save ();
        }
    }

    public class ProjectListRow : Gtk.ListBoxRow {
        public Project project;
        private Gtk.Image image;
        private Gtk.Label title;
        public ProjectListRow (Project project) {
            this.project = project;
            project.load_project ();
            image.gicon = project.icon;
            title.label = project.name;
        }

        construct {
            var grid = new Gtk.Grid ();
            grid.orientation = Gtk.Orientation.HORIZONTAL;
            grid.column_spacing = 12;
            grid.margin = 6;
            image = new Gtk.Image ();
            image.icon_size = Gtk.IconSize.BUTTON;
            title = new Gtk.Label (null);
            ((Gtk.Misc) title).xalign = 0;
            title.hexpand = true;
            var delete_button = new Gtk.Button.from_icon_name ("edit-delete", Gtk.IconSize.MENU);
            delete_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            grid.add (image);
            grid.add (title);
            grid.add (delete_button);
            add (grid);
        }
    }
}
