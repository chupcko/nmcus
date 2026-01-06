PORT = /dev/ttyUSB0
BAUD = 115200

LUAC_CROSS = luac.cross
NODEMCU_TOOL = nodemcu-tool.js -p $(PORT) -b $(BAUD)
ESPTOOL = esptool.py -p $(PORT) -b $(BAUD) --no-stub
RM = rm -rf


LFS_IMG = lfs.img
SOURCES = $(wildcard source/*.lua)

.SUFFIXES:

.DEFAULT_GOAL := all
.PHONY: all
all: $(LFS_IMG)

$(LFS_IMG): $(SOURCES)
	$(LUAC_CROSS) -p $(^)
	$(LUAC_CROSS) -f -s -o $(@) $(^)

.PHONY: clean
clean:
	$(RM) $(LFS_IMG)

.PHONY: upload
upload: $(LFS_IMG)
	$(NODEMCU_TOOL) upload $(<) -n $(<).new

.PHONY: reset
reset:
	$(NODEMCU_TOOL) reset

.PHONY: reload
reload: upload reset

.PHONY: terminal
terminal:
	$(NODEMCU_TOOL) terminal

.PHONY: hwinfo
hwinfo:
	$(ESPTOOL) chip_id
	$(ESPTOOL) flash_id

.PHONY: fsinfo
fsinfo:
	$(NODEMCU_TOOL) fsinfo

.PHONY: mkfs
mkfs:
	$(NODEMCU_TOOL) mkfs --noninteractive

.PHONY: first_setup
first_setup: mkfs upload
	$(NODEMCU_TOOL) upload first_setup.lua
	$(NODEMCU_TOOL) run first_setup.lua
	$(NODEMCU_TOOL) remove first_setup.lua

.PHONY: secret
secret:
	$(NODEMCU_TOOL) upload secret.lua
	$(NODEMCU_TOOL) run secret.lua
