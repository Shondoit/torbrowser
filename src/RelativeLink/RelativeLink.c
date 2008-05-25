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
// windres RelativeLink-res.rc RelativeLink-res.o
//
// Then you'll compile the program and include the icon object file:
// gcc -o StartTorBrowserBundle RelativeLink.c RelativeLink-res.o
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

    TCHAR *ProgramToStart;
    ProgramToStart = TEXT ("App/vidalia.exe --datadir .\\Data\\Vidalia\\");

    if( !CreateProcess( 
        NULL, ProgramToStart, NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi ))
    {
         MessageBox ( NULL, TEXT ("Unable to start Vidalia"), NULL, NULL );
         return;
    }

}
