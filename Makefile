VALAC = valac
PKG = --pkg gtk+-3.0
TARGET = oracle

all: $(TARGET)

$(TARGET): oracle.vala
	$(VALAC) $(PKG) -o $(TARGET) oracle.vala

clean:
	rm -f $(TARGET)

install: $(TARGET)
	cp $(TARGET) /usr/local/bin/

.PHONY: all clean install
