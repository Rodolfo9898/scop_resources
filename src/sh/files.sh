# shellcheck shell=bash
#
# files.sh - the resources themselves: are they all here, and if not, get what is missing from the archive.
# Sourced by run.sh (it only defines functions). Needs log.sh and archive.sh. Variables it sets:
#   MISSING   the files of the archive that are not here (an array)
#   TOTAL     how many files the archive has

# files_look   sets MISSING and TOTAL, from the listing of the archive.
files_look()
{
	local member

	MISSING=()
	TOTAL=0
	while IFS= read -r member; do
		archive_path "$member" || continue
		TOTAL=$((TOTAL + 1))
		[ -e "$REL" ] || [ -L "$REL" ] || MISSING+=("$REL")
	done <<< "$LISTING"
}

# files_extract   unpacks the archive in a temporary folder and copies from it the files that are not here. A file that is already
# here is left as it is.
files_extract()
{
	local member from

	archive_unpack || exit 1
	while IFS= read -r member; do
		archive_path "$member" || continue
		if [ -e "$REL" ] || [ -L "$REL" ]; then
			continue
		fi
		from=$WORK/${member#./}
		if [ ! -f "$from" ] || [ -L "$from" ]; then
			log_fail "$member is not a plain file in $ARCHIVE"
		fi
		mkdir -p -- "$(dirname -- "$REL")" && cp -p -- "$from" "$REL" || log_fail "cannot write $REL"
	done <<< "$LISTING"
	archive_forget
}

# files_ensure QUIET   the whole of it: returns when the files are all here (extracting what was missing), stops the script when they
# cannot be. Says what it does, unless QUIET is "quiet" and nothing was missing.
files_ensure()
{
	archive_find
	[ -n "$ARCHIVE" ] || log_fail "there is no archive in src/ (src/*.tgz) to extract the resources from"
	archive_list
	files_look
	[ "$TOTAL" -gt 0 ] || log_fail "there is no file in $ARCHIVE"
	if [ "${#MISSING[@]}" -eq 0 ]; then
		[ "${1:-}" = quiet ] || log_say "the $TOTAL files of $ARCHIVE are all here."
		return 0
	fi
	if [ "${#MISSING[@]}" -eq "$TOTAL" ]; then
		log_say "extracting the resources from $ARCHIVE ($TOTAL files)."
	else
		log_say "${#MISSING[@]} of the $TOTAL files of $ARCHIVE are missing, restoring them."
	fi
	files_extract
	files_look
	[ "${#MISSING[@]}" -eq 0 ] || log_fail "still missing after extracting $ARCHIVE: ${MISSING[*]}"
}
