

#### linux 线程

1 Linux下，没有真正意义上的多线程，Linux是用进程来模拟的线程

2 线程在进程内部运行，是进程的一个执行分支。内存运行->进程的地址空间内运行。是有独立的PCB

3  在Linux 下，进程是承担分配OS资源的基本单位，线程是CPU调度的基本单位.

在内核角度，进程是承担分配系统资源的基本单位，而线程是调度的基本单位

4  用户级线程库(pthread)，OS提供了内核的轻量级进程机制
Linux中pthread线程和内核轻量级进程是由对应关系的，1：1
5 用户级线程id是一个地址！！！
6 线程必须等待， ptrhead_join，如果不等，会有类似僵尸进程的问题
7 等待通常由主线程等待        释放资源，拿到返回结果
8  线程结束只关心返回值，代码跑完结果对或不对。不关心线程异常，因为线程异常退出后直接影响进程，使进程退出，进程返回信号
9 线程退出的3个方式：return pthread_exit  pthread_cancal()

10 检测脚本

`while :; do ps axj|head -1&&ps axj|grep thread;echo"##########"; sleep 1; done`

11、生产者消费者模型

是多线程之间一中同步和互斥的常见策略，包括2个角色，3种关系，1个交易场所。2个角色->生产者何消费者，一般有线程承担。3种关系，生产者和生产者之间的互斥关系，生产者和消费者之间的同步互斥关系，消费者之间的互斥关系。1个交易场所就是生产者和消费者之间的缓冲区。维护这个模型需要利用锁，条件变量，信号量。

12、多线程环境下，任何时候线程都有可能被调度器切走，切走的时候要保护上下文，恢复时现场恢复

13、信号量是一个计数器，本质是描述临界资源数目的计数器

14、 线程池的个数：1. 任务类型：计算密集型，IO密集型  2. 计算：线程的数量=CPU个数*每个CPU的核数 可以适度浮动    3、IO: 线程的个数>>CPU*核数  但是不建议太多    计算：如果线程过多反而可能引起效率的降低，线程间切换也是成本

15、读者写者关系：1. 读者与读者之间是共享关系 2. 写者和写者是互斥关系3. 读者和写者之间是互斥or同步

读者写者场景：写的次数特别少，而读的次数特别多

16、读者写者vs生产者消费者：根本区别是：消费的过程是会取走数据的！而读者读取数据的过程，是没有拿走数据的！！（放数据拿数据和放数据看数据的区别）

17、1. 下三层(数据链路层+物理层，网络层，传输层)：将数据可靠高效的跨网络经过路径选择传输到对方主机           2、应用层：如何解释使用该数据

18、1. 发送的时候，一定要有一个叫做自顶向下的过程，封装  2. 接收的时候，一定要有一个自底向上的过程，解报

19、 局域网：1. 任何时刻，只能一台主机发消息   2. 同时发消息，会发生数据碰撞，各自要有能力检测碰撞以及碰撞避免   3、本质上，主机向主机发消息，其实在局域网中，是有一大批吃瓜群众（主机）能收到的，只不过其他主机把它丢弃罢了	

基于碰撞检测的网叫以太网

任何报头一定要提供两个基本字段或功能：

1. 通过报头能将数据和报头信息分离   2. 报头字段中必须涵盖,将数据应该交付给上层的那个协议

   20，mac地址工作在局域网 

## 网络

###网络编程1

1、ip地址和端口号(+协议)可以唯一表示网络上某台主机的某一进程，ip地址可以标识网络上的某台主机，端口号+协议可以标识一个进程，告诉操作系统将这个数据交割哪个进程，一个端口号只能被一个进程占用

这里的一个进程可以被多个端口号绑定，但不能多个进程对应一个端口号

2、大小端

大端：高低低高  数据的高位保存在内存的低地址 ，数据的低位保存在内存的高地址

小端：高高低低  数据的高位保存在内存的高地址 ，数据的低位保存在内存的低地址

比如一个数据： tmp=0X12345678  （数据的高低位是按从左到右从高到低增长的）

再内存的存储为：

