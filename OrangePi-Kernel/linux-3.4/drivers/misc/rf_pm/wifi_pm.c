#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/delay.h>
#include <linux/platform_device.h>
#include <linux/init.h>
#include <mach/sys_config.h>
#include <linux/gpio.h>
#include <linux/proc_fs.h>
#include <linux/crypto.h>
#include <linux/scatterlist.h>
#include <linux/miscdevice.h>
#include "module_pm.h"

static char *wifi_para = "wifi_para";
struct wl_func_info  wl_info;

extern int sunxi_gpio_req(struct gpio_config *gpio);
extern int rf_module_power(int onoff);
extern int rf_pm_gpio_ctrl(char *name, int level);
#define wifi_pm_msg(...)    do {printk("[wifi_pm]: "__VA_ARGS__);} while(0)

#if defined(CONFIG_ARCH_SUN6I) || defined(CONFIG_ARCH_SUN7I)
extern void sw_mci_rescan_card(unsigned id, unsigned insert);
extern int sw_usb_disable_hcd(__u32 usbc_no);
extern int sw_usb_enable_hcd(__u32 usbc_no);
#elif defined(CONFIG_ARCH_SUN8I) || defined(CONFIG_ARCH_SUN9I)
extern void sunxi_mci_rescan_card(unsigned id, unsigned insert);
extern int sunxi_usb_disable_hcd(__u32 usbc_no);
extern int sunxi_usb_enable_hcd(__u32 usbc_no);
#endif

void wifi_pm_power(int on)
{
	int on_off = 0;

	if (on > 0){
		on_off = 1;
	} else {
		on_off = 0;
	}
	if (wl_info.wl_reg_on != -1) {
		wifi_pm_msg("set wl_reg_on %d !\n", on_off);
		gpio_set_value(wl_info.wl_reg_on, on_off);
	}

	wl_info.wl_power_state = on_off;
}
EXPORT_SYMBOL(wifi_pm_power);

int wifi_pm_gpio_ctrl(char *name, int level)
{
	int i = 0;
	int gpio = 0;
	char * gpio_name[1] = {"wl_reg_on"};

	for (i = 0; i < 1; i++) {
		if (strcmp(name, gpio_name[i]) == 0) {
			switch (i)
			{
				case 0: /*wl_reg_on*/
					gpio = wl_info.wl_reg_on;
					break;
				default:
					wifi_pm_msg("no matched gpio.\n");
			}
			break;
		}
	}

	gpio_set_value(gpio, level);
	printk("gpio %s set val %d, act val %d\n", name, level, gpio_get_value(gpio));

	return 0;
}
EXPORT_SYMBOL(wifi_pm_gpio_ctrl);

static ssize_t power_state_show(struct device *dev,
	struct device_attribute *attr, char *buf)
{
	return sprintf(buf, "%d\n", wl_info.wl_power_state);
}

static ssize_t power_state_store(struct device *dev,
	struct device_attribute *attr, const char *buf, size_t count)
{
	unsigned long state;
	int err;

	if (!capable(CAP_NET_ADMIN))
		return -EPERM;

	err = kstrtoul(buf, 0, &state);
	if (err)
		return err;

	if (state > 1 )
		return -EINVAL;

	if (state != wl_info.wl_power_state){
		wifi_pm_power(state);
	}

	return count;
}

static ssize_t scan_device_store(struct device *dev,
	struct device_attribute *attr, const char *buf, size_t count)
{
	unsigned long state;
	int err;
	int sdc_id = -1;
	int usb_id = -1;
	script_item_u val;
	script_item_value_type_e type;

	if (!capable(CAP_NET_ADMIN))
		return -EPERM;

	err = kstrtoul(buf, 0, &state);
	if (err)
		return err;

	if (state > 1 )
		return -EINVAL;

	type = script_get_item("wifi_para", "wifi_sdc_id", &val);
	if (SCIRPT_ITEM_VALUE_TYPE_INT != type) {
		wifi_pm_msg("get wifi_sdc_id failed\n");
	} else {
		sdc_id = val.val;
#if defined(CONFIG_ARCH_SUN6I) || defined(CONFIG_ARCH_SUN7I)
		sw_mci_rescan_card(sdc_id, state);
#elif defined(CONFIG_ARCH_SUN8I) || defined(CONFIG_ARCH_SUN9I)
		sunxi_mci_rescan_card(sdc_id, state);
#endif
	}
	type = script_get_item("wifi_para", "wifi_usbc_id", &val);
	if (SCIRPT_ITEM_VALUE_TYPE_INT != type) {
		wifi_pm_msg("get wifi_sdc_id failed\n");
	} else {
		usb_id = val.val;
#if defined(CONFIG_ARCH_SUN6I) || defined(CONFIG_ARCH_SUN7I)
		if (state) {
			sw_usb_disable_hcd(usb_id);
		} else {
			sunxi_usb_disable_hcd(usb_id);
		}
#elif defined(CONFIG_ARCH_SUN8I) || defined(CONFIG_ARCH_SUN9I)
		if (state) {
			sunxi_usb_enable_hcd(usb_id);
		} else {
			sunxi_usb_disable_hcd(usb_id);
		}
#endif
	}
	return count;
}

static DEVICE_ATTR(power_state, S_IWUSR | S_IWGRP | S_IRUGO,
		power_state_show, power_state_store);
static DEVICE_ATTR(scan_device, S_IWUSR | S_IWGRP,
		NULL, scan_device_store);

static struct attribute *misc_attributes[] = {
	&dev_attr_power_state.attr,
	&dev_attr_scan_device.attr,
	NULL,
};

