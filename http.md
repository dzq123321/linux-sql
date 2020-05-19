#### http

```c++
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
void Usage() {
 printf("usage: ./server [ip] [port]\n");
}
int main(int argc, char* argv[]) {
 if (argc != 3) {
 Usage();
 return 1;
 }
 
 int fd = socket(AF_INET, SOCK_STREAM, 0);
 if (fd < 0) {
 perror("socket");
 return 1;
 }
 struct sockaddr_in addr;
 addr.sin_family = AF_INET;
 addr.sin_addr.s_addr = inet_addr(argv[1]);
 addr.sin_port = htons(atoi(argv[2]));
 int ret = bind(fd, (struct sockaddr*)&addr, sizeof(addr));
 if (ret < 0) {
 perror("bind");
 return 1;
 }
 ret = listen(fd, 10);
 if (ret < 0) {
 perror("listen");
 return 1;
 } 
 for (;;) {
 struct sockaddr_in client_addr;
 socklen_t len;
 int client_fd = accept(fd, (struct sockaddr*)&client_addr, &len);
 if (client_fd < 0) {
 perror("accept");
 continue;
 }
 char input_buf[1024 * 10] = {0}; // 用一个足够大的缓冲区直接把数据读完.
 ssize_t read_size = read(client_fd, input_buf, sizeof(input_buf) - 1);
 if (read_size < 0) {
 return 1;
 }
 printf("[Request] %s", input_buf);
 char buf[1024] = {0};
 const char* hello = "<h1>hello world</h1>";
 sprintf(buf, "HTTP/1.0 200 OK\nContent-Length:%lu\n\n%s", strlen(hello), hello);
 write(client_fd, buf, strlen(buf));
 }
 return 0;
}
```

#### TCP

**1**、16位窗口大小是自己的接受缓冲区的大小

**2** 为什么三次握手：

1、TCP三次握手是为了确认客户端和服务器的全双工信道是否通畅。

2、三次握手，5，7次握手，：如果最后一个ack丢失后，客户端背锅，客户端认为链接建立好了，但服务器没收到ack,所以服务器认为没链接好，没有增加服务器的开销。对服务器的负担是最小。

**3**、syn洪水攻击，半连接攻击都有可能使服务器挂掉（服务器有大量的半链接）

**4**、 超时重传和快重传互补

**5**、滑动窗口是发送缓冲区的大小  

**6**、IP:具有将数据从A主机跨网络经过路径选择送到B主机的能力，  TCP/IP  将数据从A主机跨网络经过路径选择可靠有效的送到B主机

























