/* This translates ps fonts in .pfb format to ASCII ps files. */

#include <stdio.h>

/* Binary bytes per output line. */
#define BYTES_PER_LINE (79/2)
#define HEX_DIGITS "0123456789ABCDEF"

static char *program_name;

static void error(s)
     char *s;
{
  fprintf(stderr, "%s: %s\n", program_name, s);
  exit(2);
}

static void usage()
{
  fprintf(stderr, "usage: %s [pfb_file]\n", program_name);
  exit(1);
}

int main(argc, argv)
     int argc;
     char **argv;
{
  program_name = argv[0];
  if (argc > 2)
    usage();
  if (argc == 2 && !freopen(argv[1], "r", stdin))
    {
      perror(argv[1]);
      exit(1);
    }
  for (;;)
    {
      int type, c, i;
      long n;

      c = getchar();
      if (c != 0x80)
	error("first byte of packet not 0x80");
      type = getchar();
      if (type == 3)
	break;
      if (type != 1 && type != 2)
	error("bad packet type");
      n = 0;
      for (i = 0; i < 4; i++)
	{
	  c = getchar();
	  if (c == EOF)
	    error("end of file in packet header");
	  n |= (long)c << (i << 3);
	}
      if (n < 0)
	error("negative packet length");
      if (type == 1)
	{
	  while (--n >= 0)
	    {
	      c = getchar();
	      if (c == EOF)
		error("end of file in text packet");
	      if (c == '\r')
		c = '\n';
	      putchar(c);
	    }
	  if (c != '\n')
	    putchar('\n');
	}
      else
	{
	  int count = 0;
	  while (--n >= 0)
	    {
	      c = getchar();
	      if (c == EOF)
		error("end of file in binary packet");
	      if (count >= BYTES_PER_LINE)
		{
		  putchar('\n');
		  count = 0;
		}
	      count++;
	      putchar(HEX_DIGITS[(c >> 4) & 0xf]);
	      putchar(HEX_DIGITS[c & 0xf]);
	    }
	  putchar('\n');
	}
    }
  exit(0);
}
