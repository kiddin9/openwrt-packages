#define CENTER 0  // single item display
#define SPLIT 1	  // two items
#define MERGE 2
#define FULL 3
#define KB_BYTES (1024)
#define MB_BYTES (1024 * 1024)
#define GB_BYTES (1024 * 1024 * 1024)

void testdrawline();
void testdrawrect();
void testfillrect();
void testdrawcircle();
void testdrawroundrect();
void testfillroundrect();
void testdrawtriangle();
void testfilltriangle();
void testdrawchar();
void testscrolltext(char *str);
void display_texts();
void display_bitmap();
void display_invert_normal();
void testdrawbitmap(const unsigned char *bitmap, unsigned char w,
		    unsigned char h);
void testdrawbitmap_eg();
void deeplyembedded_credits();
void testprintinfo();
void testdate(int mode, int y);
void testip(int mode, int y, char *ifname);
void testcpufreq(int mode, int y);
void testcputemp(int mode, int y);
void testnetspeed(int mode, int y, unsigned long int rx, unsigned long int tx);
void testcpu(int y);
char *get_ip_addr(char *ifname);
