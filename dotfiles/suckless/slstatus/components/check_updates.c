#include <stdio.h>
#include <stdlib.h>

#include "../slstatus.h"
#include "../util.h"

const char *check_updates() {
    FILE *fp;
    char path[1035];
    int count = 0;

    fp = popen("nala list --upgradable | wc -l", "r"); // or use "apt list --upgradable | wc -l"
    if (fp == NULL) {
        return "Error";
    }

    while (fgets(path, sizeof(path), fp) != NULL) {
        count = atoi(path);
    }
    pclose(fp);

    static char result[20];
    snprintf(result, sizeof(result), "%d", count); 
    return result;
}

