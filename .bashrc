### computing environment setting for Linux and Mac

export MANPATH=${MANPATH}:/usr/share/man
export PROJ=~/projects
export SCRIPT=~/scripts
# python:


#export PATH=$PATH:$PROJ/geo/scripts
#export PATH=$PATH:$PROJ/geo/jiji/src/procesx

export PATH=${PATH}:$SEISHOME/pysmo-aimbat/scripts
export PATH=${PATH}:$SEISHOME/pysmo-aimbat/src/pysmo
export PATH=${PATH}:$SEISHOME/pysmo-aimbat/src/pysmo/aimbat
export PATH=${PATH}:$SEISHOME/pysmo-aimbat-more-scripts
export PYTHONPATH=${PYTHONPATH}:$SEISHOME/pysmo-aimbat/scripts
export PYTHONPATH=${PYTHONPATH}:$SEISHOME/pysmo-aimbat/src/pysmo
export PYTHONPATH=${PYTHONPATH}:$SEISHOME/pysmo-aimbat/src/pysmo/aimbat
export PYTHONPATH=${PYTHONPATH}:$SEISHOME/pysmo-aimbat-more-scripts

alias ipy="ipython-2.7 -pylab"
alias f2py="f2py-2.6"

###sourcing my scripts/programs
export PATH=$PATH:$SCRIPT
export PATH=$PATH:$SCRIPT/gmt

###
export SVN_EDITOR=vim


#export SHELL=bash
# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi


# Set path to GMT 5 and allow old-style syntax
export PATH=${PATH}:/Applications/GMT-5.1.1.app/Contents/Resources/bin
source $(gmt --show-datadir)/tools/gmt_functions.sh


# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

#if [ -f ~/.bash_aliases ]; then
#    . ~/.bash_aliases
#fi

# enable color support of ls and also add handy aliases
#if [ "$TERM" != "dumb" ]; then
    #eval "`dircolors -b`"
    #alias ls='ls --color=auto'
    #alias dir='ls --color=auto --format=vertical'
    #alias vdir='ls --color=auto --format=long'
#fi

# some more ls aliases
alias scp='scp -p -r '
alias ls='ls -G'
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

alias h='history'



### set a fancy prompt (non-color, unless we know we "want" color)
#case "$TERM" in
#xterm-256color)
#    #PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
#    PS1='${debian_chroot:+($debian_chroot)}\[\033[00;32m\]\u@\h\[\033[00m\]:\[\033[00;35m\]\w\[\033[00m\]\$ '
#    ;;
#*)
#    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
#    ;;
#esac

# Comment in the above and uncomment this below for a color prompt
# the first line is your old prompt, Trevor :)
PS1='${debian_chroot:+($debian_chroot)}\[\033[00;32m\]\u@\h\[\033[00m\]:\[\033[01;35m\]\w\[\033[00m\]\$ '
#PS1='${debian_chroot:+($debian_chroot)}\[\033[00;32m\]trevorsofficeROCKS@\h\[\033[00m\]:\[\033[01;35m\]\w\[\033[00m\]\$ '

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
# the commented line below will give you the normal title back :)
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
#    PROMPT_COMMAND='echo -ne "\033]0;killarocks: ${PWD/$HOME/~}\007"'
    ;;
*)
    ;;
esac

source /Users/lkloh/.profile
#source /opt/passcal/setup/setup.sh

export PATH=/opt/local/bin:$PATH
