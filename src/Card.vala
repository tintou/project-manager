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

public class ProjectManager.Card : Gtk.ListBoxRow {
    Gtk.Grid grid;
    public Card () {
        
    }

    construct {
        selectable = false;
        var frame = new Gtk.Frame (null);
        frame.margin = 12;
        frame.get_style_context ().add_class ("card");
        grid = new Gtk.Grid ();
        grid.margin = 3;
        frame.add (grid);
        add (frame);
    }

    public Gtk.Grid get_content_grid () {
        return grid;
    }
}
