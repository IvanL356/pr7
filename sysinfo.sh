#!/bin/bash

# Функция для вывода списка пользователей
list_users() {
    cut -d: -f1,6 /etc/passwd | sort
}

# Функция для вывода списка процессов
list_processes() {
    ps aux --sort=pid
}

# Функция для вывода справки
show_help() {
    echo "Использование: $0 [АРГУМЕНТЫ]"
    echo "Опции:"
    echo "  -u, --users            Вывести список пользователей и их домашних директорий"
    echo "  -p, --processes        Вывести список запущенных процессов (сортировка по PID)"
    echo "  -h, --help             Показать справку"
    echo "  -l, --log PATH         Записать вывод в файл"
    echo "  -e, --errors PATH      Записать ошибки в файл"
}

# Переменные для перенаправления потоков
LOG_FILE=""
ERR_FILE=""

# Парсинг аргументов с помощью getopt
PARSED_ARGS=$(getopt -a -n "$0" -o u,p,h,l:,e: --long users,processes,help,log:,errors: -- "$@")
eval set -- "$PARSED_ARGS"

# Обработка аргументов
while true; do
    case "$1" in
        -u|--users)
            COMMAND="list_users"
            shift ;;
        -p|--processes)
            COMMAND="list_processes"
            shift ;;
        -h|--help)
            show_help
            exit 0 ;;
        -l|--log)
            LOG_FILE="$2"
            if [ ! -w "$(dirname "$LOG_FILE")" ]; then
                echo "Ошибка: нет прав на запись в директорию для логов" >&2
                exit 1
            fi
            shift 2 ;;
        -e|--errors)
            ERR_FILE="$2"
            if [ ! -w "$(dirname "$ERR_FILE")" ]; then
                echo "Ошибка: нет прав на запись в директорию для ошибок" >&2
                exit 1
            fi
            shift 2 ;;
        --) shift; break ;;
        *) break ;;
    esac
done

# Применение перенаправлений
[ -n "$ERR_FILE" ] && exec 2> "$ERR_FILE"
[ -n "$LOG_FILE" ] && exec > "$LOG_FILE"

# Выполнение выбранной команды
if [ -n "$COMMAND" ]; then
    $COMMAND
else
    echo "Ошибка: не указана команда (-u или -p). Используйте -h для справки." >&2
fi
