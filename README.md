drlutil.d - D port of rlutil.h
=============================

Details
-------

It is the D port of [rlutil.h](https://github.com/tapio/rlutil) for changing the console text color, getting keyboard input, etc. It is designed to aid the creation of cross-platform console-mode roguelike games with D programming language.

Installation
------------

Clone the repository:

```
$ git clone git://github.com/danyalzia/Drlutil
```

Once cloned, while in the `Drlutil` directory:

```
$ dub build
```

Usage
-----

--------------------------------------------
```D
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
```

License
-------

It is released under [Boost license](www.boost.org/LICENSE_1_0.txt).
