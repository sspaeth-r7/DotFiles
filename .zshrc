export GOPATH=$HOME/go

case `uname` in
  Linux)
    # Linux-specific commands
    alias {start,open}="xdg-open"

    # Allow alt + L/R arrow to jump words like on mac
    bindkey "^[[1;3C" forward-word
    bindkey "^[[1;3D" backward-word

    # avoid constantly needing to type ssh passkey when gitting
    if [ $(ps ax | grep "[s]sh-agent" | wc -l) -eq 0 ] ; then
      eval $(ssh-agent -s) > /dev/null
    fi
    keychain --nogui $HOME/.ssh/id_ed25519 &> /dev/null
  ;;
  Darwin)
    # macOS-specific commands
  ;;
esac

# make ^u delete left from cursor like in bash
bindkey \^U backward-kill-line

# terraform
alias tind='docker run --network host -v $HOME/docker.terraform.d/:/root/.terraform.d -v $(git rev-parse --show-toplevel):/app --rm -it -w /app/$(git rev-parse --show-prefix) -v $HOME/.aws:/root/.aws --env AWS_PROFILE=$AWS_PROFILE --env AWS_DEFAULT_PROFILE=$AWS_DEFAULT_PROFILE tfwaws:1.4.0'
command -v terraform &>> /dev/null && alias tf="terraform"

# kubectl
command -v kubectl &>> /dev/null && alias k="kubectl"

export PATH="$HOME/.tfenv/bin:$PATH"

function __fast_git_branch() {
  local headfile head branch
  local dir="$PWD"
  while [ -n "$dir" ]; do if [ -e "$dir/.git/HEAD" ]; then
      headfile="$dir/.git/HEAD"
      break
    fi
    dir="${dir%/*}"
  done
  if [ -e "$headfile" ]; then
    read -r head < "$headfile" || return
    case "$head" in
      ref:*) branch="${head##*/}" ;;
      "") branch="" ;;
      *) branch="${head:0:7}" ;;  #Detached head. You can change the format for this too.
    esac
  fi
  if [ -z "$branch" ]; then return 0; fi

  printf "[%b] " "%F{175}$branch%F{default}"
}

setopt PROMPT_SUBST
PROMPT='%n@[%F{098}%m%f] %~ $(__fast_git_branch)%(?.%%.%F{196}%%%f) '
export PATH="$HOME/.bin:$PATH"