内存：低地址 --------------->高地址（地址是按从左到右从低到高增长的）

小端      0x78   0x56  0x34   0x12  

大端     0x12     0x34  0x56     0x78

```
//百度，查看电脑的大小端
#include <stdio.h> 
int check_sys()
{    int i = 1;    //0x 00 00 00 01 在内存中的存储为 0x01 00 00 00   x小端
     return (*(char *)&i); 
}
int main() { 
int ret = check_sys();  
if(ret == 1)    {    
   printf("小端\n");   
}   
else    
{       
    printf("大端\n");   
}   
return 0; 
```

我们的电脑（x86）一般是小端

而网络字节流是大端：先发低地址，再发高地址（低地址存放数据的高位）

UDP/TCP/IP协议规定:把接收到的第一个字节当作高位字节看待,这就要求发送端发送的第一个字节是高位字节;而在发送端发送数据时,发送的第一个字节是该数值在内存中的起始地址处对应的那个字节,也就是说,该数值在内存中的起始地址处对应的那个字节就是要发送的第一个高位字节(即:高位字节存放在低地址处);由此可见,多字节数值在发送之前,在内存中因该是以大端法存放的;

所以当我们的主机的存储是小端存放时，需要用到主机转网络的函数 `unit32_t htonl(unit32_t hostlong)`

```
htons():将16位无符号整数从本地字节序转换成网络字节序；
htonl():将32位无符号整数从本地字节序转换成网络字节序；
ntohs():将16位无符号整数从网络字节序转换成本地字节序；
ntohl():将32位无符号整数从网络字节序转换成本地字节序；
```

3、 netstat -apn  显示网络服务(-a 显示所有  -p 显示进程  -n 以数字代替  -u只显示udp  -t只显示tcp)  

####3、socket编程接口

**1、** socket 是一类特殊的文件，通过对socket文件的操作，实现网络编程，，网络中进程通信是无处不在，这就是我为什么说“一切皆socket”。
网络之间的进程如何通信：1、通过三元组（ip地址，端口号，协议）来识别目标主机的某个进  2利用socket来进行通信
本地进程之间如何通信：（必须复习）
   1、消息传递（管道，FIFO,消息队列）
   2、同步（互斥量、条件变量、读写锁、文件和写记录锁、信号量）
   3、共享内存（匿名的和具名的）
   4、远程过程调用（Solaris门和Sun RPC）

##### **2、** socket 基本操作

##### socket  bind

```
//创建socket文件描述符，对应于普通文件的发开操作fopen,返回文件指针（socket文件//描/述）
int socket(int domain, int type, int protocol);

/*domain,即协议域，又称为协议族（family）常用：
   AF_INET：用于网络通信  （用于ipv4地址（32位的）与端口号（16位的））
   AF_UNIX：单一Unix系统中进程间通信
type：指定socket类型。
  SOCK_STREAM：流式，面向连接的比特流，顺序、可靠、双向，用于TCP通信
  SOCK_DGRAM： 数据报式，无连接的，定长、不可靠  UDP通信
protocol：故名思意，就是指定协议。通常为0，表示domain和type默认的协议
  常用的协议有，IPPROTO_TCP、IPPTOTO_UDP、IPPROTO_SCTP、IPPROTO_TIPC等，它们分别对应TCP传输协议、UDP  传输协议、STCP传输协议、TIPC传输协议
*/
当我们调用socket创建一个socket时，返回的socket描述字它存在于协议族中，但没有一个具体的地址。如果想要给它赋值一个地址，就必须调用bind()函数，否则就当调用connect()、listen()时系统会自动随机分配一个端口。
因此，在创建完socket以后，需要将一个地址绑定到socket上，则需要bind
// 绑定端口号 (TCP/UDP, 服务器)   把一个ipv4或ipv6地址和端口号组合赋给socket。该函数调用成功返回0，失败返回-1
int bind(int socket, const struct sockaddr *address, socklen_t address_len);
   sockfd：即socket描述字，它是通过socket()函数创建了，唯一标识一个socket。bind()函数就是将给这个描述字绑定一个名字
   addr：一个const struct sockaddr *指针，指向要绑定给sockfd的协议地址。这个地址结构根据地址创建socket时的地址协议族的不同而不同，
   addrlen：对应的是地址的长度。
```
##### listen()、connect()函数  

 通常服务器在启动的时候都会绑定一个众所周知的地址（如ip地址+端口号），用于提供服务，客户就可以通过它来接连服务器；而客户端就不用指定，由系统自动分配一个端口号和自身的ip地址组合。这就是为什么通常服务器端在listen之前会调用bind()，而客户端就不会调用，而是在connect()时由系统随机生成一个。

