# Do You Want To Know More?

*Essential Information for Hacking COGNAC*

## Unix Philosophy and COGNAC Paradigms.

Most people have heard the phrase "Do One Thing and Do It Well" and associate it with the Unix philosophy. It’s said that this is how Unix operates and how it should be.

Personally, I used to wonder how much truth there was to this statement, or whether it was even a good idea. Like many others, I would nod along, pretending to understand it, but I didn’t really get it. Now, though, I feel I have a much better understanding of what it truly means.

ow, you ask? By reading the source code of some Unix-based OSes.
When I read a complete [shell](https://github.com/dspinellis/unix-history-repo/blob/BSD-1-Snapshot-Development/s1/sh.c), the whole source of [ls](https://github.com/dspinellis/unix-history-repo/blob/BSD-1-Snapshot-Development/s6/ls.c), or a fully running [cat](https://github.com/klange/toaruos/blob/master/apps/cat.c), I had a realization: most of these programs are written in far fewer lines of code than I would need just to write half of an object interface in a modern language.

It started to make sense. These programs were built to interact with each other. While we tend to view programs as entire projects nowadays, in Unix, a program was designed to do just one thing—and do it well. Modularity wasn’t a priority. Why create a complex interface when writing an entirely new program could be faster? In Unix, programs like cat, grep, and wc are almost like objects in an object-oriented system, inheriting basic text-handling class.

COGNAC is based on Bash, and it follows a similar philosophy.

It uses a lot of small programs that interact with each other and is supplemented by a few utilities in the bin/ directory that handle text processing tasks.

The Makefile was originally created to "make" files, and COGNAC uses it in that way.

The scripts used by the Makefile handle the actual file creation, while the Makefile itself checks if files need to be rebuilt or not.

## Templating

COGNAC’s templating system is homemade. It reads SRC files and generates DEST files. It uses several keywords, each surrounded by four underscores (e.g., `____api_version____`).
For example, you can check out [lib.h](./lib.h) or [main_tpl.c](./main_tpl.c)

Some rules support multiple languages, like `____func_code____`, which generates function calls. Others, like `____functions_proto____`, currently support only C.
