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

public static const string LAUNCHPAD_ROOT = "https://api.launchpad.net/devel/";

public class ProjectManager.Launchpad.LPPlatform : Platform {
    public LPPlatform () {
        Object (name: "Launchpad");
    }

    public override Project? get_project (string project_id, GLib.Cancellable cancellable, string? name = null) {
        if (name == null) {
            var session = new Soup.Session ();
            var msg = new Soup.Message ("GET", "%s%s".printf (LAUNCHPAD_ROOT, project_id));
            session.send_message (msg);
            if (msg.status_code != Soup.Status.OK) {
                return null;
            }
        }

        var proj = new LPProject (this, project_id);
        proj.name = name;
        return proj;
    }

    public override Person get_person (string person_id) {
        if (persons == null) {
            get_saved_persons ();
        }

        var person = persons.get (person_id);
        if (person == null) {
            person = create_person_object (person_id);
            persons.set (person_id, person);
        }

        return person;
    }

    public override Person create_person_object (string person_id) {
        return new LPPerson (this, person_id);
    }
}
