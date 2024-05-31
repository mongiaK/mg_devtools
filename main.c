#include <assert.h>
#include <signal.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include <arpa/inet.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>

#include <getopt.h>
#include <limits.h>
#include <string.h>

char *cmd_long_options_to_short_options(const struct option options[]) {
  char short_options[UCHAR_MAX * 3 + 1];
  char *p = short_options;

  for (; options->name; options++) {
    const struct option *o = options;
    if (o->flag == NULL && o->val > 0 && o->val <= UCHAR_MAX) {
      *p++ = o->val;
      if (o->has_arg == required_argument) {
        *p++ = ':';
      } else if (o->has_arg == optional_argument) {
        *p++ = ':';
        *p++ = ':';
      }
    }
  }
  *p++ = '\0';

  return strdup(short_options);
}

void parse_options(int argc, char *argv[]) {
  static const struct option long_options[] = {
      {"help", no_argument, NULL, 'h'},
      {"version", no_argument, NULL, 'v'},
      {NULL, 0, NULL, 0},
  };

  char *short_options = cmd_long_options_to_short_options(long_options);
  for (;;) {
    int c = getopt_long(argc, argv, short_options, long_options, NULL);
    if (-1 == c) {
      break;
    }

    switch (c) {
    case 'h':
      break;
    case 'v':
      break;
    default:
      abort();
    }
  }

  free(short_options);
}

void sigfunc(int signo) {
  switch (signo) {
  case SIGINT:
    printf("Recieved SIGINT. Exiting...\n");
    exit(0);
  case SIGTERM:
    printf("Recieved SIGTERM. Exiting...\n");
    exit(0);
  default:
    printf("Recieved signal %d\n", signo);
  }
}

int main(int argc, char *argv[]) {
  signal(SIGINT, sigfunc);

  return EXIT_SUCCESS;
}
