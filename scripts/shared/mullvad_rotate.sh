#!/bin/bash

# Configuration
CACHE_DIR="$HOME/.cache/vpn-checker"
URL=""
SERVICE_TYPE=""

# Create cache directory if it doesn't exist
mkdir -p "$CACHE_DIR"

# Check write permissions
if [ ! -w "$CACHE_DIR" ]; then
    echo "Error: Cannot write to cache directory $CACHE_DIR"
    exit 1
fi

# Function to ensure we're connected to VPN
ensure_vpn_connected() {
    local status_line

    # Try multiple times to get status
    for i in {1..3}; do
        status_line=$(mullvad status 2>/dev/null | head -n 1)
        if [ -n "$status_line" ]; then
            break
        fi
        sleep 1
    done

    # If still empty, assume not connected
    if [ -z "$status_line" ]; then
        echo "Could not determine VPN status. Attempting to connect..."
        status_line="Not connected"
    fi

    if [[ "$status_line" =~ ^"Connected" ]]; then
        # Already connected
        return 0
    fi

    echo "Not connected to VPN (status: $status_line). Connecting..."
    mullvad connect

    # Wait for connection
    local attempts=0
    while [ $attempts -lt 12 ]; do
        for i in {1..3}; do
            status_line=$(mullvad status 2>/dev/null | head -n 1)
            if [ -n "$status_line" ]; then
                break
            fi
            sleep 1
        done

        if [ -z "$status_line" ]; then
            status_line="Status unknown"
        fi

        if [[ "$status_line" =~ ^"Connected" ]]; then
            echo "Successfully connected to VPN"
            sleep 1  # Give connection a moment to stabilize
            return 0
        fi
        echo "Waiting for connection (current status: $status_line)..."
        sleep 1
        ((attempts++))
    done
    echo "Failed to establish VPN connection"
    return 1
}

# Function to check if a URL is accessible
check_url() {
    local url=$1
    local timeout=10

    case "$SERVICE_TYPE" in
        "reddit")
            curl -s --max-time $timeout -I "$url" | head -n 1 | grep -q "HTTP/[0-9.]\+ [23]"
            ;;
        "youtube")
            # Use dump-json to check if we can access video metadata
            # This will fail explicitly when YouTube shows the bot check page
            if ! yt-dlp --no-warnings --dump-json "$url" &> /dev/null; then
                return 1
            fi
            return 0
            ;;
        *)
            echo "Unknown service type"
            exit 1
            ;;
    esac
}

# Function to get current VPN IP
get_current_ip() {
    for i in {1..3}; do
        local ip
        ip=$(mullvad status 2>/dev/null | grep -oP 'Your connection appears to be from:.* IPv4: \K[0-9.]+')
        if [ -n "$ip" ]; then
            echo "$ip"
            return 0
        fi
        sleep 1
    done
    echo ""
    return 1
}

# Function to get exit IP
get_exit_ip() {
    for i in {1..3}; do
        echo "Debug: Attempt $i to get exit IP" >&2
        local status_output
        status_output=$(mullvad status 2>/dev/null)

        echo "Debug: Raw mullvad status output:" >&2
        echo "$status_output" >&2

        local ip

        # Match the new format: "Visible location: Country, City. IPv4: X.X.X.X"
        echo "Debug: Trying 'Visible location' pattern..." >&2
        ip=$(echo "$status_output" | grep -oP 'Visible location:.*IPv4: \K[0-9.]+')
        if [ -n "$ip" ]; then
            echo "Debug: Found IP using Visible location pattern: $ip" >&2
            echo "$ip"
            return 0
        fi

        echo "Debug: No IP found with pattern" >&2
        sleep 1
    done

    echo "Debug: Failed to get IP after all attempts" >&2
    echo ""
    return 1
}

# Function to get cache file path for a service
get_cache_file() {
    local service=$1
    echo "${CACHE_DIR}/failed_ips_${service}.txt"
}

