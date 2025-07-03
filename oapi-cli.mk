#-Wincompatible-pointer-types
$(CLI_NAME): $(OAPI_RULE_DEPEDENCIES) $(JSON_C_RULE)
	$(CC) -g -std=gnu11  -Wall -Wextra -Wno-unused-function -Wno-unused-parameter main.c osc_sdk.c -lm $(CURL_LD) $(JSON_C_LDFLAGS) $(CURL_CFLAGS) $${CURL_BASH_CFLAGS} $(JSON_C_CFLAGS) -o $(CLI_NAME) -DWITH_DESCRIPTION=1 $(CFLAGS)

appimagetool-x86_64.AppImage:
	wget https://github.com/AppImage/AppImageKit/releases/download/12/appimagetool-x86_64.AppImage
	chmod +x appimagetool-x86_64.AppImage

$(CLI_NAME)-x86_64.AppImage: $(CLI_NAME) $(CLI_NAME)-completion.bash appimagetool-x86_64.AppImage
	mkdir -p $(CLI_NAME).AppDir/
	mkdir -p $(CLI_NAME).AppDir/usr/
	install -D $$(curl-config --ca | tr -d '"') $(CLI_NAME).AppDir$$(curl-config --ca | tr -d '"')
	echo export CURL_CA_BUNDLE='$${APPDIR}'/$$(curl-config --ca | tr -d '"') > $(CLI_NAME).AppDir/import-ssl.sh
	mkdir -p $(CLI_NAME).AppDir/usr/bin/
	mkdir -p $(CLI_NAME).AppDir/usr/lib/
	cat cli.desktop | sed  "s/____cli_name____/$(CLI_NAME)/" > $(CLI_NAME).AppDir/$(CLI_NAME).desktop
	cat AppRun | sed  "s/____cli_name____/$(CLI_NAME)/" > $(CLI_NAME).AppDir/AppRun
	chmod +x $(CLI_NAME).AppDir/AppRun
	cp $(CLI_NAME) $(CLI_NAME).AppDir/usr/bin/
	cp appimage-logo.png $(CLI_NAME).AppDir/
	cp $(CLI_NAME)-completion.bash $(CLI_NAME).AppDir/usr/bin/
	LD_LIBRARY_PATH="$(LD_LIB_PATH)" ./cp-lib.sh $(CLI_NAME) ./$(CLI_NAME).AppDir/usr/lib/
	./appimagetool-x86_64.AppImage $(APPIMAGETOOL_OPTION) $(CLI_NAME).AppDir
