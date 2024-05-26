#
# $Id$
#
# The latest version of this document lives at:
# http://www.ilesansfil.org/wiki/WiFiDog/FAQ
#
# Please check the above URL if you have a FAQ that does not appear here.
#

WiFiDog/FAQ

The WiFi Dog Captive Portal Frequently Asked Questions

   To alleviate the repetition on the [9][WWW] WiFiDog mailing list, and
   to help people get started quickly, here are the FAQs:
    1. [10]The WiFi Dog Captive Portal Frequently Asked Questions
         1. [11]General questions
              1. [12]What is WiFiDog ?
              2. [13]Who makes WiFiDog ?
              3. [14]Who can use WiFiDog ?
              4. [15]Who currently uses WiFiDog ?
              5. [16]What can it do ?
              6. [17]What is it composed of ?
              7. [18]What are the main differences between it and NoCat ?
              8. [19]How does it work ?
              9. [20]What does it run on ?
             10. [21]Can I write my own client ?
             11. [22]Can I write my own auth server ?
             12. [23]What does it look like ?
         2. [24]The WiFiDog Client
              1. [25]What do I need ?
              2. [26]Pre-installation
              3. [27]Installation
              4. [28]Configuration
              5. [29]Running
              6. [30]Testing
         3. [31]The WiFiDog client on a linksys WRT54G
              1. [32]What do I need ?
              2. [33]Pre-installation
              3. [34]Installation
                   1. [35]Introduction
                   2. [36]Compiling a MIPS-friendly WiFiDog
                   3. [37]Getting the new MIPS-friendly WiFiDog onto the
                      router
                   4. [38]Actual installation
              4. [39]Configuration, Running and Testing
              5. [40]The intricate link between WiFiDog and OpenWRT
              6. [41]I am not comfortable with linux and don't know how
                 to do all this compiling stuff. Is there an easier way
                 for me to get the WiFiDog client running on a Linksys
                 WRT54G ?
         4. [42]The WiFiDog auth server
              1. [43]What do I need ?
              2. [44]Installation
              3. [45]Configuration
              4. [46]Testing

General questions

What is WiFiDog ?

   [47]WiFiDog is software used to create wireless hotspots. It is a
   next-generation alternative to [48][WWW] NoCat.

Who makes WiFiDog ?

   The technical team of [49]IleSansFil created and maintains
   [50]WiFiDog.

Who can use WiFiDog ?

   On the legal/licensing front, anyone can use [51]WiFiDog. It is free
   software released under the GPL license.

   On the practical front, we would like the answer to also be
   "everyone", however this would not be the truth. The main target user
   base of [52]WiFiDog is network administrators, hotspot administrators
   and hackers who "know what they're doing". Odds are that an average
   windows user would not benefit from, or be able to correctly setup and
   continually administer a [53]WiFiDog installation.

   If the software ever reaches a point of complete point-and-click ease
   that we feel average users can safely administer, we will update this
   document.

Who currently uses WiFiDog ?

   The following companies, organizations, groups or persons are known to
   use [54]WiFiDog on their hotspots:
     * [55]IleSansFil
     * [56][WWW] BC Wireless

What can it do ?

   See the [57]WiFiDog/FeatureList page for the feature list.

What is it composed of ?

   It is composed of 2 components:
    1. The client is a daemon process - this gets installed on every
       wireless router
    2. The auth server is a web application - this gets installed in a
       central location

What are the main differences between it and NoCat ?

   On the client side, it's smaller, has far fewer dependencies, and runs
   well on embedded devices.

   On the auth server side, it's more customizable, and is geared towards
   capitalizing the infrastructure for the purposes of building portals
   and communities.

How does it work ?

   The client daemon uses firewall rules to control traffic going through
   the router. When a new user tries to access a web site, the client
   will transparently re-direct them to the auth server where they can
   either log-in or sign-up. The client and the auth server then
   negotiate what to do with the client and either allow or deny them
   certain network access.

   The client also talks to the auth server every X minutes to update it
   on vital statistics including uptime, load, traffic count per client,
   and to let it know it's still there.

   Refer to the [58]WiFiDog/FlowDiagram document for some more details.

