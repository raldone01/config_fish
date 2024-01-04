# unset all variables starting with tide_
set -l all_varnames = (set --names)
for var_name in $all_varnames
  if string match -q "tide_*" $var_name
    echo "unset $var_name"
    set -e $var_name
    set -g -e $var_name
    set -U -e $var_name
  end
end
