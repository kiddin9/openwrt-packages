#include <linux/module.h>
#include <linux/version.h>
#include <linux/kmod.h>
#include <linux/kernel.h>
#include <linux/netfilter.h>
#include <linux/netfilter_ipv4.h>
#include <linux/ip.h>
#include <linux/tcp.h>
#include <linux/netdevice.h>
#include <linux/random.h>
#include <linux/moduleparam.h>

MODULE_AUTHOR("Haonan Chen");
MODULE_DESCRIPTION("Modify IDs of IP headers into numerically increasing order, for anti-detection of NAT.");
MODULE_LICENSE("GPL");

static u_int32_t mark_capture = 0x10;
module_param(mark_capture, uint, 0);
static u_int32_t mark_random = 0x20;
module_param(mark_random, uint, 0);

static struct nf_hook_ops nfho;
static u_int16_t id_next;

#if LINUX_VERSION_CODE >= KERNEL_VERSION(4,2,0)
unsigned int hook_funcion(void *priv, struct sk_buff *skb, const struct nf_hook_state *state)
#else
unsigned int hook_funcion(const struct nf_hook_ops *ops, struct sk_buff *skb, const struct net_device *in, const struct net_device *out, int (*okfn)(struct sk_buff *))
#endif
{
	register struct iphdr *iph;

	static u_int32_t n_not_writable = 0, n_modified = 0, n_random = 0;
	static u_int32_t n_modified_lastprint = 1;

	if(!(skb -> mark & mark_capture))
		return NF_ACCEPT;

	iph = ip_hdr(skb);
	
#if LINUX_VERSION_CODE >= KERNEL_VERSION(3, 19, 0)
	if(skb_ensure_writable(skb, (char*)iph - (char*)skb -> data + 6))
#else
	if(!skb_make_writable(skb, (char*)iph - (char*)skb -> data + 6))
#endif
	{
		if(!n_not_writable)
		{
			n_not_writable = 1;
			printk("rkp-ipid: There is a package not wirtable. Please make sure the router has enough memory.\n");
		}
		n_not_writable++;
		return NF_ACCEPT;
	}
	
	iph = ip_hdr(skb);
	if(skb -> mark & mark_random)
	{
		get_random_bytes(&(iph -> id), 2);
		n_modified++;
		n_random++;
	}
	else
	{
		iph -> id = ntohs(id_next);
		id_next++;
		n_modified++;
	}

	iph->check = 0;
	iph->check = ip_fast_csum(iph, iph->ihl);

	if(n_modified_lastprint * 2 == n_modified)
	{
		printk("rkp-ipid: Successfully modified %u packages, in which %u IDs are in increasing order, %u IDs are random. There are %u packages not writable.\n",
				n_modified, n_modified - n_random, n_random, n_not_writable);
		n_modified_lastprint *= 2;
	}

	return NF_ACCEPT;
}

static int __init hook_init(void)
{
	int ret;

	nfho.hook = hook_funcion;
	nfho.pf = NFPROTO_IPV4;
	nfho.hooknum = NF_INET_POST_ROUTING;
	nfho.priority = NF_IP_PRI_NAT_SRC;
#if LINUX_VERSION_CODE >= KERNEL_VERSION(4,13,0)
    ret = nf_register_net_hook(&init_net, &nfho);
#else
    ret = nf_register_hook(&nfho);
#endif
	get_random_bytes(&(id_next), 2);
	printk("rkp-ipid: Started, version=%d, mark_capture=0x%x. mark_random=0x%x.\n", VERSION, mark_capture, mark_random);
	printk("rkp-ipid: nf_register_hook returnd %d.\n", ret);

	return 0;
}

static void __exit hook_exit(void)
{
#if LINUX_VERSION_CODE >= KERNEL_VERSION(4,13,0)
    nf_unregister_net_hook(&init_net, &nfho);
#else
    nf_unregister_hook(&nfho);
#endif
	printk("rkp-ipid: Stopped.\n");
}

module_init(hook_init);
module_exit(hook_exit);
