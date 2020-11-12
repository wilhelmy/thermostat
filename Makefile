TTY=	/dev/ttyUSB0

DHT_FILES= $(wildcard relay/*.lua)

COPY=\
	for x in $(DHT_FILES); do \
		echo Copying $$x; \
		./nodemcu-copy -n -t $(TTY) $$x; \
		sleep 1; \
	done

dht:
	$(COPY)

.PHONY: dht
