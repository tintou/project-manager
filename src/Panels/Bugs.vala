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

const string COLORED_STYLE_CSS = """
    .colored {
        color: %s;
    }
    """;

public class ProjectManager.Panels.Bugs : Gtk.Grid {
    Gtk.ListBox list_box;
    Gtk.ListBox bug_list_box;
    unowned Project project;
    bool populated = false;
    public Bugs (Project project) {
        this.project = project;
    }

    public void populate () {
        if (populated) {
            return;
        }

        new Thread<void*> (null, () => {
            BugHeadRow[] rows = {};
            foreach (var bug in project.get_bugs ()) {
                var row = new BugHeadRow (bug);
                row.show_all ();
                rows += row;
            }

            Idle.add (() => {
                foreach (var row in rows) {
                    list_box.add (row);
                }
                return false;
            });
            populated = true;
            return null;
        });

    }

    construct {
        expand = true;
        var pane = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        list_box = new Gtk.ListBox ();
        list_box.set_sort_func ((row1, row2) => sort (row1, row2));
        list_box.set_header_func ((row, before) => header (row, before));
        var scrolled_left = new Gtk.ScrolledWindow (null, null);
        scrolled_left.expand = true;
        scrolled_left.add (list_box);
        bug_list_box = new Gtk.ListBox ();
        var scrolled_right = new Gtk.ScrolledWindow (null, null);
        scrolled_right.add (bug_list_box);
        pane.pack1 (scrolled_left, false, false);
        pane.pack2 (scrolled_right, false, false);
        add (pane);
    }

    private int sort (Gtk.ListBoxRow row1, Gtk.ListBoxRow row2) {
        var headrow1 = row1 as BugHeadRow;
        var headrow2 = row2 as BugHeadRow;
        return headrow1.bug.compare (headrow2.bug);
    }

    private void header (Gtk.ListBoxRow row, Gtk.ListBoxRow? before) {
        var headrow1 = row as BugHeadRow;
        if (before == null) {
            var head = get_header_with_string (headrow1.bug.status);
            row.set_header (head);
        } else {
            var headrow2 = before as BugHeadRow;
            if (headrow1.bug.status != headrow2.bug.status) {
                var head = get_header_with_string (headrow1.bug.status);
                row.set_header (head);
            } else {
                row.set_header (null);
            }
        }
    }

    private Gtk.Widget get_header_with_string (string head_string) {
        var label = new Gtk.Label (head_string);
        label.margin = 3;
        label.hexpand = true;
        label.get_style_context ().add_class ("h4");
        ((Gtk.Misc) label).xalign = 0;
        label.show_all ();
        return label;
    }

    public class BugHeadRow : Gtk.ListBoxRow {
        public Bug bug;
        private Gtk.Grid importance_color;
        private Gtk.Label summary;
        private Gtk.Label bug_uid;
        private Gtk.Label comments;
        private Granite.Widgets.Avatar avatar;
        public BugHeadRow (Bug bug) {
            this.bug = bug;
            summary.label = bug.summary;
            bug_uid.label = "#%s".printf (bug.uid);
            var load_icon = bug.owner.avatar as LoadableIcon;
            if (load_icon != null) {
                try {
                    var stream = load_icon.load (32, null);
                    var pixbuf = new Gdk.Pixbuf.from_stream_at_scale (stream, 32, 32, true);
                    avatar.pixbuf = pixbuf;
                } catch (Error e) {
                    critical (e.message);
                }
            }
        }

        construct {
            importance_color = new Gtk.Grid ();

            var grid = new Gtk.Grid ();
            grid.margin = 6;
            grid.column_spacing = 12;
            grid.row_spacing = 6;

            summary = new Gtk.Label (null);
            summary.hexpand = true;
            summary.ellipsize = Pango.EllipsizeMode.END;
            ((Gtk.Misc) summary).xalign = 0;
            bug_uid = new Gtk.Label (null);
            bug_uid.sensitive = false;
            ((Gtk.Misc) bug_uid).xalign = 1;
            comments = new Gtk.Label (null);
            ((Gtk.Misc) comments).xalign = 1;
            avatar = new Granite.Widgets.Avatar.with_default_icon (32);
            grid.attach (avatar, 0, 0, 1, 2);
            grid.attach (summary, 1, 0, 1, 2);
            grid.attach (bug_uid, 2, 0, 1, 1);
            grid.attach (comments, 2, 0, 1, 1);

            var main_grid = new Gtk.Grid ();
            main_grid.orientation = Gtk.Orientation.HORIZONTAL;
            main_grid.add (importance_color);
            main_grid.add (grid);
            add (main_grid);
        }

        private void set_importance_color (Gdk.RGBA color) {
            var provider = new Gtk.CssProvider ();
            try {
                var colored_css = COLORED_STYLE_CSS.printf (color.to_string ());
                provider.load_from_data (colored_css, colored_css.length);
                var context = importance_color.get_style_context ();
                context.add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
                context.add_class ("colored");
            } catch (GLib.Error e) {
                critical (e.message);
            }
        }
    }
}
