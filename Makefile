VERSION = 0.0


PORT ?= /dev/ttyUSB0
BAUD ?= 115200

LUAC_CROSS = luac.cross
NODEMCU_TOOL = nodemcu-tool.js -p $(PORT) -b $(BAUD)
ESPTOOL = esptool.py -p $(PORT) -b $(BAUD) --no-stub
CP = cp -r
RM = rm -fr
MD = mkdir -p

LFS_IMG = lfs.img
FIRMWARE_SPAR = firmware.spar
FIRMWARE_DIR = firmware
SOURCE_DIR = source
SOURCE_FILES = $(shell find $(SOURCE_DIR) -type f -name '*.lua')
HTTP_DIR = http
HTTP_FILES = $(shell find $(HTTP_DIR) -type f)


.SUFFIXES:

.DEFAULT_GOAL := all
.PHONY: all
all: $(FIRMWARE_SPAR)

$(LFS_IMG): $(SOURCE_FILES)
	$(LUAC_CROSS) -p $(SOURCE_FILES)
	$(LUAC_CROSS) -f -s -o $(LFS_IMG) $(SOURCE_FILES)

$(FIRMWARE_DIR): $(HTTP_FILES)
	$(RM) $(FIRMWARE_DIR)
	$(MD) $(FIRMWARE_DIR)
	$(CP) $(HTTP_DIR) $(FIRMWARE_DIR)
	
$(FIRMWARE_SPAR): $(LFS_IMG) $(FIRMWARE_DIR)
	$(RM) $(FIRMWARE_DIR)/$(LFS_IMG)
	$(CP) $(LFS_IMG) $(FIRMWARE_DIR) 
	tool/make_spar.py $(FIRMWARE_SPAR) $(VERSION) $(FIRMWARE_DIR)

.PHONY: clean
clean:
	$(RM) $(LFS_IMG) $(FIRMWARE_DIR) $(FIRMWARE_SPAR)


.PHONY: reset
reset:
	$(NODEMCU_TOOL) reset

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


.PHONY: upload_lfs_img
upload_lfs_img: $(LFS_IMG)
	$(NODEMCU_TOOL) remove $(LFS_IMG).new
	$(NODEMCU_TOOL) upload $(LFS_IMG) -n $(LFS_IMG).new

.PHONY: upload_firmware_spar
upload_http_spar: $(FIRMWARE_SPAR)
	$(NODEMCU_TOOL) remove $(FIRMWARE_SPAR).new
	$(NODEMCU_TOOL) upload $(FIRMWARE_SPAR) -n $(FIRMWARE_SPAR).new

.PHONY: reload
reload: upload_lfs_img reset


.PHONY: first_setup
first_setup: $(FIRMWARE_SPAR) mkfs extra/first_setup.lua
	$(NODEMCU_TOOL) upload $(LFS_IMG)
	$(NODEMCU_TOOL) upload $(FIRMWARE_SPAR)
	$(NODEMCU_TOOL) upload extra/first_setup.lua
	$(NODEMCU_TOOL) run first_setup.lua

.PHONY: secret_upload
secret_upload: extra/secret.lua
	$(NODEMCU_TOOL) upload extra/secret.lua

.PHONY: secret_run
secret_run:
	$(NODEMCU_TOOL) run secret.lua

.PHONY: secret_remove
secret_remove:
	$(NODEMCU_TOOL) remove secret.lua

.PHONY: secret
secret: secret_upload secret_run

.PHONY: reinit
reinit:
	$(NODEMCU_TOOL) remove config.data
