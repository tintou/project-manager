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

namespace ProjectManager {
    const string project_manager = N_("About Project Manager");
    public class App : Granite.Application {
        MainWindow main_window;

        construct {
            application_id = "com.github.tintou.project-manager";
            flags = ApplicationFlags.FLAGS_NONE;
            Intl.setlocale (LocaleCategory.ALL, "");
            Intl.textdomain (Build.GETTEXT_PACKAGE);

            program_name = _("Project Manager");
            app_years = "2015-2017";
            app_icon = Build.DESKTOP_ICON;

            build_data_dir = Build.DATADIR;
            build_pkg_data_dir = Build.PKGDATADIR;
            build_release_name = Build.RELEASE_NAME;
            build_version = Build.VERSION;
            build_version_info = Build.VERSION_INFO;

            app_launcher = application_id + ".desktop";
            main_url = "https://github.com/tintou/project-manager";
            bug_url = "https://github.com/tintou/project-manager/issues";
            help_url = "https://github.com/tintou/project-manager/issues"; 
            translate_url = "https://github.com/tintou/project-manager";
            about_authors = { "Corentin Noël <corentin@elementary.io>" };
            about_comments = "";
            about_translators = _("translator-credits");
            about_license_type = Gtk.License.GPL_3_0;
        }

        public override void activate () {
            if (main_window == null) {
                main_window = new MainWindow ();
                main_window.set_application (this);
                main_window.show_all ();
            }

            main_window.present ();
        }
    }

    public static int main (string[] args) {
        var application = new App ();
        return application.run (args);
    }
}