如果作为一个服务器，在调用socket()、bind()之后就会调用listen()来监听这个socket，如果客户端这时调用connect()发出连接请求，服务器端就会接收到这个请求。

```
// 开始监听socket (TCP, 服务器) 
int listen(int socket, int backlog);
// 建立连接 (TCP, 客户端)
int connect(int sockfd, const struct sockaddr *addr,  socklen_t addrlen)
   listen函数的第一个参数即为要监听的socket描述字，第二个参数为相应socket可以排队的最大连接个数。socket()函数创建的socket默认是一个主动类型的，listen函数将socket变为被动类型的，等待客户的连接请求。 
   connect函数的第一个参数即为客户端的socket描述字，第二参数为服务器的socket地址，第三个参数为socket地址的长度。客户端通过调用connect函数来建立与TCP服务器的连接。

```

##### accept()函数

TCP服务器端依次调用socket()、bind()、listen()之后，就会监听指定的socket地址了。TCP客户端依次调用socket()、connect()之后就想TCP服务器发送了一个连接请求。TCP服务器监听到这个请求之后，就会调用accept()函数取接收请求，这样连接就建立好了。之后就可以开始网络I/O操作了，即类同于普通文件的读写I/O操作。

```
int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen);
   accept函数的第一个参数为服务器的socket描述字，第二个参数为指向struct sockaddr *的指针，用于返回客户端的协议地址，第三个参数为协议地址的长度。如果accpet成功，那么其返回值是由内核自动生成的一个全新的描述字，代表与返回客户的TCP连接。
   注意：accept的第一个参数为服务器的socket描述字，是服务器开始调用socket()函数生成的，称为监听socket描述字；而accept函数返回的是已连接的socket描述字。一个服务器通常通常仅仅只创建一个监听socket描述字，它在该服务器的生命周期内一直存在。内核为每个由服务器进程接受的客户连接创建了一个已连接socket描述字，当服务器完成了对某个客户的服务，相应的已连接socket描述字就被关闭。 
```

##### recvfrom()/sendto()

```
recvfrom()/sendto()中的struct sockaddr *，recvfrom一般的场景是远端向服务器或者服务器向远端，所以不需要填充，
而sendto需要填充，因为它必须知道要发给谁，定义在循环的外面
向一指定目的地发送数据。
只有当udp服务器绑定或者客户端向服务器发送消息时才需要填参
ssize_t sendto(int sockfd, const void *buf, size_t len, int flags,
                      const struct sockaddr *dest_addr, socklen_t addrlen);
接收一个数据报并保存源地址。
ssize_t recvfrom(int sockfd, void *buf, size_t len, int flags,
                        struct sockaddr *src_addr, socklen_t *addrlen);
```

至此服务器与客户已经建立好连接了。可以调用网络I/O进行读写操作了，，调用recvfrom()/sendto()

##### close()函数

在服务器与客户端建立连接之后，会进行一些读写操作，完成了读写操作就要关闭相应的socket描述字，好比操作完打开的文件要调用fclose关闭打开的文件。

```
#include <unistd.h>
int close(int fd);
```

#### 简单的UDP网络程

