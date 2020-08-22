/*IO复用使得程序可以同时监听多个文件描述符
select:在指定的一段时间内，监听用户感兴趣的文件描述符上的可读、可写和异常等事件。

读事件就绪条件：
1、接收缓冲区可读
2、监听socket有新的请求
3、socket通信对方关闭连接
4、socket上有未处理的错误，使用getsockopt读取和清除错误
写事件就绪条件：
1、发送缓冲区可写
2、socket写操作关闭，对写操作被关闭的一方执行写操作产生SICPIPE信号
3、socket非阻塞connect连接成功或失败
4、socket上有未处理的错误，使用getsockopt读取和清除错误
*/
/*
I/O 复用的稿子应用一
非阻塞connect
socket非阻塞connect连接失败后，socket设置错误码EINPROGRESS
*/

#include<sys/types.h>
#include<sys/socket.h>
#include<netinet/in.h>
#include<arpa/inet.h>
#include<stdlib.h>
#include<assert.h>
#include<stdio.h>
#include<time.h>
#include<errno.h>
#include<fcntl.h>
#include<sys/ioctl.h>
#include<unistd.h>
#include<string.h>

#define BUFFER_SIZE 1023
int setnonblocking(int fd)
{
    int old_option = fcntl(fd, F_GETFL);
    int new_option = old_option | O_NONBLOCK;
    fcntl(fd, F_SETFL, new_option);
    return old_option;
}
//time 是select的超时时间
int unblock_connect(const char* ip, int port, int time)
{
    int ret = 0;
    struct sockaddr_in address;
    bzero(&address, sizeof(address));
    inet_pton(AF_INET, ip, &address.sin_addr);
    address.sin_port = htons(port);
    int sockfd = socket(PF_INET, SOCK_STREAM, 0);
    int fdopt = setnonblocking(sockfd);
    ret = connect(sockfd, (struct sockaddr*)&address, sizeof(address));
    if (ret == 0)
    {
        //连接成功 恢复sockfd属性，并返回
        printf("connect with server immediately\n");
        fcntl(sockfd, F_SETFL, fdopt);
        return sockfd;
    }
    else if (errno != EINPROGRESS)
    {
        //连接没有建立，只有当erron=EINPROGRESS是说明连接还在进行，否则出错
        printf("unblock connect not support\n");
        return - 1;
    }
    fd_set readfds;
    fd_set writefds;
    struct timeval timeout;
    FD_ZERO(&readfds);
    FD_SET(sockfd, &writefds);
    timeout.tv_sec = time;
    timeout.tv_usec = 0;
    ret = select(sockfd + 1, NULL, &writefds, NULL, &timeout);
    if (ret <= 0) {
        //select失败
        printf("connection time out\n");
        close(sockfd);
        return - 1;
    }
    if (!FD_ISSET(sockfd, &writefds))
    {
        printf("no events on sockfd found\n");
        close(sockfd);
        return - 1;
    }
    int error = 0;
    socklen_t length = sizeof(error);
    if (getsockopt(sockfd, SOL_SOCKET, SO_ERROR, &error, &length) < 0)
    {
        printf("get socket option falied\n");
        close(sockfd);
        return - 1;
    }
    //error不为0,表示getsockopt失败
    if (error != 0)
    {
        printf("connection failed after select with the errror: %d\n",error);
        close(sockfd);
        return - 1;

    }
    //连接成功
    printf("connection ready after select wu=ithu thr socket: %d\n", sockfd);
    fcntl(sockfd, F_SETFL, fdopt);
    return sockfd;
}
int main(int argc, char *argv[])
{
    if (argc <= 2)
    {
        printf("usage: %s ip_address port_number\n", argv[0]);
        return 1;
    }
    const char *ip = argv[1];
    int port = atoi(argv[2]);
    int sockfd = unblock_connect(ip, port, 10);
    if (sockfd < 0)
        return 1;
    close(sockfd);
    return 1;
}
