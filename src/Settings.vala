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

public class ProjectManager.Settings : Granite.Services.Settings {
    public enum WindowState {
        NORMAL,
        MAXIMIZED,
        FULLSCREEN
    }

    public int window_width { get; set; }
    public int window_height { get; set; }
    public WindowState window_state { get; set; }

    private static Settings main_settings;
    public static unowned Settings get_default () {
        if (main_settings == null)
            main_settings = new Settings ();
        return main_settings;
    }

    private Settings ()  {
        base ("org.pantheon.project-manager.settings");
    }
}
