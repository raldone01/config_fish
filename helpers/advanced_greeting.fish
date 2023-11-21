if test -z "$image_viewer"
    set -g image_viewer tiv
end

# Returns a random image path in the $pic_folders directory.
# If no image is found or there was an error it returns nothing.
# If an image path is returned the function pic_not_nice is defined.
function rand_pic_file
    set -g last_pic_file (find $pic_folders -type f \( -iname \*.jpg -o -iname \*.jpeg -o -iname \*.png \)  2> /dev/null | shuf -n 1)
    if test -r "$last_pic_file"
        # check if the file is readable

        printf "%s" "$last_pic_file"

        function pic_not_nice
            if test -z "$last_pic_file"
                echo "Last picture not found!"
                return
            end
            rm -i "$last_pic_file"
            functions -e pic_not_nice
        end
    end
end

function calm
    if not type -q $image_viewer
        echo "No image viewer found!"
        return
    end
    set -l rand_pic_file (rand_pic_file)
    if test -z "$rand_pic_file"
        echo "No pictures found!"
        return
    end
    set -l filename (basename $rand_pic_file)
    echo "Featured pic $filename (Run pic_not_nice to delete)"
    image_viewer $argv $rand_pic_file
end

function fish_greeting
    set -l rand_pic_file (rand_pic_file)
    set -l terminal_height (tput lines)
    set -l terminal_width (tput cols)

    function __before_pic_textrivate_mode -S
        # print login message

        if test $terminal_width -gt 134;
            or test $terminal_height -lt 53
            #print it in one line
            set date_str (date +"%d/%b/%Y %H:%M:%S")
        else
            # print it in two lines
            set date_str "$(printf "%s\n%s" (date +"%d/%b/%Y") (date +"%H:%M:%S"))"
        end

        if type -q boxes
            and test $terminal_width -gt 77;
            and test $terminal_height -gt 40
            printf "%s" $date_str | figlet -t | boxes -d scroll
        else
            printf "%s\n" $date_str
        end

        echo "Use calm to calm. Powered by fish the friendly interactive shell."
        if test -n "$rand_pic_file"
           and type -q $image_viewer
            set -l filename (basename $rand_pic_file)
            echo "Featured pic $filename (Run pic_not_nice to delete)"
        end
    end
    function __after_pic_text -S
    end
    set -l before_pic_text (__before_pic_textrivate_mode)
    set -l after_pic_text (__after_pic_text)

    set -l before_lines (printf "%s\n" $before_pic_text | wc -l)
    set -l after_lines (printf "%s\n" $after_pic_text | wc -l)
    set -l prompt_lines (printf "%s\n" $fish_prompt | wc -l)

    # echo "$terminal_height $before_lines $after_lines $prompt_lines"
    set -l image_height (math $terminal_height - $before_lines - $after_lines - $prompt_lines)
    printf "%s\n" $before_pic_text
    if test -n "$rand_pic_file"
       and type -q $image_viewer
        image_viewer -h "$image_height" -w "$terminal_width" "$rand_pic_file"
    end
    printf "%s" $after_pic_text
end
