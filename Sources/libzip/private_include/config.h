#ifndef HAD_CONFIG_H
#define HAD_CONFIG_H
#ifndef _HAD_ZIPCONF_H
#include "zipconf.h"
#endif

/* BEGIN DEFINES */
#if __APPLE__

#define HAVE_ARC4RANDOM
#define HAVE_CLONEFILE
#define HAVE_COMMONCRYPTO
#define HAVE_CRYPTO
#define HAVE_FILENO
#define HAVE_FSEEKO
#define HAVE_FTELLO
#define HAVE_GETPROGNAME
#define HAVE_LIBBZ2
#define HAVE_LOCALTIME_R
#define HAVE_NULLABLE
#define HAVE_OPEN
#define HAVE_SETMODE
#define HAVE_SNPRINTF
#define HAVE_SSIZE_T_LIBZIP
#define HAVE_STRCASECMP
#define HAVE_STRDUP
#define HAVE_STRTOLL
#define HAVE_STRTOULL
#define HAVE_STDBOOL_H
#define HAVE_STRINGS_H
#define HAVE_UNISTD_H
#define INT8_T_LIBZIP 1
#define UINT8_T_LIBZIP 1
#define INT16_T_LIBZIP 2
#define UINT16_T_LIBZIP 2
#define INT32_T_LIBZIP 4
#define UINT32_T_LIBZIP 4
#define INT64_T_LIBZIP 8
#define UINT64_T_LIBZIP 8
#define SHORT_LIBZIP 2
#define INT_LIBZIP 4
#define LONG_LIBZIP 8
#define LONG_LONG_LIBZIP 8
#define SIZEOF_OFF_T 8
#define SIZE_T_LIBZIP 8
#define SSIZE_T_LIBZIP 8
#define HAVE_FTS_H
#define HAVE_SHARED

#else

#define HAVE_CRYPTO
#define HAVE_FICLONERANGE
#define HAVE_FILENO
#define HAVE_FSEEKO
#define HAVE_FTELLO
#define HAVE_LOCALTIME_R
#define HAVE_NULLABLE
#define HAVE_OPEN
#define HAVE_OPENSSL
#define HAVE_SNPRINTF
#define HAVE_SSIZE_T_LIBZIP
#define HAVE_STRCASECMP
#define HAVE_STRDUP
#define HAVE_STRTOLL
#define HAVE_STRTOULL
#define HAVE_STDBOOL_H
#define HAVE_STRINGS_H
#define HAVE_UNISTD_H
#define INT8_T_LIBZIP 1
#define UINT8_T_LIBZIP 1
#define INT16_T_LIBZIP 2
#define UINT16_T_LIBZIP 2
#define INT32_T_LIBZIP 4
#define UINT32_T_LIBZIP 4
#define INT64_T_LIBZIP 8
#define UINT64_T_LIBZIP 8
#define SHORT_LIBZIP 2
#define INT_LIBZIP 4
#define LONG_LIBZIP 8
#define LONG_LONG_LIBZIP 8
#define SIZEOF_OFF_T 8
#define SIZE_T_LIBZIP 8
#define SSIZE_T_LIBZIP 8
#define HAVE_FTS_H
#define HAVE_SHARED

#endif
/* END DEFINES */


#define PACKAGE "libzip"
#define VERSION "1.6.1a"

#ifndef HAVE_SSIZE_T_LIBZIP
#  if SIZE_T_LIBZIP == INT_LIBZIP
typedef int ssize_t;
#  elif SIZE_T_LIBZIP == LONG_LIBZIP
typedef long ssize_t;
#  elif SIZE_T_LIBZIP == LONG_LONG_LIBZIP
typedef long long ssize_t;
#  else
#error no suitable type for ssize_t found
#  endif
#endif

#endif /* HAD_CONFIG_H */
