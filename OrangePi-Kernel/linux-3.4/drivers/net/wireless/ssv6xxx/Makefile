KMODULE_NAME=ssv6051

KBUILD_TOP := drivers/net/wireless/ssv6xxx
ifeq ($(MAKELEVEL),0)
KBUILD_TOP := .
endif

include $(KBUILD_TOP)/ssv6051.cfg
include $(KBUILD_TOP)/platform-config.mak

# Generate version strings
# GEN_VER := $(shell cd $(KBUILD_TOP); ./ver_info.pl include/ssv_version.h)
# Generate -wifi.cfg
#BKP_CFG := $(shell cp $(KBUILD_TOP)/ssv6051-wifi.cfg $(KBUILD_TOP)/image/$(KMODULE_NAME)-wifi.cfg)

EXTRA_CFLAGS := -I$(KBUILD_TOP) -I$(KBUILD_TOP)/include

KERN_SRCS := ssvdevice/ssvdevice.c
KERN_SRCS += ssvdevice/ssv_cmd.c

KERN_SRCS += hci/ssv_hci.c

KERN_SRCS += ssv6200smac/init.c
KERN_SRCS += ssv6200smac/dev.c
KERN_SRCS += ssv6200smac/ssv_rc.c
KERN_SRCS += ssv6200smac/ssv_ht_rc.c
KERN_SRCS += ssv6200smac/ap.c
KERN_SRCS += ssv6200smac/ampdu.c
KERN_SRCS += ssv6200smac/ssv6xxx_debugfs.c
KERN_SRCS += ssv6200smac/sec_ccmp.c
KERN_SRCS += ssv6200smac/sec_tkip.c
KERN_SRCS += ssv6200smac/sec_wep.c
KERN_SRCS += ssv6200smac/wapi_sms4.c
KERN_SRCS += ssv6200smac/sec_wpi.c
KERN_SRCS += ssv6200smac/efuse.c
KERN_SRCS += ssv6200smac/ssv_pm.c

KERN_SRCS += hwif/sdio/sdio.c

ifeq ($(findstring -DCONFIG_SSV_SUPPORT_AES_ASM, $(ccflags-y)), -DCONFIG_SSV_SUPPORT_AES_ASM)
KERN_SRCS += crypto/aes_glue.c
KERN_SRCS += crypto/sha1_glue.c
KERN_SRCS_S := crypto/aes-armv4.S
KERN_SRCS_S += crypto/sha1-armv4-large.S
endif

KERN_SRCS += ssv6051-generic-wlan.c

$(KMODULE_NAME)-y += $(KERN_SRCS_S:.S=.o)
$(KMODULE_NAME)-y += $(KERN_SRCS:.c=.o)

obj-$(CONFIG_SSV6XXX) += $(KMODULE_NAME).o

export CONFIG_SSV6XXX=m

.PHONY: all ver modules clean

all: modules
	
modules:
	$(MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) -C $(KSRC) M=$(shell pwd) modules

strip:
	$(CROSS_COMPILE)strip $(MODULE_NAME).ko --strip-unneeded

#install:
#	install -p -m 644 $(MODULE_NAME).ko  $(MODDESTDIR)
#	/sbin/depmod -a ${KVER}
#
#uninstall:
#	rm -f $(MODDESTDIR)/$(MODULE_NAME).ko
#	/sbin/depmod -a ${KVER}

clean:
	rm -fr *.mod.c *.mod *.o .*.cmd *.ko *~
	rm -fr .tmp_versions
	rm -fr Module.symvers
	rm -fr Module.markers
	rm -fr modules.order
	cd ssvdevice/; 		rm -fr *.mod.c *.mod *.o .*.cmd *.ko
	cd hci/; 			rm -fr *.mod.c *.mod *.o .*.cmd *.ko
	cd ssv6200smac/; 	rm -fr *.mod.c *.mod *.o .*.cmd *.ko
	cd hwif/; 			rm -fr *.mod.c *.mod *.o .*.cmd *.ko
	cd hwif/sdio/; 			rm -fr *.mod.c *.mod *.o .*.cmd *.ko
	cd crypto/; 		rm -fr *.mod.c *.mod *.o .*.cmd *.ko
	

