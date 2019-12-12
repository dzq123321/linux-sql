--键的综合案例
create table `good`(
goods_id int primary key auto_increment comment '商品编号',
goods_name varchar(20) not null comment '商品名',
price varchar(10) not null default 0 comment '商品单价',
category varchar(12) comment '商品类别',
provider varchar(64) not null comment '供应商'
);
create table `customer`(
customer_id int primary key auto_increment comment '客户编号',
name varchar(32) not null comment '客户名',
address varchar(50) not null  comment '住址',
email char(20) not null  unique comment '邮件',
sex enum ('男','女') not null  comment '性别',
card_id char(18) not null  comment '性别'
);

create table `purchase`(
order_id int primary key auto_increment comment '订货编号',
customer_id int  comment '客户编号',
goods_id int  comment '商品编号',
nums int default 0 comment '购买数量',
foreign key (goods_id) references good(goods_id),
foreign key (customer_id) references customer(customer_id)
);
--表的增删查改  create retrieve updata delete alter
create table stu(
id int unsigned primary key auto_increment,
sn int not null unique comment '学号',
name varchar (20) not null,
qq varchar(20) default 0
);
insert into stu (id,sn,name) values(100,10000,'唐三藏');
insert into stu (id,sn,name) values(101,10001,'孙悟空');
--当键冲突时可以进行更新
insert into stu (id,sn,name) values(101,10002,'曹操') on duplicate key update sn=10002,name='曹操';
--当键冲突时删除在加入
replace into stu (id,sn,name) values(101,10001,'曹贼');
--select------------------------------------------------最重要-------------------
--select [distinct] {*| cloumn [,cloumn]...) [from table_name] [where ...] [order by cloumn [ASC|DESC]]  Limit...
CREATE TABLE exam_result (
  id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT, 
  name VARCHAR(20) NOT NULL COMMENT '同学姓名',
  yuwen float DEFAULT 0.0 COMMENT '语文成绩',
  shuxue float DEFAULT 0.0 COMMENT '数学成绩',
  yingyu float DEFAULT 0.0 COMMENT '英语成绩' );

INSERT INTO exam_result (name, yuwen, shuxue, yingyu) VALUES
   ('唐三藏', 67, 98, 56),
   ('孙悟空', 87, 78, 77),
   ('猪悟能', 88, 98, 90),
   ('曹孟德', 82, 84, 67),
   ('刘玄德', 55, 85, 45),
   ('孙权', 70, 73, 78),
   ('宋公明', 75, 65, 30);

rename table exam_result to grade;
 select *from grade;

--指定列查询
select id,name,yingyu from grade;
--指定字段为表达式
select id,name,10 from grade;
select id,name,yingyu+10 from grade;
select id,name,yingyu+shuxue+yuwen as total from grade;
--distinct 去重
select distinct id,name,yingyu from grade;
select  id,name,distinct shuxue from grade;

--where
--运算符  is null      is not null
--<=> (等于 null安全)  
--！=,<>  不等
--between a0 and a1  范围[a0,a1]  返回1
--in(option,..) 如果是option中的一个，返回1
--like 模糊匹配 like% 表示多个字符，保护0字符  like_表示一个字符  %的应用广
-- 逻辑运算的  and or not
select id, name , yingyu from grade where yingyu > 90;
select id,name,yuwen from grade where shuxue between 80 and 90;
select id,name,shuxue from grade where shuxue in(58,59,98,99);
select id,name from grade where name like '孙%';--模糊匹配
select id,name,yingyu+shuxue+yuwen as total from grade where total >200;
select id,name,yingyu+shuxue+yuwen  from grade where yingyu + shuxue + yuwen >200;
--语文成绩>80 并不姓孙
select id,name, yuwen from grade where yuwen >80 and name not like '孙%';