What does it run on ?

   The client runs on any linux machine that has a working
   netfilter+iptables installation.

   The auth server runs on any PHP-enabled web server.

Can I write my own client ?

   Sure, but why ? We've done all the work. The client is written in C
   and is extremely lightweight so that it runs comfortably in embedded
   environments such as the [59][WWW] Linksys WRT54G router.

   The client is time-tested and is fairly stable. It is used extensively
   in [60][WWW] IleSansFil's deployed hotspots.

Can I write my own auth server ?

   Again, we've done all the work. However our auth server at the time of
   this writing is not as polished as the client. Feel free to make it
   better or write your own from scratch. If you go with the later option
   you'll have to respect the same protocol the client uses for the whole
   system to work correctly.

What does it look like ?

   The client is a daemon process that runs in the background. It looks
   like zen, chi, the ether, zilch. It has no user interface.

   The auth server is a web application that can be customized via
   templates to look however you want it to look. To check out
   [61]IleSansFil's auth server installation see [62][WWW]
   https://auth.ilesansfil.org

The WiFiDog Client

What do I need ?

    1. Basic proficiency in a linux environment
    2. A linux OS with netfilter compiled into the kernel
    3. The iptables package
    4. The GNU C compiler (gcc). Other compilers may work, but we have
       not tested and will not support them.
    5. The latest [63]WiFiDog tarball which can be obtained from
       [64][WWW] SourceForge

Pre-installation

   This is where a lot of people run into problems, so let's state this
   in bold:

   MAKE SURE EVERYTHING WORKS FIRST BEFORE INTRODUCING [65]WiFiDog INTO
   THE ENVIRONMENT

   That especially means:
     * The router must boot properly
     * The router must bring up the interfaces properly
     * The router must set up the routes properly
     * The router must connect to the internet properly
     * DNS settings must be set or obtained properly. DNS must work.
     * DHCP settings (client, server or both) must be set or obtained
       properly.
     * If using NAT, the router must setup NAT/masquerading rules with
       iptables properly
     * Clients on the desired ([66]WiFi) network must be able to bind,
       associate, lease and connect the internet properly
     * All the above must happen automatically when the router starts or
       gets rebooted

   Do NOT proceed with installing [67]WiFiDog until you've satisfied the
   above. It will not work otherwise and you will waste lots of time.

Installation

   [68]WiFiDog, like many open source projects, is distributed with
   standard autotools utilities to make installation easy. Unpack the
   tarball, then follow the standard:
./configure
make
make install

Configuration

   Edit /etc/wifidog.conf and follow the instructions in the file. Things
   should be self-explanatory.

Running

   For the first time, run [69]WiFiDog with the following switches:
wifidog -f -d 7

   -f means to run in foreground (do not become a background daemon)

   -d 7 increases debug output level to the maximum

Testing

   As a client on the [70]WiFi network (or whatever interface is
   configured as the LAN interface in /etc/wifidog.conf), open a web
   browser and try to browse to your favourite web site.

   Monitor the output of the running [71]WiFiDog to see what it's doing.

The WiFiDog client on a linksys WRT54G

   Due to the lightness of the [72]WiFiDog client it is often installed
   inside the linksys WRT54G. There are some profound issues that arise
   with this setup that it warrants its own section in this FAQ:

What do I need ?

   You will need to have basic/full proficiency in a linux environment

   You need to re-flash your router with a hacker-friendly firmware
   called [73][WWW] OpenWRT. [74][WWW] Follow the user guide on the
   OpenWRT site to get this part done.

   Do not proceed until you've completed the above. We also recommend you
   spend some time familiarizing yourself with your new router's OS
   before introducing [75]WiFiDog into that environment. This especially
   includes the nvram settings, network interfaces and existing interface
   bridges.

