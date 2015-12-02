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
    private Gtk.ComboBox project_combobox;
    private Gtk.SearchEntry search_entry;
    private Gtk.StackSwitcher stack_switcher;
    private Gtk.Stack main_stack;

    public MainWindow () {
        window_position = Gtk.WindowPosition.CENTER;
        title = _("Project Manager");
        icon_name = "apport";
        set_size_request (750, 550);

        main_stack = new Gtk.Stack ();
        main_stack.transition_type = Gtk.StackTransitionType.OVER_UP_DOWN;

        var list_store = new Gtk.ListStore (2, typeof (string), typeof (Project));
        project_combobox = new Gtk.ComboBox.with_model (list_store);
        var renderer = new Gtk.CellRendererText ();
        project_combobox.pack_start (renderer, true);
        project_combobox.add_attribute (renderer, "text", 0);

        stack_switcher = new Gtk.StackSwitcher ();

        search_entry = new Gtk.SearchEntry ();

        var manager_button = new Gtk.Button.from_icon_name ("folder-saved-search", Gtk.IconSize.LARGE_TOOLBAR);
        manager_button.tooltip_text = _("Manage Projects List…");

        var headerbar = new Gtk.HeaderBar ();
        headerbar.show_close_button = true;
        headerbar.set_custom_title (stack_switcher);
        headerbar.pack_start (project_combobox);
        headerbar.pack_start (manager_button);
        headerbar.pack_end (search_entry);
        set_titlebar (headerbar);
        add (main_stack);

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

        manager_button.clicked.connect (() => {
            var popover = new ProjectList ();
            popover.relative_to = manager_button;
            popover.show_all ();
        });

        foreach (var project in Database.get_default ().get_saved_projects ()) {
            Gtk.TreeIter iter;
            list_store.append (out iter);
            list_store.set (iter, 0, project.name, 1, project);
        }

        project_combobox.changed.connect (() => {
            Value val;
            Gtk.TreeIter iter;
            project_combobox.get_active_iter (out iter);
            list_store.get_value (iter, 1, out val);
            var project = (Project) val.get_object ();
            focus_project (project);
        });

        project_combobox.active = 0;
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

    private void focus_project (Project project) {
        var stack_name = "%s-%s".printf (project.platform, project.uid);
        var stack = main_stack.get_child_by_name (stack_name) as Gtk.Stack;
        if (stack == null) {
            stack = new Gtk.Stack ();
            stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;

            var overview_panel = new Panels.Overview ();
            var code_panel = new Panels.Code ();
            var blueprints_panel = new Panels.Blueprints ();
            var bugs_panel = new Panels.Bugs (project);
            stack.add_titled (overview_panel, "overview", _("Overview"));
            stack.add_titled (code_panel, "code", _("Code"));
            stack.add_titled (blueprints_panel, "blueprints", _("Blueprints"));
            stack.add_titled (bugs_panel, "bugs", _("Bugs"));
            stack.show_all ();
            main_stack.add_named (stack, stack_name);
        }

        var bugs_panel = stack.get_child_by_name ("bugs") as Panels.Bugs;
        bugs_panel.populate ();

        stack_switcher.set_stack (stack);
        stack_switcher.show_all ();
        main_stack.set_visible_child (stack);
    }
}
