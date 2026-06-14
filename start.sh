#!/bin/bash

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect OS and install dependencies
install_dependencies() {
    echo "Checking for required dependencies..."
    
    # Check for Python 3
    if ! command_exists python3; then
        echo "Python 3 not found. Installing..."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            if command_exists apt-get; then
                sudo apt-get update
                sudo apt-get install -y python3
            elif command_exists yum; then
                sudo yum install -y python3
            elif command_exists dnf; then
                sudo dnf install -y python3
            else
                echo "Error: Could not determine package manager"
                exit 1
            fi
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            if ! command_exists brew; then
                echo "Please install Homebrew first: https://brew.sh/"
                exit 1
            fi
            brew install python
        else
            echo "Error: Unsupported OS for automatic dependency installation"
            exit 1
        fi
    fi
    
    # Check for OpenSSL
    if ! command_exists openssl; then
        echo "OpenSSL not found. Installing..."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            if command_exists apt-get; then
                sudo apt-get update
                sudo apt-get install -y openssl
            elif command_exists yum; then
                sudo yum install -y openssl
            elif command_exists dnf; then
                sudo dnf install -y openssl
            else
                echo "Error: Could not determine package manager"
                exit 1
            fi
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS has OpenSSL by default
            echo "OpenSSL already available on macOS"
        else
            echo "Error: Unsupported OS for automatic dependency installation"
            exit 1
        fi
    fi
    
    echo "All dependencies satisfied."
}

# Function to get PFX file path interactively
get_pfx_path_interactive() {
    while true; do
        read -p "Enter the path to your PKCS#12 (.pfx) file: " pfx_path
        if [[ -f "$pfx_path" ]]; then
            echo "$pfx_path"
            return 0
        else
            echo "File not found. Please try again."
        fi
    done
}

# Function to validate PFX file
validate_pfx_file() {
    local pfx_path="$1"
    if [[ ! -f "$pfx_path" ]]; then
        echo "Error: File '$pfx_path' does not exist."
        return 1
    fi
    
    # Check if it's actually a PFX file (basic check)
    if [[ "${pfx_path,,}" != *.pfx ]] && [[ "${pfx_path,,}" != *.p12 ]]; then
        echo "Warning: File extension suggests it might not be a PKCS#12 file"
    fi
    
    return 0
}

# Function to get password interactively
get_password() {
    read -s -p "Enter the password for the PKCS#12 file: " password
    echo
    echo "$password"
}

# Function to run the Python script
run_extraction() {
    local pfx_path="$1"
    local password="$2"
    
    echo "Running extraction with: $pfx_path"
    
    # Create a temporary directory for the Python script
    temp_dir=$(mktemp -d)
    cp "$(dirname "$0")/extract_pem.py" "$temp_dir/"
    
    # Run the Python script with the specified parameters
    python3 "$temp_dir/extract_pem.py" "$pfx_path" --password "$password"
    
    # Clean up
    rm -rf "$temp_dir"
    
    if [[ $? -eq 0 ]]; then
        echo "Extraction completed successfully!"
        echo "Output files created:"
        ls -la privkey.pem cert.crt chain.crt fullchain.pem 2>/dev/null || echo "No output files created"
    else
        echo "Extraction failed!"
        exit 1
    fi
}

# Main execution
main() {
    echo "PKCS#12 Extraction Tool"
    echo "======================="
    
    # Check and install dependencies
    install_dependencies
    
    # Get PFX file path
    if [[ $# -gt 0 ]]; then
        # Use first argument as PFX path
        pfx_path="$1"
        if ! validate_pfx_file "$pfx_path"; then
            exit 1
        fi
    else
        # Interactive mode
        echo ""
        echo "PFX File Selection:"
        pfx_path=$(get_pfx_path_interactive)
    fi
    
    # Get password
    password=$(get_password)
    
    # Run extraction
    run_extraction "$pfx_path" "$password"
}

# Parse arguments and call main
if [[ $# -eq 0 ]]; then
    # No arguments, use interactive mode
    main
else
    # Arguments provided, run with those arguments
    main "$@"
fi
