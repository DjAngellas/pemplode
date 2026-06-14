# PemPlode - a PKCS#12 Extraction Tool

A comprehensive bash script that automates the extraction of PEM files from PKCS#12 certificate files with robust dependency management and error handling.

# Highlights
- Automatic Dependency Management: Automatically detects and installs Python 3 and OpenSSL when missing
- Cross-Platform Support: Works on Linux (Ubuntu/Debian/CentOS/RHEL), macOS, and other Unix-like systems
- Flexible Input Methods: Accepts PFX file path as command-line argument or prompts interactively
- Secure Password Handling: Masks password input for security
- Robust Error Handling: Comprehensive validation and graceful error recovery
- Automation Ready: Designed for integration with CI/CD pipelines and automation scripts
- Multiple Output Formats: Creates all necessary PEM files for SSL/TLS configurations

# Features
- Extracts private key (privkey.pem)
- Extracts certificate (cert.crt)
- Extracts CA certificates (chain.crt)
- Combines certificate and chain into fullchain.pem
- Validates input files and dependencies
- Provides clear status messages and error reporting
- Clean temporary file management

# Prerequisites
- Bash shell
- Python 3 (automatically installed if missing)
- OpenSSL (automatically installed if missing)

# Entry Point
The main entry point is start.sh, which handles all dependencies and execution:
```
./start.sh
```
# Usage
## Interactive Mode
```
chmod +x start.sh
./start.sh
```
## Command-Line Mode
```
./start.sh /path/to/certificate.pfx
```
## With Password Supplied
```
./start.sh /path/to/certificate.pfx --password "your_password"
```
# Output Files
After successful execution, the following files will be created in the current directory:

- privkey.pem - Private key (unencrypted)
- cert.crt - Certificate
- chain.crt - CA certificates
- fullchain.pem - Combined certificate and chain

# Requirements
- Bash shell
- Python 3 (automatically installed if missing)
- OpenSSL (automatically installed if missing)

# Supported Operating Systems
- Ubuntu/Debian Linux
- CentOS/RHEL/Fedora Linux
- macOS
- Other Unix-like systems with package managers

# Interactive usage
```
./start.sh
```
# Automated usage with password
```
./start.sh /home/user/server.pfx --password "secure123"
```
# Using with CI/CD pipeline
```
echo "Extracting certificates..." && ./start.sh /etc/ssl/certs/server.pfx --password "$CERT_PASSWORD"
```

# Security Notes
- Password input is masked for security
- Temporary files are cleaned up automatically
- All dependencies are installed with appropriate permissions
- Script validates file paths before processing

# Integration
The script is designed for automation and can be easily integrated into:

- CI/CD pipelines
- Deployment scripts
- Configuration management tools
- Backup and recovery processes

# Troubleshooting
## Common Issues
### Permission Denied: 
- Ensure the script has execute permissions:<br/>
  ```
  chmod +x start.sh
  ```

## Dependency Installation Failed:<br/>
  Manual installation may be required:

### For Ubuntu/Debian
```
sudo apt-get update && sudo apt-get install python3 openssl
```
### For CentOS/RHEL
```
sudo yum install python3 openssl
```
## File Not Found:<br/>
  Verify the PFX file path exists and is accessible.

# License
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see https://www.gnu.org/licenses/.

# Directory Structure
project/<br/>
├── start.sh          # Main entry point script<br/>
└── extract_pem.py    # Python utility for PEM extraction<br/>

The start.sh script serves as the primary interface and handles all dependency management, making it easy to use without requiring manual setup of prerequisites.

# How to Contribute
Contributions are welcome! Please fork the repository and submit pull requests for improvements or bug fixes.

# Author Note
I'm totally not a coding guru, even a little bit.  Feel free to poke and prod and make better for the world.<br/>

"Make the world a bit better or more beautiful because you have lived in it." -Edward William Bok

Anyway, I couldn't find an easy tool to automate updating my PKI so this is the result.  This is packaged for ease of use and simplicity of deployment.  I hope it saves you time.

# Disclaimer
This tool is provided "as is" without any warranty. Use at your own risk. The authors are not responsible for any damage caused by the use of this tool.

Note: The script requires write permissions in the current directory to create output files.
