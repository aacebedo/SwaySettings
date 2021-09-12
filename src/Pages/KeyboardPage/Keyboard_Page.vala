using Gee;

namespace SwaySettings {
    public class Keyboard_Page : Input_Page {

        public Keyboard_Page (string label, Hdy.Deck deck, IPC ipc) {
            base (label, deck, ipc);
        }

        public override SwaySettings.Input_Types input_type {
            get {
                return Input_Types.keyboard;
            }
        }

        public override ArrayList<Input_Page_Section> get_top_sections () {
            return new ArrayList<Input_Page_Section>.wrap ({
                new Input_Page_Section (get_keyboard_language (), "Keyboard Layout"),
            });
        }
    }
}