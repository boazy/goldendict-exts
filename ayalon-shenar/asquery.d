import html = dhtmlparser;
import std.algorithm;
import std.conv;
import std.range;
import std.regex;
import std.stdio;
import std.string;
import std.traits;
import curl = std.net.curl;

class Div {
    this(string c1, int c2, int start) {
        idType = c1;
        idNum = c2;
        start = start;
    }

    string idType;
    int idNum;
    int start;
}

Div make_div(Match)(Match m) {
    return new Match();
}

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

    // auto firstId = parts[0];
    auto mainText = to!string(parts[1]);
    auto mainDom = html.parseString(mainText);
    writeln(mainDom.find("li")[0]);
    return 0;

    auto exText = to!string(parts[2]);
    if (!exText.length) {
      writeln("אין תוצאות");
      return 0;
    }    

    // Fix divs with id numbers: remove explicit CSS styles and add a generic class (without the id number)
    //auto fixed = replace(exText, regex(`<div\s+id="([A-Za-z]+)(\d+)"(\s+style=".*?")?\s*>`, "g"), `<div id="$1$2" class="$1">`);

    auto reDivs = regex(`<div\s+id="([A-Za-z]+)(\d+)"(\s+style=".*?")?\s*>|</div>`, "g");
    immutable char* startPtr = exText.ptr;
    int textIndex = 0;
    Div[] divStack;
    foreach (divDef; match(exText, reDivs)) {
        int postStart = divDef.post.ptr - startPtr;
        if (divDef.hit == "</div>") {
            Div lastDiv = divStack.back;
            string lastStr = divDef.pre[textIndex..$];
            if (lastDiv.idType == "ex" && !find(lastStr, "אין דוגמאות והערות").empty) {
                writeln("Basa");
            }
            else {
                write(lastStr);
            }
            write("</div>");
            divStack.popBack;
        } else {
            Div div = new Div(divDef.captures[1], to!int(divDef.captures[2]), postStart);
            divStack ~= div;
            write(divDef.pre[textIndex..$]);
            write(format(`<div id="%s%s" class="%s">`, div.idType, div.idNum, div.idType));
        }
        textIndex = postStart;
    }
    write(exText[textIndex..$]);
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

    //writeln(fixed);
    writeln("</div>");

    return 0;
}
