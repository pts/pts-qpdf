/* gcc -c -O2 -DNO_VIZ -W -Wall -Wextra -Werror -ansi -pedantic zall.c
 * g++ -c -O2 -DNO_VIZ -W -Wall -Wextra -Werror -ansi -pedantic zall.c
 *
 * Works with gcc-4.4, g++-4.4.
 */

/* Also useful: #define NO_VIZ 1 */
#define NO_DUMMY_DECL 1

#include "inflate.c"
#include "crc32.c"
#include "adler32.c"
#include "inffast.c"
#include "inftrees.c"
#include "zutil.c"

#include "deflate.c"
#include "trees.c"
