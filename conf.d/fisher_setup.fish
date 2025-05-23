set -U fisher_path ~/.config/fisher

if not type -q fisher && not test -e $fisher_path
  mkdir -p $fisher_path

  echo "No fisher detected installing..."
  echo "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"
  curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher

  fisher install jorgebucaran/fisher IlanCosman/tide jorgebucaran/nvm.fish
end

set -p fish_complete_path $fisher_path/completions
set -p fish_function_path $fisher_path/functions
for file in $fisher_path/conf.d/*
  source $file
end
