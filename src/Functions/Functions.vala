using Gee;

namespace SwaySettings {
    public class Functions {

        public delegate void Delegate_walk_func (FileInfo file_info, File file);

        public static int walk_through_dir (string path, Delegate_walk_func func) {
            try {
                var directory = File.new_for_path (path);
                if (!directory.query_exists ()) return 1;
                var enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME, 0);
                FileInfo file_prop;
                while ((file_prop = enumerator.next_file ()) != null) {
                    func (file_prop, directory);
                }
            } catch (Error e) {
                print ("Error: %s\n", e.message);
                return 1;
            }
            return 0;
        }

        public static File check_settings_folder_exists (string file_name) {
            string basePath = GLib.Environment.get_user_config_dir () + "/sway/.generated_settings";
            // Checks if directory exists. Creates one if none
            if (!GLib.FileUtils.test (basePath, GLib.FileTest.IS_DIR)) {
                try {
                    var file = File.new_for_path (basePath);
                    file.make_directory ();
                } catch (Error e) {
                    print ("Error: %s\n", e.message);
                }
            }
            // Checks if file exists. Creates one if none
            var file = File.new_for_path (basePath + @"/$(file_name)");
            if (!file.query_exists ()) {
                try {
                    file.create (FileCreateFlags.NONE);
                } catch (Error e) {
                    print ("Error: %s\n", e.message);
                    Process.exit (1);
                }
            }
            return file;
        }

        public static void write_settings (string file_name, Array<string> lines) {
            try {
                var file = check_settings_folder_exists (file_name);
                var fos = file.replace (null,
                                        false,
                                        FileCreateFlags.REPLACE_DESTINATION,
                                        null);
                var dos = new DataOutputStream (fos);
                dos.put_string ("# GENERATED BY SWAYSETTINGS. DON'T MODIFY THIS FILE!\n");
                foreach (string line in lines.data) {
                    dos.put_string (line);
                }
            } catch (Error e) {
                print ("Error: %s\n", e.message);
                Process.exit (1);
            }
        }

        public static bool is_swaync_installed () {
            return GLib.Environment.find_program_in_path ("swaync") != null;
        }

        public static string get_swaync_config_path () {
            string[] paths = {};
            paths += Path.build_path (Path.DIR_SEPARATOR.to_string (),
                                      GLib.Environment.get_user_config_dir (),
                                      "swaync/config.json");
            foreach (var path in GLib.Environment.get_system_config_dirs ()) {
                paths += Path.build_path (Path.DIR_SEPARATOR.to_string (),
                                          path, "swaync/config.json");
            }

            string path = "";
            foreach (string try_path in paths) {
                if (File.new_for_path (try_path).query_exists ()) {
                    path = try_path;
                    break;
                }
            }
            return path;
        }
    }
}
