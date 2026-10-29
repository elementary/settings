/*
 * Copyright 2017–2021 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

private class Switchboard.SettingsSidebarRow : Gtk.ListBoxRow {
    public SettingsPage.StatusType status_type {
        set {
            switch (value) {
                case SettingsPage.StatusType.ERROR:
                    status_icon.icon_name = "emblem-error";
                    break;
                case SettingsPage.StatusType.OFFLINE:
                    status_icon.icon_name = "emblem-disabled";
                    break;
                case SettingsPage.StatusType.SUCCESS:
                    status_icon.icon_name = "emblem-enabled";
                    break;
                case SettingsPage.StatusType.WARNING:
                    status_icon.icon_name = "emblem-warning";
                    break;
                case SettingsPage.StatusType.NONE:
                    status_icon.clear ();
                    break;
            }
        }
    }

    public string? header { get; set; }
    public string? status { get; set; }
    public string title { get; set; }

    public unowned SettingsPage page { get; construct; }

    public Icon icon { get; set; }

    private Gtk.Widget display_widget;
    private Gtk.Image status_icon;

    public SettingsSidebarRow (SettingsPage page) {
        Object (
            page: page
        );
    }

    construct {
        var header_label = new Granite.HeaderLabel (page.title) {
            ellipsize = END,
            mnemonic_widget = this,
            size = H3,
            valign = CENTER,
            vexpand = true
        };

        status_icon = new Gtk.Image () {
            halign = Gtk.Align.END,
            valign = Gtk.Align.END
        };

        if (!page.with_avatar) {
            display_widget = new Gtk.Image () {
                icon_size = LARGE
            };

            page.bind_property ("icon", display_widget, "gicon", SYNC_CREATE);
        } else {
            display_widget = new Adw.Avatar (32, page.title, true) {
                valign = START
            };

            page.bind_property ("avatar-paintable", display_widget, "custom-image", SYNC_CREATE);
            page.bind_property ("title", display_widget, "text", SYNC_CREATE);
        }

        var overlay = new Gtk.Overlay () {
            child = display_widget
        };
        overlay.add_overlay (status_icon);

        var box = new Granite.Box (HORIZONTAL, HALF);
        box.append (overlay);
        box.append (header_label);

        accessible_role = TAB;
        child = box;

        header = page.header;
        page.bind_property ("icon", this, "icon", BindingFlags.DEFAULT);
        page.bind_property ("status", header_label, "secondary-text", BindingFlags.DEFAULT);
        page.bind_property ("status-type", this, "status-type", BindingFlags.DEFAULT);
        page.bind_property ("title", header_label, "label", BindingFlags.DEFAULT);

        if (page.status != null) {
            status = page.status;
        }

        if (page.status_type != SettingsPage.StatusType.NONE) {
            status_type = page.status_type;
        }
    }
}
