#!/usr/bin/env python3
import subprocess
import sys
import os
import argparse

def run_openssl_command(command, password):
    """Execute an OpenSSL command with the provided password."""
    try:
        process = subprocess.Popen(
            command,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        stdout, stderr = process.communicate(input=password + '\n')
        
        if process.returncode != 0:
            raise subprocess.CalledProcessError(
                process.returncode, 
                command, 
                output=stderr
            )
        return stdout
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"OpenSSL command failed: {' '.join(e.cmd)}\nError: {e.output}")

def extract_pem_files(pfx_file, password):
    """Extract private key, certificate, and chain files from PKCS#12 file."""
    
    # Validate input file exists
    if not os.path.exists(pfx_file):
        raise FileNotFoundError(f"PKCS#12 file '{pfx_file}' not found")
    
    # Extract private key (without certificates)
    print("Extracting private key...")
    run_openssl_command([
        'openssl', 'pkcs12', '-in', pfx_file, '-nocerts', '-nodes', '-out', 'privkey.pem'
    ], password)
    
    # Extract certificate only
    print("Extracting certificate...")
    run_openssl_command([
        'openssl', 'pkcs12', '-in', pfx_file, '-clcerts', '-nokeys', '-out', 'cert.crt'
    ], password)
    
    # Extract CA certificates
    print("Extracting CA certificates...")
    run_openssl_command([
        'openssl', 'pkcs12', '-in', pfx_file, '-cacerts', '-nokeys', '-out', 'chain.crt'
    ], password)
    
    # Combine certificate and chain into fullchain.pem
    print("Creating fullchain.pem...")
    try:
        with open('cert.crt', 'r') as cert_file, \
             open('chain.crt', 'r') as chain_file, \
             open('fullchain.pem', 'w') as fullchain_file:
            
            fullchain_file.write(cert_file.read())
            fullchain_file.write(chain_file.read())
    except IOError as e:
        raise RuntimeError(f"Failed to create fullchain.pem: {e}")

def main():
    parser = argparse.ArgumentParser(description='Extract PEM files from PKCS#12 certificate')
    parser.add_argument('pfx_file', help='Path to the PKCS#12 (.pfx) file')
    parser.add_argument('--password', help='Password for the PKCS#12 file')
    
    args = parser.parse_args()
    
    # Get password from argument or prompt user
    if args.password:
        password = args.password
    else:
        try:
            password = input("Enter PKCS#12 password: ")
        except KeyboardInterrupt:
            print("\nOperation cancelled by user")
            sys.exit(1)
        except Exception as e:
            print(f"Error reading password: {e}")
            sys.exit(1)
    
    try:
        # Validate required tools exist
        subprocess.run(['openssl', 'version'], 
                      stdout=subprocess.DEVNULL, 
                      stderr=subprocess.DEVNULL, 
                      check=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("Error: OpenSSL is not installed or not in PATH")
        sys.exit(1)
    
    try:
        extract_pem_files(args.pfx_file, password)
        print("Successfully extracted all PEM files:")
        print("- privkey.pem")
        print("- cert.crt")
        print("- chain.crt")
        print("- fullchain.pem")
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
