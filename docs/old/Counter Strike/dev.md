# Counter-Strike: Global Offensive (CSGO) development documentation
(Ecrit le 03/09/2019)

## CSGO Vanilla plugin
Compilation Base:
<https://github.com/alliedmodders/hl2sdk/tree/csgo>

Doc:
- Official: <https://developer.valvesoftware.com/wiki/Server_plugins>
- Alliedmods:
  - <https://wiki.alliedmods.net/Game_Events_(Source)>
  - <https://wiki.alliedmods.net/Generic_Source_Server_Events>
  - <https://wiki.alliedmods.net/Counter-Strike:_Global_Offensive_Events>

Example:
- <https://github.com/burnedram/csgo-plugin-color-say/blob/master/README.md>

## Communication between CSGO Server and others
### Rcon Command doc:

List of commands
- <https://developer.valvesoftware.com/wiki/List_of_CS:GO_Cvars>

Source Rcon Protocole (Doc and dev libraries list like nodejs, php...)
- <https://developer.valvesoftware.com/wiki/Source_RCON_Protocol>


### Get CS:GO Logs (HTTP POST):
(CSGO cfg)

```
mp_logdetail 3
logaddress_add_http <url>
log on
```
### Example of receiving logs from CSGO server
PHP example:
<https://medium.com/@indexCS/receiving-srcds-csgo-server-logs-from-a-gameserver-live-with-php-68497aa092bb>
Mirror:
<https://discordapp.com/channels/475775050470129676/618246057423273984/618250408015429663>
```
As a part of CSGOPanel I’ve been looking into receiving the logs from SRCDS with PHP/NodeJS so I can get realtime statistics to users.

I’ve had a breakthrough in receiving the logs remotely that I want to share because the documentation for this is shite (valve pls fix).

To do this, you need a little PHP script and a few commands for the server.

The server commands (stick these in server.cfg)

    mp_logdetail 3
    sv_logsecret 12345
    logaddress_add_http <url>
    log on

The URL should point to a publicly accessible php file that accepts a POST. Every time the CS server would write to a file it will POST data to your server on this URL.

To implement this, you can’t use the $_POST variable. The data is sent raw with no keys. Here is an example of my script:

    ```php
    if ($_SERVER['REMOTE_ADDR'] == '<<GAMESERVER IP>>') {
    file_put_contents('log.txt', file_get_contents('php://input'), FILE_APPEND); // put raw input into a file
    } else {
    echo "FAIL";
    }http_response_code(200);

    ```

First off, you have to use `file_get_contents(‘php://input’)` to get the data because it’s not sent keyed as a form would be. All I do with the if statement is check the server IP to prevent unsolicited access to files.

There will need to be some validation done on these inputs fairly obviously, but this is a good starting point that should help kickstart your project.

I’ll do a more comprehensive writeup at some point but I wanted to get my solution out to help anyone else out.
```


## Installation Guide for hl2sdk-CSGO

PACKAGE TO INSTALL:
pkg-config
protoc 2.5.0 (<https://github.com/protocolbuffers/protobuf/releases/tag/v2.5.0>)
g++, and g++-multilib if you're compiling on a 64-bit machine.

DEBIAN:
LIBS:
sudo apt-get install autoconf automake libtool curl make g++ unzip pkg-config g++-multilib

PROTOBUF:
wget <https://github.com/protocolbuffers/protobuf/releases/download/v2.5.0/protobuf-2.5.0.zip>
unzip protobuf-2.5.0.zip
./configure --build=i686-pc-linux-gnu \
            --host=x86_64-pc-linux-gnu \
            "CFLAGS=-m32" "CXXFLAGS=-m32" "LDFLAGS=-m32" --prefix=/usr
make
make check
sudo make install
sudo ldconfig # refresh shared library cache.

mkdir MYPROJECT
cd MYPROJECT
git clone --single-branch --branch csgo <https://github.com/alliedmodders/hl2sdk.git>

### Makefile

```makefile
# install g++-4.6 g++-4.6-multilib
# https://gcc.gnu.org/onlinedocs/libstdc++/manual/abi.html
# 4.6 is GLIBCXX_3.4.15, use the newest version that csgo-ds has, which can be found using
# strings csgo-ds/bin/libstdc++.so.6 | grep "^GLIBCXX_"
GCC := g++
WARNINGS := -Wall #-Werror
OPTIONS := -m32 -pipe -msse -mfpmath=sse -std=c++0x
# When updating to a newer version of g++, use -std=c++11
FLAGS := -fvisibility=hidden -fvisibility-inlines-hidden -fexceptions -fno-threadsafe-statics -fpermissive
EXTRA_FLAGS := -fno-rtti
DEFINES := -Dstricmp=strcasecmp -D_stricmp=strcasecmp -D_snprintf=snprintf \
		  -D_vsnprintf=vsnprintf -DGNUC -D_LINUX -DPOSIX -DCOMPILER_GCC
INCLUDES := -Ihl2sdk-csgo/public -Ihl2sdk-csgo/public/engine -Ihl2sdk-csgo/public/mathlib \
		   -Ihl2sdk-csgo/public/tier0 -Ihl2sdk-csgo/public/tier1 -Ihl2sdk-csgo/public/game/server

SOURCE_DIR := src
BUILD_DIR := build
CSGO_LIB_DIR := hl2sdk-csgo/lib/linux
CSGO_LIBS := $(addprefix $(CSGO_LIB_DIR)/,libtier0.so libvstdlib.so tier1_i486.a interfaces_i486.a)
CSGO_LINKING := -Lhl2sdk-csgo/lib/linux $(patsubst $(CSGO_LIB_DIR)/%.a,-l:%.a,$(patsubst $(CSGO_LIB_DIR)/lib%.so,-l%, $(CSGO_LIBS)))
PROTOBUF_LINKING := $(patsubst -lprotobuf,-l:libprotobuf.a, $(shell pkg-config --cflags --libs protobuf))

PROTOBUF_FLAGS := $(WARNINGS) $(OPTIONS) $(FLAGS) -I$(SOURCE_DIR)/protobuf
PLUGIN_FLAGS := $(WARNINGS) $(OPTIONS) $(FLAGS) $(EXTRA_FLAGS) $(DEFINES) $(INCLUDES) -I$(SOURCE_DIR) -I$(SOURCE_DIR)/protobuf

NETMESSAGES_PB_SOURCE := $(addprefix $(SOURCE_DIR)/protobuf/,netmessages.pb.cc netmessages.pb.h) 
CSTRIKE_PB_SOURCE := $(addprefix $(SOURCE_DIR)/protobuf/,cstrike15_usermessages.pb.cc cstrike15_usermessages.pb.h) 
PROTOBUF_SOURCE := $(NETMESSAGES_PB_SOURCE) $(CSTRIKE_PB_SOURCE)

OBJECT_FILES := $(patsubst $(SOURCE_DIR)/%.cpp,$(BUILD_DIR)/%.o,$(wildcard $(SOURCE_DIR)/*.cpp)) $(patsubst $(SOURCE_DIR)/protobuf/%.pb.cc,$(BUILD_DIR)/%.pb.o,$(PROTOBUF_SOURCE))

.PHONY: all
all: prepare colorsay.so colorsay.vdf

.PHONY: list
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs

.PHONY: prepare
prepare: $(PROTOBUF_SOURCE)

colorsay.so: $(OBJECT_FILES) $(CSGO_LIBS)
	$(GCC) $(OBJECT_FILES) $(CSGO_LINKING) $(PROTOBUF_LINKING) $(OPTIONS) -shared -o colorsay.so

$(BUILD_DIR)/colorsay.o: $(addprefix $(SOURCE_DIR)/,colorsay.cpp colorsay.h recipientfilters.h protobuf/cstrike15_usermessages.pb.h) | $(BUILD_DIR)
	$(GCC) $< $(PLUGIN_FLAGS) -c -o $@

$(BUILD_DIR)/%.pb.o: $(addprefix $(SOURCE_DIR)/protobuf/,%.pb.cc %.pb.h) | $(BUILD_DIR)
	$(GCC) $< $(PROTOBUF_FLAGS) -c -o $@

$(BUILD_DIR)/%.o: $(addprefix $(SOURCE_DIR)/,%.cpp %.h) | $(BUILD_DIR)
	$(GCC) $< $(PLUGIN_FLAGS) -c -o $@

$(NETMESSAGES_PB_SOURCE): hl2sdk-csgo/public/engine/protobuf/netmessages.proto
	protoc --proto_path=$(dir $<) --proto_path=/usr/include --cpp_out=$(dir $@) $<

$(CSTRIKE_PB_SOURCE): hl2sdk-csgo/public/game/shared/csgo/protobuf/cstrike15_usermessages.proto hl2sdk-csgo/public/engine/protobuf/netmessages.proto
	protoc $(addprefix --proto_path=,$(dir $^) /usr/include) --cpp_out=$(dir $@) $<

$(PROTOBUF_SOURCE): | $(SOURCE_DIR)/protobuf

$(SOURCE_DIR)/protobuf:
	mkdir -p $(SOURCE_DIR)/protobuf

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

.PHONY: clean
clean:
	rm -f colorsay.so colorsay.vdf
	rm -rf $(BUILD_DIR)
	rm -rf $(SOURCE_DIR)/protobuf

CSGO_USER := steam
CSGO_GROUP := steam
INSTALL_DIR := /home/$(CSGO_USER)/csgo-ds/csgo/addons

.PHONY: install
install: $(INSTALL_DIR) $(addprefix $(INSTALL_DIR)/,colorsay.so colorsay.vdf)

$(INSTALL_DIR):
	mkdir -p $@
	chown $(CSGO_USER):$(CSGO_GROUP) $@

$(INSTALL_DIR)/colorsay.so: colorsay.so
	cp $< $@
	chown $(CSGO_USER):$(CSGO_GROUP) $@

$(INSTALL_DIR)/colorsay.vdf: colorsay.vdf
	cp colorsay.vdf $@
	chown $(CSGO_USER):$(CSGO_GROUP) $@

define VDF_CONTENT
"Plugin"
{
		"file"  "addons/colorsay"
}
endef

export VDF_CONTENT
colorsay.vdf:
	echo "$$VDF_CONTENT" > colorsay.vdf
```