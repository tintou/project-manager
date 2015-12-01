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

public class ProjectManager.ProjectList : Gtk.Dialog {
    Gtk.TreeView treeview;
    Gtk.ListStore list_store;
    public ProjectList () {
        set_size_request (400, 350);
        /*uint search_behavior = 0U;
        GLib.Cancellable cancellable = null;
        if (cancellable != null)  {
            cancellable.cancel ();
        }

        cancellable = new GLib.Cancellable ();

        if (search_behavior != 0U) {
            Source.remove (search_behavior);
        }

        search_behavior = Timeout.add (150, () => {
            search_project (cancellable);
            search_behavior = 0;
            return GLib.Source.REMOVE;
        });*/
    }

    construct {
        modal = true;
        title = _("Manage Projects");
        var grid = new Gtk.Grid ();
        grid.margin = 6;
        grid.margin_top = 0;
        grid.orientation = Gtk.Orientation.VERTICAL;
        list_store = new Gtk.ListStore (2, typeof (string), typeof (Project));
        treeview = new Gtk.TreeView.with_model (list_store);

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.shadow_type = Gtk.ShadowType.IN;
        scrolled.expand = true;
        scrolled.add (treeview);

        var toolbar = new Gtk.Toolbar ();
        toolbar.icon_size = Gtk.IconSize.SMALL_TOOLBAR;
        toolbar.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);

        var add_button = new Gtk.ToolButton (null, null);
        add_button.icon_name = "list-add-symbolic";
        add_button.tooltip_text = _("Add Project");

        var remove_button = new Gtk.ToolButton (null, null);
        remove_button.icon_name = "list-remove-symbolic";
        remove_button.tooltip_text = _("Remove Selected Project");

        toolbar.add (add_button);
        toolbar.add (remove_button);

        this.add_button (_("Close"), 0);
        response.connect ((id) => destroy ());

        grid.add (scrolled);
        grid.add (toolbar);
        get_content_area ().add (grid);
    }
}
