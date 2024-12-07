#!/bin/bash

# Baixar Flutter
git clone https://github.com/flutter/flutter.git
export PATH="$PATH:`pwd`/flutter/bin"

# Configurar Flutter
flutter channel stable
flutter upgrade
flutter config --enable-web

# Build do projeto
flutter build web --release

# Copiar arquivos para diretório de publicação
cp -r build/web/* public/
