# A simple Makefile to automate building the RelativeLink program
APPNAME = StartTorBrowserBundle
OBJECTS = RelativeLink-res.rc.o RelativeLink.o
CFLAGS = -Wall -mwindows -static

all: RelativeLink

RelativeLink: $(OBJECTS) 
	$(CC) $(OBJECTS) $(CFLAGS) -o $(APPNAME)

RelativeLink.o: RelativeLink.c
	$(CC) $(CFLAGS) -c RelativeLink.c -o RelativeLink.o

RelativeLink-res.rc.o: RelativeLink-res.rc
	windres.exe RelativeLink-res.rc RelativeLink-res.rc.o

clean:
	rm -rf *.exe
	rm -rf *.o
