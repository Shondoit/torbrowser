# A simple Makefile to automate building the RelativeLink program
APPNAME=StartTorBrowserBundle

all: RelativeLink

RelativeLinkIcon:
	windres.exe RelativeLink-res.rc RelativeLink-res.rc.o

RelativeLink: RelativeLinkIcon
	gcc -Wall -mwindows -o $(APPNAME) RelativeLink.c RelativeLink-res.rc.o

clean:
	rm -rf *.exe
	rm -rf *.o

.rc.o:
		windres.exe $^ -o $@
%.o : %.rc
		windres.exe $^ -o $@
