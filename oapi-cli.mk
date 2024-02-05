#-Wincompatible-pointer-types
oapi-cli: $(OAPI_RULE_DEPEDENCIES) $(JSON_C_RULE)
	$(CC) -g  -Wall -Wextra -Wno-unused-function -Wno-unused-parameter main.c osc_sdk.c $(CURL_LD) $(JSON_C_LDFLAGS) $(CURL_CFLAGS) $${CURL_BASH_CFLAGS} $(JSON_C_CFLAGS) -o oapi-cli -DWITH_DESCRIPTION=1 $(CFLAGS)

appimagetool-x86_64.AppImage:
	wget https://github.com/AppImage/AppImageKit/releases/download/12/appimagetool-x86_64.AppImage
	chmod +x appimagetool-x86_64.AppImage

oapi-cli-x86_64.AppImage: oapi-cli appimagetool-x86_64.AppImage
	mkdir -p oapi-cli.AppDir/usr/
	install -D $$(curl-config --ca) oapi-cli.AppDir/$$(curl-config --ca)
	echo export CURL_CA_BUNDLE='$${APPDIR}'/$$(curl-config --ca) > oapi-cli.AppDir/import-ssl.sh
	mkdir -p oapi-cli.AppDir/usr/bin/
	mkdir -p oapi-cli.AppDir/usr/lib/
	cp oapi-cli oapi-cli.AppDir/usr/bin/
	cp oapi-cli-completion.bash oapi-cli.AppDir/usr/bin/
	LD_LIBRARY_PATH="$(LD_LIB_PATH)" ./cp-lib.sh oapi-cli ./oapi-cli.AppDir/usr/lib/
	./appimagetool-x86_64.AppImage $(APPIMAGETOOL_OPTION) oapi-cli.AppDir
