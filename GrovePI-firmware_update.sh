#!/usr/bin/env bash


# Script om GrovePi+ software en firmware te updaten
# Werkt op Raspberry Pi OS / Debian 13
#Auteur : Rayen Jiwalal

echo "=== GrovePi+ Update Start ==="

sudo apt update


# 1) Update / install repository
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

# 2) Optioneel: installeer dependencies of scripts
# (meestal handled door install.sh)
echo "Installeer GrovePi scripts en dependencies..."
if [ -f "Script/install.sh" ]; then
  sudo chmod +x Script/install.sh
  sudo Script/install.sh
fi


# voorbereiding voor Firmware Update

#!/usr/bin/env bash
set -e

echo "ðŸ“¦ Verwijder bestaande avrdude (indien aanwezig)..."
sudo apt remove -y avrdude || true

echo "ðŸ“¥ Installeer build dependencies..."
sudo apt update
sudo apt install -y build-essential flex bison gcc libusb-dev libftdi-dev libhidapi-dev libpthread-stubs0-dev libelf-dev

echo "â¬‡ï¸ Download avrdude 6.1 broncode..."
cd /tmp
wget http://download.savannah.gnu.org/releases/avrdude/avrdude-6.1.tar.gz
tar xzf avrdude-6.1.tar.gz
cd avrdude-6.1

echo "ðŸ©¹ Fix printf bug in linuxgpio.c (indien nodig)..."
sed -i 's/%ud/%u/g' ./linuxgpio.c

echo "âš™ï¸ Configureer met GPIO-ondersteuning..."
./configure --enable-linuxgpio

echo "ðŸ”¨ Compileer avrdude..."
make

echo "ðŸ“¦ Installeer avrdude..."
sudo make install

echo "ðŸ§© Voeg linuxgpio programmer toe aan avrdude.conf..."
CONF_PATH="/usr/local/etc/avrdude.conf"
if ! grep -q "linuxgpio" "$CONF_PATH"; then
cat <<EOF | sudo tee -a "$CONF_PATH" > /dev/null

# GrovePi linuxgpio programmer
programmer
  id    = "linuxgpio";
  desc  = "Use the Linux sysfs interface to bitbang GPIO lines";
  type  = "linuxgpio";
  reset = 22;
  sck   = 11;
  mosi  = 10;
  miso  = 9;
;
EOF
fi

echo "âœ… Avrdude met linuxgpio ondersteuning is klaar!"
echo "â„¹ï¸ Test met: sudo avrdude -c linuxgpio -p m328p -v"






# 3) Firmware update
FIRMWARE_DIR="$BASE_DIR/Firmware"

echo "Firmware map: $FIRMWARE_DIR"

if [ -d "$FIRMWARE_DIR" ]; then
  cd "$FIRMWARE_DIR"
  echo "Maak firmware_update.sh uitvoerbaar..."
  sudo chmod +x firmware_update.sh

  echo "Start firmware update â€” zorg dat GrovePi+ correct is aangesloten..."
  sudo ./firmware_update.sh <<EOF
y
EOF

  echo "Firmware update voltooid."
else
  echo "âŒ Firmware map niet gevonden: $FIRMWARE_DIR"
  exit 2
fi

echo "=== GrovePi+ Update Klaar ==="