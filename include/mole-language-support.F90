! Copyright (c) 2024-2025, The Regents of the University of California
! Terms of use are as specified in LICENSE.txt

#ifndef MOLE_LANGUAGE_SUPPORT
#define MOLE_LANGUAGE_SUPPORT


#ifdef __GNUC__
#  define GCC_VERSION (__GNUC__ * 10000 + __GNUC_MINOR__ * 100 + __GNUC_PATCHLEVEL__)
#else
#  define GCC_VERSION 0
#endif

#if __GNUC__ && ( __GNUC__ < 14 || (__GNUC__ == 14 && __GNUC_MINOR__ < 3) )
#define GCC_GE_MINIMUM
#endif

#ifndef HAVE_DO_CONCURRENT_TYPE_SPEC_SUPPORT
#  if defined(_CRAYFTN) || defined(__INTEL_COMPILER) || defined(NAGFOR) || defined(__flang__)
#    define HAVE_DO_CONCURRENT_TYPE_SPEC_SUPPORT 1
#  else
#    define HAVE_DO_CONCURRENT_TYPE_SPEC_SUPPORT 0
#  endif
#endif

#endif
