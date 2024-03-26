# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    cleaner-linux-42.sh                                :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: dherszen <dherszen@student.42.rio>         +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/03/26 11:54:53 by dherszen          #+#    #+#              #
#    Updated: 2024/03/26 12:58:08 by dherszen         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# ********************************************************************* #
#          .-.                                                          #
#    __   /   \   __                                                    #
#   (  `'.\   /.'`  )   Restore Kit - session_clear.sh                  #
#    '-._.(;;;)._.-'                                                    #
#    .-'  ,`"`,  '-.                                                    #
#   (__.-'/   \'-.__)   BY: Rosie (https://github.com/BlankRose)        #
#       //\   /         Last Updated: Wed Mar 22 18:06:37 CET 2023      #
#      ||  '-'                                                          #
# ********************************************************************* #

if [ "$1" == '--edit' ] || [ "$1" == '-e' ]; then
	vim $0
	exit 0
fi

# ####################################### #
#                                         #
#              DECLARATIONS               #
#   List of folders and files to clears   #
#                                         #
# ####################################### #

# Quick Accesses
apps="$HOME/.var/app"
conf="$HOME/.config"
profile_path=$(grep -oP 'Default=\K.*' "$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox/profiles.ini")
firefox_path="$apps/org.mozilla.firefox/.mozilla/firefox"
firefox_profile_path="$firefox_path/$profile_path"

# Folders to clear up
select=(
	"$conf/Code/User/workspaceStorage"
	"$conf/Code/CachedExtensionVSIXs"
	"$conf/Code/Cache"

	"$HOME/.cache"
	"$apps/com.visualstudio.code/cache"
	"$apps/com.discordapp.Discord/cache"
	"$apps/com.discordapp.Discord/config/discord/Cache"
	"$apps/com.slack.Slack/cache"
	"$apps/com.slack.Slack/config/Slack/Cache"
	"$apps/com.slack.Slack/config/Slack/Service Worker/CacheStorage"
	"$apps/org.mozilla.firefox/cache"

	"$firefox_profile_path/storage/default"
	"$apps/com.google.Chrome/cache"
)

# Additional files to track down and clear
files=(
	".DS_Store"
	"*.swp"
)

# ####################################### #
#                                         #
#                  TASKS                  #
#    Procedure to clean up everything     #
#                                         #
# ####################################### #

# 1 . Get initial size
printf "\033[33mƒ Preparing cleanup.."
start=$(du -c -d0 $HOME 2>&1 | grep total | awk '{print $1}')

# 2 . Clean selected folders
for i in "${select[@]}"; do
	printf "\033[2K\rƒ Cleaning up folders.. ($i)"
	find "$i" ! -path "$i" 2>&1 | xargs -I {} rm -rf "{}" > /dev/null 2>&1
done

# 3 . Clean selected files
for i in "${files[@]}"; do
	printf "\033[2K\rƒ Removing unwanted files.. ($i)"
	find $HOME -name "$i" -type f 2>&1 | xargs -I {} rm -rf "{}" > /dev/null 2>&1
done

# 4 . Clean docker caches (if Docker is present)
if command -v docker &> /dev/null; then
	printf "\033[2K\rƒ Cleaning up Docker.."
	docker rm -f `docker ps -aq > /dev/null 2>&1` > /dev/null 2>&1 | true
	docker rmi -f `docker images -aq > /dev/null 2>&1` > /dev/null 2>&1 | true
	docker volume rm -f `docker volume ls -q > /dev/null 2>&1` > /dev/null 2>&1 | true
fi

# 5 . Calculate saved space
end=$(cd $HOME && du -c -d0 2>&1 | grep total | awk '{print $1}')
total=$(echo "$start-$end" | bc)

# 6 . Print out results
printf "\033[2K\r\033[32m√ Session has been successfully cleaned up!\n"
if [ $total -eq 0 ]; then
	printf "\033[32mNothing has been cleared! Did you already cleaned everything?\033[0m\n"
elif [ $total -lt 0 ]; then
	printf "\033[32mCouldn't estimate cleaned size since something in background is creating more files aswell...\033[0m\n"
else
	printf "\033[32mTotal Cleaned: $total bytes\033[0m\n"
fi