Pre-installation

   The same rules apply as the pre-installation in a non-WRT54G
   environment above. Do not proceed until you've satisfied them. In
   summary: Make sure EVERYTHING works first.

Installation

Introduction

   Installation of the client on the WRT54G is a bit tricky. The space
   limitations on the device mean there is no compiler in the OpenWRT
   operating system. That means that you must compile the client on an
   external machine then transfer the compiled form onto the router.

   To complicate things more, if you compile your client regularly on a
   standard x86 desktop the produced binary will not run on the router
   due to the different type of processor (MIPS) on that router.

   What is needed is called cross-compilation, In that scenario you use
   an architecture (such as your x86 desktop) to produce binaries
   explicitly designed to run on a different architecture (your MIPS
   router).

   The above was the bad news since it makes things sound complicated.
   The good news is that it's not too complicated and we've built scripts
   to make this a snap for you. As a matter of fact, you've already done
   this before!

   Remember when you followed the OpenWRT building instructions ? Without
   knowing it, you already cross-compiled stuff! You used your desktop to
   cross-compile an entire operating system for the MIPS architecture
   which resulted in one compressed firmware image you installed on your
   router.

Compiling a MIPS-friendly WiFiDog

    1. Download the latest [76][WWW] WiFiDog tarball from sourceforge.
    2. Uncompress the tarball, enter the directory
    3. Run the following, replacing /usr/local/openwrt/ with wherever you
       unpacked the OpenWRT tarball earlier:

ipkg/rules BUILDROOT=/usr/local/openwrt/

   You're done. If all is well you should now have a new file named
   wifidog_1.1.0_mipsel.ipk (version number may be different depending on
   the tarball you downloaded).

Getting the new MIPS-friendly WiFiDog onto the router

   The .ipk is a data file for the simple "ipkg/i-Package" package
   manager already on your router. All that's needed now is to copy that
   file onto your router. If you have installed the dropbear SSH daemon
   package on your router you can use scp on your desktop to copy the
   .ipk file to the router. Otherwise copy that file to any web server
   you have access to, then use wget on the router to download the file
   from the web server.

   Either way, place the file in the /tmp/ directory on the router.

Actual installation

   Once you have the .ipk file on the router, use this command to install
   it:
ipkg install /tmp/wifidog_1.1.0_mipsel.ipk

   Once that is successful delete the .ipk file from /tmp/ to free the
   occupied memory.

Configuration, Running and Testing

   Same as the earlier section in a non-WRT54G environment

The intricate link between WiFiDog and OpenWRT

   Repeat after me:

   A [77]WiFiDog RUNNING ON AN OpenWRT INSTALLATION MUST HAVE BEEN
   COMPILED AGAINST THE SAME OpenWRT BUILDROOT USED TO CREATE THAT
   INSTALLATION

   What does that mean ?
    1. If you downloaded and compiled OpenWRT yourself, download and
       compile [78]WiFiDog yourself against the same buildroot - Do not
       use someone else's pre-compiled [79]WiFiDog
    2. If you downloaded a pre-compiled OpenWRT firmware image:
         1. Ask the person who built it to compile [80]WiFiDog for you
            against the same buildroot
         2. Or ask them for a copy of their OpenWRT buildroot so you may
            compile [81]WiFiDog against it

