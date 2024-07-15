#ifndef DEBUG_H
#define DEBUG_H

#include <stdio.h>
using namespace std;

/* Compile with flag -DDEBUG_MODE to activate debuggin statements */

#ifdef DEBUG_MODE
#define DBGMSG( msg )         moleDebugLog( __FILE__, __LINE__, msg );              // regular debug
#define DBGVMSG( msg, value ) moleDebugLog( __FILE__, __LINE__,  msg, value );      // regular debug with value
#else
#define DBGMSG( msg )
#define DBGVMSG( msg, value )
#endif


/* Error message function for #define DEBUG */
// DEBUG debugging message
void moleDebugLog ( const char *file, int line, const std::string &message )
{
    cerr << "[" << file << "]:" << line << ", " << message << endl;
}
void moleDebugLog ( const char *file, int line, const std::string &message, double value )
{
    cerr << "[" << file << "]:" << line << ", " << message << " is " << value << endl;
}


#endif