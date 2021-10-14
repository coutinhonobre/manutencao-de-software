/*
 * File......: FTINT86.CH - Header file for users of FT_INT86() function
 * Author....: Ted Means
 * Date......: $Date:   02 Apr 1991 18:26:18  $
 * Revision..: $Revision:   1.0  $
 * Log file..: $Logfile:   E:/nanfor/src/ftint86.chv  $
 * 
 * This is an original work by Ted Means and is placed in the
 * public domain.
 *
 * Modification history:
 * ---------------------
 *
 * $Log:   E:/nanfor/src/ftint86.chv  $
 *   
 *     Rev 1.0   02 Apr 1991 18:26:18   GLENN
 *  Nanforum Toolkit
 *
 */


#define AX         1
#define BX         2
#define CX         3
#define DX         4
#define SI         5
#define DI         6
#define BP         7
#define DS         8
#define ES         9
#define FLAGS     10
#define DS_STRING 11
#define ES_STRING 12

#define INT86_MAX_REGS       12
#define INT86_SUCCESS         0
#define INT86_INVALID_PARMS  -1
#define INT86_MEMORY_ERROR   -2

#translate makehi( <X> )   => (<X> * (2 ^ 8))

#translate register( <X> ) => chr( <X> )

#translate highbyte( <X> ) => int( <X> / 256 )

#translate lowbyte( <X> )  => int( <X> % 256 )
      