```c++
//makefile

.PHONY:all
all:udp_client udp_server
udp_client:udp_client.cc
	g++ -o $@ $^ -std=c++11
udp_server:udp_server.cc
	g++ -o $@ $^ -std=c++11
.PHONY:clean
clean:
	rm -f udp_client udp_server

//udp_client.hpp
#pragma once

#include <iostream>
#include <string>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <strings.h>

class Client{
    private:
        int sockfd;
        std::string peer_ip;
        short peer_port;
    public:
        Client(std::string _peer_ip= "127.0.0.1", short _peer_port=8080)
            :sockfd(-1), peer_ip(_peer_ip), peer_port(_peer_port)
        {
        }
        void InitClient()
        {
            sockfd = socket(AF_INET, SOCK_DGRAM, 0);
            if(sockfd < 0){
                std::cerr << "socket error ..." << std::endl;
                exit(2);
            }
        }
        void Run()
        {
            std::string message;
            struct sockaddr_in server;
            server.sin_family = AF_INET;
            server.sin_port = htons(peer_port);
            server.sin_addr.s_addr = inet_addr(peer_ip.c_str());

            socklen_t len = sizeof(server);
            char buf[1024];
            struct sockaddr_in temp;
            int flag = 1;
            while(1){
                socklen_t len = sizeof(temp);
                if(flag){
                  std::cout << "请输入你要发送的信息# ";
                  std::cin >> message;
                  sendto(sockfd, message.c_str(), message.size(), 0, (struct sockaddr*)&server, len);//将sockfd发送到server
                  flag = 0;
                }
                ssize_t s = recvfrom(sockfd, buf, sizeof(buf)-1, 0, (struct sockaddr*)&temp, &len);//因为肯定是服务器发送给客户的，所以不要填充
                if(s > 0){
                    buf[s] = 0;//这里buf[s]要清零，如果不清话会重生冗余
                    std::cout << "server echo# " << buf << std::endl;
                }
            }
        }

        ~Client()
        {
            if(sockfd >= 0){
                close(sockfd);
            }
        }
};

//udp_client.cc
#include "udp_client.hpp"

void Usage(std::string _proc)
{
    std::cout << _proc << " server_ip server_port" << std::endl;
}

//./udp_client server_ip server_port
int main(int argc, char *argv[])
{
    if(argc != 3){
        Usage(argv[0]);
        exit(1);
    }
    Client *cli = new Client(argv[1], atoi(argv[2]));
    cli->InitClient();
    cli->Run();
    return 0;
}
//udp_server.hpp
#pragma once

#include <iostream>
#include <string>
#include <vector>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <strings.h>
#include <sys/wait.h>
    private:
        short port;
        std::string ip;
        int sockfd;
    public:
        Server(std::string _ip="127.0.0.1", short _port = 8080):ip(_ip), port(_port), sockfd(-1)
        {
        }
        void InitServer()
        {
            sockfd = socket(AF_INET, SOCK_DGRAM, 0);
            if(sockfd < 0){
                std::cerr << "socket error..." << std::endl;
                exit(2);
            }

            struct sockaddr_in local;
            bzero(&local, sizeof(local));
            local.sin_family = AF_INET;
            local.sin_port = htons(port);
            local.sin_addr.s_addr = inet_addr(ip.c_str());//点分十进制IP转成整形ip，host -> net
//绑定的时候需要填充
            if(bind(sockfd, (struct sockaddr*)&local, sizeof(local)) == 0){
                std::cout << "server run on " << ip << " : " << port << " ... success." << std::endl;
            }else{
                std::cerr << "bind error..." << std::endl;
                exit(3);
            }
        }
        //接受数据并打印
        void Run()
        {
            std::vector<struct sockaddr_in> v;
            char buf[1024];
            struct sockaddr_in peer;
            for(;;){
            //收到来自于客户端的，不需要填参，客户端的信息会被自动填充到peer
                socklen_t len = sizeof(peer);
                ssize_t size = recvfrom(sockfd, buf, sizeof(buf)-1, 0, (struct sockaddr*)&peer, &len);
                if(size > 0){
                    buf[size] = 0;
                    std::string client_ip = inet_ntoa(peer.sin_addr);
                    int client_port = ntohs(peer.sin_port);
                    std::cout << client_ip << ":"<< client_port << " # "<< buf << std::endl;
                    v.push_back(peer);
                    std::vector<struct sockaddr_in>::iterator it = v.begin();
                    for(; it != v.end(); it++){
                        sendto(sockfd, buf, strlen(buf), 0, (struct sockaddr*)&(*it), len);
                    }
                    std::string cmd = buf;
                    if(cmd == "ls"){
                        if(fork() == 0){
                          execl("/usr/bin/ls", "ls" ,"-al", NULL);
                          exit(1);
                        }
                        wait(nullptr);
                    }
                    if(cmd == "vim"){
                        if(fork() == 0){
                          execl("/usr/bin/vim", "vim", NULL);
                          exit(1);
                        }
                        wait(nullptr);
                    }
                }
            }
        }
        ~Server()
        {
            if(sockfd >= 0){
              close(sockfd);
            }
        }
};

//udp_server.cc

#include "udp_server.hpp"

void Usage(std::string _port)
{
    std::cout << _port << " ip port" << std::endl;
}
//./udp_server ip port
int main(int argc, char *argv[])
{
    if(argc != 3){
        Usage(argv[0]);
        exit(1);
    }
    Server *sp = new Server(argv[1], atoi(argv[2]));
    sp->InitServer();
    sp->Run();
    return 0;
}


```

