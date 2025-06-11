#!/bin/bash

MACHINE="2700"
WEBPORT="4443"
SSHPORT="2223"
SOLPORT="2200"
IMGDIR="ast2700-default"

print_usage() {
  printf "\n===================================================================="
  printf "\n QEMU wrapper for ASPEED EVB                                        "
  printf "\n===================================================================="
  printf "\n Author         : Mohammed Javith Akthar M                          "
  printf "\n Script Version : 1.0                                               "
  printf "\n--------------------------------------------------------------------"
  printf "\n Usage                                                              "
  printf "\n                                                                    "
  printf "\n -m/--machine   : 2600, 2700(default)                               "
  printf "\n                                                                    "
  printf "\n -i/--img       : MTD image path for AST2600                        "
  printf "\n                : ast2700-default folder path for AST2700 (default) "
  printf "\n                                                                    "
  printf "\n -w/--webport   : BMC web access port. default 4443                 "
  printf "\n                                                                    "
  printf "\n -s/--sshport   : BMC ssh access port. default 2223                 "
  printf "\n===================================================================="
  printf "\n"
}

check_qemu() {
  if ! [[ -f "qemu-system-aarch64" ]] ; then
	  printf "\nqemu-system-aarch64 not found in ${PWD} !!\nDownloading latest from github.com/mohammedjavitham/latest-qemu\n"
	  get_latest_qemu
  fi
}

get_latest_qemu() {
  curl -s https://api.github.com/repos/mohammedjavitham/latest-qemu/releases/latest \
  | grep "browser_download_url.*64" \
  | cut -d : -f 2,3 \
  | tr -d \" \
  | wget -qi -

  chmod +x qemu-system-aarch64
}

ast2700() {
UBOOT_SIZE=$(stat --format=%s -L ${IMGDIR}/u-boot-nodtb.bin)

check_qemu

./qemu-system-aarch64 -M ast2700-evb \
     -device loader,force-raw=on,addr=0x400000000,file=${IMGDIR}/u-boot-nodtb.bin \
     -device loader,force-raw=on,addr=$((0x400000000 + ${UBOOT_SIZE})),file=${IMGDIR}/u-boot.dtb \
     -device loader,force-raw=on,addr=0x430000000,file=${IMGDIR}/bl31.bin \
     -device loader,force-raw=on,addr=0x430080000,file=${IMGDIR}/optee/tee-raw.bin \
     -device loader,cpu-num=0,addr=0x430000000 \
     -device loader,cpu-num=1,addr=0x430000000 \
     -device loader,cpu-num=2,addr=0x430000000 \
     -device loader,cpu-num=3,addr=0x430000000 \
     -smp 4 \
     -drive file=${IMGDIR}/image-bmc,format=raw,if=mtd \
     -nographic \
     -net nic,macaddr=F8:63:3F:66:95:11 \
     -net nic -net user,hostfwd=:0.0.0.0:${WEBPORT}-:443,hostfwd=:0.0.0.0:${SSHPORT}-:22,hostname=qemu
}

ast2600() {

check_qemu

./qemu-system-aarch64 -M ast2600-evb \
     -m 1024 \
     -nographic \
     -drive file=${IMGDIR},format=raw,if=mtd \
     -net nic,macaddr=F8:63:3F:66:95:11 \
     -net nic -net user,hostfwd=:0.0.0.0:${WEBPORT}-:443,hostfwd=:0.0.0.0:${SSHPORT}-:22,hostfwd=:0.0.0.0:${SOLPORT}-:2200,hostname=qemu \
     -serial mon:stdio \
     -serial telnet:localhost:5067,server,nowait
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -m|--machine)
      MACHINE="$2"
      shift # past argument
      shift # past value
      ;;
    -w|--webport)
      WEBPORT="$2"
      shift # past argument
      shift # past value
      ;;
    -s|--sshport)
      SSHPORT="$2"
      shift # past argument
      shift # past value
      ;;
    -i|--img)
      IMGDIR="$2"
      shift # past argument
      shift # past value
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    -*|--*)
      printf "\nUnknown option $1\n\n"
      print_usage
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

if [[ "$MACHINE" == "2600" ]] || [[ "$MACHINE" == "2700" ]] ; then

  if [[ "$MACHINE" == "2600" ]] && [[ -f "$IMGDIR" ]] ; then
    ast2600
  elif [[ "$MACHINE" == "2700" ]] && [[ -d "$IMGDIR" ]] ; then
    ast2700
  else
    printf "\nInvalid IMGDIR : ${IMGDIR}\n\n"
    print_usage
  fi

else
  printf "\nInvalid MACHINE : ${MACHINE}\n\n"
  print_usage
fi
