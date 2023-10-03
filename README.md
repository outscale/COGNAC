# Generator for Outscale API.
[![Project Sandbox](https://docs.outscale.com/fr/userguide/_images/Project-Sandbox-yellow.svg)](https://docs.outscale.com/en/userguide/Open-Source-Projects.html)

## using

configure COGNAC using `./configure`, then use either `cognac_gen.sh SOURCE DEST LANGUAGE` directly, or the Makefile.

*note: the primary use of this repo, is to generate source code, do not use this repo if your goal is to compile [osc-sdk-c](https://github.com/outscale/osc-sdk-c) or oapi-cli, but use they own repo instead, that take care of the code generation for you*

## Dependency

Non exaustive list:
- GNU sed
- bash
- jq
- [json-search](https://github.com/cosmo-ray/json-search)
- make
- pkg-config
- C Compiller

## contribution

Open Pull Requests and Issues are welcome.
