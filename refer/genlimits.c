/* This tries to generate definitions of PATH_MAX and NAME_MAX. */

#include <sys/types.h>
#include <sys/param.h>

#ifdef HAVE_LIMITS_H
#include <limits.h>
#endif /* HAVE_LIMITS_H */

#ifdef HAVE_DIRENT_H
#include <dirent.h>
#endif /* HAVE_DIRENT_H */

#ifndef PATH_MAX
#include <sys/param.h>
#ifndef PATH_MAX
#ifdef MAXPATHLEN
#define PATH_MAX ((MAXPATHLEN)-1)
#else /* !MAXPATHLEN */
#define PATH_MAX 255
#endif /* !MAXPATHLEN */
#endif /* !PATH_MAX */
#endif /* !PATH_MAX */

#ifndef NAME_MAX
#ifdef MAXNAMLEN
#define NAME_MAX MAXNAMLEN
#else /* !MAXNAMLEN */
#ifdef MAXNAMELEN
#define NAME_MAX MAXNAMELEN
#else /* !MAXNAMELEN */
#define NAME_MAX 14
#endif /* !MAXNAMELEN */
#endif /* !MAXNAMLEN */
#endif /* !NAME_MAX */

#include <stdio.h>

main()
{
  printf("#define NAME_MAX %d\n", NAME_MAX);
  printf("#define PATH_MAX %d\n", PATH_MAX);
  exit(0);
}
