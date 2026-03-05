/* Oracle - Numerology Divination Engine
   Copyright 2026 Larry Bruce Daniel Atlanta, Georgia

   A GNOME application that enciphers text using the Daniel cipher,
   reduces it to its numerological root, and reveals its meaning.
*/

namespace Oracle {

    // Daniel cipher: character-to-number mapping
    // This is a derivation of the CipherX by Joel Love.
    int encipher_char(unichar c) {
        switch (c.toupper()) {
            case 'A': return 8;
            case 'B': return 16;
            case 'C': return 15;
            case 'D': return 6;
            case 'E': return 22;
            case 'F': return 2;
            case 'G': return 12;
            case 'H': return 14;
            case 'I': return 27;
            case 'J': return 21;
            case 'K': return 1;
            case 'L': return 18;
            case 'M': return 5;
            case 'N': return 25;
            case 'O': return 15;
            case 'P': return 31;
            case 'Q': return 13;
            case 'R': return 4;
            case 'S': return 23;
            case 'T': return 10;
            case 'U': return 28;
            case 'V': return 11;
            case 'W': return 2;
            case 'X': return 24;
            case 'Y': return 7;
            case 'Z': return 29;
            default:  return 0;
        }
    }

    int encipher(string text) {
        int sum = 0;
        unichar c;
        int i = 0;
        while (text.get_next_char(ref i, out c)) {
            sum += encipher_char(c);
        }
        return sum;
    }

    // Numerological reduction to single digit 1-9
    int reduce(int n) {
        int val = n.abs() % 9;
        return (val == 0) ? 9 : val;
    }

    // Root meanings
    string root_meaning(int root) {
        switch (root) {
            case 1: return "The Initiator\nIndependence, creation, new beginnings.\nThe primal force from which all emerges.";
            case 2: return "The Diplomat\nBalance, partnership, duality.\nThe bridge between opposing forces.";
            case 3: return "The Creator\nExpression, joy, synthesis.\nWhere two become something greater.";
            case 4: return "The Builder\nStructure, discipline, foundation.\nThe four walls that shelter truth.";
            case 5: return "The Seeker\nFreedom, change, adventure.\nThe restless spirit that refuses stagnation.";
            case 6: return "The Guardian\nHarmony, responsibility, love.\nThe force that binds community.";
            case 7: return "The Mystic\nWisdom, introspection, analysis.\nThe inner eye that sees what others cannot.";
            case 8: return "The Sovereign\nPower, abundance, karma.\nWhat is given returns eightfold.";
            case 9: return "The Sage\nCompletion, universal truth, transcendence.\nAll numbers resolve here. The end is the beginning.";
            default: return "";
        }
    }

    // Root symbols (Unicode geometric shapes)
    string root_symbol(int root) {
        switch (root) {
            case 1: return "\xe2\x97\x89";  // ◉
            case 2: return "\xe2\x98\xaf";  // ☯
            case 3: return "\xe2\x96\xb3";  // △
            case 4: return "\xe2\x97\x87";  // ◇
            case 5: return "\xe2\x98\x86";  // ☆
            case 6: return "\xe2\xac\xa1";  // ⬡
            case 7: return "\xe2\x9c\xa7";  // ✧
            case 8: return "\xe2\x88\x9e";  // ∞
            case 9: return "\xe2\x97\x8e";  // ◎
            default: return "";
        }
    }

    // Per-letter breakdown as markup string
    string letter_breakdown(string text) {
        var sb = new StringBuilder();
        unichar c;
        int i = 0;
        bool first = true;
        while (text.get_next_char(ref i, out c)) {
            int val = encipher_char(c);
            if (val == 0) continue;
            if (!first) sb.append("  +  ");
            first = false;
            sb.append("<b>%s</b>=%d".printf(c.toupper().to_string(), val));
        }
        return sb.str;
    }

    class Window : Gtk.Window {
        private Gtk.Entry entry;
        private Gtk.Label result_label;
        private Gtk.Label meaning_label;
        private Gtk.Label breakdown_label;
        private Gtk.Label symbol_label;
        private Gtk.Label sum_label;

