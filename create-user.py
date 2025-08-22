#!/usr/bin/env python3
"""
Simple script to create users for Radicale authentication.
This script generates bcrypt hashed passwords for the users file.
"""

import bcrypt
import getpass
import os
import sys

def create_user():
    """Create a new user with bcrypt hashed password."""
    print("Radicale User Creation Tool")
    print("=" * 30)
    
    # Get username
    username = input("Enter username: ").strip()
    if not username:
        print("Username cannot be empty!")
        return False
    
    # Get password
    password = getpass.getpass("Enter password: ")
    if not password:
        print("Password cannot be empty!")
        return False
    
    # Confirm password
    password_confirm = getpass.getpass("Confirm password: ")
    if password != password_confirm:
        print("Passwords do not match!")
        return False
    
    # Generate hash
    print("Generating password hash...")
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
    
    # Create user entry
    user_entry = f"{username}:{hashed.decode()}"
    
    # Determine users file path (container vs host)
    if os.path.exists("/etc/radicale/users"):
        users_file = "/etc/radicale/users"
    else:
        users_file = "config/users"
        # Create config directory if it doesn't exist
        os.makedirs("config", exist_ok=True)
    
    # Check if users file exists and ask about appending
    if os.path.exists(users_file):
        append = input(f"Users file '{users_file}' exists. Append to it? (y/N): ").lower().strip()
        mode = 'a' if append == 'y' else 'w'
    else:
        mode = 'w'
        print(f"Creating new users file: {users_file}")
    
    # Write to users file
    try:
        with open(users_file, mode) as f:
            if mode == 'w':
                f.write("# Radicale users file\n")
                f.write("# Format: username:password_hash\n")
            f.write(f"{user_entry}\n")
        
        print(f"✅ User '{username}' {'added to' if mode == 'a' else 'created in'} {users_file}")
        print(f"📝 User entry: {user_entry}")
        return True
        
    except Exception as e:
        print(f"❌ Error writing to users file: {e}")
        return False

def main():
    """Main function."""
    if len(sys.argv) > 1 and sys.argv[1] in ['-h', '--help']:
        print(__doc__)
        print("\nUsage: python3 create-user.py")
        print("\nThis script will:")
        print("1. Prompt for username and password")
        print("2. Generate a bcrypt hash")
        print("3. Save to config/users file")
        return
    
    try:
        while True:
            if create_user():
                another = input("\nCreate another user? (y/N): ").lower().strip()
                if another != 'y':
                    break
            else:
                retry = input("\nTry again? (y/N): ").lower().strip()
                if retry != 'y':
                    break
        
        print("\n✅ Done! You can now start your Radicale container.")
        print("💡 Run: docker-compose up -d")
        
    except KeyboardInterrupt:
        print("\n\n👋 Goodbye!")
    except Exception as e:
        print(f"\n❌ Unexpected error: {e}")

if __name__ == "__main__":
    main()
