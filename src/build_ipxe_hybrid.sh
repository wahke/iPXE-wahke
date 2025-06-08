#!/bin/bash

set -e

# Farben für Lesbarkeit
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}🧼 Schritt 1: make clean...${NC}"
make clean

echo -e "${GREEN}🔧 Schritt 2: iPXE bauen (BIOS)...${NC}"
make bin/ipxe.lkrn EMBED=embedded.ipxe

echo -e "${GREEN}🔧 Schritt 3: iPXE bauen (UEFI)...${NC}"
make bin-x86_64-efi/ipxe.efi EMBED=embedded.ipxe

echo -e "${GREEN}📁 Schritt 4: Verzeichnisstruktur anlegen...${NC}"
mkdir -p ~/ipxe-iso/boot/grub
mkdir -p ~/ipxe-iso/EFI/BOOT

echo -e "${GREEN}📄 Schritt 5: Dateien kopieren...${NC}"
cp bin/ipxe.lkrn ~/ipxe-iso/ipxe.lkrn
cp bin-x86_64-efi/ipxe.efi ~/ipxe-iso/EFI/BOOT/BOOTX64.EFI

echo -e "${GREEN}🖋 Schritt 6: GRUB-Konfiguration erstellen...${NC}"
cat <<EOF > ~/ipxe-iso/boot/grub/grub.cfg
set timeout=0
set default=0

menuentry "iPXE BIOS Boot" {
    linux16 /ipxe.lkrn
}

menuentry "iPXE UEFI Boot" {
    chainloader /EFI/BOOT/BOOTX64.EFI
}
EOF

echo -e "${GREEN}📦 Schritt 7: ISO erzeugen...${NC}"
grub-mkrescue -o ipxe-hybrid.iso ~/ipxe-iso --modules="linux16 chain"

echo -e "${GREEN}✅ Fertig! Deine ISO: ${NC}ipxe-hybrid.iso"
