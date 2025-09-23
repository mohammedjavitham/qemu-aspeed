# QEMU wrapper for aspeed evb
## Usage
```shell
# Tested using Ubuntu 24.04
1. sudo apt update && sudo apt install libfdt1 libslirp0
2. git clone https://github.com/mohammedjavitham/qemu-aspeed.git
3. cd qemu-aspeed
4. chmod +x qemu-aspeed.sh

# For AST2600EVB
5. cp <openbmc_workspace>/<build_dir>/evb-ast2600/tmp/deploy/images/evb-ast2600/image-bmc .
6. ./qemu-aspeed.sh -i image-bmc -m 2600 -w 1234
7. Web UI access -> https://localhost:1234
8. Press Ctrl + a then x to terminate QEMU session
```

### AST2600EVB 128M SPI image support

4.1 Modify the script with following changes after step 4

```diff
--- a/qemu-aspeed.sh
+++ b/qemu-aspeed.sh
@@ -68,7 +68,7 @@ ast2600() {

check_qemu

-./qemu-system-aarch64 -M ast2600-evb \
+./qemu-system-aarch64 -M ast2600-evb,fmc-model=w25q01jvq,spi-model=w25q01jvq \
      -m 1024 \
      -nographic \
      -drive file=${IMGDIR},format=raw,if=mtd \
```

List of available SPI models can be found here - https://github.com/qemu/qemu/blob/ab8008b231e758e03c87c1c483c03afdd9c02e19/hw/block/m25p80.c#L365C13-L365C22
