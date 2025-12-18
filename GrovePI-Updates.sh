#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

# Script om GrovePi+ software en firmware te updaten
# Werkt op Raspberry Pi OS / Debian 13
# Auteur: Rayen Jiwalal

echo "=== GrovePi+ Update Start ==="

# 1) Controleer of SPI en I2C zijn ingeschakeld
echo "Controleer of SPI en I2C zijn ingeschakeld..."
if ! grep -q "dtparam=i2c_arm=on" /boot/config.txt || ! grep -q "dtparam=spi=on" /boot/config.txt; then
  echo "⚠️ SPI en/of I2C lijken niet ingeschakeld te zijn."
  echo "  Voer: sudo raspi-config"
  echo "  Ga naar: Interfaces -> Enable SPI en I2C"
  exit 1
fi

# 2) Update / install repository
BASE_DIR="$HOME/Dexter/GrovePi"

echo "Update/installatie van GrovePi software..."

if [ ! -d "$BASE_DIR" ]; then
  echo "Repository niet gevonden, klonen..."
  mkdir -p "$HOME/Dexter"
  git clone https://github.com/DexterInd/GrovePi.git "$BASE_DIR"
else
  echo "Repository bestaat, fetch & reset..."
  cd "$BASE_DIR"
  sudo git fetch origin
  sudo git reset --hard origin/master
fi

cd "$BASE_DIR"

# 3) Optioneel: installeer dependencies of scripts
# (meestal handled door install.sh)
echo "Installeer GrovePi scripts en dependencies..."
if [ -f "Script/install.sh" ]; then
  sudo chmod +x Script/install.sh
  sudo Script/install.sh
fi

# 4) Firmware update
FIRMWARE_DIR="$BASE_DIR/Firmware"

echo "Firmware map: $FIRMWARE_DIR"

if [ -d "$FIRMWARE_DIR" ]; then
  cd "$FIRMWARE_DIR"
  echo "Maak firmware_update.sh uitvoerbaar..."
  sudo chmod +x firmware_update.sh

  echo "Start firmware update — zorg dat GrovePi+ correct is aangesloten..."
  sudo ./firmware_update.sh <<EOF
y
EOF

  echo "Firmware update voltooid."
else
  echo "❌ Firmware map niet gevonden: $FIRMWARE_DIR"
  exit 2
fi

echo "=== GrovePi+ Update Klaar ==="
