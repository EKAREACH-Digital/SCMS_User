#!/usr/bin/env bash
# Usage:
#   ./tool/check_rules.sh                 scan all lib/**/*.dart
#   ./tool/check_rules.sh a.dart b.dart   scan only these files
#   ./tool/check_rules.sh --changed       scan files changed in git (staged, unstaged, untracked)
#   --hook                                add when called from a Claude Code Stop hook
cd "$(dirname "$0")/.." || exit 1

# ---- adjust these to your project -----------------------------------------
FONT_DEF_FILES='app_fonts\.dart$|app_colors\.dart$'   # files allowed to use TextStyle/FontWeight
LOGGER_FILE='logger\.dart$'                            # file allowed to call print/debugPrint
# ---------------------------------------------------------------------------

HOOK=0; MODE=all; ARGS=(); FILES=(); FAIL=0
for a in "$@"; do
  case "$a" in
    --hook) HOOK=1 ;;
    --changed) MODE=changed ;;
    *) ARGS+=("$a") ;;
  esac
done

# Stop-hook loop guard: if Claude is already continuing because of this hook, let it stop
if [[ $HOOK -eq 1 ]]; then
  input=$(cat)
  [[ "$(echo "$input" | jq -r '.stop_hook_active // false')" == "true" ]] && exit 0
fi

if [[ ${#ARGS[@]} -gt 0 ]]; then
  FILES=("${ARGS[@]}")
elif [[ $MODE == changed ]]; then
  while IFS= read -r f; do
    [[ -f "$f" ]] && FILES+=("$f")
  done < <( (git diff --name-only HEAD 2>/dev/null; git ls-files --others --exclude-standard) \
            | grep -E '^lib/.*\.dart$' | grep -vE '\.(g|freezed)\.dart$' | sort -u )
else
  while IFS= read -r f; do FILES+=("$f"); done \
    < <(find lib -name '*.dart' ! -name '*.g.dart' ! -name '*.freezed.dart')
fi

[[ ${#FILES[@]} -eq 0 ]] && exit 0

# check <regex> <message> [exclude-path-regex] [only-in-path-regex]
check() {
  local regex="$1" msg="$2" exclude="${3:-}" include="${4:-}" hits="" f out
  for f in "${FILES[@]}"; do
    [[ -n "$exclude" && "$f" =~ $exclude ]] && continue
    [[ -n "$include" && ! "$f" =~ $include ]] && continue
    out=$(grep -nE "$regex" "$f" | grep -vE '^[0-9]+:[[:space:]]*//')
    [[ -n "$out" ]] && hits+="$(printf '%s\n' "$out" | sed "s|^|  $f:|")"$'\n'
  done
  if [[ -n "$hits" ]]; then
    echo "✗ $msg" >&2
    printf '%s' "$hits" >&2
    FAIL=1
  fi
}

# ---- logging ----
check '(^|[^A-Za-z0-9_])(debugPrint|print)\(' \
      'Use AppLogger (core/utils/logger.dart), never print()/debugPrint()' "$LOGGER_FILE"

# ---- typography & colors ----
check '(^|[^A-Za-z0-9_])TextStyle\(' \
      'Use AppFonts.headingN.copyWith(...), not raw TextStyle' "$FONT_DEF_FILES"
check 'FontWeight\.w[0-9]' \
      'Use AppFonts.regular/medium/semiBold/bold, not FontWeight.wXXX' "$FONT_DEF_FILES"
check '(^|[^A-Za-z0-9_])Colors\.grey' \
      'Use an AppColors constant, not Colors.grey' "$FONT_DEF_FILES"

# ---- UI construction ----
check '(^|[^A-Za-z0-9_])_build[A-Z][A-Za-z0-9_]*\(' \
      'No _buildX() helpers; extract a named StatelessWidget'
check '(^|[^A-Za-z0-9_])Opacity\(' \
      'Do not use Opacity; use Visibility, Offstage or AnimatedOpacity'

# ---- navigation ----
check 'Navigator\.(push|pushNamed|pushReplacement|pushReplacementNamed|pushAndRemoveUntil|pushNamedAndRemoveUntil)\(|Navigator\.of\([^)]*\)\.(push|pushNamed|pushReplacement|pushReplacementNamed|pushAndRemoveUntil|pushNamedAndRemoveUntil)\(' \
      'Use context.go() / context.push(), never Navigator.push*'

# ---- layering ----
check '^import .*/(repositories|datasources)/' \
      'Views/ViewModels must not import Repository or Datasource directly (ViewModels get them by injection)' \
      '' '/presentation/views/'
check '^import .*/presentation/' \
      'Repositories must not import anything from the presentation layer' \
      '' '/data/repositories/'

if [[ $FAIL -eq 1 ]]; then
  echo "Fix the violations above (see CLAUDE.md)." >&2
  exit 2
fi
exit 0