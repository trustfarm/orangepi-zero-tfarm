
#CONFIG_SSV6200_CORE=m
#ccflags-y += -DCONFIG_SSV6200_CORE

ccflags-y += -Werror

############################################################
# If you change the settings, please change the file synchronization
# ssv6200smac\firmware\include\config.h & compiler firmware
############################################################
#ccflags-y += -DCONFIG_SSV_CABRIO_A
ccflags-y += -DCONFIG_SSV_CABRIO_E

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

############################################################
# NOTE:
#    Only one of the following flags could be turned on.
# It also turned off the following flags. In this case, 
# pure software security or pure hardware security is used.
#
############################################################
#ccflags-y += -DCONFIG_SSV_SW_ENCRYPT_HW_DECRYPT
#ccflags-y += -DCONFIG_SSV_HW_ENCRYPT_SW_DECRYPT


#workaround
#ccflags-y += -DCONFIG_SSV_CABRIO_EXT_PA

#CONFIG_SSV_SUPPORT_BTCX=y

# FOR WFA
#ccflags-y += -DWIFI_CERTIFIED

#ccflags-y += -DCONFIG_SSV_SDIO_EXT_INT

ccflags-y += -DCONFIG_SSV6200_CLI_ENABLE

# Generic decision table applicable to both AP and STA modes.
ccflags-y += -DUSE_GENERIC_DECI_TBL

ccflags-y += -DCONFIG_SSV6200_HAS_RX_WORKQUEUE
ccflags-y += -DUSE_THREAD_RX
ccflags-y += -DUSE_THREAD_TX
ccflags-y += -DENABLE_AGGREGATE_IN_TIME
ccflags-y += -DENABLE_INCREMENTAL_AGGREGATION

# Use crypto in SSV driver.
ccflags-y += -DUSE_LOCAL_CRYPTO
ccflags-y += -DUSE_LOCAL_WEP_CRYPTO
#ccflags-y += -DUSE_LOCAL_TKIP_CRYPTO
ccflags-y += -DUSE_LOCAL_CCMP_CRYPTO
ccflags-y += -DUSE_LOCAL_SMS4_CRYPTO

ccflags-y += -DMULTI_THREAD_ENCRYPT
ccflags-y += -DFW_WSID_WATCH_LIST
#ccflags-y += -DUSE_BATCH_RX
#ccflags-y += -DCONFIG_IRQ_DEBUG_COUNT
#ccflags-y += -DCONFIG_SSV_BUILD_AS_ONE_KO
#ccflags-y += -DCONFIG_SSV_SUPPORT_AES_ASM
ccflags-y += -DCONFIG_SSV_WAPI

ccflags-y += -DSSV6200_ECO

#ccflags-y += -DCONFIG_DEBUG_SKB_TIMESTAMP

# Enable -g to help debug. Deassembly from .o to .S would help to track to 
# the problomatic line from call stack dump.
ccflags-y += -g

#enable p2p client to parse GO broadcast noa
#ccflags-y += -DCONFIG_P2P_NOA
