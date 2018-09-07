
#!/bin/bash


localAccts=$(dscl . list /Users UniqueID | awk '$2>500{print $1}' | grep -v simpleit)

while read account; do
    echo "Making sure $account is not in the local admin group"
    dseditgroup -o edit -d $account admin
done < <(echo "$localAccts")

exit
