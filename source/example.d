import std.stdio;
import rlutil.d;

void main() {
    setColor(YELLOW);
    writeln("This is Yellow Text");
 
    setColor(RED);
    writeln("This is Red Text");
 
    setColor(BLUE);
    writeln("This is Blue Text");
 
    setColor(GREEN);
    writeln("This is Green Text");
 
    setColor(WHITE);
    writeln("This is White Text");
 
    setColor(GREEN);
    write("Green, ");
    setColor(RED);
    write("Red, ");
    setColor(BLUE);
    writeln("Blue");
 
    // Change the color back to default grey
    setColor(GREY);
}
