#!/bin/bash

# Set colors for output
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
BOLD="\033[1m"
NC="\033[0m"

# Define directory paths
SWARM_DIR="$HOME/rl-swarm"
TRAINING_DIR="$HOME/rl-swarm-training"
TEMP_DATA_PATH="$SWARM_DIR/modal-login/temp-data"
HOME_DIR="$HOME"
BACKUP_DIR="$HOME/rl-swarm-backup"
BACKUP_ZIP="$HOME/rl-swarm-backup.zip"
WEB_SERVE_DIR="/tmp/rl-swarm-serve"

# Default repository
TRAINING_REPO="https://github.com/namerose/rl-swarm.git"

# Function to serve files via HTTP for easy download
serve_files_via_http() {
    local files_to_serve="$1"
    local server_port=8085
    local timeout_seconds=600  # 10 minutes timeout
    
    # Create a temporary directory for serving files
    mkdir -p "$WEB_SERVE_DIR"
    
    # Copy the files to the serving directory
    cp "$files_to_serve" "$WEB_SERVE_DIR/"
    
    # Get the file name from the path
    file_name=$(basename "$files_to_serve")
    
    # Get server IP
    server_ip=$(hostname -I | cut -d' ' -f1)
    if [ -z "$server_ip" ]; then
        server_ip="localhost"
    fi
    
    echo -e "${GREEN}${BOLD}[✓] Starting HTTP server to serve backup files...${NC}"
    echo -e "${CYAN}${BOLD}[i] You can download your backup at: ${NC}"
    echo -e "${YELLOW}${BOLD}    http://$server_ip:$server_port/$file_name${NC}"
    echo -e "${CYAN}${BOLD}[i] Server will automatically shut down after $timeout_seconds seconds or when you press Ctrl+C${NC}"
    
    cd "$WEB_SERVE_DIR"
    
    # Start a simple HTTP server
    if command -v python3 &>/dev/null; then
        timeout $timeout_seconds python3 -m http.server $server_port
    elif command -v python &>/dev/null; then
        timeout $timeout_seconds python -m SimpleHTTPServer $server_port
    else
        echo -e "${RED}${BOLD}[✗] Python not found. Cannot start HTTP server.${NC}"
        echo -e "${YELLOW}${BOLD}[!] Your backup is available at: $files_to_serve${NC}"
        return 1
    fi
    
    echo -e "${GREEN}${BOLD}[✓] HTTP server stopped. Cleaning up...${NC}"
    rm -rf "$WEB_SERVE_DIR"
}

