#!/bin/bash

EXTENSIONS=( "kgjfgplpablkjnlkjmjdecgdpfankdle" "aomjjhallfgjeglblehebfpbcfeobpgk" )

EXTENSIONS_DIR="/Library/Application Support/Google/Chrome/External Extensions"

if ! [ -d "$EXTENSIONS_DIR" ]; then
    sudo mkdir -p "$EXTENSIONS_DIR"
fi

EXTENSION_CODE=$(cat <<'EOF'
{
    "external_update_url": "https://clients2.google.com/service/update2/crx"
}
EOF
)

for i in "${EXTENSIONS[@]}"
do
    printf "$EXTENSION_CODE" | sudo tee "$EXTENSIONS_DIR/$i.json" > /dev/null
done
