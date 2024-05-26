#
# Copyright (C) 2017-2020 Ian Leonard <antonlacon@gmail.com>
# Copyright (C) 2018 Ted Hess <thess@kitschensync.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ffmpeg-remux
PKG_VERSION:=4.3.3
PKG_RELEASE:=3

PKG_SOURCE:=ffmpeg-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://ffmpeg.org/releases/
PKG_HASH:=skip
PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>, \
		Ian Leonard <antonlacon@gmail.com>

PKG_LICENSE:=LGPL-2.1-or-later GPL-2.0-or-later LGPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING.GPLv2 COPYING.GPLv3 COPYING.LGPLv2.1 COPYING.LGPLv3
PKG_CPE_ID:=cpe:/a:ffmpeg:ffmpeg

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-x/ffmpeg-$(PKG_VERSION)

FFMPEG_REMUX_DECODERS:= \
	mpeg1video \
	mpeg2video \
	mpeg4 \
	mpegvideo \
	h264 \
	hevc \
	vc1 \

FFMPEG_REMUX_MUXERS:= \
	matroska \
	h264 \
	hevc \
	mp4 \
	mpeg1video \
	mpeg2video \
	mpegts \
	ogg \

FFMPEG_REMUX_DEMUXERS:= \
	avi \
	h264 \
	hevc \
	matroska \
	mov \
	mpegps \
	mpegts \
	mpegvideo \
	ogg \
	rm \
	vc1 \
	wv \

FFMPEG_REMUX_PARSERS:= \
	aac \
	flac \
	ac3 \
	h264 \
	hevc \
	mpegaudio \
	mpeg4video \
	mpegvideo \
	vc1 \

FFMPEG_REMUX_PROTOCOLS:= \
	file pipe

include $(INCLUDE_DIR)/package.mk

define Package/ffmpeg-remux
 TITLE:=FFmpeg remux
 SECTION:=multimedia
 CATEGORY:=Multimedia
 URL:=https://ffmpeg.org/
 DEPENDS+= +libpthread +zlib +libbz2
endef

define Package/ffmpeg-remux/description
 FFmpeg remux only program
endef

# Strip off FPU notation
REAL_CPU_TYPE:=$(firstword $(subst +, ,$(CONFIG_CPU_TYPE)))
# Fixup cpu types recogized by ffmpeg configure
REAL_CPU_TYPE:=$(subst octeonplus,octeon+,$(REAL_CPU_TYPE))

FFMPEG_CONFIGURE:= \
	CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS) $(FPIC)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	./configure \
	--enable-cross-compile \
	--cross-prefix="$(TARGET_CROSS)" \
	--arch="$(ARCH)" \
	$(if $(REAL_CPU_TYPE),--cpu=$(call qstrip,$(REAL_CPU_TYPE)),) \
	--target-os=linux \
	--prefix="/usr" \
	--pkg-config="pkg-config" \
	--enable-shared \
	--enable-pthreads \
	--enable-zlib \
	--disable-doc \
	--disable-debug \
	\
	--disable-lzma \
	--disable-vaapi \
	--disable-vdpau \
	--disable-outdevs

ifeq ($(CONFIG_SOFT_FLOAT),y)
FFMPEG_CONFIGURE+= \
	--disable-altivec \
	--disable-vsx \
	--disable-power8 \
	--disable-armv5te \
	--disable-armv6 \
	--disable-armv6t2 \
	--disable-fast-unaligned \
	--disable-runtime-cpudetect

else ifneq ($(findstring arm,$(CONFIG_ARCH))$(findstring aarch64,$(CONFIG_ARCH)),)
FFMPEG_CONFIGURE+= \
	--disable-runtime-cpudetect
# XXX: GitHub issue 3320 ppc cpu with fpu but no altivec (WNDR4700)
else ifneq ($(findstring powerpc,$(CONFIG_ARCH)),)
FFMPEG_CONFIGURE+= \
	--disable-altivec
endif

# selectively disable optimizations according to arch/cpu type
ifneq ($(findstring arm,$(CONFIG_ARCH)),)
	FFMPEG_CONFIGURE+= --enable-lto

	ifneq ($(findstring vfp,$(CONFIG_CPU_TYPE)),)
		FFMPEG_CONFIGURE+= --enable-vfp
	else
		FFMPEG_CONFIGURE+= --disable-vfp
	endif
	ifneq ($(findstring neon,$(CONFIG_CPU_TYPE)),)
		FFMPEG_CONFIGURE+= \
			--enable-neon \
			--enable-vfp
	else
		FFMPEG_CONFIGURE+= --disable-neon
	endif
endif

ifneq ($(findstring aarch64,$(CONFIG_ARCH)),)
	FFMPEG_CONFIGURE+= \
		--enable-lto \
		--enable-neon \
		--enable-vfp
endif

ifeq ($(ARCH),x86_64)
	FFMPEG_CONFIGURE+= --enable-lto
endif

ifeq ($(CONFIG_FFMPEG_X86ASM),y)
  FFMPEG_CONFIGURE += --enable-x86asm
else
  FFMPEG_CONFIGURE += --disable-x86asm
endif


FFMPEG_ENABLE= \
	$(foreach c, $(2), \
		--enable-$(1)="$(c)" \
	)

FFMPEG_CONFIGURE+= \
	--enable-hardcoded-tables \
	--disable-static \
	--libdir="/usr/lib/remux" \
	--enable-rpath \
	\
	--disable-ffplay \
	--disable-alsa \
	--disable-iconv \
	--disable-sndio \
	--disable-schannel \
	--disable-sdl2 \
	--disable-securetransport \
	--disable-xlib \
	--disable-v4l2-m2m \
	--disable-avdevice \
	--disable-postproc \
	--disable-swresample \
	--disable-swscale \
	--disable-everything \
	$(call FFMPEG_ENABLE,decoder,$(FFMPEG_REMUX_DECODERS)) \
	$(call FFMPEG_ENABLE,parser,$(FFMPEG_REMUX_PARSERS)) \
	$(call FFMPEG_ENABLE,demuxer,$(FFMPEG_REMUX_DEMUXERS)) \
	$(call FFMPEG_ENABLE,muxer,$(FFMPEG_REMUX_MUXERS)) \
	$(call FFMPEG_ENABLE,protocol,$(FFMPEG_REMUX_PROTOCOLS))

ifneq ($(CONFIG_TARGET_x86),)
  TARGET_CFLAGS+= -fomit-frame-pointer
endif

define Build/Configure
	( cd $(PKG_BUILD_DIR); $(FFMPEG_CONFIGURE) )
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		all install
endef

define Package/ffmpeg-remux/install
	$(INSTALL_DIR) $(1)/usr/lib/remux
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/remux/lib{avcodec,avfilter,avformat,avutil}.so.* $(1)/usr/lib/remux/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/ffmpeg $(1)/usr/bin/remux
endef

$(eval $(call BuildPackage,ffmpeg-remux))
