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

cognac_gen.sh is the script that generate everything, it's a shell script, that call sub-shell script,
and a few C binaries that are compiled by the Makefile. (see bin/)

It takes 3 arguments, a source file, a destination file, and a language.
The language is here because some keyword can be interpreted differently depending on the wanted language.

It uses a file call osc-api.json which is the OpenAPI represent as json.
For Outscale API, we take the yaml source, and convert it to json using yq.

When generated API Call, COGNAC assume that the OpenAPI file have some components named CallRequest,
So if the API have a call named `CreatePony`, it should have a `#/components/schemas/CreatePonyRequest`.

*Note: 2 versions of yq exist, one in python and one in go, default yq depend on the distribution. On Arch base the python is the default one, on Debian-base it's the go, cognac handle both, but in order to use the go version you need to pass `--yq-go` to `./configure`*

### Example with a new api.

You have an API, that is not outscale api, and want to generate a CLI, from it.
You have only an UNL with a yaml file, let's say `https://ponyapi.yolo`
The API Request componant are not call "XRequest" but "XInput".

The first step is to configure the Makefile to handle the CLI name `pony-cli`, and tell Makefile how to get the API, and change the `Input` to `request`.

To do so, you first call 
```bash
./configure --cli-name=pony-cli --api-script='curl -s https://ponyapi.yolo | yq $(YQ_ARG) | sed "s/Input/Request/" > osc-api.json'
```

`-cli-name=pony-cli` set the generated binary name to `pony-cli`

```bash
--api-script='curl -s https://ponyapi.yolo | yq $(YQ_ARG) | sed "s/Input/Request/" > osc-api.json'
```
Is the script that will be used to get the api-file.


First, it retrieves the API in yaml using `curl -s https://ponyapi.yolo`
Then convert it to json using `| yq $(YQ_ARG)`, *Note the usage of `$(YQ_ARG)`, so ./configure can handle go version of yq*
Finally, rename all component named `XInput` into `XRequest`.

Doing so you can now use the Makefile, but you should also check `./configure --help` which contain some useful options.
`--wget-json-search` and `--compile-json-c` are 2 useful options as json-search is not easy to install, and a recent version of `json-c` is required if you want to support colour.

Now you can simply call `make` which will generate every file, and compile the CLI for you.
It will also create a C SDK, which will be made of 2 files: `osc-sdk.c` and `osc-sdk.h`.

If you want more control on the generation, you can call make rules yourself, so `make main.c osc_sdk.c osc_sdk.h pony-cli-completion.bash pony-cli`


## Dependency

Non-exhaustive list:
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
That mean, don't add dependencies that are not already require by a CLI.

For more information about cognac code, see [HACKING.md](./HACKING.md)
