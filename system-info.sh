
#!/bin/bash

# macOS System Information CLI — Pink & White

PINK=$'\033[38;2;255;183;213m'
WHITE=$'\033[97m'
RESET=$'\033[0m'

# System information
USER_NAME=$(whoami)
HOST_NAME=$(scutil --get LocalHostName 2>/dev/null || hostname)
OS_VERSION=$(sw_vers -productVersion)
MODEL=$(sysctl -n hw.model)
KERNEL=$(uname -r)
SHELL_NAME=$(basename "$SHELL")

CPU=$(sysctl -n machdep.cpu.brand_string 2>/dev/null)
if [[ -z "$CPU" ]]; then
    CPU=$(system_profiler SPHardwareDataType |
          awk -F': ' '/Chip:/ {print $2; exit}')
fi

GPU=$(system_profiler SPDisplaysDataType |
      awk -F': ' '/Chipset Model:/ {print $2; exit}')

[[ -z "$CPU" ]] && CPU="Unknown"
[[ -z "$GPU" ]] && GPU="Unknown"

UPTIME=$(uptime | sed -E \
    's/^.* up (.*), [0-9]+ users?,.*$/\1/;
     s/^.* up (.*), load averages:.*$/\1/')

# Memory
MEM_TOTAL=$(sysctl -n hw.memsize)
PAGE_SIZE=$(pagesize)

MEM_USED_PAGES=$(vm_stat | awk '
    /Pages active:/ {a=$3}
    /Pages wired down:/ {w=$4}
    /Pages occupied by compressor:/ {c=$5}
    END {
        gsub(/\./,"",a)
        gsub(/\./,"",w)
        gsub(/\./,"",c)
        print a+w+c
    }')

MEM_USED=$((MEM_USED_PAGES * PAGE_SIZE))
MEM_PERCENT=$((MEM_USED * 100 / MEM_TOTAL))

MEM_USED_GB=$(awk -v n="$MEM_USED" \
    'BEGIN {printf "%.1f", n/1073741824}')

MEM_TOTAL_GB=$(awk -v n="$MEM_TOTAL" \
    'BEGIN {printf "%.0f", n/1073741824}')

# Disk: use the macOS Data volume
DISK_PATH="/System/Volumes/Data"
[[ ! -d "$DISK_PATH" ]] && DISK_PATH="/"

read -r DISK_TOTAL DISK_USED DISK_PERCENT < <(
    df -k "$DISK_PATH" | awk 'NR==2 {
        gsub("%","",$5)
        print $2, $3, $5
    }'
)

DISK_USED_GB=$(awk -v n="$DISK_USED" \
    'BEGIN {printf "%.1f", n/1048576}')

DISK_TOTAL_GB=$(awk -v n="$DISK_TOTAL" \
    'BEGIN {printf "%.0f", n/1048576}')

# Pink and white progress bar
progress_bar() {
    local percent=$1
    local width=20
    local filled=$((percent * width / 100))
    local empty=$((width - filled))

    (( filled > width )) && filled=$width
    (( filled < 0 )) && filled=0
    empty=$((width - filled))

    printf '['
    printf '%s' "$PINK"
    for ((j=0; j<filled; j++)); do printf '━'; done
    printf '%s' "$WHITE"
    for ((j=0; j<empty; j++)); do printf '━'; done
    printf '%s]' "$RESET"
}

MEM_BAR=$(progress_bar "$MEM_PERCENT")
DISK_BAR=$(progress_bar "$DISK_PERCENT")

# Rainbow color palette
rainbow() {
    local colors=(1 3 2 6 4 5 7 8)
    local bright=(9 11 10 14 12 13 15 0)
    local color
    local indent=$((ART_WIDTH + 3))

    # First row
    for color in "${colors[@]}"; do
        printf '\033[48;5;%sm     ' "$color"
    done
    printf '%s\n' "$RESET"

    # Align second row with first
    printf '%*s' "$indent" ''

    # Second row
    for color in "${bright[@]}"; do
        printf '\033[48;5;%sm     ' "$color"
    done
    printf '%s\n' "$RESET"
}
# System information lines
INFO=(
    "${PINK}${USER_NAME}${WHITE}@${HOST_NAME}${RESET}"
    "${PINK}────────────────────────────────────${RESET}"
    "${PINK}OS:${RESET}      ${WHITE}macOS ${OS_VERSION}${RESET}"
    "${PINK}Host:${RESET}    ${WHITE}${MODEL}${RESET}"
    "${PINK}Kernel:${RESET}  ${WHITE}${KERNEL}${RESET}"
    "${PINK}Shell:${RESET}   ${WHITE}${SHELL_NAME}${RESET}"
    "${PINK}CPU:${RESET}     ${WHITE}${CPU}${RESET}"
    "${PINK}GPU:${RESET}     ${WHITE}${GPU}${RESET}"
    "${PINK}Uptime:${RESET}  ${WHITE}${UPTIME}${RESET}"
    "${PINK}Memory:${RESET}  ${MEM_BAR} ${WHITE}${MEM_USED_GB} / ${MEM_TOTAL_GB} GB (${MEM_PERCENT}%)${RESET}"
    "${PINK}Disk:${RESET}    ${DISK_BAR} ${WHITE}${DISK_USED_GB} / ${DISK_TOTAL_GB} GB (${DISK_PERCENT}%)${RESET}"
)

# ASCII art — white only
ART=()
while IFS= read -r line; do
    ART+=("$line")
done <<'EOF'
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣠⣤⣤⣤⣄⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⣠⡶⠒⠒⠶⣄⣠⡴⠚⠉⠁⠀⠀⠀⠀⠀⠉⠙⠳⢦⡀⠀⠀⠀⠀⠀⠀
⢠⡏⠀⠀⠀⠀⠘⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢧⡀⠀⠀⠀⠀
⢸⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠋⢱⠀⠀⢠⠉⢡⠀⠀⠀⠀⠀⠻⡄⠀⠀⠀
⠀⣧⠀⠀⠀⠀⠀⠀⠀⠀⢸⣧⣾⠄⠀⢸⣦⣾⠀⠀⠀⠀⠀⠀⢻⡄⠀⠀
⠀⠘⢧⡀⠀⠀⠀⠀⠀⠀⠈⣿⣿⠀⠀⠸⣿⡿⠀⠀⠀⠀⠀⠀⠈⠳⣄⠀
⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠈⠁⡴⠶⡆⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠹⡄
⠀⠀⠀⢷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠒⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣷
⠀⠀⠀⠸⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠇
⠀⠀⠀⣀⡿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡽⣿⡛⠁⠀
⠀⣠⢾⣭⠀⠈⠳⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⠊⠀⢠⣝⣷⡀
⢠⡏⠘⠋⠀⠀⠀⠈⠑⠦⣄⣀⠀⠀⠀⠀⠀⣀⡠⠔⠋⠀⠀⠀⠈⠛⠃⢻
⠈⠷⣤⣀⣀⣀⣀⣀⣀⣀⣤⡽⠟⠛⠿⣭⣄⣀⣀⣀⣀⣀⣀⣀⣀⣀⣤⠞
⠀⠀⠀⠀⠉⠉⠉⠉⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠉⠉⠉⠉⠀⠀⠀
EOF

# Display side by side
# Braille characters and ideographic spaces need
# different display widths.
ART_WIDTH=0

for line in "${ART[@]}"; do
    line_width=$(printf '%s' "$line" |
        perl -CSDA -MUnicode::UCD=charinfo -ne '
            use utf8;
            my $width=0;
            for my $c (split //) {
                my $info=charinfo(ord($c));
                $width += ($info->{ea} =~ /^[WF]$/) ? 2 : 1;
            }
            print $width;
        ')

    (( line_width > ART_WIDTH )) && ART_WIDTH=$line_width
done

printf '\n'

ROWS=${#ART[@]}
(( ${#INFO[@]} > ROWS )) && ROWS=${#INFO[@]}

for ((i=0; i<ROWS; i++)); do
    art_line="${ART[$i]}"
    info_line="${INFO[$i]}"

    # Compute display width of the current art line
    line_width=$(printf '%s' "$art_line" |
        perl -CSDA -MUnicode::UCD=charinfo -ne '
            use utf8;
            my $width=0;
            for my $c (split //) {
                my $info=charinfo(ord($c));
                $width += ($info->{ea} =~ /^[WF]$/) ? 2 : 1;
            }
            print $width;
        ')

    padding=$((ART_WIDTH - line_width + 3))

    printf '%s%s%s' "$WHITE" "$art_line" "$RESET"
    printf '%*s' "$padding" ''
    printf '%b\n' "$info_line"
done

# Rainbow palette aligned with information

# Move cursor up 2 lines
printf '\033[2A'
# Align rainbow with system information
printf '\r\033[%dC' "$((ART_WIDTH + 3))"
rainbow

printf '\n\n'
