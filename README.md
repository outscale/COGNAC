# Generator for Outscale API.
[![Project Sandbox](https://docs.outscale.com/fr/userguide/_images/Project-Sandbox-yellow.svg)](https://docs.outscale.com/en/userguide/Open-Source-Projects.html)

## Usage

*note: The primary purpose of this repository is to generate source code. If your goal is to compile osc-sdk-c or oapi-cli, please refer to their respective repositories, which handle the code generation process for you.*

### Brief

To configure the COGNAC Makefile, use `./configure.`
You can use `cognac_gen.sh SOURCE DEST LANGUAGE` to generate files from a template.
The Makefile is designed to help you generate all the required files.
If you want to generate everything, simply run `make`.

### Generated Files

COGNAC generates four main files:
- main.c: Source code for the CLI.
- osc_sdk.h: Header file for the C library.
- osc_sdk.c: Source code for the C library.
- $(CLI_NAME)-completion.bash: Autocompletion file for the CLI.

### cognac_gen.sh

cognac_gen.sh is the script responsible for generating all the necessary files. It’s a shell script that calls sub-shell scripts and executes a few C binaries, which are compiled by the Makefile (see bin/).

It takes three arguments: a source file, a destination file, and a language.
The language argument is crucial as certain keywords might be interpreted differently depending on the target language.

The script uses a file called osc-api.json, which represents the OpenAPI specification in JSON format.
For the Outscale API, the YAML source is converted to JSON using `yq`: (https://kislyuk.github.io/yq/ or https://github.com/mikefarah/yq)

When generating API calls, COGNAC by default assumes that the OpenAPI file contains components named CallRequest.
For example, if the API has a call named `CreatePony`, the corresponding component should be located at `#/components/schemas/CreatePonyRequest`.

You can modify the suffix of functions by using `--function-suffix=FUNCTION_SUFFIX` option with `./configure` command.

Or you can generate functions using what is inside `paths`, using `./configure --from-path`

*Note: There are two versions of yq: one written in Python and one in Go. The default version depends on your distribution. On Arch-based distributions, the Python version is typically the default, whereas on Debian-based distributions, the Go version is default. COGNAC supports both, but to use the Go version, you need to pass `--yq-go` to `./configure`.*

### Examples: Generating a CLI for a New API

#### Configure cognac for an Api using elements in schema as entry point for API Calls

Let’s say you have an API that is not the Outscale API, and you want to generate a CLI for it.
You have a URL to a YAML file, such as `https://ponyapi.yolo/`, and the API request components are named `XInput` instead of `XRequest`.

To configure the Makefile to generate the CLI with the name `pony-cli`, and adjust the component naming convention, follow these steps:

Run the following command:
```bash
./configure --cli-name=pony-cli --function-suffix Input --api-script='curl -s https://ponyapi.yolo | yq $(YQ_ARG)" > osc-api.json'
```

`-cli-name=pony-cli` set the generated binary name to `pony-cli`

```bash
--function-suffix Input
```

Search for functions named XInput instead of XRequest.
```bash
--api-script='curl -s https://ponyapi.yolo | yq $(YQ_ARG) > osc-api.json'
```


This script is used to fetch the API file.


Here’s what the script does:

1. Retrieves the API in YAML format using curl -s `https://ponyapi.yolo/.`
2. Converts the YAML to JSON using yq `$(YQ_ARG)`. *Note the usage of `$(YQ_ARG)`, so ./configure can handle go version of yq*


#### Configure cognac for an Api using elements in path as entry point for API Calls

For this example we will use [guru](https://apis.guru/api-doc/)

Run the following commande
```
./configure --sdk-name=guru-sdk --cli-name=guru --from-path --api-script='curl -s https://api.apis.guru/v2/openapi.yaml | yq $(YQ_ARG)" > osc-api.json'
```

`--cli-name=guru` set the generated binary name to `guru`
`--sdk-name=guru-sdk` set the generate sdk name and UserAgent to `guru-sdk`
`--from-path` generate API calls from elements in `paths` instead of `components.schemas`


#### Generte the code

Once this setup is complete, you can now use the Makefile. It's also a good idea to run ./configure --help, as it contains several useful options.
- `--wget-json-search`: Helps with downloading `json-search`, which can be tricky to install, **If unsure, we recommend using this by default**
- `--compile-json-c`: Ensures a recent version of `json-c` is compiled, required for color support. **If unsure, we recommend using this by default**

Now, simply run `make` to generate all necessary files and compile the CLI. This will also create a C SDK, consisting of two files: `osc-sdk.c` and `osc-sdk.h`.

If you want more control over the generation process, you can manually invoke specific Makefile rules:
```bash
make main.c osc_sdk.c osc_sdk.h pony-cli-completion.bash pony-cli
```


## Dependencies

Here’s a non-exhaustive list of required dependencies:
- GNU sed
- bash
- jq
- [json-search](https://github.com/cosmo-ray/json-search)
- make
- pkg-config
- C Compiler

### Optional Dependencies
- libfuse2 (require if building appimage or with `--wget-json-search`)


## Contribution

Open Pull Requests and Issues are welcome.

If you want to add binaries to the bin/ directory, please ensure they are easy to compile.
This means avoiding additional dependencies that are not already required by the CLI.

For more information about cognac code, see [HACKING.md](./HACKING.md)
