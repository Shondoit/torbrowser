#include <windows.h>
#include <stdio.h>
#include <tchar.h>

//
// RelativeLink.c
// by Jacob Appelbaum <jacob@appelbaum.net>
//
// This is a very small program to work around the lack of relative links 
// in any of the most recent builds of Windows.
//
// To build this, you need Cygwin or MSYS.
//
// You need to build the icon resource first:
// windres ShortCut-res.rc ShortCut-res.o
//
// Then you'll compile the program and include the icon object file:
// gcc -o StartTorBrowserBundle ShortCut.c ShortCut-res.o
//
// End users will be able to use StartTorBrowserBundle.exe
//

int _tmain( int argc, TCHAR *argv[])
{
    STARTUPINFO si;
    PROCESS_INFORMATION pi;
    
    ZeroMemory ( &si, sizeof(si) );  
    si.cb = sizeof(si);
    ZeroMemory ( &pi, sizeof(pi) );

    char *ProgramToStart;
    ProgramToStart = "App/vidalia.exe --datadir .\\Data\\Vidalia\\";

    if( !CreateProcess( 
        NULL, ProgramToStart, NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi ))
    {
         printf("Unable to start Vidalia: (%d)\n", GetLastError() );
         return;
    }

}
