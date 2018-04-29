#!/bin/bash

# ПЕРЕМЕННЫЕ
# x, y = {1-3}
# symbol, symbol_enemy = {x, y}
# state = {'move', 'wait'}
# pipe - fifo
# line - последняя считанная строка
points=(0 1 2 3 4 5 6 7 8)
# points[x + 3 * y] = {x, y, trash-number}
# correct_point = {0 = некорректная, 1 = корректная}

# ОТЛАДКА
# player = {1, 2 = (запустил программу не 1ый)} для отладки

function quit {
    clearStatus
    echo -en "\E[0;0fПобедили $1"
    showCursor
    echo -en '\E[5;0f'
    exit
}

function parsePoint() {
    IFS=' ' read -r -a array <<< $line
    x=${array[0]}
    y=${array[1]}
}

function readPoint() {
    read pointInStr
    IFS=' ' read -r -a array <<< $pointInStr
    x=${array[0]}
    y=${array[1]}
}

function showStatusEnter() {
    clearStatus
    echo -en '\E[0;0fВведите точку: '
}

function showStatusNoCorrectAndEnter {
    clearStatus
    echo -en '\E[0;0fВведите КОРРЕКТНУЮ точку: '
}

function showStatusWaitEnemy() {
    clearStatus
    echo -en '\E[0;0fХод соперника'
}

function clearStatus() {
    echo -en '\E[0;0f\E[K'
}

function savePoint() {
    echo -e "\E[$((y+1));${x}f$1"
    index=$(((x - 1) + 3 * (y - 1)))
    points[$index]=$1
}

function hideCursor() {
    tput civis
}

function showCursor() {
    tput cnorm
}

function checkCorrectPoints() {
    index=$(((x - 1) + 3 * (y - 1)))
    value=${points[$index]}
    if [[ ($x == 1 || $x == 2 || $x == 3) && ($y == 1 || $y == 2 || $y == 3)
        && $value != 'x' && $value != 'o' ]]
    then
        correct_point=1
    else
        correct_point=0
    fi
}

function checkResult() {
    # горизонталь
    # 1
    if [[ ${points[0]} == ${points[1]} && ${points[0]} == ${points[2]} ]]
    then
        quit ${points[0]}
    fi
    # 2
    if [[ ${points[3]} == ${points[4]} && ${points[3]} == ${points[5]} ]]
    then
        quit ${points[3]}
    fi
    # 3
    if [[ ${points[6]} == ${points[7]} && ${points[6]} == ${points[8]} ]]
    then
        quit ${points[6]}
    fi
    # вертикаль
    # 1
    if [[ ${points[0]} == ${points[3]} && ${points[0]} == ${points[6]} ]]
    then
        quit ${points[0]}
    fi
    # 2
    if [[ ${points[1]} == ${points[4]} && ${points[1]} == ${points[7]} ]]
    then
        quit ${points[1]}
    fi
    # 3
    if [[ ${points[2]} == ${points[5]} && ${points[2]} == ${points[8]} ]]
    then
        quit ${points[2]}
    fi
    # диагональ
    # 1
    if [[ ${points[0]} == ${points[4]} && ${points[0]} == ${points[8]} ]]
    then
        quit ${points[0]}
    fi
    # 2
    if [[ ${points[2]} == ${points[4]} && ${points[2]} == ${points[6]} ]]
    then
        quit ${points[2]}
    fi
}

function start() {
    pipe=/tmp/tic_tac_toe
    trap "rm -f $pipe" EXIT

    if [[ ! -p $pipe ]]
    then
        mkfifo $pipe
        # player=1
        symbol=x
        symbol_enemy=o
        state='move'
        waitConnection
        clear
        gameHandler
    else
        # player=2
        symbol=o
        symbol_enemy=x
        state='wait'
        echo "go" >$pipe
        clear
        gameHandler
    fi
}

function waitConnection() {
    while true
    do
        if read line <>$pipe; then
            if [[ "$line" == 'go' ]]; then
                break
            fi
            echo $line
        fi
    done
}

function gameHandler() {
    while true
    do
        if [[ $state == 'move' ]]
        then
            showCursor
            correct_point=0
            showStatusEnter
            while true
            do
                readPoint
                checkCorrectPoints
                if [[ $correct_point == 1 ]]
                then
                    break
                else
                    showStatusNoCorrectAndEnter
                fi
            done
            savePoint $symbol
            echo ${x} ${y} >${pipe}
            checkResult
            correct_point=0
            state='wait'
        else
            hideCursor
            showStatusWaitEnemy
            while true
            do
                if read line <$pipe; then
                    parsePoint
                    savePoint $symbol_enemy
                    checkResult
                    state='move'
                    break
                fi
            done
        fi
    done
}


start
