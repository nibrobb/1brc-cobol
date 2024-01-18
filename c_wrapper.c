#include <stddef.h>
#include <string.h>
#include <stdio.h>

#include <libcob.h>

#define MAX_MSG_LEN 255

extern int ONEBRCCBL(char *filepath);

int main(int argc, char **argv) {
    char filepath[MAX_MSG_LEN] = {0};

    if (argc == 2) {
        strncpy(filepath, argv[1], MAX_MSG_LEN);
    } else {
        fprintf(stderr, "Usage: %s measurements.txt\n", argv[0]);
        return 1;
    }

    cob_init(0, NULL);

    int ret = ONEBRCCBL(filepath);

    cob_tidy();

    return ret;
}
