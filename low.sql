
--Database 中只有表 不能嵌套
--对数据库的修改主要指修改数据库的字符集，校验规则
--* 表示全列
--标识符不区分大小写
--gb2312 汉字编码 10000000 100000000   
--gbk 100000000 000000000  (比gb2312包括更多的汉字)
--utf8 110xxxxx 100000000 000000000   目前在中国的utf8在mysql是三字节  (万国码)
--big5 是繁体
--sc  简化汉字 
system clear --清屏 和linux下不一样
mysql -uroot;  --进入mysql
service mysqld start  --启动数据库服务
service mysqld restart --数据库重启
service mysqld stop  --数据库停止

create database data1;  --创建数据库
use data1;
create table student2(
id int,
name  varchar(20),
gender varchar(2)
);
insert into student (id,name,gender) values (1,'张三','男');
insert into student (id,name,gender) values (2,'李四',"女");
insert into student (id,name,gender) values (3,'王五',"男");
--mysql中，其实单引号和双引号没啥区别，单引号和双引号都可以表示字符串
--mysql的别名可以不加引号，如果加引号，单引号和双引号以及反引号都可以

select *from student2;  --查询表的数据
-- 查看默认校验规则，字符集 引擎
show variables like 'character_set_database';
show variables like 'collation_database';
show engines;
--使用
create database db1 charset utf8 collate utf8_general_ci;
alter database db1 charset utf8; --修改数据库，主要是字符集和校验规则
alter database db1 collate utf8_general_ci;  --字符集和校验规则不能一起改
drop database  db1 --删库
show engines \G; --显示存储引擎
 
 
--数据库改名
--1 
 -- rename database data1 to newdate2;  好像无法改库名 可以改表名
 show processlist --查看连接情况
 show create database db1;

--表的操作  insert drop update(更新)  alter(修改) select(重要)
show tables;  --显示创建的表
show create table test1;  --显示表的具体性质  （存储引擎 字符集 校验规则）
rename table data1 to newdate2;  --改表名  可能数据丢失   或者直接备份然后恢复成另一个表名

--库的字符集和校验规则和表的字符集校验规则
create database db1 charset utf8 collate utf8_general_ci;  --库不存在引擎，只有表可以
create table test2(
id int,
name varchar(20))  charset utf8  collate utf8_general_ci engine InooDB; --charset= utf8 , collate =utf8_general_ci ,engine =InooDB; 一样，不区分， =


create table student3(
id int,
name  varchar(20),
gender varchar(2)
)  engine MyISAM;
insert into student3 (id,name,gender) values (1,'张三','男');
insert into student3 (id,name,gender) values (2,'李四',"女");
insert into student3 (id,name,gender) values (3,'王五',"男");
select *from student3;

show create table student3; 
desc student3;  --查看表

drop table users;

create table users(
 id int,
 name varchar(20) comment '用户名',
 password char(32) comment '密码是32位的md5值',
 birthday date comment '生日' ) character set utf8 engine MyISAM;
 
 insert into users values(1,'a','b','1982-01-04'),(2,'b','c','1984-01-04');
--在users 表添加一个字段，用于保存图片路径
alter table users add assets varchar(100) comment '图片路径' after birthday;  
alter table users add gender varchar(10) comment '性别' after name;
alter table users add id int comment '身份证' first;  --加到第一列
 select *from users;
 alter table users modify name varchar(60); --修改name,将其长度改为60
 alter table users drop id;  --删掉id列
 alter table users rename to people;
 alter table people change name xingming varchar(30);
  select *from people;
 show full columns from test; --显示所有注释
 --或者
 show create table test;
 
  
