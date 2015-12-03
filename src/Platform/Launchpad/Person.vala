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

public class ProjectManager.Launchpad.LPPerson : Person {
    public LPPerson (Platform platform, string uid) {
        Object (platform: platform, uid: uid);
        var session = new Soup.Session ();
        var msg = new Soup.Message ("GET", "%s%s".printf (LAUNCHPAD_ROOT, uid));
        session.send_message (msg);
        if (msg.status_code != Soup.Status.OK) {
            return;
        }

        var parser = new Json.Parser ();
        try {
            parser.load_from_data ((string) msg.response_body.data);
            weak Json.Object root_object = parser.get_root ().get_object ();
            name = root_object.get_string_member ("display_name");
            unowned string avatar_uri = root_object.get_string_member ("mugshot_link");
            var msg2 = new Soup.Message ("GET", avatar_uri);
            session.send_message (msg2);
            if (msg2.status_code == Soup.Status.OK) {
                avatar = new FileIcon (File.new_for_uri (avatar_uri));
            }
        } catch (Error e) {
            critical (e.message);
        }
    }
}
