*This project has been created as part of the 42 curriculum by rperez-t.*

# scop_resources

## Description

The resources of the scop project, as provided by the intranet (`resources.tgz`): the
`.obj` models the subject asks to show, the 42 logo first. They are kept here so that
they can be used as a git submodule (`resources/` of
[scop](https://github.com/Rodolfo9898/scop)). Nothing in them was modified: the files
are byte for byte those of the archive.

Git keeps the archive and the script that extracts it (`run.sh` and its modules), and
none of the files in it. `run.sh` extracts the archive at the root of the repository
the first time it runs, and again whenever one of its files is missing; `run.sh
--destroy` removes them, so the folder is back to what git keeps. A fresh clone is one
`./run.sh` away from the models.

What `run.sh` extracts at the root (and git ignores):

| File | What it is |
|---|---|
| `42.obj`, `42.mtl` | The 42 logo the subject asks to show spinning, and its material |
| `teapot.obj` | The original teapot, with its unusual edges (the bonus asks to draw it right) |
| `teapot2.obj`, `teapot2.mtl` | The same teapot, re-exported from Blender and normalized |
| `._teapot.obj` | Finder metadata macOS left in the archive (not a model) |

What git keeps:

| File | What it is |
|---|---|
| `src/resources.tgz` | The archive from the intranet, untouched: the only copy of the resources in git |
| `run.sh` | The main: loads the modules, makes sure the files are all at the root (extracting what is missing), or removes them |
| `src/sh/log.sh` | The messages, and the errors that stop everything |
| `src/sh/archive.sh` | Finds the archive in `src/`, reads and checks its list of files, says where each one goes, and unpacks it to read from |
| `src/sh/files.sh` | Checks that the files are all at the root, and extracts from the archive what is missing |
| `src/sh/destroy.sh` | The opposite: removes the files from the root, so that only what git keeps is left |
| `.gitignore` | Ignores everything at the root but `run.sh`, `src/` and the README, so the extracted files are never committed |
| `README.md` | This file |

## Instructions

### Requirements

- `bash` and `tar`. Nothing to build or install. GNU tar warns about the extended
  attributes macOS wrote in the archive; `run.sh` hides that warning only.

### Running

```sh
./run.sh
```

It works in the folder it is in, so it can be started from anywhere. In order:

1. It reads the archive, `src/*.tgz` (exactly one), and looks for each of its files at
   the root, without the archive's top folder: `resources/42.obj` is `42.obj`.
2. If they are all there, it says so and extracts nothing. If not, it says so, unpacks
   the archive in a temporary folder (removed afterwards) and copies from it the files
   that are missing: `scop_resources: extracting the resources from
   src/resources.tgz (6 files).` for a fresh clone, `scop_resources: 1 of the 6 files
   of src/resources.tgz are missing, restoring them.` for a folder that lost one. A
   file that is already there is never overwritten.

`./run.sh --extract` does the same, silently when nothing is missing: it is what the
Makefile of scop runs at every `make`.

`./run.sh --destroy` removes every file of the archive that is still the archive's own
(compared byte for byte), then the folders that leaves empty. Nothing that somebody
wrote is ever removed: a file that was changed is kept and named
(`scop_resources: kept 1 file(s) that differ from the archive ...`), and so is
everything the archive does not have. It is what `make fclean` of scop runs.

It stops with a message, and nothing done, when there is no archive, when `src/` holds
two, when the archive cannot be read, or when a file in it would leave the folder or go
into `src/` or `.git` (so an archive can never replace the modules).

### How `run.sh` is organized

`run.sh` is only the main. It moves to its own folder, loads the modules of `src/sh/`
in this order (`log`, `archive`, `files`, `destroy`), and its `main` function does the
work: `files_ensure` (steps 1 and 2), or `destroy_files`. It always removes the
temporary folder when it ends, by an `EXIT` trap.

The modules only define functions, so nothing happens when one is loaded. The
functions start with the name of their module: `log_say`, `log_warn`, `log_fail`,
`archive_find`, `archive_list`, `archive_path`, `archive_dir`, `archive_unpack`,
`archive_forget`, `files_look`, `files_extract`, `files_ensure`, `destroy_files`. The
few variables they share are in capitals (`ARCHIVE`, `LISTING`, `REL`, `WORK`,
`MISSING`, `TOTAL`, `REMOVED`, `KEPT`) and are listed at the top of the module that
sets them.

### Starting over

To get a file back as the archive has it, delete it and run `./run.sh` again. To use
another version of the archive, run `./run.sh --destroy`, put the new one in `src/` in
place of the old one, and run `./run.sh`.

Without `run.sh`:

```sh
tar -xzf src/resources.tgz --strip-components=1
```

## Resources

- The scop subject, version 5.0.
- The archive is provided by 42 for the curriculum; the 42 logo is copyrighted and can
  be used for pedagogical purposes only.
- `man tar`, `man cmp`, `man bash`
- Wavefront `.obj` format - https://paulbourke.net/dataformats/obj/

**Use of AI.** This repository follows the layout of the author's Netpractice_live; an
AI assistant (Claude, in Claude Code) adapted its script and README to the resources of
scop at the author's request.