# Function to inspect cache
inspect_cache() {
    if [ -n "$SERVICE_TYPE" ]; then
        local cache_file
        cache_file=$(get_cache_file "$SERVICE_TYPE")
        echo "Current failed endpoints for $SERVICE_TYPE:"
        if [ -f "$cache_file" ] && [ -s "$cache_file" ]; then
            while IFS=':' read -r ip server_name timestamp; do
                local current_time
                current_time=$(date +%s)
                local age=$((current_time - timestamp))
                local minutes=$((age/60))
                if [ $minutes -eq 0 ]; then
                    echo "$server_name ($ip) - failed less than a minute ago"
                else
                    echo "$server_name ($ip) - failed $minutes minute(s) ago"
                fi
            done < "$cache_file"
        else
            echo "No failed endpoints recorded for $SERVICE_TYPE"
        fi
    else
        echo "All failed endpoints:"
        for f in "$CACHE_DIR"/failed_ips_*.txt; do
            if [ -f "$f" ]; then
                service=${f##*failed_ips_}
                service=${service%.txt}
                echo "=== $service ==="
                if [ -s "$f" ]; then
                    while IFS=':' read -r ip server_name timestamp; do
                        local current_time
                        current_time=$(date +%s)
                        local age=$((current_time - timestamp))
                        local minutes=$((age/60))
                        if [ $minutes -eq 0 ]; then
                            echo "$server_name ($ip) - failed less than a minute ago"
                        else
                            echo "$server_name ($ip) - failed $minutes minute(s) ago"
                        fi
                    done < "$f"
                else
                    echo "No failed endpoints"
                fi
                echo
            fi
        done
    fi
}

# Function to clear cache
clear_cache() {
    if [ -n "$SERVICE_TYPE" ]; then
        local cache_file
        cache_file=$(get_cache_file "$SERVICE_TYPE")
        > "$cache_file"
        echo "Cleared cache for $SERVICE_TYPE"
    else
        rm -f "$CACHE_DIR"/failed_ips_*.txt
        echo "Cleared all caches"
    fi
}

# Function to mark IP as failed in cache
mark_ip_as_failed() {
    local ip=$1
    local server_name=$2
    local service=$3
    local cache_file
    cache_file=$(get_cache_file "$service")

    if [ -z "$ip" ] || [ -z "$service" ] || [ -z "$server_name" ]; then
        echo "Error: Missing required parameters for mark_ip_as_failed"
        return 1
    fi

    # Create the cache file if it doesn't exist
    touch "$cache_file"

    # Remove any existing entry for this IP
    if [ -f "$cache_file" ]; then
        sed -i "/^$ip:/d" "$cache_file"
    fi

    # Add new entry with current timestamp and server name
    echo "$ip:$server_name:$(date +%s)" >> "$cache_file"
    echo "Marked $server_name ($ip) as failed at $(date)"
}

# Function to get WireGuard relays for a region
get_wireguard_relays() {
    local region=$1
    echo "Getting relays for region: $region" >&2
    mullvad relay list | grep "wg-" | grep "$region" | while read -r line; do
        if [[ $line =~ ([a-z0-9-]+)[[:space:]]*\(([0-9.]+) ]]; then
            echo "${BASH_REMATCH[1]} ${BASH_REMATCH[2]}"
        fi
    done
}

get_server_exit_ip() {
    local server_name=$1
    local cache_file=$2

    if [ ! -f "$cache_file" ]; then
        return 1
    fi

    # Get the most recent IP used by this server
    grep ":$server_name:" "$cache_file" | tail -n 1 | cut -d':' -f1
}

is_ip_failed() {
    local ip=$1
    local service=$2
    local cache_file
    cache_file=$(get_cache_file "$service")

    if [ ! -f "$cache_file" ]; then
        return 1
    fi

    # Check if IP exists in cache and get its timestamp
    while IFS=':' read -r cached_ip cached_server cached_ts; do
        if [ "$cached_ip" = "$ip" ]; then
            local current_time
            current_time=$(date +%s)
            local age=$((current_time - cached_ts))

            # If IP has failed in the last 30 minutes, skip it
            if [ $age -lt 1800 ]; then
                echo "Skipping $ip (failed $((age/60)) minutes ago)"
                return 0
            else
                # Remove old entry as we'll retry it
                sed -i "/^$ip:/d" "$cache_file"
                echo "Retrying $ip (last failure was $((age/60)) minutes ago)"
                return 1
            fi
        fi
    done < "$cache_file"

    return 1
}

shuffle_array() {
    local array=("$@")
    local i j temp
    for ((i = ${#array[@]} - 1; i > 0; i--)); do
        j=$((RANDOM % (i + 1)))
        temp="${array[$i]}"
        array[$i]="${array[$j]}"
        array[$j]="$temp"
    done
    printf '%s\n' "${array[@]}"
}



# Function to try different VPN endpoints with multihop
try_endpoints() {
    local entry_regions=("se")
    local exit_regions=("se" "no" "dk" "fi" "de" "nl" "gb")

    # Setup multihop
    echo "Setting up WireGuard multihop..."
    mullvad relay set tunnel-protocol wireguard
    mullvad relay set tunnel wireguard --use-multihop on

    # Shuffle entry regions
    mapfile -t shuffled_entry_regions < <(shuffle_array "${entry_regions[@]}")

    for entry_region in "${shuffled_entry_regions[@]}"; do
        echo "Trying entry points in $entry_region..."

        mapfile -t cities < <(get_wireguard_relays "$entry_region" | cut -d'-' -f2 | sort -u)
        mapfile -t shuffled_cities < <(shuffle_array "${cities[@]}")

        for city in "${shuffled_cities[@]}"; do
            echo "Setting entry point: $entry_region $city"
            mullvad relay set tunnel wireguard entry location "$entry_region" "$city"

            # Shuffle exit regions
            mapfile -t shuffled_exit_regions < <(shuffle_array "${exit_regions[@]}")

            for exit_region in "${shuffled_exit_regions[@]}"; do
                echo "Trying exit points in $exit_region..."

                # Collect all valid exit points first
                declare -a valid_exits=()
                while IFS=' ' read -r server_name server_ip || [ -n "$server_name" ]; do
                    [ -z "$server_name" ] && continue

                    local cached_exit_ip
                    cached_exit_ip=$(get_server_exit_ip "$server_name" "$(get_cache_file "$SERVICE_TYPE")")

                    if [ -n "$cached_exit_ip" ]; then
                        if is_ip_failed "$cached_exit_ip" "$SERVICE_TYPE"; then
                            continue
                        fi
                    fi

                    valid_exits+=("$server_name $server_ip")
                done < <(get_wireguard_relays "$exit_region")

                # Shuffle valid exits
                mapfile -t shuffled_exits < <(shuffle_array "${valid_exits[@]}")

                for exit_info in "${shuffled_exits[@]}"; do
                    read -r server_name server_ip <<< "$exit_info"

                    echo "Trying endpoint: $server_name ($server_ip)"
                    city_code=$(echo "$server_name" | cut -d'-' -f2)

                    echo "Setting exit location to $exit_region $city_code $server_name..."
                    mullvad relay set location "$exit_region" "$city_code" "$server_name"

                    echo "Current relay settings:"
                    mullvad relay get

                    # Ensure we're connected with new settings
                    if ! ensure_vpn_connected; then
                        echo "Failed to connect with this endpoint configuration"
                        continue
                    fi

                    # Test the connection multiple times with delays
                    local max_attempts=1
                    local attempt=1
                    local success=false

                    while [ $attempt -le $max_attempts ]; do
                        echo "Attempt $attempt of $max_attempts..."
                        if check_url "$URL"; then
                            echo "Success! Connected through $server_name"
                            success=true
                            break
                        else
                            echo "Failed attempt $attempt"
                            if [ $attempt -lt $max_attempts ]; then
                                echo "Waiting before next attempt..."
                                sleep 1
                            fi
                        fi
                        ((attempt++))
                    done

                    if $success; then
                        return 0
                    else
                        echo "Failed all attempts with this endpoint"
                        local exit_ip
                        exit_ip=$(get_exit_ip)
                        if [ -n "$exit_ip" ]; then
                            echo "Marking exit IP $exit_ip as failed"
                            mark_ip_as_failed "$exit_ip" "$server_name" "$SERVICE_TYPE"
                        else
                            echo "Warning: Could not determine exit IP"
                        fi
                    fi
                done
            done
        done
    done

    return 1
}

# Main script
usage() {
    echo "Usage: $0 [-u URL] [-s SERVICE_TYPE] [-i] [-c]"
    echo "SERVICE_TYPE can be 'reddit' or 'youtube'"
    echo "Options:"
    echo "  -u URL          Target URL to check"
    echo "  -s SERVICE_TYPE Type of service (reddit/youtube)"
    echo "  -i              Inspect cache contents"
    echo "  -c              Clear cache"
    exit 1
}

while getopts "u:s:ic" opt; do
    case $opt in
        u) URL="$OPTARG" ;;
        s) SERVICE_TYPE="$OPTARG" ;;
        i) inspect_cache; exit 0 ;;
        c) clear_cache; exit 0 ;;
        *) usage ;;
    esac
done

if [ -z "$URL" ] || [ -z "$SERVICE_TYPE" ]; then
    usage
fi

echo "Checking access to $URL..."

# First ensure VPN is connected
if ! ensure_vpn_connected; then
    echo "Failed to establish VPN connection. Exiting."
    exit 1
fi

if check_url "$URL"; then
    echo "URL is already accessible!"
    exit 0
fi

echo "URL is not accessible. Will try different endpoints..."

if try_endpoints; then
    echo "Successfully found working endpoint!"
else
    echo "Failed to find working endpoint after trying all regions"
    exit 1
fi