#### tcp

```
////////////////////////////  
//tcp_server.hpp
#include <iostream>
#include <string>
#include <string.h>
#include <string.h>
#include <unordered_map>
#include <signal.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

class Dict{
    private:
        std::unordered_map<std::string, std::string> dict;
    public:
        Dict()
        {
            dict.insert({
                    {"apple", "苹果"},
                    {"banana", "香蕉"},
                    {"old", "老的"},
                    {"phone", "电话"},
                    });
        }
       // void InitDict()
       // {
       //     //fstream打开文件，用文件内容填充你的字典
       // }
        std::string Search(const std::string &k)
        {
            std::unordered_map<std::string, std::string>::const_iterator it = dict.find(k);
            if(it == dict.end()){
                return "查不到";
            }
            return it->second;
        }
        ~Dict()
        {
        }
};

class Server{
    private:
        std::string ip;
        short port;
        int listen_sock;
        static Dict d;
    public:
        Server(std::string _ip, short _port)
            :ip(_ip), port(_port),listen_sock(-1)
        {}
        void InitServer()
        {
            listen_sock = socket(AF_INET, SOCK_STREAM, 0);
            if(listen_sock < 0){
                std::cerr << "socket error!" << std::endl;
                exit(2);
            }
            struct sockaddr_in local;
            bzero(&local, sizeof(local));
            local.sin_family = AF_INET;
            local.sin_port = htons(port);
            local.sin_addr.s_addr = inet_addr(ip.c_str());

            if(bind(listen_sock, (struct sockaddr*)&local, sizeof(local)) < 0){
                std::cerr << "bind error!" << std::endl;
                exit(3);
            }

            if(listen(listen_sock, 5) < 0){
                std::cerr << "listen error!" << std::endl;
                exit(4);
            }
        }
        static void *ServiceIO(void *args)
        {
            int *p = (int*)args;
            int fd = *p;
            delete p;

            char buf[1024];
            while(1){
                ssize_t s = read(fd, buf, sizeof(buf)-1);
                if(s > 0){
                    buf[s] = 0;
                    std::string q = buf;
                    if(q == "q" || q == "quit"){
                        std::cout << "client ... quit" << std::endl;
                        break;
                    }
                    std::string value = d.Search(q);
                    std::cout << "client# " << q << "->" << value << std::endl;
                    write(fd, value.c_str(), value.size());
                }
                else if(s == 0){
                    std::cout << "client ... quit" << std::endl;
                    break;
                }
                else{
                    std::cerr << "read ... error" << std::endl;
                    break;
                }
            }
            close(fd);
            std::cout << "service .... done" << std::endl;
        }
        
        void Start()
        {
            signal(SIGCHLD, SIG_IGN);
            for( ; ; ){
                struct sockaddr_in peer;
                socklen_t len = sizeof(peer);
                int fd = accept(listen_sock, (struct sockaddr*)&peer, &len);
                if(fd < 0){
                    std::cerr << "accept error!" << std::endl;
                    continue;
                }
                std::cout << "get a linking ... [" << inet_ntoa(peer.sin_addr) << ":" << ntohs(peer.sin_port) << "]" << std::endl;
                pthread_t tid;
                int *p = new int(fd);
                pthread_create(&tid, nullptr, ServiceIO, (void*)p);

                //fd -> io 服务
       //         pid_t id = fork();
       //         if(id == 0){
       //             //child
       //             close(listen_sock);
       //             ServiceIO(fd);
       //             exit(0);
       //         }
       //         close(fd);
            }
        }
        ~Server()
        {
            if(listen_sock >= 0){
                close(listen_sock);
            }
        }

};
Dict Server::d;

//////////////////////////////////////////////////////////
//tcp_server.cc
#include "tcp_server.hpp"

void Usage(std::string proc)
{
    std::cout << proc << " ip port" << std::endl;
}

// ./tcp_server ip port
int main(int argc, char *argv[])
{
    if(argc != 3){
        Usage(argv[0]);
        exit(1);
    }
    std::string ip = argv[1];
    int port = atoi(argv[2]);

    Server *sp = new Server(ip, port);
    sp->InitServer();
    sp->Start();

    return 0;
}

////////////////////////////////////////////////
//tcp_client.hpp
#include <iostream>
#include <stdlib.h>
#include <unistd.h>
#include <string>
#include <string.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/types.h>


class Client{
    private:
        int sockfd;
        std::string svr_ip;
        int svr_port;

    public:
        Client(std::string _ip, int _port):svr_ip(_ip), svr_port(_port), sockfd(-1)
        {}
        void InitClient()
        {
            sockfd = socket(AF_INET, SOCK_STREAM, 0);
            if(sockfd < 0){
                std::cout << "socket error!" << std::endl;
                exit(2);
            }
            std::cout << "init client ... success" << std::endl;
        }
        void Connect()
        {
            struct sockaddr_in svr;
            svr.sin_family = AF_INET;
            svr.sin_port = htons(svr_port);
            svr.sin_addr.s_addr = inet_addr(svr_ip.c_str());

            if(connect(sockfd, (struct sockaddr*)&svr, sizeof(svr)) == 0){
                std::cout << "connect ... success" << std::endl;
            }
            else{
                std::cout << "connect ... failed" << std::endl;
                exit(3);
            }
        }
        void Start()
        {
            std::string message;
            char buf[1024];
            while(1){
                std::cout << "Please Enter Your Message# ";
                std::cin >> message;
                write(sockfd, message.c_str(), message.size());
                if(message == "q" || message == "quit"){
                    break;
                }

                ssize_t s = read(sockfd, buf, sizeof(buf)-1);
                if(s > 0){
                    buf[s] = 0;
                    std::cout << "Server Echo# " << buf << std::endl;
                }
            }
            std::cout << "quit!" << std::endl;
        }
        ~Client()
        {
            if(sockfd >= 0){
                close(sockfd);
            }
        }
};
/////////////////////////////////////////////////////
//tcp_client.cc
#include "tcp_client.hpp"

void Usage(std::string proc)
{
    std::cout << proc << " server_ip server_port" << std::endl;
}

// ./tcp_client server_ip server_port
int main(int argc, char *argv[])
{
    if(argc != 3){
        Usage(argv[0]);
        exit(1);
    }
    std::string ip = argv[1];
    int port = atoi(argv[2]);

    Client *cp = new Client(ip, port);
    cp->InitClient();
    cp->Connect();
    cp->Start();

    return 0;
}

```

