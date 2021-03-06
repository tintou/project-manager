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

public abstract class ProjectManager.Bug : GLib.Object {
    public unowned Project project { public get; construct; }
    public unowned Platform platform { public get; construct; }
    public string uid { public get; construct; }
    public string summary { public get; public set; }
    public string description { public get; public set; }
    public string status { public get; public set; }
    public string importance { public get; public set; }
    public Person owner { public get; public set; }
    public string assignment { public get; public set; }
    public string milestone { public get; public set; }
    public string[] tags { public get; public set; }
    /**
     * Get all the possible values that the status field can have
     */
    public abstract Gee.TreeSet<string> get_possible_states ();
    /**
     * Get all the possible values that the status field can have when the bug should be hidden (closed, won't fix, released…)
     */
    public abstract Gee.TreeSet<string> get_hidden_states ();
    public abstract int compare (Bug other);
}
