#!/bin/bash
prompt="Pick the target platform:"
chip_options=("a33" \
              "h8" \
              "h3" \
              "rk3066" \
              "rk3128" \
              "atm7029-action" \
              "aml-s805")
PLATFORM=""

select opt in "${chip_options[@]}" "Quit"; do 
    case "$REPLY" in

    1 ) echo "${chip_options[$REPLY-1]} is option";PLATFORM=${chip_options[$REPLY-1]};break;;
    2 ) echo "${chip_options[$REPLY-1]} is option";PLATFORM=${chip_options[$REPLY-1]};break;;
    3 ) echo "${chip_options[$REPLY-1]} is option";PLATFORM=${chip_options[$REPLY-1]};break;;
    4 ) echo "${chip_options[$REPLY-1]} is option";PLATFORM=${chip_options[$REPLY-1]};break;;
    5 ) echo "${chip_options[$REPLY-1]} is option";PLATFORM=${chip_options[$REPLY-1]};break;;
    6 ) echo "${chip_options[$REPLY-1]} is option";PLATFORM=${chip_options[$REPLY-1]};break;;
    7 ) echo "${chip_options[$REPLY-1]} is option";PLATFORM=${chip_options[$REPLY-1]};break;;

    $(( ${#chip_options[@]}+1 )) ) echo "Goodbye!"; break;;
    *) echo "Invalid option. Try another one.";continue;;
    esac
done

if [ "$PLATFORM" != "" ]; then
./ver_info.pl include/ssv_version.h
cp Makefile.android Makefile
sed -i 's,PLATFORMS =,PLATFORMS = '"$PLATFORM"',g' Makefile
make
echo "Done ko!"
else
echo "Fail!"
fi

