# QEMU wrapper for aspeed evb
## Usage
```shell
1. git clone https://github.com/mohammedjavitham/qemu-aspeed.git
2. cd qemu-aspeed
3. chmod +x qemu-aspeed.sh

# For AST2600EVB
4. cp <openbmc_workspace>/<build_dir>/evb-ast2600/tmp/deploy/images/evb-ast2600/image-bmc .
5. ./qemu-aspeed.sh -i image-bmc -m 2600 -w 1234
6. Web UI access -> https://localhost:1234
7. Press Ctrl + a then x to terminate QEMU session
```
