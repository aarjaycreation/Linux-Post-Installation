#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../slstatus.h"
#include "../util.h"

const char *check_updates() {
    FILE *fp;
    static char result[20];
    char command_output[10];
    
    // Execute the update command
    system("apt update > /dev/null 2>&1");
    
    // Execute the command to count upgradable packages
    fp = popen("apt list --upgradable 2>/dev/null | grep -c 'upgradable'", "r");
    if (fp == NULL) {
        return "Error";
    }

    // Read the output
    if (fgets(command_output, sizeof(command_output), fp) == NULL) {
        pclose(fp);
        return "Error";
    }
    pclose(fp);

    // Remove newline character from the end
    size_t len = strlen(command_output);
    if (len > 0 && command_output[len - 1] == '\n') {
        command_output[len - 1] = '\0';
    }

    // Copy the output directly to result
    snprintf(result, sizeof(result), "%s", command_output);

    return result;
}
