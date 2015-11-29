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

public class ProjectManager.Panels.Bugs : Gtk.Grid {
    Gtk.ListBox list_box;
    Gtk.ListBox bug_list_box;
    public Bugs () {
        
    }

    construct {
        expand = true;
        var pane = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        list_box = new Gtk.ListBox ();
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
}