backup_swarm_files() {
    echo -e "${CYAN}${BOLD}[✓] Starting backup process...${NC}"
    
    # Check if swarm.pem exists
    if [ ! -f "$SWARM_DIR/swarm.pem" ]; then
        echo -e "${RED}${BOLD}[✗] Error: swarm.pem file not found in $SWARM_DIR${NC}"
        echo -e "${YELLOW}${BOLD}[!] Please run the installation first and complete the setup to generate the files.${NC}"
        return 1
    fi
    
    BACKUP_TEMP_DIR="$BACKUP_DIR/temp-data"
    
    echo -e "${CYAN}${BOLD}[✓] Creating backup directory at $BACKUP_DIR...${NC}"
    mkdir -p "$BACKUP_TEMP_DIR"
    
    echo -e "${CYAN}${BOLD}[✓] Backing up swarm.pem...${NC}"
    cp "$SWARM_DIR/swarm.pem" "$BACKUP_DIR/"
    
    if [ -d "$TEMP_DATA_PATH" ]; then
        echo -e "${CYAN}${BOLD}[✓] Backing up temp data files...${NC}"
        cp "$TEMP_DATA_PATH/userData.json" "$BACKUP_TEMP_DIR/" 2>/dev/null
        cp "$TEMP_DATA_PATH/userApiKey.json" "$BACKUP_TEMP_DIR/" 2>/dev/null
    fi
    
    echo -e "${CYAN}${BOLD}[✓] Creating zip archive of backup...${NC}"
    if command -v zip &>/dev/null; then
        cd "$HOME" && zip -r "$BACKUP_ZIP" "$(basename "$BACKUP_DIR")" > /dev/null
        echo -e "${GREEN}${BOLD}[✓] Backup zip created at: $BACKUP_ZIP${NC}"
        
        echo -e "${BOLD}${YELLOW}Do you want to make the backup available for download via web browser?${NC}"
        echo -e "${BOLD}1) Yes - Start a temporary web server to download the backup${NC}"
        echo -e "${BOLD}2) No - Keep the backup only on this server${NC}"
        
        while true; do
            read -p $'\e[1mEnter your choice (1 or 2): \e[0m' download_choice
            if [ "$download_choice" == "1" ]; then
                serve_files_via_http "$BACKUP_ZIP"
                break
            elif [ "$download_choice" == "2" ]; then
                echo -e "${YELLOW}${BOLD}[!] Backup is available locally at: $BACKUP_ZIP${NC}"
                break
            else
                echo -e "\n${BOLD}${RED}[✗] Invalid choice. Please enter 1 or 2.${NC}"
            fi
        done
    else
        echo -e "${YELLOW}${BOLD}[!] zip command not found. Installing zip utility...${NC}"
        sudo apt update && sudo apt install -y zip
        cd "$HOME" && zip -r "$BACKUP_ZIP" "$(basename "$BACKUP_DIR")" > /dev/null
        echo -e "${GREEN}${BOLD}[✓] Backup zip created at: $BACKUP_ZIP${NC}"
        
        echo -e "${BOLD}${YELLOW}Do you want to make the backup available for download via web browser?${NC}"
        echo -e "${BOLD}1) Yes - Start a temporary web server to download the backup${NC}"
        echo -e "${BOLD}2) No - Keep the backup only on this server${NC}"
        
        while true; do
            read -p $'\e[1mEnter your choice (1 or 2): \e[0m' download_choice
            if [ "$download_choice" == "1" ]; then
                serve_files_via_http "$BACKUP_ZIP"
                break
            elif [ "$download_choice" == "2" ]; then
                echo -e "${YELLOW}${BOLD}[!] Backup is available locally at: $BACKUP_ZIP${NC}"
                break
            else
                echo -e "\n${BOLD}${RED}[✗] Invalid choice. Please enter 1 or 2.${NC}"
            fi
        done
    fi
    
    echo -e "${GREEN}${BOLD}[✓] Backup completed successfully!${NC}"
    echo -e "${BLUE}${BOLD}[i] Files are backed up to: $BACKUP_DIR${NC}"
    echo -e "${BLUE}${BOLD}[i] To restore, you can use option 1 during installation.${NC}"
}