static struct attribute_group misc_attribute_group = {
	.name  = "rf-ctrl",
	.attrs = misc_attributes,
};

static struct miscdevice sunxi_wlan_dev = {
	.minor = MISC_DYNAMIC_MINOR,
	.name  = "sunxi-wlan",
};

static int wifi_pm_get_res(void)
{
	script_item_value_type_e type;
	script_item_u val;
	struct gpio_config  *gpio_p = NULL;

	type = script_get_item(wifi_para, "wifi_used", &val);
	if (SCIRPT_ITEM_VALUE_TYPE_INT != type) {
		wifi_pm_msg("failed to fetch wifi configuration!\n");
		return -1;
	}
	if (!val.val) {
		wifi_pm_msg("no wifi used in configuration\n");
		return -1;
	}
	wl_info.wifi_used = val.val;

	wl_info.wl_reg_on = -1;
	type = script_get_item(wifi_para, "wl_reg_on", &val);
	if (SCIRPT_ITEM_VALUE_TYPE_PIO!=type)
		wifi_pm_msg("get wl_reg_on gpio failed\n");
	else {
		gpio_p = &val.gpio;
		wl_info.wl_reg_on = gpio_p->gpio;
		sunxi_gpio_req(gpio_p);
	}

	return 0;
}

extern int sunxi_get_soc_chipid(uint8_t *chip_id);
void wifi_hwaddr_from_chipid(u8 *addr)
{
#define MD5_SIZE	16
#define CHIP_SIZE	16

	struct crypto_hash *tfm;
	struct hash_desc desc;
	struct scatterlist sg;
	u8 result[MD5_SIZE];
	u8 chipid[CHIP_SIZE];
	int i = 0;
	int ret = -1;

	memset(chipid, 0, sizeof(chipid));
	memset(result, 0, sizeof(result));

	sunxi_get_soc_chipid((u8 *)chipid);

	tfm = crypto_alloc_hash("md5", 0, CRYPTO_ALG_ASYNC);
	if (IS_ERR(tfm)) {
		pr_err("Failed to alloc md5\n");
		return;
	}
	desc.tfm = tfm;
	desc.flags = 0;

	ret = crypto_hash_init(&desc);
	if (ret < 0) {
		pr_err("crypto_hash_init() failed\n");
		goto out;
	}

	sg_init_one(&sg, chipid, sizeof(chipid) - 1);
	ret = crypto_hash_update(&desc, &sg, sizeof(chipid) - 1);
	if (ret < 0) {
		pr_err("crypto_hash_update() failed for id\n");
		goto out;
	}

	crypto_hash_final(&desc, result);
	if (ret < 0) {
		pr_err("crypto_hash_final() failed for result\n");
		goto out;
	}

	/* Choose md5 result's [0][2][4][6][8][10] byte as mac address */
	for (i = 0; i < 6; i++) {
		addr[i] = result[2*i];
	}
	addr[0] &= 0xfe;     /* clear multicast bit */
	addr[0] &= 0xfd;     /* clear local assignment bit (IEEE802) */
	addr[5] ^= 0x01;     /* be different with ethernet mac address */

out:
	crypto_free_hash(tfm);
}
EXPORT_SYMBOL(wifi_hwaddr_from_chipid);

static int __devinit wifi_pm_probe(struct platform_device *pdev)
{
	int ret = 0;

	ret = misc_register(&sunxi_wlan_dev);
	if (ret) {
		wifi_pm_msg("register driver as misc device error!\n");
		return ret;
	}
	ret = sysfs_create_group(&sunxi_wlan_dev.this_device->kobj,
			&misc_attribute_group);
	if (ret) {
		wifi_pm_msg("register sysfs create group failed!\n");
		return ret;
	}
	return 0;
}

static int __devexit wifi_pm_remove(struct platform_device *pdev)
{
	WARN_ON(0 != misc_deregister(&sunxi_wlan_dev));
	sysfs_remove_group(&(sunxi_wlan_dev.this_device->kobj),
			&misc_attribute_group);
	return 0;
}

#ifdef CONFIG_PM
static int wifi_pm_suspend(struct device *dev)
{
	return 0;
}

static int wifi_pm_resume(struct device *dev)
{
	return 0;
}

static struct dev_pm_ops wifi_dev_pm_ops = {
	.suspend	= wifi_pm_suspend,
	.resume		= wifi_pm_resume,
};
#endif

static struct platform_device wifi_pm_dev = {
	.name           = "wifi_pm",
};

static struct platform_driver wifi_pm_driver = {
	.driver.name    = "wifi_pm",
	.driver.owner   = THIS_MODULE,
#ifdef CONFIG_PM
	.driver.pm      = &wifi_dev_pm_ops,
#endif
	.probe          = wifi_pm_probe,
	.remove         = __devexit_p(wifi_pm_remove),
};

static int __init wifi_pm_init(void)
{
	memset(&wl_info, 0, sizeof(struct wl_func_info));
	wifi_pm_get_res();
	if (!wl_info.wifi_used)
		return 0;

	wl_info.wl_power_state = 0;

	platform_device_register(&wifi_pm_dev);
	return platform_driver_register(&wifi_pm_driver);
}

static void __exit wifi_pm_exit(void)
{
	if (!wl_info.wifi_used)
		return;

	platform_driver_unregister(&wifi_pm_driver);
	platform_device_unregister(&wifi_pm_dev);
}

late_initcall_sync(wifi_pm_init);
module_exit(wifi_pm_exit);
