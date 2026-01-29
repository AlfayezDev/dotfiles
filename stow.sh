rm -rf .config
cp -r ./config ./.config
stow --adopt -v -t "$HOME" .
