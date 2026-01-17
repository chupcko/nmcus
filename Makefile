VERSION = 0.0


PORT ?= /dev/ttyUSB0
BAUD ?= 115200


LUAC_CROSS = luac.cross
NODEMCU_TOOL = nodemcu-tool.js -p $(PORT) -b $(BAUD)
ESPTOOL = esptool.py -p $(PORT) -b $(BAUD) --no-stub
RM = rm -f


LFS_IMG = lfs.img
HTTP_SPAR = http.spar
SOURCE = source
SOURCE_FILES = $(shell find $(SOURCE) -type f -name '*.lua')
HTTP = http
HTTP_FILES = $(shell find $(HTTP) -type f)


.SUFFIXES:

.DEFAULT_GOAL := all
.PHONY: all
all: $(LFS_IMG) $(HTTP_SPAR)

$(LFS_IMG): $(SOURCE_FILES)
	$(LUAC_CROSS) -p $(^)
	$(LUAC_CROSS) -f -s -o $(@) $(^)
	
$(HTTP_SPAR): $(HTTP_FILES)
	tool/make_spar.py $(@) $(VERSION) $(HTTP)

.PHONY: clean
clean:
	$(RM) $(LFS_IMG) $(HTTP_SPAR)

.PHONY: upload_lfs_img
upload_lfs_img: $(LFS_IMG)
	$(NODEMCU_TOOL) upload $(<) -n $(<).new

.PHONY: upload_http_spar
upload_http_spar: $(HTTP_SPAR)
	$(NODEMCU_TOOL) upload $(<)

.PHONY: upload
upload: upload_lfs_img upload_http_spar

.PHONY: reload
reload: upload_lfs_img reset


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


.PHONY: first_setup
first_setup: mkfs upload extra/first_setup.lua
	$(NODEMCU_TOOL) upload extra/first_setup.lua
	$(NODEMCU_TOOL) run first_setup.lua
	$(NODEMCU_TOOL) remove first_setup.lua

.PHONY: secret_upload
secret_upload: extra/secret.lua
	$(NODEMCU_TOOL) upload extra/secret.lua

.PHONY: secret_run
secret_run:
	$(NODEMCU_TOOL) run secret.lua

.PHONY: secret
secret: secret_upload secret_run

.PHONY: reinit
reinit:
	$(NODEMCU_TOOL) remove config.data
