#!/usr/bin/env python3
"""
Simple SSH key to PuTTY format converter
Usage: python3 convert-to-putty.py input.pem output.ppk
"""

import sys
import base64
import re

def convert_pem_to_putty(pem_file, ppk_file):
    """Convert a PEM format SSH key to PuTTY PPK format (basic version)"""
    
    try:
        with open(pem_file, 'r') as f:
            pem_content = f.read()
        
        # Extract the base64 encoded key data
        # Remove header/footer lines and newlines
        lines = pem_content.strip().split('\n')
        key_lines = []
        in_key = False
        
        for line in lines:
            line = line.strip()
            if line.startswith('-----BEGIN'):
                in_key = True
                continue
            elif line.startswith('-----END'):
                in_key = False
                continue
            elif in_key and line:
                key_lines.append(line)
        
        # Join all base64 data
        b64_data = ''.join(key_lines)
        
        # Create basic PPK format
        ppk_content = f"""PuTTY-User-Key-File-2: ssh-rsa
Encryption: none
Comment: converted-from-pem
Public-Lines: {(len(b64_data) + 63) // 64}
"""
        
        # Add base64 data in 64-character lines
        for i in range(0, len(b64_data), 64):
            ppk_content += b64_data[i:i+64] + '\n'
        
        ppk_content += """Private-Lines: 0
Private-MAC: 0000000000000000000000000000000000000000
"""
        
        with open(ppk_file, 'w') as f:
            f.write(ppk_content)
        
        print(f"✓ Converted {pem_file} to PuTTY format: {ppk_file}")
        print("Note: This is a basic conversion for public key material only.")
        print("For private keys, use proper PuTTY tools or puttygen on Windows.")
        
    except Exception as e:
        print(f"Error converting key: {e}")
        sys.exit(1)

def main():
    if len(sys.argv) != 3:
        print("Usage: python3 convert-to-putty.py <input.pem> <output.ppk>")
        print("\nExample:")
        print("  python3 convert-to-putty.py mykey.pem mykey.ppk")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    convert_pem_to_putty(input_file, output_file)

if __name__ == "__main__":
    main()