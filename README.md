# Generator for Outscale API.
[![Project Sandbox](https://docs.outscale.com/fr/userguide/_images/Project-Sandbox-yellow.svg)](https://docs.outscale.com/en/userguide/Open-Source-Projects.html)

## Usage

*note: The main purpose of this repository is to generate source code. If your goal is to compile osc-sdk-c or oapi-cli, please use their respective repositories, which handle the code generation process for you.*

### Brief

configure COGNAC Makefile using `./configure`
you can use `cognac_gen.sh SOURCE DEST LANGUAGE` to generate a file from a template
the Makefile is here to help you generate all the files.
if you want to generate everything, just call `make`

### Generated Files

COGNAC generate 4 files:
- main.c: source of the cli
- osc_sdk.h: header of C library
- osc_sdk.c: code of C library
- $(CLI_NAME)-completion.bash: autocompletion file

### cognac_gen.sh

cognac_gen.sh is the script that generate evrything, it's a shellscript, that call sub-shellscript,
and a few C binaries that are compiled by the Makefile. (see bin/)

It take 3 arguments, a source file, a destination file, and a language.
The language is here because some keyword can be interpreted diferently depending of the wanted language.

it use a file call osc-api.json which is the openapi represent as json.
For Outscale api, we take the yaml source, and convert them to json using yq.

When generated API Call, COGNAC assume that the openapi file have some componant named CallRequest,
So if the api have a call named `CreatePony`, it should have a `#/components/schemas/CreatePonyRequest`.

*Note: 2 versions of yq exist, one in python and one in go, default yq depend of the distribution. On Arch base the python is the default one, on debian-base it's the go, cognac handle both, but in order to use the go version you need to pass `--yq-go` to `./configure`*

### Example with a new api.

let's say you have an api, that is not outscale api, and want to generate a cli, from it.
you have only an url with a yaml file. let's say `https://ponyapi.yolo`
The API Request componant are not call "XRequest" but "XInput".

the irst step is to configure the Makefile to handle the cli name `pony-cli`, and tell Makefile how to get the api, and change the `Input` to `request`.

to do so, you first call `./configure --cli-name=pony-cli --api-script='curl -s https://ponyapi.yolo | yq $(YQ_ARG) | sed "s/Input/Request/" > osc-api.json'`

`-cli-name=pony-cli` set the generated binary name to `pony-cli`

`--api-script='curl -s https://ponyapi.yolo | yq $(YQ_ARG) | sed "s/Input/Request/" > osc-api.json'`
is the script that will be use to get the api-file.
it first get the api in yaml using `curl -s https://ponyapi.yolo`
convert it to json using `| yq $(YQ_ARG)`, Note the usage of `$(YQ_ARG)`, so the configure can handle go version of yq.
Then rename all componant named `XInput` into `XRequest`.

doing so you can now use the Makefile, but you should also check `./configure --help` which contain some useful options.
`--wget-json-search` and `--compile-json-c` are 2 useful otpions as json-search is not easy to install, and a recent version of `json-c` is require if you want to support color.

Now you can simple call `make` which will generate everyfile, and compile the cli for you.
It will also create a C sdk, which will be made of 2 files: `osc-sdk.c` and `osc-sdk.h`.

If you want more controll on the generation, you can call make rules yourself, so `make main.c osc_sdk.c osc_sdk.h pony-cli-completion.bash pony-cli`


## Dependency

Non exaustive list:
- GNU sed
- bash
- jq
- [json-search](https://github.com/cosmo-ray/json-search)
- make
- pkg-config
- C Compiller


## Contribution

Open Pull Requests and Issues are welcome.

If you want to add binary in bin/ please try to make it easy to compile.
That mean don't add dependancies that are not alerady require by a cli.

## Do You Want To Know More?

*Info that will be useful if you want to Hack COGNAC*

### Unix philosophy, and COGNAC Paradigms.

Most peoples have hear the sentence "Do One Thing and Do It Well", and hear that's how Unix is and how Unix should be.

I personally don't know how much this true nor a good idea, and like most peoples I use to pretend to understand this, but did not, I don't know if I got it now, but I have a far better understand of what it use to.

How so ? you didn't ask. By reading source from some unix OS.
And when I read a complet [shell](https://github.com/dspinellis/unix-history-repo/blob/BSD-1-Snapshot-Development/s1/sh.c), the whole source of [ls](https://github.com/dspinellis/unix-history-repo/blob/BSD-1-Snapshot-Development/s6/ls.c), or a fully running [cat](https://github.com/klange/toaruos/blob/master/apps/cat.c), I got hit by the reallisation that most of thoses programes take less line of code, that I would need to write half of an interface in any OOP.

But it kind of made sense, program was made to interact together, and where we tend to see a program as a whole project, a program on unix use to do only one thing, and do it well.
You don't need modularity if writing a whole program annew is faster than creating an interface, and as program are made to interact together, it's not completelly wrong to see cat/grep/wc or any unix program as an object, inheriting some text handling class.

COGNAC is bash, and as sure try to follow this idea.

It use lot of small program interactive together, and is complet by a few utilities in bin/ that do some text handling.

Makefile was create to... make files, and so Makefile is use that way.

Scripts use by the makefile, do the job of creating the file, and the makefile check that they have been create, and that there's no need to rebuild them.

### Templating

the templating system cognac is homemade, it read SRC file and generate DEST file
it use multiple keywork, each sourouding by 4 underscore (example: `____api_version____`)
as an example you can look at [lib.h](./lib.h) or [main_tpl.c](./main_tpl.c)

Some rules support multiples languages sure as `____func_code____`, which will generate functions calls,
and some are not. (like `____functions_proto____` which for now support only C)
