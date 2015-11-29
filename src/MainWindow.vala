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

public class ProjectManager.MainWindow : Gtk.Window {
    private Gtk.ComboBoxText project_combobox;
    private Gtk.SearchEntry search_entry;
    private Panels.Overview overview_panel;
    private Panels.Code code_panel;
    private Panels.Blueprints blueprints_panel;
    private Panels.Bugs bugs_panel;

    public MainWindow () {
        window_position = Gtk.WindowPosition.CENTER;
        title = _("Project Manager");
        icon_name = "apport";
        set_size_request (750, 550);

        var stack = new Gtk.Stack ();
        stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;

        project_combobox = new Gtk.ComboBoxText.with_entry ();

        var stack_switcher = new Gtk.StackSwitcher ();
        stack_switcher.set_stack (stack);

        search_entry = new Gtk.SearchEntry ();

        var headerbar = new Gtk.HeaderBar ();
        headerbar.show_close_button = true;
        headerbar.set_custom_title (stack_switcher);
        headerbar.pack_start (project_combobox);
        headerbar.pack_end (search_entry);
        set_titlebar (headerbar);


        overview_panel = new Panels.Overview ();
        code_panel = new Panels.Code ();
        blueprints_panel = new Panels.Blueprints ();
        bugs_panel = new Panels.Bugs ();
        stack.add_titled (overview_panel, "overview", _("Overview"));
        stack.add_titled (code_panel, "code", _("Code"));
        stack.add_titled (blueprints_panel, "blueprints", _("Blueprints"));
        stack.add_titled (bugs_panel, "bugs", _("Bugs"));
        add (stack);

        unowned Settings saved_state = Settings.get_default ();
        set_default_size (saved_state.window_width, saved_state.window_height);

        // Maximize window if necessary
        switch (saved_state.window_state) {
            case Settings.WindowState.MAXIMIZED:
                this.maximize ();
                break;
            default:
                break;
        }

        project_combobox.changed.connect (() => {
            warning (project_combobox.get_active_text ());
        });
    }

    public override bool delete_event (Gdk.EventAny event) {
        int window_width;
        int window_height;
        get_size (out window_width, out window_height);
        unowned Settings saved_state = Settings.get_default ();
        saved_state.window_width = window_width;
        saved_state.window_height = window_height;
        if (is_maximized) {
            saved_state.window_state = Settings.WindowState.MAXIMIZED;
        } else {
            saved_state.window_state = Settings.WindowState.NORMAL;
        }

        return false;
    }
}