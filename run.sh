#!/usr/bin/env bash

# scop_resources, the resources of the scop subject (the models of the intranet archive).
#
# This is the main. The work is in the modules of src/sh/, which only define functions (they are loaded here, in this order):
#
#   src/sh/log.sh      the messages, and the errors that stop everything
#   src/sh/archive.sh  finds the archive in src/, checks its names and unpacks it to read from
#   src/sh/files.sh    checks that its files are all here, and extracts from the archive what is missing
#   src/sh/destroy.sh  removes them again, so that only what git keeps is left
#
# git keeps this script, the modules and the archive (src/*.tgz), and none of the files in it: they are extracted next to this
# script when any of them is missing, and removed on demand. A file that is already here is never overwritten, and one that was
# changed is never removed.
#
#   ./run.sh              extract what is missing, and say so (or that everything is here)
#   ./run.sh --extract    the same, silent when nothing is missing (what the Makefile of scop runs)
#   ./run.sh --destroy    remove the extracted files (what make fclean of scop runs)

[ -n "${BASH_VERSION:-}" ] || exec bash "$0" "$@"	# started with "sh run.sh": this file needs bash

ROOT=$(cd -- "$(dirname -- "$0")" && pwd) || exit 1
cd -- "$ROOT" || exit 1					# everything happens in this folder, wherever it was started from

for module in log archive files destroy; do
	[ -f "$ROOT/src/sh/$module.sh" ] || { echo "scop_resources: src/sh/$module.sh is missing" >&2; exit 1; }
	. "$ROOT/src/sh/$module.sh"
done

main()
{
	trap archive_forget EXIT				# the temporary folder never outlives the script
	case ${1:-} in
		'')
			files_ensure
			;;
		--extract)
			files_ensure quiet
			;;
		--destroy)
			archive_find
			[ -n "$ARCHIVE" ] || log_fail "no archive in src/ (src/*.tgz) to tell what the resources are"
			archive_list
			destroy_files
			[ "$REMOVED" -gt 0 ] || [ "${#KEPT[@]}" -gt 0 ] || log_say "no file of the archive is here."
			;;
		*)
			log_fail "usage: ./run.sh [--extract | --destroy]"
			;;
	esac
}

main "$@"