I am not comfortable with linux and don't know how to do all this compiling
stuff. Is there an easier way for me to get the WiFiDog client running on a
Linksys WRT54G ?

   You can use an OpenWRT and [82]WiFiDog compiled by someone else. They
   must be compiled by the same person against the same OpenWRT
   buildroot.

   [83]IleSansFil makes it's own pair of OpenWRT images and [84]WiFiDog
   .ipk compiled files available to the public:
     * You can download a pre-compiled OpenWRT firmware image [85][WWW]
       here
     * And you can download a compatible [86]WiFiDog .ipk file [87][WWW]
       here

   Look in the [88][WWW] OpenWRT site for instructions on how to re-flash
   your router with the firmware image (skip any download/building
   instructions).

   Then follow the above installation instructions for installing the
   [89]WiFiDog .ipk file into the OpenWRT-flashed router.

   Please note that the above saves you from the knowledge and time
   needed to compile and produced these binary files. It is however no
   magical cure for linux illiteracy. You need to be proficient enough in
   a unix environment to be able to telnet/ssh into the router and
   perform the outlined installation and configuration tasks. If you do
   not feel comfortable doing this we advise you consult with someone who
   is proficient in linux and networking.

The WiFiDog auth server

What do I need ?

   Refer to [90]WiFiDog/AuthServerDoc

Installation

   Refer to [91]WiFiDog/AuthServerDoc

Configuration

   Refer to [92]WiFiDog/AuthServerDoc

Testing

   Refer to [93]WiFiDog/AuthServerDoc

   last edited 2005-03-27 13:11:15 by [94]MinaNaguib

