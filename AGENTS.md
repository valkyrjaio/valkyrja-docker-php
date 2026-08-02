# AGENTS.md

**valkyrja `valkyrja-docker-php`** — a Docker setup that runs a Valkyrja PHP
project on a local machine. It builds one image with Nginx and PHP-FPM, and it
mounts the project into the container.

This is **not** a framework code repo. It holds a `Dockerfile`, server
configuration, and shell scripts, so only part of the canonical guide applies.

## Read first

**Cross-language canonical** —
<https://github.com/valkyrjaio/architecture/blob/master/AGENTS.md>

It governs the parts that **do** apply here:

- The `[Root] type:` commit and PR-title format.
- The branch → commit → push → open-PR workflow, with confirmation before each
  write action.
- The current-working-branch policy. This repo has no `??.x` branch, so the
  policy falls back to `master`. Branch off `master`, and base each pull request
  on `master`.
- Simplified Technical English in every document.
- Trailing newlines, and American English.
- The copyright header, on every program file. See the [Copyright
  header](#copyright-header) section below.

## What does NOT apply

This repo holds no Valkyrja PHP source, so the PHP Layer-2 guide does not govern
it. Ignore the framework-specific sections of the canonical guide:

- The structure and naming taxonomy — contracts, providers, throwables, and the
  `Abstract\`, `Enum\`, and `Contract\` segments.
- The provider conventions and the binding-key conventions.
- The 100% line-and-branch coverage rule. This repo runs no test suite.
- The PHP CI gate — PHPStan, Psalm, PHPUnit, PHP CS Fixer, PHPArkitect, and
  Rector. This repo runs none of them.

## What this repo holds

- **`Dockerfile`** — the image. It installs Nginx, PHP, and the PHP extensions,
  copies the configuration into place, and installs the `valkyrja` shell alias
  and its bash completion.
- **`docker-compose.yml`** — the service definition and the mounts.
- **`docker/conf/site.conf`** — the Nginx site configuration.
- **`docker/apt/sources.list`** — the package sources.
- **`docker/sync.sh` and `docker/sync-site.sh`** — the file sync inside the
  container.
- **`docker/bash_completion/valkyrja`** — the bash completion for the CLI.
- **The helper scripts in the root** — `build.sh`, `up.sh`, `start.sh`,
  `stop.sh`, `remove.sh`, `logs.sh`, `bash.sh`, and `bash-win.sh`. Each one wraps
  one Docker command. `bash-win.sh` is the Windows form of `bash.sh`.
- **`.github/ci/copyright-header/config`** — the identifier and the exclusion
  list that the shared copyright header check reads.

`bash.sh` and `bash-win.sh` do the same job on two platforms. A change to one
usually needs the same change to the other.

## Warning — a package change breaks the build for every user

The `Dockerfile` pins the base image, the package repository, and each installed
package. A change to any one of them changes the image that every user builds.
Build the image and start the container before you open the pull request. CI
does not build the image.

```bash
./build.sh && ./up.sh
```

State the reason for a package change in the pull request description. Never
write the reason as a comment in the `Dockerfile` — the canonical guide forbids
a comment that states a current condition, because a later edit strands it.

## Copyright header

Every program file in this repo carries the copyright header. The package
identifier is `Valkyrja Docker`. `COPYRIGHT_HEADER.md` in the `.github` repo
holds the identifier for every repo, and it is the source of truth for the
header text.

A program file writes the header as a line comment, because this repo holds no
PHP. The header follows the shebang when the file has one:

```bash
#!/bin/bash
#
# This file is part of the Valkyrja Docker package.
#
# Copyright (c) 2016-present Melech Mizrachi
#
# Released under the MIT License. See LICENSE.md for details.
#
```

A file that holds no program code carries no header. A document, a workflow, and
a configuration file are such files. `docker-compose.yml`,
`docker/conf/site.conf`, and `docker/apt/sources.list` carry none.

The shared `_copyright-header-check.yml` workflow in the `.github` repo enforces
the rule, and `ci.yml` calls it. The organization keeps one check for every repo,
so a correction reaches every repo at once. This repo supplies only its own
settings, in `.github/ci/copyright-header/config`. That file sets `IDENTIFIER`,
and it sets the `EXCLUDED` list. The shared script sources the file as shell, so
the file is a program file and it carries the header itself.

The check reads every tracked file, and it requires the header in each file that
`EXCLUDED` does not match. Warning: a new file fails the check until a person
acts. Add the header to the file, or add the file to `EXCLUDED` when the file
holds no program code.

Warning: the check reads `git ls-files`, so it does not see an untracked file. A
new file that you have not staged passes in silence. Stage the file, then run the
check before you open the pull request:

```bash
REF="$(grep -o '_copyright-header-check.yml@[0-9a-f]*' .github/workflows/ci.yml | cut -d '@' -f 2)"
curl -fsSL "https://raw.githubusercontent.com/valkyrjaio/.github/$REF/.github/ci/scripts/copyright-header-check.sh" | bash
```

The first command reads the commit that `ci.yml` pins, so the script you run
locally is the script that CI runs.

## CI

The gate here checks files, not code. `ci.yml` runs the trailing newline check
and the copyright header check. `pr.yml` runs the commit message check. There is
no Markdown check in this repo.

## Roots

Most relevant here: `[Dockerfile]`, `[Compose]`, `[Nginx]`, `[PHP]`,
`[Workflow]`, `[GitHub]`, and `[Git]`.

**`[Docker]` is not a root in this repo.** A root is never the repo's own
identity, and this repo _is_ the Docker setup, so the name says nothing here.
Name the file or the service instead. `[Docker]` stays correct in another repo,
where a Docker file genuinely stands out.
