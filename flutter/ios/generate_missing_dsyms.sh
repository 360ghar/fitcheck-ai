#!/bin/sh
# generate_missing_dsyms.sh
# ---------------------------------------------------------------------------
# During archive (ACTION=install), produce a dSYM for any embedded *.framework
# binary whose UUID is not already covered by the archive dSYMs folder.
#
# WHY (Sentry specifically):
#   sentry_flutter uses the static Sentry SPM xcframework. Real Sentry code is
#   linked into Runner, but Xcode still embeds a small stub Sentry.framework
#   with a unique UUID every build. No shipping dSYM matches that UUID, so
#   Xcode Organizer "Upload symbols" fails with:
#     "The archive did not include a dSYM for the Sentry.framework with the
#      UUIDs [...]."
#
#   `dsymutil` on the stub binary creates a dSYM with the matching UUID.
#   Apple only checks UUID presence; real crash symbolication still comes
#   from sentry-cli uploads of SPM/archive dSYMs (see build-ios.yml).
# ---------------------------------------------------------------------------

set -e

if [ "${ACTION}" != "install" ]; then
  echo "generate_missing_dsyms: skip (ACTION=${ACTION:-unset})"
  exit 0
fi

if [ -z "${DWARF_DSYM_FOLDER_PATH}" ]; then
  echo "generate_missing_dsyms: DWARF_DSYM_FOLDER_PATH unset; skip"
  exit 0
fi

# App Frameworks directory after embed phases.
APP_FW="${TARGET_BUILD_DIR}/${WRAPPER_NAME}/Frameworks"
if [ ! -d "${APP_FW}" ]; then
  # Fallback used in some archive layouts.
  APP_FW="${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/Frameworks"
fi

if [ ! -d "${APP_FW}" ]; then
  echo "generate_missing_dsyms: no Frameworks dir at ${APP_FW}; skip"
  exit 0
fi

mkdir -p "${DWARF_DSYM_FOLDER_PATH}"

echo "generate_missing_dsyms: frameworks=${APP_FW}"
echo "generate_missing_dsyms: dsym_dir=${DWARF_DSYM_FOLDER_PATH}"

for framework in "${APP_FW}"/*.framework; do
  [ -d "${framework}" ] || continue

  name="$(basename "${framework}" .framework)"
  binary="${framework}/${name}"
  if [ ! -f "${binary}" ]; then
    # Some frameworks nest the binary under Versions/A/
    if [ -f "${framework}/Versions/A/${name}" ]; then
      binary="${framework}/Versions/A/${name}"
    else
      echo "generate_missing_dsyms: no binary in ${name}.framework; skip"
      continue
    fi
  fi

  bin_uuids="$(dwarfdump --uuid "${binary}" 2>/dev/null | awk '{print toupper($2)}' | sort -u || true)"
  if [ -z "${bin_uuids}" ]; then
    echo "generate_missing_dsyms: no UUID for ${name}; skip"
    continue
  fi

  dsym_path="${DWARF_DSYM_FOLDER_PATH}/${name}.framework.dSYM"
  need_generate=0

  if [ ! -d "${dsym_path}" ]; then
    need_generate=1
  else
    dsym_uuids="$(dwarfdump --uuid "${dsym_path}" 2>/dev/null | awk '{print toupper($2)}' | sort -u || true)"
    # If any binary UUID is missing from the dSYM, regenerate.
    for u in ${bin_uuids}; do
      if ! echo "${dsym_uuids}" | grep -q "${u}"; then
        need_generate=1
        break
      fi
    done
  fi

  if [ "${need_generate}" -eq 0 ]; then
    echo "generate_missing_dsyms: OK ${name}.framework (UUID match)"
    continue
  fi

  echo "generate_missing_dsyms: generating ${name}.framework.dSYM"
  rm -rf "${dsym_path}"
  # May warn "no debug symbols" for stubs; still writes a UUID-matched dSYM.
  if ! dsymutil "${binary}" -o "${dsym_path}"; then
    echo "warning: generate_missing_dsyms: dsymutil failed for ${name}" >&2
    continue
  fi

  echo "generate_missing_dsyms: wrote ${dsym_path}"
  dwarfdump --uuid "${dsym_path}" 2>/dev/null || true
done

echo "generate_missing_dsyms: done"
ls -1 "${DWARF_DSYM_FOLDER_PATH}" 2>/dev/null || true
