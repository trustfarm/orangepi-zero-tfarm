
KVERSION="`uname -r`"
#DRVPATH=/lib/modules/$(KVERSION)/kernel/drivers/net/wireless/ssv6200
DRVPATH=kernel/drivers/net/wireless/ssv6200
KCFLAG += -Werror
EXTRA_CFLAGS := -I$(KBUILD_TOP) -I$(KBUILD_TOP)/include


###########################################################################
# Compiler options                                                        #
###########################################################################
ccflags-y += -Werror

# Enable -g to help debug. Deassembly from .o to .S would help to track to 
# the problomatic line from call stack dump.
ccflags-y += -g


###########################################################
# option to :qswitch driver between relay device and sw mac device
# Enable ->Relay device	(CHAR)
# Disable->SW MAC device(NET)

#DRV_OPT = HUW_DRV

CONFIG_SSV6200_CORE=m
#ccflags-y += -DCONFIG_SSV6200_CORE

############################################################
# If you change the settings, please change the file synchronization
# ssv6200smac\firmware\include\config.h & compiler firmware
############################################################
#ccflags-y += -DCONFIG_SSV_CABRIO_A
ccflags-y += -DCONFIG_SSV_CABRIO_E

#CONFIG_SSV_SUPPORT_BTCX=y

ccflags-y += -DCONFIG_SSV6200_CLI_ENABLE

#ccflags-y += -DCONFIG_SSV_BUILD_AS_ONE_KO
ccflags-y += -DCONFIG_SSV_WAPI


############################################################
# Options should be able to set as parameters.             #
############################################################

############################################################
# FPGA XTAL = 40
# UBUNTU DEMO BOARD = 26
############################################################
#XTAL setting(24.26.40)
ccflags-y += -DSSV_XTAL=26
#volt regulator(DCDC-1 LDO-0)
ccflags-y += -DSSV_VOLT_REGULATOR=1

#PADPD
#ccflags-y += -DCONFIG_SSV_DPD

#ccflags-y += -DCONFIG_SSV_CABRIO_MB_DEBUG
ccflags-y += -DCONFIG_SSV6XXX_DEBUGFS

#SDIO
ccflags-y += -DCONFIG_SSV_TX_LOWTHRESHOLD

############################################################
# Rate control update for MPDU.
############################################################
ccflags-y += -DRATE_CONTROL_REALTIME_UPDATA

#workaround
#ccflags-y += -DCONFIG_SSV_CABRIO_EXT_PA

############################################################
# NOTE:
#    Only one of the following flags could be turned on.
# It also turned off the following flags. In this case, 
# pure software security or pure hardware security is used.
#
############################################################
#ccflags-y += -DCONFIG_SSV_SW_ENCRYPT_HW_DECRYPT
#ccflags-y += -DCONFIG_SSV_HW_ENCRYPT_SW_DECRYPT

# FOR WFA
#ccflags-y += -DWIFI_CERTIFIED

#ccflags-y += -DCONFIG_SSV_SDIO_EXT_INT

#######################################################
ccflags-y += -DCONFIG_SSV6200_HAS_RX_WORKQUEUE
ccflags-y += -DUSE_THREAD_RX
ccflags-y += -DUSE_THREAD_TX
ccflags-y += -DENABLE_AGGREGATE_IN_TIME
ccflags-y += -DENABLE_INCREMENTAL_AGGREGATION

# Generic decision table applicable to both AP and STA modes.
ccflags-y += -DUSE_GENERIC_DECI_TBL

# Use crypto in SSV driver.
ccflags-y += -DUSE_LOCAL_CRYPTO
ccflags-y += -DUSE_LOCAL_WEP_CRYPTO
ccflags-y += -DUSE_LOCAL_TKIP_CRYPTO
ccflags-y += -DUSE_LOCAL_CCMP_CRYPTO
ccflags-y += -DUSE_LOCAL_SMS4_CRYPTO

ccflags-y += -DMULTI_THREAD_ENCRYPT
ccflags-y += -DFW_WSID_WATCH_LIST
#ccflags-y += -DUSE_BATCH_RX
#ccflags-y += -DCONFIG_IRQ_DEBUG_COUNT
#ccflags-y += -DCONFIG_SSV_SUPPORT_AES_ASM
ccflags-y += -DSSV6200_ECO
#ccflags-y += -DENABLE_WAKE_IO_ISR_WHEN_HCI_ENQUEUE

#ccflags-y += -DCONFIG_DEBUG_SKB_TIMESTAMP

#For HUW to define some resources
ifeq ($(DRV_OPT), HUW_DRV)
ccflags-y += -DHUW_DRV
endif

#enable p2p client to parse GO broadcast noa
#ccflags-y += -DCONFIG_P2P_NOA