        public Window() {
            this.title = "Oracle — Numerology Engine";
            this.set_default_size(520, 440);
            this.border_width = 24;
            this.destroy.connect(Gtk.main_quit);

            var vbox = new Gtk.Box(Gtk.Orientation.VERTICAL, 16);

            // Title
            var title = new Gtk.Label(null);
            title.set_markup("<span size='xx-large' weight='bold'>The Oracle</span>");
            vbox.pack_start(title, false, false, 0);

            var subtitle = new Gtk.Label(null);
            subtitle.set_markup("<span size='small' color='#888888'>Numerological Divination via the Daniel Cipher</span>");
            vbox.pack_start(subtitle, false, false, 0);

            // Separator
            vbox.pack_start(new Gtk.Separator(Gtk.Orientation.HORIZONTAL), false, false, 4);

            // Input area
            var input_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 8);
            entry = new Gtk.Entry();
            entry.placeholder_text = "Enter a word, name, or phrase...";
            entry.hexpand = true;
            entry.activate.connect(on_divine);
            input_box.pack_start(entry, true, true, 0);

            var button = new Gtk.Button.with_label("Divine");
            button.get_style_context().add_class("suggested-action");
            button.clicked.connect(on_divine);
            input_box.pack_start(button, false, false, 0);

            vbox.pack_start(input_box, false, false, 0);

            // Letter breakdown
            breakdown_label = new Gtk.Label("");
            breakdown_label.use_markup = true;
            breakdown_label.wrap = true;
            breakdown_label.max_width_chars = 60;
            vbox.pack_start(breakdown_label, false, false, 0);

            // Sum display
            sum_label = new Gtk.Label("");
            sum_label.use_markup = true;
            vbox.pack_start(sum_label, false, false, 0);

            // Symbol
            symbol_label = new Gtk.Label("");
            symbol_label.use_markup = true;
            vbox.pack_start(symbol_label, false, false, 8);

            // Root number
            result_label = new Gtk.Label("");
            result_label.use_markup = true;
            vbox.pack_start(result_label, false, false, 0);

            // Meaning
            meaning_label = new Gtk.Label("");
            meaning_label.use_markup = true;
            meaning_label.wrap = true;
            meaning_label.justify = Gtk.Justification.CENTER;
            meaning_label.max_width_chars = 50;
            vbox.pack_start(meaning_label, true, false, 0);

            this.add(vbox);

            // CSS styling
            var css = new Gtk.CssProvider();
            try {
                css.load_from_data("""
                    window {
                        background-color: #1a1a2e;
                    }
                    label {
                        color: #e0e0e0;
                    }
                    entry {
                        background-color: #16213e;
                        color: #e0e0e0;
                        border-color: #0f3460;
                        border-radius: 6px;
                        padding: 8px;
                        font-size: 14px;
                    }
                    button {
                        border-radius: 6px;
                        padding: 8px 16px;
                        font-weight: bold;
                    }
                    separator {
                        background-color: #0f3460;
                    }
                """);
                Gtk.StyleContext.add_provider_for_screen(
                    Gdk.Screen.get_default(),
                    css,
                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
                );
            } catch (Error e) {
                stderr.printf("CSS error: %s\n", e.message);
            }
        }

        private void on_divine() {
            string text = entry.text.strip();
            if (text.length == 0) {
                result_label.set_markup("");
                meaning_label.set_markup("");
                breakdown_label.set_markup("");
                symbol_label.set_markup("");
                sum_label.set_markup("");
                return;
            }

            int sum = encipher(text);
            int root = reduce(sum);
            string meaning = root_meaning(root);
            string symbol = root_symbol(root);
            string breakdown = letter_breakdown(text);

            breakdown_label.set_markup("<span size='small' color='#7b8794'>%s</span>".printf(breakdown));
            sum_label.set_markup("<span size='large' color='#a8b2d1'>Cipher Sum: <b>%d</b>    →    Root: <b>%d</b></span>".printf(sum, root));
            symbol_label.set_markup("<span size='48000' color='#e94560'>%s</span>".printf(symbol));
            result_label.set_markup("<span size='x-large' weight='bold' color='#e94560'>— %d —</span>".printf(root));
            meaning_label.set_markup("<span size='large' color='#c8d6e5'>%s</span>".printf(meaning.replace("\n", "\n")));
        }
    }
}

int main(string[] args) {
    Gtk.init(ref args);
    var window = new Oracle.Window();
    window.show_all();
    Gtk.main();
    return 0;
}
