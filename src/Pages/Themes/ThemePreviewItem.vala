namespace SwaySettings {
    public enum ThemeStyle {
        DEFAULT, DARK;

        public string to_string () {
            switch (this) {
                default:
                case DEFAULT:
                    return "Light";
                case DARK:
                    return "Dark";
            }
        }

        public string get_preview_class (bool front) {
            switch (this) {
                default:
                case DEFAULT:
                    if (!front) return "dark";
                    return "light";
                case DARK:
                    return "dark";
            }
        }

        public string get_gsettings_name () {
            switch (this) {
                default:
                case DEFAULT:
                    return "default";
                case DARK:
                    return "prefer-dark";
            }
        }

        public static ThemeStyle from_gsettings (string value) {
            switch (value) {
                default:
                case "default":
                    return DEFAULT;
                case "prefer-dark":
                    return DARK;
            }
        }
    }

    [GtkTemplate (ui = "/org/erikreider/swaysettings/Pages/Themes/ThemePreviewItem.ui")]
    public class ThemePreviewItem : Gtk.Box {
        [GtkChild]
        unowned Gtk.Label label;

        [GtkChild]
        unowned Gtk.RadioButton button;

        [GtkChild]
        unowned Gtk.Box box;

        [GtkChild]
        unowned Gtk.Overlay overlay;

        [GtkChild]
        unowned Gtk.DrawingArea drawing_area;

        [GtkChild]
        unowned Gtk.Fixed fixed;

        const int TINY_WINDOW_HEIGHT = 64;
        const int TINY_WINDOW_WIDTH = 90;

        public SList<Gtk.RadioButton> group {
            get {
                return button.get_group ();
            }
        }

        public bool active {
            get {
                return button.get_active ();
            }
        }

        ThemeStyle theme_style;

        public signal void toggled (ThemeStyle style);

        public ThemePreviewItem (ThemeStyle style) {
            this.theme_style = style;

            this.set_halign (Gtk.Align.CENTER);

            // Add the fake floating windows
            fixed.put (get_tiny_window (false),
                       50,
                       25);
            fixed.put (get_tiny_window (true),
                       20,
                       45);

            drawing_area.draw.connect (area_draw);

            box.draw.connect (box_draw);

            label.set_text (theme_style.to_string ());

            button.toggled.connect (() => {
                if (!button.active) return;
                toggled (theme_style);
            });
        }

        public void set_toggled (bool state) {
            button.set_active (state);
        }

        public void set_group (SList<Gtk.RadioButton> ? group) {
            button.set_group (group);
        }

        private bool area_draw (Cairo.Context cr) {
            int width = drawing_area.get_allocated_width ();
            int height = drawing_area.get_allocated_height ();

            cr.rectangle (0, 0, width, height);
            double value = theme_style == ThemeStyle.DARK ? 0.4 : 0.8;
            cr.set_source_rgb (value, value, value);
            cr.fill ();
            return false;
        }

        /**
         * Act like the GTK4 overflow property.
         * Makes it rounded and clips the content.
         */
        private bool box_draw (Cairo.Context cr) {
            const double radius = 6;
            const double degrees = Math.PI / 180.0;
            int width = box.get_allocated_width ();
            int height = box.get_allocated_height ();

            cr.new_sub_path ();
            cr.arc (width - radius, radius, radius, -90 * degrees, 0 * degrees);
            cr.arc (width - radius, height - radius, radius, 0 * degrees, 90 * degrees);
            cr.arc (radius, height - radius, radius, 90 * degrees, 180 * degrees);
            cr.arc (radius, radius, radius, 180 * degrees, 270 * degrees);
            cr.close_path ();

            cr.set_source_rgb (0.5, 0.5, 1);
            cr.clip ();

            overlay.draw (cr);
            return true;
        }

        Gtk.Widget get_tiny_window (bool front) {
            var window = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            var style = window.get_style_context ();
            style.add_class ("window");
            style.add_class (theme_style.get_preview_class (front));
            style.add_class (front ? "front" : "back");

            var header_bar = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            var header_style = header_bar.get_style_context ();
            header_style.add_class ("header-bar");
            header_style.add_class (theme_style.get_preview_class (front));
            window.add (header_bar);

            window.set_size_request (TINY_WINDOW_WIDTH, TINY_WINDOW_HEIGHT);
            window.show_all ();
            return window;
        }
    }
}