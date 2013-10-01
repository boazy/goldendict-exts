import std.conv;
import std.regex;
import std.stdio;
import std.string;
import curl = std.net.curl;

int main(string args[]) {

    // Parse arguments
    //if (args.length < 2) {
    //  writeln("Not enough arguments!");
    //  return 1;
    //}
    //string word = args[1];
    string word = "%u0627%u0644";

    // Return a string containing the response specified by an URL
    char[] response = curl.get("http://arabdictionary.huji.ac.il/Matrix.Arabdictionary/Search.aspx?RadioArabic=true&RadioRoot=false&WordString=" ~ word);
    char[][] parts = response.split("^");

    if (parts.length < 3) {
      writeln("!!! ERROR: Unexpected response, should be ID#^radio_buttons^explanations format !!!");
      writeln();
      writeln(response);
      return 1;
    }

    // auto id = parts[0];
    auto fullDef = to!string(parts[2]);
    if (!fullDef.length) {
      writeln("אין תוצאות");
      return 0;
    }

    // Fix divs with id numbers: remove explicit CSS styles and add a generic class (without the id number)
    //auto fixed = replace(fullDef, regex(`<div\s+id="([A-Za-z]+)(\d+)"(\s+style=".*?")?\s*>`, "g"), `<div id="$1$2" class="$1">`);

    auto reDivs = regex(`<div\s+id="([A-Za-z]+)(\d+)"(\s+style=".*?")?\s*>|</div>`, "g");
    writeln(reDivs.)
    return 0;
    
    writeln(q"EOS
    <style type="text/css">
    div#result {
      direction: rtl;
    }

    </style>
    <div id="result">
EOS"
    );

    writeln(fixed);
    writeln("</div>");

    return 0;
}