References

   1. http://www.ilesansfil.org/wiki/FrontPage
   2. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=raw
   3. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print
   4. http://www.ilesansfil.org/wiki/WiFiDog
   5. http://www.ilesansfil.org/wiki/FindPage
   6. http://www.ilesansfil.org/wiki/TitleIndex
   7. http://www.ilesansfil.org/wiki/WordIndex
   8. http://www.ilesansfil.org/wiki/HelpOnFormatting
   9. http://listes.ilesansfil.org/
  10. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-b9d27a8844e66371abfbb27bf54669896d8bf4fa
  11. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-eb7dd5c81583187efb2d29ebc9ab2b6457417b13
  12. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-e05420efb19364f3fa0844223f1bcfc71be7db00
  13. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-80293173c84355ebeff2ecbfabaa32edb3c3ae75
  14. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-2aa554753e8b93818ba5ef190e67e401421931b9
  15. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-975f3574aa59265dd2b0c45ae96e90c98c8bc7d5
  16. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-dccf73ff2dcc305d6334dfd0ed90d1c4221b8a12
  17. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-ebd81c14ab1b66d6aada9fc399597b644e120036
  18. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-9b4c49acb692c6ba8bc2c0e43a991c5fc7b80220
  19. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-5aa44a01d2ff78d1e2b5240e0a6c75910d584a0e
  20. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-738ab14de6f62065ca3daf9dd3341bfcabc06223
  21. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-6059fbd6c262224baf06331fbe83f319ffe730fa
  22. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-e8131f271e42589291d507afd89d0c5d24f02ad1
  23. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-6a764a3be722e0ff8d1446586643ea57d70cd489
  24. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-a650736551182819fd6f742597362be729d9b70d
  25. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-57aaa0d1e21d38a7f5bedea65950c36b422cbbb6
  26. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-2b75ffe2445295c9982d0873d48e11d5cd89816e
  27. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-930f69b528374c4c55fc91b52e030deef8a93648
  28. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-4b221edbf4c2383afab601694f2db039700c21cc
  29. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-9fcf91fbcf4712b6de6d5b70e703192dd882afa8
  30. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-18cc26d84a97b42f3bc06af0203038062a8efb06
  31. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-8ba37f479842312562f131032bb11e4fb68942aa
  32. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-57aaa0d1e21d38a7f5bedea65950c36b422cbbb6-2
  33. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-2b75ffe2445295c9982d0873d48e11d5cd89816e-2
  34. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-930f69b528374c4c55fc91b52e030deef8a93648-2
  35. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-b6830b2e74230b45153f4fa98ee189d5748ec9f0
  36. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-78504516e51f8fc43cc111b9a8a41a85cb652fff
  37. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-92221794cfda95baa91352d087656f27754027d2
  38. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-2474f5bb689b7b06fc3334eb8e29a26ed60c4280
  39. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-37c9cfe0aa830fa8ef3e6f617bd3c741cca6947c
  40. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-1dee9a0f840701e6518a0763c48aef734d1996f8
  41. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-158e6f354a348c9374107d0a66a7f4c84603ba8a
  42. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-30106563831cfdb0840b05fa48e9194d7876f12e
  43. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-57aaa0d1e21d38a7f5bedea65950c36b422cbbb6-3
  44. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-930f69b528374c4c55fc91b52e030deef8a93648-3
  45. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-4b221edbf4c2383afab601694f2db039700c21cc-2
  46. http://www.ilesansfil.org/wiki/WiFiDog/FAQ?action=print#head-18cc26d84a97b42f3bc06af0203038062a8efb06-2
  47. http://www.ilesansfil.org/wiki/WiFiDog
  48. http://nocat.net/
  49. http://www.ilesansfil.org/wiki/IleSansFil
  50. http://www.ilesansfil.org/wiki/WiFiDog
  51. http://www.ilesansfil.org/wiki/WiFiDog
  52. http://www.ilesansfil.org/wiki/WiFiDog
  53. http://www.ilesansfil.org/wiki/WiFiDog
  54. http://www.ilesansfil.org/wiki/WiFiDog
  55. http://www.ilesansfil.org/wiki/IleSansFil
  56. http://www.bcwireless.net/
  57. http://www.ilesansfil.org/wiki/WiFiDog/FeatureList
  58. http://www.ilesansfil.org/wiki/WiFiDog/FlowDiagram
  59. http://www.linksys.com/products/product.asp?prid=508&scid=35
  60. http://auth.ilesansfil.org/hotspot_status.php
  61. http://www.ilesansfil.org/wiki/IleSansFil
  62. https://auth.ilesansfil.org/
  63. http://www.ilesansfil.org/wiki/WiFiDog
  64. http://sourceforge.net/projects/wifidog
  65. http://www.ilesansfil.org/wiki/WiFiDog
  66. http://www.ilesansfil.org/wiki/WiFi
  67. http://www.ilesansfil.org/wiki/WiFiDog
  68. http://www.ilesansfil.org/wiki/WiFiDog
  69. http://www.ilesansfil.org/wiki/WiFiDog
  70. http://www.ilesansfil.org/wiki/WiFi
  71. http://www.ilesansfil.org/wiki/WiFiDog
  72. http://www.ilesansfil.org/wiki/WiFiDog
  73. http://openwrt.org/
  74. http://openwrt.org/OpenWrtDocs
  75. http://www.ilesansfil.org/wiki/WiFiDog
  76. http://sourceforge.net/projects/wifidog
  77. http://www.ilesansfil.org/wiki/WiFiDog
  78. http://www.ilesansfil.org/wiki/WiFiDog
  79. http://www.ilesansfil.org/wiki/WiFiDog
  80. http://www.ilesansfil.org/wiki/WiFiDog
  81. http://www.ilesansfil.org/wiki/WiFiDog
  82. http://www.ilesansfil.org/wiki/WiFiDog
  83. http://www.ilesansfil.org/wiki/IleSansFil
  84. http://www.ilesansfil.org/wiki/WiFiDog
  85. http://www.ilesansfil.org/dist/openwrt/
  86. http://www.ilesansfil.org/wiki/WiFiDog
  87. http://www.ilesansfil.org/dist/wifidog/
  88. http://www.openwrt.org/
  89. http://www.ilesansfil.org/wiki/WiFiDog
  90. http://www.ilesansfil.org/wiki/WiFiDog/AuthServerDoc
  91. http://www.ilesansfil.org/wiki/WiFiDog/AuthServerDoc
  92. http://www.ilesansfil.org/wiki/WiFiDog/AuthServerDoc
  93. http://www.ilesansfil.org/wiki/WiFiDog/AuthServerDoc
  94. http://www.ilesansfil.org/wiki/MinaNaguib
