# @file		Makefile
# @author	Sebastien LEGRAND (oaxley)
# @license	MIT License
#
# @brief	Makefile to compile the library

#----- variables

# build dirs
BUILD_DIR := build

OBJ_DIR := $(BUILD_DIR)/obj
BIN_DIR := $(BUILD_DIR)/bin
SRC_DIR := src

# compilation flags
TARGET := liboaxlib
CXX=g++
CXXFLAGS := -I$(SRC_DIR) -I$(OBJ_DIR)
LDFLAGS := -L/usr/lib
LDLIBS := -ldl -lpthread

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	LDFLAGS += -shared
endif

ifeq ($(UNAME_S),Darwin)
	LDFLAGS += -dynamiclib
endif

ifdef mode
	ifeq ($(mode), debug)
		CXXFLAGS += -DDEBUG -g
		TARGET := $(TARGET)d
	endif
endif

TARGET_STATIC := $(BIN_DIR)/$(TARGET).a
TARGET_SHARED := $(BIN_DIR)/$(TARGET).so

# precompiled header
PCH := $(SRC_DIR)/oaxlib.hpp
GCH := $(OBJ_DIR)/oaxlib.hpp.gch

# sources files and their corresponding objects
SOURCES := $(shell find $(SRC_DIR) -name '*.cpp')
OBJECTS := $(SOURCES:%.cpp=%.o)


#----- rules
.PHONY: clean all prebuild compile shared static

all: prebuild compile shared static

clean:
	@ rm -rf build
	@ find $(SRC_DIR) -type f -name '*.o' -exec rm {} \;

prebuild:
	@ mkdir -p $(OBJ_DIR)
	@ mkdir -p $(BIN_DIR)

compile: $(GCH)

shared: $(TARGET_SHARED)

static: $(TARGET_STATIC)

$(GCH): $(PCH)
	@ $(CXX) $(CXXFLAGS) $^ -o $@

%.o: %.cpp
	@ $(CXX) $(CXXFLAGS) -fPIC -include $(PCH) -c $^ -o $@


$(TARGET_SHARED): $(OBJECTS)
	@ $(CXX) $(LDFLAGS) $(LDLIBS) $^ -o $@

$(TARGET_STATIC): $(OBJECTS)
	@ ar rcvs $@ $^ >/dev/null 2>&1