install_rl_swarm() {
    echo -e "${CYAN}${BOLD}[✓] Starting RL-Swarm installation process...${NC}"
    echo -e "${BLUE}${BOLD}[i] Repository: $TRAINING_REPO${NC}"

    cd $HOME
    echo -e "${CYAN}${BOLD}[✓] Working in home directory: $HOME${NC}"

    # Install sudo if not already installed
    echo -e "${CYAN}${BOLD}[✓] Updating system and installing sudo...${NC}"
    apt update && apt install -y sudo

    # Install basic dependencies
    echo -e "${CYAN}${BOLD}[✓] Installing required packages...${NC}"
    sudo apt update && sudo apt install -y python3 python3-venv python3-pip curl wget screen git lsof nano unzip iproute2

    # Create symlink for python
    if ! command -v python &>/dev/null && command -v python3 &>/dev/null; then
        echo -e "${CYAN}${BOLD}[✓] Creating symlink from python3 to python...${NC}"
        sudo ln -sf $(which python3) /usr/bin/python
        echo -e "${GREEN}${BOLD}[✓] Python symlink created: $(python --version)${NC}"
    fi

    # Install Node.js 20 and npm
    echo -e "${CYAN}${BOLD}[✓] Installing Node.js 20 and npm...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt install -y nodejs
    echo -e "${GREEN}${BOLD}[✓] Node.js $(node -v) and npm $(npm -v) installed successfully${NC}"

    echo -e "${CYAN}${BOLD}[✓] Setting up compiler tools...${NC}"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      if command -v apt &>/dev/null; then
        echo -e "${CYAN}${BOLD}[✓] Debian/Ubuntu detected. Installing build-essential, gcc, g++...${NC}"
        sudo apt update > /dev/null 2>&1
        sudo apt install -y build-essential gcc g++ > /dev/null 2>&1

      elif command -v yum &>/dev/null; then
        echo -e "${CYAN}${BOLD}[✓] RHEL/CentOS detected. Installing Development Tools...${NC}"
        sudo yum groupinstall -y "Development Tools" > /dev/null 2>&1
        sudo yum install -y gcc gcc-c++ > /dev/null 2>&1

      elif command -v pacman &>/dev/null; then
        echo -e "${CYAN}${BOLD}[✓] Arch Linux detected. Installing base-devel...${NC}"
        sudo pacman -Sy --noconfirm base-devel gcc > /dev/null 2>&1

      else
        echo -e "${YELLOW}${BOLD}[!] Linux detected but unsupported package manager.${NC}"
      fi

    elif [[ "$OSTYPE" == "darwin"* ]]; then
      echo -e "${CYAN}${BOLD}[✓] macOS detected. Installing Xcode Command Line Tools...${NC}"
      xcode-select --install > /dev/null 2>&1

    else
      echo -e "${YELLOW}${BOLD}[!] Unsupported OS: $OSTYPE. Continuing anyway...${NC}"
    fi

    if command -v gcc &>/dev/null; then
      export CC=$(command -v gcc)
      echo -e "${CYAN}${BOLD}[✓] Exported CC=$CC${NC}"
    else
      echo -e "${YELLOW}${BOLD}[!] gcc not found. CUDA installation may fail.${NC}"
    fi

    cd $HOME

    if [ -f "$SWARM_DIR/swarm.pem" ]; then
        echo -e "${BOLD}${YELLOW}You already have an existing ${GREEN}swarm.pem${YELLOW} file.${NC}\n"
        echo -e "${BOLD}${YELLOW}Do you want to:${NC}"
        echo -e "${BOLD}1) Use the existing swarm.pem and associated data${NC}"
        echo -e "${BOLD}${RED}2) Delete existing swarm.pem and start fresh${NC}"

        while true; do
            read -p $'\e[1mEnter your choice (1 or 2): \e[0m' choice
            if [ "$choice" == "1" ]; then
                echo -e "\n${BOLD}${YELLOW}[✓] Using existing swarm.pem...${NC}"
                # Backup existing files
                mv "$SWARM_DIR/swarm.pem" "$HOME_DIR/"
                mv "$TEMP_DATA_PATH/userData.json" "$HOME_DIR/" 2>/dev/null
                mv "$TEMP_DATA_PATH/userApiKey.json" "$HOME_DIR/" 2>/dev/null

                rm -rf "$SWARM_DIR"

                break
            elif [ "$choice" == "2" ]; then
                echo -e "${BOLD}${YELLOW}[✓] Removing existing folder and starting fresh...${NC}"
                rm -rf "$SWARM_DIR"
                break
            else
                echo -e "\n${BOLD}${RED}[✗] Invalid choice. Please enter 1 or 2.${NC}"
            fi
        done
    else
        echo -e "${BOLD}${YELLOW}[✓] No existing swarm.pem found. Proceeding with fresh installation...${NC}"
    fi

    echo -e "${CYAN}${BOLD}[✓] Cloning training repository into $TRAINING_DIR...${NC}"
    if [ -d "$TRAINING_DIR" ]; then
        echo -e "${YELLOW}${BOLD}[!] Training directory already exists. Updating...${NC}"
        cd "$TRAINING_DIR" && git pull
        cd $HOME
    else
        git clone "$TRAINING_REPO" "$TRAINING_DIR"
    fi

    echo -e "${CYAN}${BOLD}[✓] Cloning/checking main rl-swarm repository...${NC}"
    if [ ! -d "$SWARM_DIR" ]; then
        cd $HOME && git clone "$TRAINING_REPO" rl-swarm > /dev/null 2>&1
        echo -e "${GREEN}${BOLD}[✓] rl-swarm repository cloned successfully${NC}"
    else
        echo -e "${YELLOW}${BOLD}[!] rl-swarm directory already exists${NC}"
    fi

    if [ "$choice" == "1" ] && [ -f "$HOME_DIR/swarm.pem" ]; then
        echo -e "${BOLD}${YELLOW}[✓] Restoring saved swarm.pem and data files...${NC}"
        mkdir -p "$TEMP_DATA_PATH"
        mv "$HOME_DIR/swarm.pem" "$SWARM_DIR/"
        mv "$HOME_DIR/userData.json" "$TEMP_DATA_PATH/" 2>/dev/null
        mv "$HOME_DIR/userApiKey.json" "$TEMP_DATA_PATH/" 2>/dev/null
        echo -e "${GREEN}${BOLD}[✓] Files restored successfully${NC}"
    fi

    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    CUDA_SCRIPT=""
    for DIR in "$HOME/rl-swarm-training" "$HOME/rl-swarm" "$SCRIPT_DIR" "$(pwd)" "/rl-swarm"; do
      if [ -n "$DIR" ] && [ -f "$DIR/cuda.sh" ]; then
        CUDA_SCRIPT="$DIR/cuda.sh"
        break
      fi
    done

    echo -e "${CYAN}${BOLD}[✓] Looking for CUDA installation script...${NC}"
    if [ -f "$CUDA_SCRIPT" ]; then
        echo -e "${GREEN}${BOLD}[✓] Found CUDA script at: $CUDA_SCRIPT${NC}"
        
        echo -e "${CYAN}${BOLD}[✓] Fixing Windows line endings in CUDA script...${NC}"
        
        echo -e "${CYAN}${BOLD}[✓] Using sed to fix first line (shebang)...${NC}"
        sudo sed -i -e '1s/\r$//' "$CUDA_SCRIPT" 2>/dev/null || true
        
        echo -e "${CYAN}${BOLD}[✓] Creating a clean version of the script...${NC}"
        TMP_SCRIPT=$(mktemp)
        cat "$CUDA_SCRIPT" | tr -d '\r' > "$TMP_SCRIPT"
        sudo chmod +x "$TMP_SCRIPT"
        
        echo -e "${CYAN}${BOLD}[✓] Running CUDA installation...${NC}"
        sudo bash "$TMP_SCRIPT"
        rm "$TMP_SCRIPT"
    else
        echo -e "${RED}${BOLD}[✗] Could not find cuda.sh. CUDA installation skipped.${NC}"
        echo -e "${YELLOW}${BOLD}[!] Please make sure cuda.sh is in one of the repositories${NC}"
    fi

    RL_SWARM_SCRIPT=""
    for DIR in "$HOME/rl-swarm-training" "$HOME/rl-swarm" "$SCRIPT_DIR" "$(pwd)" "/rl-swarm"; do
      if [ -n "$DIR" ] && [ -f "$DIR/run_rl_swarm.sh" ]; then
        RL_SWARM_SCRIPT="$DIR/run_rl_swarm.sh"
        break
      fi
    done

    # Execute run_rl_swarm.sh and start RL-Swarm
    echo -e "${CYAN}${BOLD}[✓] Looking for RL-Swarm startup script...${NC}"
    if [ -f "$RL_SWARM_SCRIPT" ]; then
        echo -e "${GREEN}${BOLD}[✓] Found run_rl_swarm.sh at: $RL_SWARM_SCRIPT${NC}"
        sudo chmod +x "$RL_SWARM_SCRIPT"
        RL_SWARM_DIR="$(dirname "$RL_SWARM_SCRIPT")"
        
        echo -e "${CYAN}${BOLD}[✓] Creating optimized version of run_rl_swarm.sh...${NC}"
        MODIFIED_SCRIPT="${RL_SWARM_SCRIPT}.modified"
        
        cp "$RL_SWARM_SCRIPT" "$MODIFIED_SCRIPT"
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' 's/read -p ">> Enter option \[1-4\]: " tunnel_option/read -p ">> Enter option \[1-3\]: " tunnel_option # Avoid option 4 (Localtunnel) which can cause issues/' "$MODIFIED_SCRIPT"
        else
            sed -i 's/read -p ">> Enter option \[1-4\]: " tunnel_option/read -p ">> Enter option \[1-3\]: " tunnel_option # Avoid option 4 (Localtunnel) which can cause issues/' "$MODIFIED_SCRIPT"
        fi
        
        sudo chmod +x "$MODIFIED_SCRIPT"
        
        cd $HOME
        
        echo -e "${CYAN}${BOLD}[✓] Starting screen session named 'gensyn'...${NC}"
        echo -e "${YELLOW}${BOLD}[!] You can detach from the screen session using Ctrl+A+D${NC}"
        echo -e "${YELLOW}${BOLD}[!] You can reattach to the session using 'screen -r gensyn'${NC}"
        echo -e "${YELLOW}${BOLD}[!] IMPORTANT: Avoid selecting option 4 (Localtunnel) when prompted for tunneling - use options 1-3 instead${NC}"
        echo -e "${GREEN}${BOLD}[✓] Installation complete! Starting RL-Swarm in screen session...${NC}"

        screen -dmS gensyn bash -c "cd \"$RL_SWARM_DIR\" && \"$MODIFIED_SCRIPT\"; exec bash"
        
        echo -e "${GREEN}${BOLD}[✓] RL-Swarm is now running in a screen session named 'gensyn'${NC}"
        echo -e "${BLUE}${BOLD}[i] To view the running process, type: screen -r gensyn${NC}"
        echo -e "${BLUE}${BOLD}[i] Training files are located in: $TRAINING_DIR${NC}"
    else
        echo -e "${RED}${BOLD}[✗] Could not find run_rl_swarm.sh. Cannot start RL-Swarm.${NC}"
        echo -e "${YELLOW}${BOLD}[!] Please make sure run_rl_swarm.sh is in one of the repositories.${NC}"
    fi
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --training-repo=*)
      TRAINING_REPO="${1#*=}"
      shift
      ;;
    --help)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  --training-repo=URL    Specify the GitHub repository for training files (default: $TRAINING_REPO)"
      echo "  --help                 Display this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

echo -e "${BOLD}${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║            Oceans RL-Swarm             ║${NC}"
echo -e "${BOLD}${CYAN}╠════════════════════════════════════════╣${NC}"
echo -e "${BOLD}${CYAN}║                                        ║${NC}"
echo -e "${BOLD}${CYAN}║  ${GREEN}1) Install/Update RL-Swarm            ${CYAN}║${NC}"
echo -e "${BOLD}${CYAN}║  ${YELLOW}2) Backup swarm.pem and user data     ${CYAN}║${NC}"
echo -e "${BOLD}${CYAN}║                                        ║${NC}"
echo -e "${BOLD}${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""

while true; do
    read -p $'\e[1mEnter your choice (1 or 2): \e[0m' main_choice
    if [ "$main_choice" == "1" ]; then
        install_rl_swarm
        break
    elif [ "$main_choice" == "2" ]; then
        backup_swarm_files
        break
    else
        echo -e "\n${BOLD}${RED}[✗] Invalid choice. Please enter 1 or 2.${NC}"
    fi
done
