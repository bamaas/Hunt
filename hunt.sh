hunt() {
  if [[ -z "$ZSH_VERSION" ]]; then
    echo "Hunt requires zsh. Please run in a zsh shell." >&2
    return 1
  fi

  emulate -L zsh
  local -a fzf_opts=(--reverse --style full)

  # ──────────────────────────────────────────────────────────────────────
  # Configuration via environment variables (all optional)
  # ──────────────────────────────────────────────────────────────────────
  #   HUNT_EDITOR           Editor command (falls back to $EDITOR, then vim)
  #   HUNT_PREVIEW_POSITION Where preview sits: right, left, up, down (default: right)
  #   HUNT_PREVIEW_SIZE     Preview size as percent 1-99 (default: 40)
  #
  # Usage: hunt [directory]
  #
  # Keybindings:
  #   ctrl-t:files  ctrl-g:grep  ctrl-r:recent  ctrl-e:explore  ctrl-j:jump
  #   ctrl-/:toggle preview  ctrl-c:exit
  #   In explore: enter=cd/open  esc=up
  # ──────────────────────────────────────────────────────────────────────

  local dir="${1:-.}"
  local editor="${HUNT_EDITOR:-${EDITOR:-vim}}"
  local preview_pos="${HUNT_PREVIEW_POSITION:-right}"
  local preview_size="${HUNT_PREVIEW_SIZE:-40}"

  local preview_border="border"

  local preview_window="${preview_pos}:${preview_size}%"
  local preview_full="${preview_window},${preview_border}"

  local fd_excludes="--exclude .git --exclude node_modules --exclude .cache --exclude target --exclude dist --exclude .venv --exclude __pycache__"
  local rg_excludes="--glob '!.git' --glob '!node_modules' --glob '!.cache' --glob '!target' --glob '!dist' --glob '!.venv' --glob '!__pycache__' --colors 'line:fg:0x57,0xC7,0xFF'"

  local color="prompt:#FF6AC1,pointer:#FF6AC1,marker:#FF6AC1,fg:#BBBBBB,fg+:#FFFFFF,header:#9AEDFE,hl:underline:#5AF78E,hl+:underline:#5AF78E:bold,border:#444444,label:#686868,preview-border:#444444,preview-label:#686868"

  # Use alt- in Windows Terminal (which sets $WT_SESSION), ctrl- everywhere else
  if [[ -n "$WT_SESSION" ]]; then
    local kf="alt-f" kg="alt-g" kr="alt-r" ke="alt-e" kj="alt-j" kp="alt-/"
  else
    local kf="ctrl-f" kg="ctrl-g" kr="ctrl-r" ke="ctrl-e" kj="ctrl-j" kp="ctrl-/"
  fi
  local header="${kf}:files  ${kg}:grep  ${kr}:recent  ${ke}:explore  ${kj}:jump  ${kp}:preview"

  local result file line mode="files"
  local browse_dir
  browse_dir=$(realpath "$dir")

  local last_grep_query=""
  local last_files_query=""
  local raw_result
  local target

  __hunt_split() {
    local raw="$1"
    local q_var="$2"
    local r_var="$3"
    local first rest
    {
      IFS= read -r first
      rest=$(cat)
    } <<EOF
$raw
EOF
    eval "$q_var=\$first"
    eval "$r_var=\$rest"
  }

  while true; do
    case "$mode" in
      grep)
        raw_result=$(
          fzf "${fzf_opts[@]}" --ansi \
            --color="$color" \
            --info=hidden \
            --input-label ' Input ' --header-label ' Help ' \
            --list-label " ${browse_dir} " \
            --bind "result:transform-list-label:
                if [ -z \"\$FZF_QUERY\" ]; then
                  echo \" ${browse_dir} · \$FZF_MATCH_COUNT items \"
                else
                  echo \" ${browse_dir} · \$FZF_MATCH_COUNT matches \"
                fi
                " \
            --bind 'focus:transform-preview-label:[ -n {1} ] && printf " Previewing [%s] " {1}' \
            --height=100% \
            --layout=default \
            --delimiter=: \
            --print-query \
            --query="$last_grep_query" \
            --prompt="grep> " \
            --header "$header  ctrl-c:exit" \
            --bind "esc:ignore" \
            --bind "${kj}:become(echo __JUMP__)" \
            --bind "start:reload(rg --line-number --no-heading --color=always --smart-case --hidden $rg_excludes '' \"$dir\")" \
            --bind "${kf}:change-prompt(files> )+change-preview-window($preview_window)+clear-query+unbind(change)+reload(fd -t f --hidden $fd_excludes . \"$dir\")" \
            --bind "${kg}:change-prompt(grep> )+change-preview-window($preview_window)+clear-query+rebind(change)+reload(rg --line-number --no-heading --color=always --smart-case --hidden $rg_excludes '' \"$dir\")" \
            --bind "${kr}:change-prompt(recent> )+change-preview-window($preview_window)+clear-query+unbind(change)+reload(fd -t f --hidden $fd_excludes --changed-within 7d . \"$dir\")" \
            --bind "${ke}:become(echo __EXPLORE__)" \
            --bind "change:reload:rg --line-number --no-heading --color=always --smart-case --hidden $rg_excludes -- {q} \"$dir\" || true" \
            --bind "${kp}:toggle-preview" \
            --preview '
              file=$(echo {} | cut -d: -f1)
              lineno=$(echo {} | cut -d: -f2)
              if [ -n "$lineno" ] && [ "$lineno" -gt 0 ] 2>/dev/null; then
                bat --color=always --style=numbers --highlight-line "$lineno" "$file"
              else
                bat --color=always --style=numbers {}
              fi' \
            --preview-window=$preview_full
        ) || return

        if [[ "$raw_result" == __*__ && "$raw_result" != *$'\n'* ]]; then
          result="$raw_result"
        else
          __hunt_split "$raw_result" last_grep_query result
        fi
        ;;

      explore)
        printf '\033[2J\033[H'
        result=$(
          {
            EZA_COLORS='reset:di=38;2;87;199;255:fi=0:ex=0:ln=0:or=0:pi=0:so=0:bd=0:cd=0' eza --all --group-directories-first --git-ignore --color=always "$browse_dir" | grep -v '^\.git$'
          } | fzf "${fzf_opts[@]}" --ansi \
            --color="$color" \
            --info=hidden \
            --input-label ' Input ' --header-label ' Help ' \
            --list-label " ${browse_dir} " \
            --bind "result:transform-list-label:echo ' ${browse_dir} · '\$FZF_MATCH_COUNT' items '" \
            --bind 'focus:transform-preview-label:[ -n {} ] && printf " Previewing [%s] " {}' \
            --height=100% \
            --layout=default \
            --no-sort --tac \
            --prompt="explore> " \
            --header "${header}  esc:up" \
            --bind "${kj}:become(echo __JUMP__)" \
            --bind "${kf}:become(echo __FILES__)" \
            --bind "${kg}:become(echo __GREP__)" \
            --bind "${kr}:become(echo __RECENT__)" \
            --bind "esc:become(echo __UP__)" \
            --bind "${kp}:toggle-preview" \
            --preview "
              entry={}
              name=\$(echo \"\$entry\" | sed 's/\x1b\[[0-9;]*m//g')
              target=\"$browse_dir/\$name\"
              if [ -d \"\$target\" ]; then
                EZA_COLORS='reset:di=38;2;87;199;255:fi=0:ex=0:ln=0:or=0:pi=0:so=0:bd=0:cd=0' eza --tree --level=2 --group-directories-first --all --git-ignore --color=always \"\$target\" 2>/dev/null
              elif [ -f \"\$target\" ]; then
                bat --color=always --style=numbers \"\$target\" 2>/dev/null || cat \"\$target\"
              fi
            " \
            --preview-window=$preview_full
        ) || return
        ;;

      *)
        raw_result=$(
          fzf "${fzf_opts[@]}" --ansi \
            --color="$color" \
            --info=hidden \
            --input-label ' Input ' --header-label ' Help ' \
            --list-label " ${browse_dir} " \
            --bind "result:transform-list-label:
                if [ -z \"\$FZF_QUERY\" ]; then
                  echo \" ${browse_dir} · \$FZF_MATCH_COUNT items \"
                else
                  echo \" ${browse_dir} · \$FZF_MATCH_COUNT matches \"
                fi
                " \
            --bind 'focus:transform-preview-label:[ -n {1} ] && printf " Previewing [%s] " {1}' \
            --height=100% \
            --layout=default \
            --delimiter=: \
            --print-query \
            --query="$last_files_query" \
            --prompt="files> " \
            --header "$header" \
            --bind "esc:ignore" \
            --bind "${kj}:become(echo __JUMP__)" \
            --bind "start:unbind(change)+reload(fd -t f --hidden $fd_excludes . \"$dir\")" \
            --bind "${kf}:change-prompt(files> )+change-preview-window($preview_window)+clear-query+unbind(change)+reload(fd -t f --hidden $fd_excludes . \"$dir\")" \
            --bind "${kg}:change-prompt(grep> )+change-preview-window($preview_window)+clear-query+rebind(change)+reload(rg --line-number --no-heading --color=always --smart-case --hidden $rg_excludes '' \"$dir\")" \
            --bind "${kr}:change-prompt(recent> )+change-preview-window($preview_window)+clear-query+unbind(change)+reload(fd -t f --hidden $fd_excludes --changed-within 7d . \"$dir\")" \
            --bind "${ke}:become(echo __EXPLORE__)" \
            --bind "change:reload:rg --line-number --no-heading --color=always --smart-case --hidden $rg_excludes -- {q} \"$dir\" || true" \
            --bind "${kp}:toggle-preview" \
            --preview '
              file=$(echo {} | cut -d: -f1)
              lineno=$(echo {} | cut -d: -f2)
              if [ -n "$lineno" ] && [ "$lineno" -gt 0 ] 2>/dev/null; then
                bat --color=always --style=numbers --highlight-line "$lineno" "$file"
              else
                bat --color=always --style=numbers {}
              fi
            ' \
            --preview-window=$preview_full
        ) || return

        if [[ "$raw_result" == __*__ && "$raw_result" != *$'\n'* ]]; then
          result="$raw_result"
        else
          __hunt_split "$raw_result" last_files_query result
        fi
        ;;
    esac

    case "$result" in
      __JUMP__)
        target=$(
          zoxide query -l | fzf "${fzf_opts[@]}" \
            --ansi \
            --color="$color" \
            --info=hidden \
            --input-label ' Input ' --header-label ' Help ' \
            --bind 'result:transform-list-label:
                if [ -z "$FZF_QUERY" ]; then
                  echo " $FZF_MATCH_COUNT items "
                else
                  echo " $FZF_MATCH_COUNT matches "
                fi
                ' \
            --popup center,80%,50% \
            --height=100% \
            --layout=default \
            --prompt="jump> " \
            --header $'ctrl-/:preview  enter:cd  esc:back  ctrl-c:exit' \
            --bind "esc:become(echo __BACK__)"
        )

        if [[ "$target" == "__BACK__" ]]; then
          continue
        fi

        if [[ -z "$target" ]]; then
          return
        fi

        if [[ -d "$target" ]]; then
          cd "$target"
          dir="$PWD"
          browse_dir="$PWD"
          last_files_query=""
          last_grep_query=""
          mode="files"
        fi

        continue
        ;;
      __EXPLORE__) last_files_query=""; last_grep_query=""; mode="explore"; continue ;;
      __FILES__)   last_files_query=""; last_grep_query=""; mode="files"; continue ;;
      __GREP__)    last_files_query=""; last_grep_query=""; mode="grep"; continue ;;
      __RECENT__)  last_files_query=""; last_grep_query=""; mode="files"; continue ;;
      __UP__)      browse_dir=$(dirname "$browse_dir"); mode="explore"; continue ;;
    esac

    if [[ "$mode" == "explore" ]]; then
      [[ -z "$result" ]] && continue

      target="$browse_dir/$result"

      if [[ -d "$target" ]]; then
        browse_dir=$(realpath "$target")
        continue
      fi

      if [[ -f "$target" ]]; then
        "$editor" "$target"
      fi

      continue
    fi

    [[ -z "$result" ]] && continue

    if [[ "$result" == *:*:* ]]; then
      file=${result%%:*}
      rest=${result#*:}
      line=${rest%%:*}
      mode="grep"
      last_grep_query="$last_files_query"
      "$editor" +"$line" "$file"
    else
      mode="files"
      "$editor" "$result"
    fi
  done
}
