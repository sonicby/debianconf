# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
# umask 022

#remove duplicate from history
HISTCONTROL=ignoredups:ignorespace
#append history to history file, dont overwrite
shopt -s histappend
# You may uncomment the following lines if you want `ls' to be colorized:
export LS_OPTIONS='--color=auto'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'
#
# Some more alias to avoid making mistakes:
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'
prompt_command () {
        # set an error string for the prompt, if applicable
        if [ $? -eq 0 ]; then
                ERRPROMPT=" "
        else
                ERRPROMPT=" ($?) "
        fi

        local BRANCH=""

        # if we're in a Git repo, show current branch
        #if [ "\$(type -t __git_ps1)" ]; then
        #       BRANCH="\$(__git_ps1 '[ %s ] ')"
        #fi

        if [ -d ".svn" ]; then
                BRANCH="[ "`svn info | awk '/Last\ Changed\ Rev/ {print $4}'`" ]"
        fi

        local LOAD=`cut -d' ' -f1 /proc/loadavg`
        #local TIME=`date +"%d.%m.%Y %H:%M:%S"`
        local TIME=`date +"%H:%M:%S"`
        local IPADR=`ifconfig eth0 | grep inet | grep -v inet6 | cut -d ":" -f 2 | cut -d " " -f 1`
        local CURENT_PATH=`echo ${PWD/#$HOME/\~}`

        # trim long path
        if [ ${#CURENT_PATH} -gt "35" ]; then
                let CUT=${#CURENT_PATH}-35
                CURENT_PATH="...$(echo -n $PWD | sed -e "s/\(^.\{$CUT\}\)\(.*\)/\2/")"
        fi

        local TITLEBAR="\[\e]2;${CURENT_PATH}\a"

        local GREEN="\[\033[0;32m\]"
        local CYAN="\[\033[0;36m\]"
        local BCYAN="\[\033[1;36m\]"
        local BLUE="\[\033[0;34m\]"
        local GRAY="\[\033[0;37m\]"
        local DKGRAY="\[\033[1;30m\]"
        local WHITE="\[\033[1;37m\]"
        local RED="\[\033[0;31m\]"
        # return color to Terminal setting for text color
        local DEFAULT="\[\033[0;39m\]"

        PROMPT="[ ${TIME}, ${LOAD}, ${USER}@${HOSTNAME} ]$ERRPROMPT [ ${CURENT_PATH} ]"

        # different prompt and color for root
        local PR="$ "
        local USERNAME_COLORED="${BCYAN}${USER}${GREEN}@${BCYAN}${HOSTNAME}"
        if [ "$UID" = "0" ]; then
                PR="# "
                USERNAME_COLORED="${RED}${USER}${GREEN}@${RED}${HOSTNAME}@${GREEN}${IPADR}"
        fi

        # use only ASCII symbols in linux console
        local DASH="\e(0q\e(B"
        local TC="\]\e(0l\e(B\]"
        local BC="\[\e(0\]m\[\e(B\]"
        if [ "$TERM" = "linux" ]; then
                TITLEBAR=""
                DASH="-"
                TC=""
                BC=""
        fi

        local SEPARATOR=""
        let FILLS=${COLUMNS}-${#PROMPT}
        for (( i=0; i<$FILLS; i++ )) do
                SEPARATOR=$SEPARATOR$DASH
        done

        local TOP_LINE="${TC}${CYAN}[ ${WHITE}${TIME}, ${DKGRAY}${LOAD}, ${USERNAME_COLORED} ${CYAN}]${RED}$ERRPROMPT${CYAN}[ ${GRAY}${CURENT_PATH}${CYAN} ]${GRAY}"
        local BOTTOM_LINE="${BC}${GREEN}${BRANCH}${CYAN}[ ${GREEN}${PR}${DEFAULT}"
        export PS1="${TITLEBAR}\n${TOP_LINE}\n${BOTTOM_LINE}"
}
PROMPT_COMMAND=prompt_command
if [ -f /etc/bash_completion ]; then
. /etc/bash_completion
fi 
