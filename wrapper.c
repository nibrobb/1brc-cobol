#include <stddef.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>

#include <libcob.h>

#define MAX_MSG_LEN 255


extern int ONEBRCCBL(char *filepath);


void usage(const char* prgname) {
    fprintf(stderr, "Usage: %s [OPTIONS] --file...\n\
\n\
Options:\n\
\n\
  --threads -t\t\tNumber of threads\n\
  --file -f\t\tPath to measurements.txt\n", prgname);
}


static char filepath[MAX_MSG_LEN] = {0};
static char threads[4] = {0};
static int num_threads = 4;


void parse_cmd_opts(int argc, char* const* argv) {
    if (argc < 2) {
        usage(argv[0]);
    }

    while (1)
    {
        static struct option long_options[] =
        {
            {"threads", required_argument, 0, 't'},
            {"file", required_argument, 0, 'f'},
            {0, 0, 0, 0}
        };

        int option_index = 0;

        int c = getopt_long(argc, argv, "f:t:", long_options, &option_index);

        if (c == -1)
            break;
        
        switch (c) {
            case 't':
                strncpy(threads, optarg, 4);
                break;
            case 'f':
                strncpy(filepath, optarg, MAX_MSG_LEN);
                break;
            default:
                exit(1);
        }
    }
}


int main(int argc, char **argv) {
    parse_cmd_opts(argc, argv);

    if (strlen(threads) > 0) {
        num_threads = atoi(threads);
    }
    fprintf(stderr, "Input file: `%s' running with %d threads\n", filepath, num_threads);

    cob_init(0, NULL);

    int ret = ONEBRCCBL(filepath);

    cob_tidy();

    return ret;
}
