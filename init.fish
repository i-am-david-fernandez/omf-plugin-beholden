# beholder initialization hook
#
# You can use the following variables in this file:
# * $package       package name
# * $path          package path
# * $dependencies  package dependencies

set -g beholder_store "$HOME/.beheld.db"

function __beholder_init
    echo "CREATE TABLE IF NOT EXISTS Commands \
    (Timestamp REAL, DayOfWeek INTEGER, Hour INTEGER, Minute INTEGER, Command TEXT, WorkingDirectory TEXT);" | sqlite3 $beholder_store
end

function __beholder_show
    echo "SELECT * FROM Commands;" | sqlite3 $beholder_store
end

function __beholder_sanitise
    echo $argv | sed -e "s/'/''/g"
end

function __beholder_pre --on-event fish_preexec
    if test -z "$argv"
        return
    end

    date +"%s.%N %u %H %M" | read timestamp day_of_week hour minute
    set -l _argv (__beholder_sanitise $argv)
    echo "INSERT INTO Commands (Timestamp, DayOfWeek, Hour, Minute, Command, WorkingDirectory) \
    VALUES ($timestamp, $day_of_week, $hour, $minute, '$_argv', '$PWD');" | sqlite3 $beholder_store
end

# function __beholder_post --on-event fish_postexec
#     #echo "POST: $argv, $PWD" >> $beholder_store
# end

__beholder_init