-----------------------5表的约束 各种键---------------------------------------
  
  create table myclass(
  id int unsigned default 0,
  class_name varchar(20) not null,
  class_room varchar(20) not null,
  sex char(2) not null default '男'
  );
  
  --zerofull
  alter table myclass change id  id int(5) zerofill;
  --主键 （不能为空，不能重复 只能有一个主键） 在创建表的时候加主键  可以复合主键，但只能有一个主键  
  create table keyt(
  id int unsigned,
  course char(10) comment'课程',
  score tinyint unsigned default 60 comment'成绩',
  primary key(id ,course)
  );
   select *from keyt;
  alter table keyt add primary key (score);  --增加主键 当不存在主键时可以成功加入主键，因为只能有一个主键
  alter table keyt drop primary key; --删除主键
  insert into keyt values (1,'语文',80);
  insert into keyt values (1,'语文',80);
  
  --自增长  前提是有主键
  auto_increment
  insert into keyt(course,score) values('语文',80);
 select last_insert_id();  --获取上次auto_inscrment的值
 
 --唯一键   （可以为空  不能重复 有多个主键）  
 alter table keyt change course course char(10) unique comment '课程不能为空';
  alter table keyt change id id int(10) unique comment '身份不能为空';
  alter table keyt change id id int(10) unique;
  create table test3(
  id int unsigned,
  course char(10) unique comment'课程',
  score tinyint unsigned unique default 60 comment'成绩'
  );
  --外键  foreign key   MyISAM 不存在外键 只有InnoDB 有外键
  --主表
  create table myclass1(
  id int primary key,
  name varchar(20) not null comment'班级名'
  );
  --从表
  create table stu(
  id int primary key,
  name varchar(30) not null ,
  class_id int,
  foreign  key (class_id) references myclass1(id)
  );
  insert into myclass1 values (10,'533'),(20,'213');
  
insert into stu values (64546,'zhang',20);
insert into stu values (64546,'li',30);  --主表中没有30这个班级
-----------------------数据类型----------------------------------------------------------------------
--float  32位
--double  ()
create table tt1(num tinyint);
insert into tt1 values(1);
select *from tt1;

create table bt (num1 tinyint,num2 bit(8));   --bit类型显示的时ASCII码的对应值
insert into bt values(65,97);
insert into bt values(65,35);
insert into bt values(65,48);
select *from bt;


--decimal(m,d)[unsigned]:m是有效长度 d是小数点的位数 m省略 默认10 d省略 默认0
--decimal 和float很像 区别在于flaot最大精度为7，decimal最大精度为30，m最大为65
create table dectest (
id int,
salary float(10,8),
salary2 decimal(10,8)
);
insert into dectest values(100,23.12345612, 23.12345612);  
--char varchar()
--char(L)  固定长度字节数(L*单位字节)，最大255字节  L表示字符串的长度  ‘ab’ ->2
--varchar(L) 可变长度 最大65535字节

create table chartest (
str1 char(3),  
str2 varchar(3)
);
insert into chartest values('abc','abc');
insert into chartest values('abcd','abcd');   --只能存储3个字符长度的
select *from chartest;

--utf8  是3字节存储 ，1-3个字节用于记录数据大小，所以65532/3=21844 最多存的长度 每个字符为3字节
--gbk  是2字节存储,所以65532/2=32766 最多存的长度 每个字符为2字节
--这个可以
create table chartest1 (  
str2 varchar(32766)       
)charset = gbk;
--不行
 create table chartest2 (  
str2 varchar(32767)
)charset = gbk;
  
--日期类

create table datetest (
t1 datetime,  
t2 date,
t3 timestamp
);
insert into datetest(t1,t2) values('2019-12-11-15-21-23','2019-12-11');
insert into datetest(t1,t2) values('2019-12-11 15:22:59','2019-12-11');
insert into datetest(t1,t2) values('2019-12-11 15:22:59','2019-12-11');
select *from datetest;

--enum set
create table votes(
username varchar(30),
hobby set('登山','游泳','篮球','武术'),
gender enum('男','女')
);
 drop table votes;
insert into votes values('雷锋', '登山,武术', '男');
insert into votes values('Juse','登山,武术',2); select * from votes where gender=2;

select *from votes where hobby='登山';   --只能找到爱好只有登山的

select *from votes where find_in_set('登山',hobby);--找到爱好包括登山的

 







