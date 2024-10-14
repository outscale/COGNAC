# Do You Want To Know More?

*Info that will be useful if you want to Hack COGNAC*

## Unix philosophy, and COGNAC Paradigms.

Most peoples have hear the sentence "Do One Thing and Do It Well", and heard that's how Unix is and how Unix should be.

I personally don't know how much this is true nor a good idea, and like most peoples I use to pretend to understand this, but did not, I don't know if I got it now, but I have a far better understand of what it uses to.

How so ? You didn't ask. By reading source from some Unix OS.
When I read a complete [shell](https://github.com/dspinellis/unix-history-repo/blob/BSD-1-Snapshot-Development/s1/sh.c), the whole source of [ls](https://github.com/dspinellis/unix-history-repo/blob/BSD-1-Snapshot-Development/s6/ls.c), or a fully running [cat](https://github.com/klange/toaruos/blob/master/apps/cat.c), I got hit by the realisation that most of those programmes take less line of code, that I would need to write half of an object interface in any language.

But it kind of made sense, programmes were made to interact together, and where we tend to see a program as a whole project, a program on Unix use to do only one thing, and do it well.
You don't need modularity in your program if writing a whole program anew is faster than creating an interface, and as program are made to interact together, it's not completely wrong to see cat/grep/wc or any Unix program as an object, inheriting some text handling class.

COGNAC is bash, and as sure try to follow this idea.

It use lot of small program interactive together, and is complet by a few utilities in bin/ that do some text handling.

Makefile was create to... make files, and so Makefile is use that way.

Scripts use by the makefile, do the job of creating the file, and the makefile check that they have been created, and that there's no need to rebuild them.

## Templating

the templating system cognac is homemade, it read SRC file and generate DEST file
it uses multiple keyword, each surrounded by 4 underscore (example: `____api_version____`)
as an example, you can look at [lib.h](./lib.h) or [main_tpl.c](./main_tpl.c)

Some rules support multiples languages sure as `____func_code____`, which will generate functions calls,
and some are not. (like `____functions_proto____` which for now support only C)
