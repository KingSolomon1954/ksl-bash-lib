<!---
Comments here if needed.
-->

<h1 align="center">KSL Bash Library</h1>

<p align="center">
<a href="https://www.freeiconspng.com/img/2450" title="Image from freeiconspng.com"><img src="https://www.freeiconspng.com/uploads/blue-fire-17.png" width="40" alt="Blue Fire" /></a>
</p>

<p align="center">
A collection of useful Bash functions that simplify writing scripts.
</p>

---

[![Build](https://img.shields.io/github/actions/workflow/status/kingsolomon1954/ksl-bash-lib/build.yml)](https://github.com/kingsolomon1954/ksl-bash-lib/actions/workflows/build.yml)
[![Version](https://img.shields.io/github/v/release/kingsolomon1954/ksl-bash-lib)](https://github.com/kingsolomon1954/ksl-bash-lib/releases)

## Features

- **libArrays** - simplify handling of indexed and associative arrays
- **libColor** - consistent use of color
- **libEnv** - useful functions to manipulate PATH-like environment variables
- **libError** - functions that support error passing
- **libFiles** - useful functions to manipulate directory and file names
- **libStdOut** - functions for consistent printing to stdout and stderr
- **libStrings** - useful functions to manipulate strings
- no calls to external utilities (such as sed or tr)

See the library documentation here:  [Github Pages](https://kingsolomon1954.github.io/ksl-bash-lib)

## Prerequisites

- no additional dependencies
- all functions use only shell intrinsics, except for
  libColors::ksl::isColorCapable() which calls `tput`, and
  libError::ksl::epSet() which calls `date`.
- tested against bash 5.2
  
## Usage

Setup environment variable `KSL_BASH_LIB` to where you installed KSL
Bash library.

Then, in scripts that you write:

```bash
#!/usr/bin/env bash
# Bring in desired parts of KSL Bash library
source "${KSL_BASH_LIB}"/libColors.bash
source "${KSL_BASH_LIB}"/libStdOut.bash
```

- all KSL Bash library functions use `ksl::` as a prefix, e.g.,
  `ksl::isInteger`

- library documentation is available here on 
  [Github Pages](https://kingsolomon1954.github.io/ksl-bash-lib)
  as well as included with the installed package in
  `$KSL_BASH_LIB/docs/site/index.html`.

## Installation

KSL Bash library is installed by one of the following methods.
Then set KSL_BASH_LIB to where you placed it.

### Via GitHub Release 

1. Grab the latest release from here:

https://github.com/KingSolomon1954/ksl-bash-lib/releases

Download the ksl-bash-lib-x.y.z.tgz file.

2. Untar it to a location of your choosing.

``` bash
cd $HOME/bin
tar -xzf ~/downloads/ksl-bash-lib-x.y.z.tgz
```

3. Setup environment variable to point to it.

``` bash
export KSL_BASH_LIB=$HOME/bin/ksl-bash-lib-x.y.z
```

4. Examine docs

``` bash
firefox $HOME/bin/ksl-bash-lib-x.y.z/docs/index.html
```

### Via git clone

1. Clone the repo

``` bash
git clone https://github.com/KingSolomon1954/ksl-bash-lib.git $HOME/dev/ksl-bash-lib
```

2. Setup environment variable to point to it.

``` bash
export KSL_BASH_LIB=$HOME/dev/ksl-bash-lib/lib
```

3. Examine docs

``` bash
firefox $HOME/dev/ksl-bash-lib/docs/site/index.html
```

## Developing the KSL Bash Library

This section till the end of the file are relevant only to
developing the KSL Bash library.

### Prerequisites for Development

- GNU Makefile
- Podman or Docker
- Typical Linux command line utilities

### Containerized Tools

- Uses containers for build tools where it makes sense
  - for doc generation
  - for static analysis via shellcheck
- Supports Docker or Podman, prefers Podman over Docker if found
- Containers mount local host workspace, no copying into container

### Folder Layout

**Top Level View**

    ├── lib
    ├── test
    ├── docs
    ├── tools
    ├── etc
    ├── Makefile
    ├── version
    └── Readme.md

**Two Level View**

    ├── Makefile
    ├── Readme.md
    ├── version
    ├── lib
    │  └── ...
    ├── test
    │  ├── ...
    │  └── unit-test.mak
    ├── docs
    │  ├── src
    │  ├── site
    │  └── docs.mak
    ├── tools
    │  ├── bash-unit
    │  ├── shdoc
    │  └── submakes
    └── etc
       ├── examples
       ├── License
       └── todo.txt

Generally conforms to
[PitchFork](https://github.com/vector-of-bool/pitchfork) project layout.

## Example Usages

``` bash
make help
KSL Bash Library
-------------- Targets --------------

all                   - Build the repo
docs                  - Builds all the docs
docs-clean            - Deletes generated docs
docs-publish          - Update ./docs/site with ./_build/docs/site and checkin to Git
docs-shdoc            - Generates only bash API docs
docs-sphinx           - Generates only Sphinx docs
<filepath>.sta        - Runs Bash static analysis on given file
help                  - Displays help information and targets
static-analysis-clean - Deletes Bash static analysis artifacts
static-analysis       - Runs Bash static analysis against repo
unit-test             - runs unit tests
unit-tests            - runs unit tests
```

### Run Unit Tests

``` bash
make
# or
make unit-test

```

### Unit Testing

- Unit tests are kept separate from source code
- Uses [bash_unit](https://github.com/pgrange/bash_unit)
- bash_unit is installed within this repo

### Build and Examine the Documentation

``` bash
make docs
firefox _build/site/index.html
```

### Versioning

- Single version file in project root
- All built artifacts obtain version information from this one file
- Auto-documentation and containers use this version file
- Semantic versioning

``` bash
cat version
1.0.0
```

### Static Code Analysis

Static code analysis can be performed against all source code in the
library at once or against a single file. Underlying tool is a
containerized [shellcheck](https://github.com/koalaman/shellcheck).

The following makefile targets are available:

    static-analysis       - Runs Bash static analysis against library
    static-analysis-clean - Deletes Bash static analysis artifacts
    <filepath>.sta        - Runs Bash static analysis on given file

Find results in `_build/static-analysis/results.txt`.

``` bash
make static-analysis
less _build/static-analysis/results.txt
#
# Or for a single file
#
make lib/libStrings.sta

```

### GitHub Workflows

Four workflows manage this repo.

1. build.yml - builds on any push
2. release.yml - manually triggered when a release is desired
3. shared-build.yml - performs both build and release activities
4. deploy-gh-pages.yml - updates GitHub pages after a release

### Documentation Generation

- Uses [Sphinx](https://www.sphinx-doc.org/) with
  [read-the-docs](https://sphinx-rtd-theme.readthedocs.io/en/stable/index.html)
  theme
- [shdoc](https://github.com/reconquest/shdoc/) generates library API from source code
- [pandoc](https://pandoc.org/) for intermediate document conversions


#### Building the Docs

From top level folder, invoke:

```bash
make docs
firefox _build/site/index.html
```

#### Pubishing the Docs

When satisfied with the generated site docs, from top level folder,
invoke the following to publish the site.

```bash
make docs-publish
```

The generated static website sitting in `_build/site`, is copied over to
the `docs/site` folder and then checked into Git (not pushed yet). Later
when the branch is merged to main, a GitHub action kicks in and
publishes `docs/site` folder to the actual GitHub Pages website. The
`docs/site` folder is hard coded into the `deploy-gh-pages.yml` GitHub
action.

The makefile `docs-publish` rule looks something like this:

``` bash
> make -n docs-publish
git rm -r --ignore-unmatch ./docs/site/*
mkdir -p ./docs/site
cp -r ./_build/site/* ./docs/site/
touch ./docs/site/.nojekyll
git add -A ./docs/site
git commit -m "Publish docs"

```