### 线程池版本的 TCP 服务器

1、客户端不是不允许调用bind(), 只是没有必要调用bind()固定一个端口号. 否则如果在同一台机器上启动 多个客户端, 就会出现端口号被占用导致不能正确建立连接; 服务器也不是必须调用bind(), 但如果服务器不调用bind(), 内核会自动给服务器分配监听端口, 每次启动 服务器时端口号都不一样, 客户端要连接服务器就会遇到麻烦

```c++
//makefile
cc=g++

.PHONY:all
all:Client Server

Client:Client.cc
	$(cc) -o $@ $^ -std=c++11
Server:Server.cc
	$(cc) -o $@ $^ -lpthread -std=c++11

.PHONY:clean
clean:
	rm -f Client Server


//Protocol.hpp

#pragma once
#include <iostream>
#include <string>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdlib.h>

#define BACK_LOG 5
//工具类
//Util
//
//socket类
class Sock{
    public:
        static int Socket()
        {
            int sock = socket(AF_INET, SOCK_STREAM, 0);
            if(sock < 0){
                std::cerr << "socket error!" << std::endl;
                exit(2);
            }
            return sock;
        }
        static void Bind(int sockfd, std::string ip, int port)
        {
            struct sockaddr_in local;
            bzero(&local, sizeof(local));
            local.sin_family = AF_INET;
            local.sin_port = htons(port);
            local.sin_addr.s_addr = inet_addr(ip.c_str());

            if(bind(sockfd, (struct sockaddr*)&local, sizeof(local)) < 0){
                std::cerr << "bind error" << std::endl;
                exit(3);
            }
        }
        static void Listen(int sockfd, int backlog)
        {
            if(listen(sockfd, backlog) < 0){
                std::cerr << "listen error" << std::endl;
                exit(4);
            }
        }
        static int Accept(int sockfd)
        {
            struct sockaddr_in peer;
            socklen_t len = sizeof(peer);
            int _sock = accept(sockfd, (struct sockaddr*)&peer, &len);
            if(_sock < 0){
                std::cerr << "accept error!" << std::endl;
            }
            else{
                std::cout << "获取一个新链接..." << std::endl;
            }

            return _sock;
        }
        static void Connect(int sockfd, std::string peer_ip, int peer_port)
        {
            struct sockaddr_in pee:r;
            bzero(&peer, sizeof(peer));
            peer.sin_family = AF_INET;
            peer.sin_port = htons(peer_port);
            peer.sin_addr.s_addr = inet_addr(peer_ip.c_str());

            if(connect(sockfd, (struct sockaddr*)&peer, sizeof(peer)) < 0){
                std::cerr << "connect erro" << std::endl;
                exit(3);
            }
        }
        static void Send(int sockfd, std::string &msg)
        {
            write(sockfd, msg.c_str(), msg.size());
        }
        //Recv,Send
        static bool Recv(int sockfd, std::string &output)
        {
            char buf[1024];
            bool ret = true;
            ssize_t s = read(sockfd, buf, sizeof(buf)-1);
            if(s > 0){
                buf[s] = 0;
                output = buf;
            }
            else if(s == 0 ){
                std::cout << "对方关闭链接..." << std::endl;
                close(sockfd);
                ret = false;
            }
            else{
                std::cout << "读取错误..." << std::endl;
                close(sockfd);
                ret = false;
            }

            return ret;
        }
};



// Server.hpp

#pragma once

#include <iostream>
#include "Protocol.hpp"
#include "ThreadPool.hpp"

class Server{
    private:
        int listen_sock;
        int port;
        std::string ip;
        ThreadPool tp;

    public:
        Server(std::string _ip, int _port):ip(_ip), port(_port), listen_sock(-1), tp(10){}

        void InitServer()
        {
            listen_sock = Sock::Socket();
            Sock::Bind(listen_sock, ip, port);
            Sock::Listen(listen_sock, BACK_LOG);
            tp.InitThreadPool();
        }
        void Start()
        {
            for(;;){
                std::string message;
                int sock = Sock::Accept(listen_sock);
                if(sock >= 0){
                    Task t(sock);
                    tp.PushTask(t);
                }
            }
        }
        ~Server()
        {
            if(listen_sock < 0){
                close(listen_sock);
                listen_sock = -1;
            }
        }
};



//// Server.cc
#include "Server.hpp"

void Usage(std::string proc)
{
    std::cout << "Usage: " << proc << " local_ip local_port" << std::endl;
}
int main(int argc, char *argv[])
{
    if(argc != 3){
        Usage(argv[0]);
        exit(1);
    }

    int port = atoi(argv[2]);
    std::string ip = argv[1];
    
    Server *sp = new Server(ip, port);
    sp->InitServer();
    sp->Start();

    return 0;
}


//Client.hpp

#pragma once

#include <iostream>
#include "Protocol.hpp"

class Client{
    private:
        int sock;
        int port;
        std::string ip;
    public:
        Client(std::string _ip, int _port):ip(_ip), port(_port),sock(-1){}
        void InitClient()
        {
            sock = Sock::Socket();
            Sock::Connect(sock, ip, port);
        }
        void Start()
        {
            while(1){
                std::string output;
                std::cout <<"请输入# ";
                std::string input;
                std::cin >> input;
                Sock::Send(sock, input);

                if(Sock::Recv(sock, output)){
                    std::cout << "服务器回显# " << output << std::endl;
                }
                else{
                    break;
                }
            }
        }
        
        ~Client()
        {
            if(sock < 0){
                close(sock);
                sock = -1;
            }
        }
};



//Client.cc

#include "Client.hpp"

void Usage(std::string proc)
{
    std::cout << "Usage: " << proc << " server_ip server_port" << std::endl;
}
int main(int argc, char *argv[])
{
    if(argc != 3){
        Usage(argv[0]);
        exit(1);
    }

    int port = atoi(argv[2]);
    std::string ip = argv[1];
    
    Client *cp = new Client(ip, port);
    cp->InitClient();
    cp->Start();

    return 0;
}


//ThreadPool.hpp


#pragma once

#include <iostream>
#include <queue>
#include <pthread.h>
#include "Task.hpp"

class ThreadPool{
    private:
        int num;
        std::queue<Task> q;
        pthread_mutex_t lock;
        pthread_cond_t cond;
    public:
        ThreadPool(int _num = 5):num(_num)
        {
            pthread_mutex_init(&lock, nullptr);
            pthread_cond_init(&cond, nullptr);
        }
        bool IsEmpty()
        {
            return q.empty();
        }
        void LockQueue()
        {
            pthread_mutex_lock(&lock);
        }
        void UnlockQueue()
        {
            pthread_mutex_unlock(&lock);
        }
        void ThreadWait()
        {
            std::cout << "thread " << pthread_self() << " wait..." << std::endl;
            pthread_cond_wait(&cond, &lock);
        }
        void WakeUp()
        {
            std::cout << "thread " << pthread_self() << " wakeup, handler task..." << std::endl;
            pthread_cond_signal(&cond);
        }
        void PopTask(Task &t)
        {
            t = q.front();
            q.pop();
        }
        void PushTask(Task &t)
        {
            LockQueue();
            q.push(t);
            UnlockQueue();
            WakeUp();
        }
        static void *HandlerTask(void *arg)
        {
            pthread_detach(pthread_self());
            ThreadPool *tp = (ThreadPool*)arg;
            for(;;){
                Task t;
                tp->LockQueue();
                while(tp->IsEmpty()){
                    tp->ThreadWait();
                }
                tp->PopTask(t);
                tp->UnlockQueue();
                t.Run();
            }
        }
        void InitThreadPool()
        {
            for(auto i = 0; i < num; i++){
                pthread_t tid;
                pthread_create(&tid, nullptr, HandlerTask, (void*)this);
            }
        }
        ~ThreadPool()
        {
            pthread_mutex_destroy(&lock);
            pthread_cond_destroy(&cond);
        }
};



//Task.hpp
#pragma once

#include <iostream>
#include <string>
#include <pthread.h>
#include "Protocol.hpp"

class Task{
    private:
        int sock;
    public:
        Task(){}
        Task(int _sock):sock(_sock){}
        void Run()
        {
            std::cout << "Task ID: " << sock << " handler thread is : " << pthread_self() << std::endl;
            std::string message;
            while(1){
                if(!Sock::Recv(sock, message)){
                    break;
                }
                std::cout <<"消息# " << message << std::endl;
                Sock::Send(sock, message);
            }
            close(sock);
        }
        ~Task()
        {
            //close(sock);
        }
};

```

