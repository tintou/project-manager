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
    public string uid { public get; construct; }
    public string name { public get; public set; }
    public string summary { public get; public set; }
    public string description { public get; public set; }
    public GLib.Icon icon { public get; public set; }
    public GLib.Icon logo { public get; public set; }
    public bool loaded { public get; internal set; default=false; }

    public abstract bool load_project ();
    public abstract Gee.TreeSet<Bug> get_bugs ();
    public void save () {
    
    }
}
