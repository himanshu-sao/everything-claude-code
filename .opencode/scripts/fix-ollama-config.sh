#!/bin/bash

# fix-ollama-config.sh
#
# A script to automate the maintenance and synchronization of Ollama model configurations
# within the opencode environment, making it easier to onboard new models.

set -e

OPENCODE_JSON_PATH="/Users/himanshusao/.config/opencode/opencode.json"
AGENT_DIR="/Users/himanshusao/Work/src/extra/himanshu-sao/everything-claude-code/.opencode/agents"
SCRIPT_DIR="/Users/himanshusao/Work/src/extra/himanshu-sao/everything-claude-code/.opencode/scripts"

# --- Pre-checks ---

check_dependencies() {
    echo "-> Checking required dependencies..."
    if ! command -v ollama &> /dev/null; then
        echo "🚨 ERROR: 'ollama' command not found. Please ensure Ollama is installed and running."
        exit 1
    fi
    if ! command -v fzf &> /dev/null; then
        echo "🚨 ERROR: 'fzf' command not found. Please install it (e.g., brew install fzf)."
        exit 1
    fi
    if ! command -v jq &> /dev/null; then
        echo "🚨 ERROR: 'jq' (JSON processor) not found. Please install it (e.g., brew install jq)."
        exit 1
    fi
    echo "✅ Dependencies checked successfully."
}

# --- Core Functions ---

# 1. Get and parse all available models from Ollama
get_available_models() {
    echo ""
    echo "========================================"
    echo "🌐 STEP 1: Listing Available Ollama Models"
    echo "========================================"
    
    # Run ollama list and filter for model names
    ollama list | tail -n +2 | awk '{print $1}' | tr -d '\r\n' | sort -u | tr '\n' ',' | sed 's/,$//'
}

# 2. Load current config and agent assignments
load_all_mappings() {
    echo ""
    echo "========================================"
    echo "📖 STEP 2: Analyzing Current Configurations"
    echo "========================================"

    # 2a. Get current stored config (only model names/providers for now)
    if [[ -f "$OPENCODE_JSON_PATH" ]]; then
        cat "$OPENCODE_JSON_PATH" | jq -r '.provider.ollama.models | keys[]' | tr '\n' ' '
    else
        echo "⚠️ WARNING: $OPENCODE_JSON_PATH not found. Skipping structured comparison."
    fi

    # 2b. Get all agent model assignments
    grep -E '^  Line 5: model:' "$AGENT_DIR"/*.md | awk -F': ' '{print $2}' | tr '\n' ',' | sed 's/,$//'
}


# --- Main Interactive Logic ---

main_menu() {
    echo ""
    echo "======================================================================"
    echo "✨ Opencode Ollama Model Configuration Assistant ✨"
    echo "======================================================================"
    echo "Before modifying any file, remember to BACKUP the original: cp $OPENCODE_JSON_PATH $OPENCODE_JSON_PATH.bak"
    echo ""
    echo "What do you want to do?"
    
    # Interactive menu using fzf
    SELECTED_OPTION=$(echo -e "1) Add/Update Models\n2) Fix Agent Model Mappings\n3) Review Rebalancing Suggestions\n4) Quit and Exit" | fzf --prompt="[opencode] > ")

    case "$SELECTED_OPTION" in
        1*)
            echo ""
            echo "--- Running Model Discovery & Addition Menu ---"
            # Placeholder for actual interactive logic 
            echo "Implementing Model Addition Menu..."
            # Actual implementation will use get_available_models and build a fzf interface.
            ;;
        2*)
            echo ""
            echo "--- Running Agent Model Mapping Fix Menu ---"
            # Placeholder for actual interactive logic
            echo "Implementing Agent Model Fix Menu..."
            # Will compare grep results with current config.
            ;;
        3*)
            echo ""
            echo "--- Running Model Rebalancing Preview ---"
            # Placeholder for actual interactive logic
            echo "Implementing Rebalance Preview Menu..."
            # Will analyze distribution found by the grep step.
            ;;
        4*)
            echo "Exiting script on user request. Goodbye!"
            ;;
    esac
}

# --- Execution ---

check_dependencies

# Placeholder for the actual execution flow in a real interactive tool
echo ""
echo "######################################################################"
echo "Script setup complete. Initializing main interactive menu..."
echo "######################################################################"
main_menu