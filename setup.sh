#!/bin/zsh

# Check if brew is installed
if command -v brew >/dev/null 2>&1; then
    echo "brew is already installed."
else
    echo "Installing brew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install Ruby build dependencies
echo "Installing Ruby build dependencies..."
brew install libyaml openssl

# Check if mise is installed
if command -v mise >/dev/null 2>&1; then
    echo "mise is already installed."
else
    echo "Installing mise..."
    brew install mise
fi

echo "Trusting mise config files..."
mise trust .

echo "Installing tools from .mise.toml..."
mise install

echo "Installing Ruby gems..."
mise x -- gem install bundler
mise x -- bundle install

echo "Setup complete."
