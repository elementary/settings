/*
 * Copyright 2017-2026 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

/**
 * SettingsSidebar acts as a controller for a Gtk.SelectionModel; it shows a row of buttons
 * to switch between the various pages of the associated model.
 *
 * All the content for the rows comes from the child properties of a Granite.SettingsPage
 * inside of the model
 */
public class Switchboard.SettingsSidebar : Gtk.Widget {
    /**
     * The Gtk.Stack to control
     */
    [Version (deprecated = true, deprecated_since = "9.0.0")]
    public Gtk.Stack? stack { get; construct; default = null; }

    /**
     * The Gtk.SingleSelection to control
     */
    public Gtk.SingleSelection model { get; construct; }

    /**
     * Whether to show back and title buttons in the header area
     */
    public bool show_title_buttons { get; set;}

    /**
     * The name of the currently visible Granite.SettingsPage
     */
   [Version (deprecated = true, deprecated_since = "9.0.0")]
    public string? visible_child_name { get; set; default = null; }

    /**
     * Create a new SettingsSidebar
     */
    public SettingsSidebar (Gtk.Stack stack) {
        var selection_model = new Gtk.SingleSelection (stack.pages);
        selection_model.notify["selected"].connect (() => {
            stack.pages.select_item (selection_model.selected, true);
        });

        stack.pages.selection_changed.connect ((pos, n_items) => {
            selection_model.selected = stack.pages.get_selection ().get_minimum ();
        });

        Object (
            model: selection_model,
            stack: stack
        );
    }

    public SettingsSidebar.from_model (Gtk.SingleSelection selection_model) {
        Object (model: selection_model);
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BinLayout));
    }

    class construct {
        set_css_name ("settingssidebar");
    }

    construct {
        var factory = new Gtk.SignalListItemFactory ();
        factory.bind.connect (bind_item);

        var header_factory = new Gtk.SignalListItemFactory ();
        header_factory.bind.connect (bind_header);

        var listview = new Gtk.ListView (model, factory) {
            header_factory = header_factory
        };

        var scrolled = new Gtk.ScrolledWindow () {
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            child = listview
        };

        var headerbar = new Adw.HeaderBar () {
            show_end_title_buttons = false,
            show_title = false
        };

        var toolbarview = new Adw.ToolbarView () {
            content = scrolled,
            top_bar_style = FLAT
        };
        toolbarview.add_top_bar (headerbar);
        toolbarview.set_parent (this);

        add_css_class (Granite.STYLE_CLASS_SIDEBAR);

        bind_property ("show-title-buttons", toolbarview, "reveal-top-bars", SYNC_CREATE);
    }

    ~SettingsSidebar () {
        get_first_child ().unparent ();
    }

    private void bind_item (Object object) {
        var list_item = (Gtk.ListItem) object;
        //FIXME: check type of item in model;
        unowned var stack_page = (Gtk.StackPage) list_item.item;
        unowned var settings_page = (SettingsPage) stack_page.child;
        list_item.child = new SettingsSidebarRow (settings_page);
    }

    private void bind_header (Object item) {
        var list_item = (Gtk.ListHeader) item;
        unowned var stack_page = (Gtk.StackPage) list_item.item;
        unowned var settings_page = (SettingsPage) stack_page.child;

        if (settings_page.header != null) {
            ((Gtk.ListHeader) item).child = new Granite.HeaderLabel (settings_page.header);
        } else {
            ((Gtk.ListHeader) item).child = null;
        }
    }
}
