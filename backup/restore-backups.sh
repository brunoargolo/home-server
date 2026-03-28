#!/bin/bash

################################################################################
# Media PC Backup Restore Script
# Restores Docker service backups to /media/bruno/docker-volumes/
# Usage: ./restore-backups.sh [service1] [service2] ... or ./restore-backups.sh all
################################################################################

set -e

# Configuration
BACKUP_DIR="/media/bruno/seagate-portable-drive/Backup"
VOLUMES_DIR="$HOME/docker-volumes"
DOCKER_UID=1000
DOCKER_GID=1000

# Available services (excluding plex and immich)
AVAILABLE_SERVICES=("radarr" "sonarr" "prowlarr" "overseerr" "qbittorrent" "bazarr")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

usage() {
    cat << EOF
Usage: $0 [OPTIONS]

OPTIONS:
    all                      Restore all services
    [service_name]           Restore specific service(s)
    --list                   List available services
    --verify                 Verify backup files exist
    --help                   Show this help message

EXAMPLES:
    $0 all                           # Restore all services
    $0 radarr sonarr                 # Restore radarr and sonarr only
    $0 --verify                      # Check if all backup files are present
    $0 --list                        # Show available services

SERVICES:
    ${AVAILABLE_SERVICES[@]}

EOF
    exit 0
}

list_services() {
    echo -e "\n${BLUE}Available services:${NC}"
    for service in "${AVAILABLE_SERVICES[@]}"; do
        echo "  - $service"
    done
    echo ""
}

verify_backups() {
    print_header "Verifying Backup Files"
    
    if [ ! -d "$BACKUP_DIR" ]; then
        print_error "Backup directory not found: $BACKUP_DIR"
        return 1
    fi
    
    local all_exist=true
    
    for service in "${AVAILABLE_SERVICES[@]}"; do
        local backup_file="$BACKUP_DIR/${service}-backup.zip"
        
        # Special case for qbittorrent
        if [ "$service" = "qbittorrent" ]; then
            backup_file="$BACKUP_DIR/qTorrent-backup.zip"
        fi
        
        if [ -f "$backup_file" ]; then
            local size=$(du -h "$backup_file" | cut -f1)
            print_success "$service: $backup_file ($size)"
        else
            print_error "$service: $backup_file NOT FOUND"
            all_exist=false
        fi
    done
    
    if [ "$all_exist" = true ]; then
        echo ""
        print_success "All backup files verified!"
        return 0
    else
        echo ""
        print_error "Some backup files are missing!"
        return 1
    fi
}

create_directories() {
    for service in "$@"; do
        local dir="$VOLUMES_DIR/$service"
        sudo mkdir -p "$dir"
    done
}

extract_backup() {
    local service=$1
    local backup_file="$BACKUP_DIR/${service}-backup.zip"
    local target_dir="$VOLUMES_DIR/$service"
    
    # Special case for qbittorrent - extract to qBittorrent subdirectory
    if [ "$service" = "qbittorrent" ]; then
        backup_file="$BACKUP_DIR/qTorrent-backup.zip"
        target_dir="$VOLUMES_DIR/$service/qBittorrent"
    fi
    
    if [ ! -f "$backup_file" ]; then
        print_error "Backup file not found: $backup_file"
        return 1
    fi
    
    echo -n "Extracting $service... "
    
    # Create target directory if it doesn't exist
    sudo mkdir -p "$target_dir"
    
    # Clear existing content
    sudo rm -rf "${target_dir:?}"/*
    
    # Extract (unzip returns 1 for warnings like backslash paths, which are non-fatal)
    sudo unzip -q -o -d "$target_dir" "$backup_file" 2>&1 | grep -v "warning" || true
    
    # Check if files were actually extracted
    local file_count=$(sudo find "$target_dir" -type f -o -type d 2>/dev/null | wc -l)
    
    if [ "$file_count" -gt 1 ]; then
        print_success "$service extracted"
        return 0
    else
        print_error "Failed to extract $service (no files found)"
        return 1
    fi
}

set_permissions() {
    local service=$1
    local dir="$VOLUMES_DIR/$service"
    
    echo -n "Setting permissions for $service... "
    
    if sudo chown -R $DOCKER_UID:$DOCKER_GID "$dir" && sudo chmod -R 755 "$dir"; then
        print_success "Permissions set for $service"
        return 0
    else
        print_error "Failed to set permissions for $service"
        return 1
    fi
}

restore_service() {
    local service=$1
    local dir="$VOLUMES_DIR/$service"
    
    # Special case for qbittorrent - shows qBittorrent subdirectory
    if [ "$service" = "qbittorrent" ]; then
        dir="$VOLUMES_DIR/$service/qBittorrent"
    fi
    
    print_header "Restoring $service"
    echo -e "Destination: ${BLUE}$dir${NC}"
    echo ""
    
    if ! extract_backup "$service"; then
        return 1
    fi
    
    if ! set_permissions "$service"; then
        return 1
    fi
    
    return 0
}

restore_all_services() {
    print_header "Restoring All Services"
    
    create_directories "${AVAILABLE_SERVICES[@]}"
    
    echo ""
    
    local failed_services=()
    
    for service in "${AVAILABLE_SERVICES[@]}"; do
        if ! restore_service "$service"; then
            failed_services+=("$service")
        fi
        echo ""
    done
    
    if [ ${#failed_services[@]} -eq 0 ]; then
        print_success "All services restored successfully!"
        return 0
    else
        print_error "Failed to restore: ${failed_services[*]}"
        return 1
    fi
}

show_summary() {
    print_header "Restore Summary"
    
    for service in "${AVAILABLE_SERVICES[@]}"; do
        local dir="$VOLUMES_DIR/$service"
        if [ -d "$dir" ]; then
            local size=$(du -sh "$dir" 2>/dev/null | cut -f1)
            local file_count=$(find "$dir" -type f 2>/dev/null | wc -l)
            echo -e "${GREEN}$service${NC}: $size ($file_count files)"
        fi
    done
    
    echo ""
    print_success "Restore complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Update docker-compose.yml with volume paths"
    echo "  2. Run: docker compose up -d"
    echo "  3. Check logs: docker compose logs -f"
    echo ""
}

################################################################################
# Main Script
################################################################################

main() {
    # No arguments provided
    if [ $# -eq 0 ]; then
        usage
    fi
    
    # Parse arguments
    case "$1" in
        --help|-h)
            usage
            ;;
        --list|-l)
            list_services
            exit 0
            ;;
        --verify|-v)
            verify_backups
            exit $?
            ;;
        all)
            restore_all_services
            exit_code=$?
            if [ $exit_code -eq 0 ]; then
                show_summary
            fi
            exit $exit_code
            ;;
        *)
            # Restore specific services
            local services_to_restore=()
            local invalid_services=()
            
            for arg in "$@"; do
                if [[ " ${AVAILABLE_SERVICES[@]} " =~ " ${arg} " ]]; then
                    services_to_restore+=("$arg")
                else
                    invalid_services+=("$arg")
                fi
            done
            
            if [ ${#invalid_services[@]} -gt 0 ]; then
                print_error "Unknown service(s): ${invalid_services[*]}"
                echo ""
                list_services
                exit 1
            fi
            
            if [ ${#services_to_restore[@]} -eq 0 ]; then
                usage
            fi
            
            print_header "Restoring Services: ${services_to_restore[*]}"
            
            create_directories "${services_to_restore[@]}"
            echo ""
            
            for service in "${services_to_restore[@]}"; do
                restore_service "$service"
                echo ""
            done
            
            show_summary
            ;;
    esac
}

main "$@"