--孙某同学，否则要求总成绩 > 200 并且 语文成绩 < 数学成绩 并且 英语成绩 > 80 
select id,name,yingyu+shuxue+yuwen as total from grade where name like '孙_' or yingyu+shuxue+yuwen>200 and yuwen < shuxue and yingyu >80;
--查询qq是null同学的姓名
select id,sn,name from stu where qq is  null;

----结果排序   order by  只有order可以使用别名
--ASC (默认)为升序 DESC为降序
--同学及数学成绩，按数学成绩升序显示
select id ,name ,shuxue from grade order by shuxue asc;  --DESC
-- 查询同学各门成绩，依次按 数学降序，英语升序，语文升序的方式显示
select id ,name ,shuxue,yingyu, yuwen from grade order by shuxue DESC,yingyu asc,yuwen asc;
--查询同学及总分，由高到低
select id,name,yingyu+shuxue+yuwen as total from grade order by total DESC;

--查询姓孙的同学或者姓曹的同学数学成绩，结果按数学成绩由高到低显示
select id,name,shuxue from grade where name like '孙%' or  name like '曹%'  order by shuxue ;
select distinct shuxun from grade;
--limit 筛选分页结果
select id,name,shuxue from grade where name like '孙%' or  name like '曹%'  order by shuxue  limit 1 offset 2;
--update   update table_name set column = exper [, clumn2=exper] [where ...] [order by ] [limit ...]
--将孙悟空同学的数学成绩变更为 80 
--查询
select id,name ,shuxue from grade where name like '孙悟空';
update grade set shuxue = 80 where name like '孙悟空';
  --将曹孟德同学的数学成绩变更为 60 分，语文成绩变更为 70 分
  update grade set shuxue=60 ,yuwen=70 where name='曹孟德' ;
select *from grade;
--将总成绩倒数前三的 3 位同学的数学成绩加上 30 分  order by 默认从小到大排列
update grade set shuxue=shuxue+30 order by shuxue+yuwen+yingyu limit 3;
--将所有同学的语文成绩更新为原来的 2 倍
update grade set yuwen=yuwen*2;

--Delete  ---delete from table_name [where...] [order by ...] [Limit...]
--删除孙悟空同学的考试成绩
delete from grade where name='孙悟空';
--截断表
--truncate [table] table_name 重置AUTO_INCREMENT 的值
CREATE TABLE for_truncate (
id INT PRIMARY KEY AUTO_INCREMENT comment '身份',
name VARCHAR(20)
);
INSERT INTO for_truncate (name) VALUES ('A'), ('B'), ('C');
SELECT * FROM for_truncate;
TRUNCATE for_truncate;
SELECT * FROM for_truncate;
INSERT INTO for_truncate (name) VALUES ('D');
SELECT * FROM for_truncate;
SHOW CREATE TABLE for_truncate\G;
--插入结果查询 将一个表中有重复数据的结果去重
create table duplicate_table (
id int,
name varchar(20)
);
insert into duplicate_table values
(100, 'aaa'), (100, 'aaa'), (200, 'bbb'), (200, 'bbb'), (200, 'bbb'), (300, 'ccc');
select distinct * from duplicate_table;
--建立新表
create table no_duplicate_table like duplicate_table;
show create table no_duplicate_table;
--将原表去重数据导入
insert into no_duplicate_table select distinct *from  duplicate_table;
show create table no_duplicate_table;
SELECT * FROM no_duplicate_table;
--删掉旧表
drop table duplicate_table;

--聚合操作
-- count([distincture] exper) 返回查询数据的数量   sum avg平均 max min
--统计班级共有多少同学
select count(*) from grade;
--统计数学成绩不及格
select count(shuxue) from grade where shuxue <60;
-- 统计总分成绩不到330

--返回英语最高分 人的信息？
select max(yingyu) from grade; --先找到最大成绩  --90
select id, name, yingyu  from grade where yingyu =90;  --根据成绩=90找到对应人的信息
--将两句话合并如下；
select id, name, yingyu  from grade where yingyu =(select max(yingyu) from grade);

































