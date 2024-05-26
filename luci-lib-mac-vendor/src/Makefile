clean:
compile:
install:
	mkdir -p "$(DESTDIR)/www/luci-static/resources/mac_vendor"
	cp -a "$(LIB_DIST)/." "$(DESTDIR)/www/luci-static/resources/mac_vendor/"
	$(SED) 's#=PKG_VERSION"#=$(LIB_VERSION)"#g' "$(DESTDIR)/www/luci-static/resources/mac_vendor/mac_vendor.js"
