# RPiLogger (라즈베리파이 데이터로거)

## 개요
  - 대용량의 측정데이터를 장시간 저장하는 안정적인 데이터로거 제품은 고가임
  - 데이터 접근 측면에서 저장을 주변 로컬 스토리지를 이용하는 경우가 대부분임. 클라우드로 데이터가 빠져나가게 되면 데이터 소유권이 애매해지는 현상이 발생함
  - 시큐리티의 경우에도, 공장/빌딩/가정의 센서 측정 데이터가 외부에 저장되는 것에 대한 반감이 있음. 구글 메일의 경우도 사람들이 안심하고 자신의 개인 메일을 저장해 놓는 문화가 형성될때 까지 꽤 많은 시간이 소요됨
  - 무선센서, 센서수집/저장, 웹서비스 기능을 통합하여 제공
    - RaspberryPi2는 컴퓨팅 성능이 높아지고, Python으로 Hardware pin 제어도 제공하기 때문에, 이전까지는 불가능 했던 하드웨어 Driver 와 서버 SW 의 통합 실행이 가능해 졌다
    - 센서 하드웨어와 웹서비스 서버가 통합된 형태로, 설치 / 설정 / 서비스가 한꺼번에 지원됨

  - 지금까지 WSN 시스템은 원격 서버 저장 기능을 이용하여, 데이터를 손실없이 수집, 저장하려고 노력하였고, 안정화 비용이 너무 높았음
    - 안정적인 무선 네트워크 구성과 100% 수신율의 데이터 저장은 여러가지 문제들로 쉽게 확보하기 어려웠다
    - RPI2는 저렴한 가격에 안정적인 Linux 시스템과 센서 하드웨어 연결을 제공하기 때문에, 안정적 로컬 데이터 저장 장치로 활용될 수 있다

1. 목적
  - 쉽게 사용 가능하고 저렴한 데이터 로거를 만들고 싶음(라즈베리파이)
  - 라즈베리파이에 시계열데이터베이스를 설치하여 대용량의 센싱 데이터를 고속으로 처리
  - 원격 서버에 데이터를 PUT 하여 입력할 수 있으며, 반대로 원격 서버에서 원하는 데이터를 PULL 하여 수집할 수도 있음

1. 규격
  - 하드웨어
    - 라즈베리파이2 + SD카드 + WiFi 동글 + MicroUSB 전원케이블
    - CO2 + 온습도 + LED 보드
    - LED 보드
    - Kmote
    - 통합센서

![pic](https://raw.githubusercontent.com/kowonsik/RPiLogger/master/material/logger.png)

  - 소프트웨어
    - Raspbian : 라즈베리파이 OS
    - openTSDB : 시계열 데이터베이스
    - co2_rest.py : 라즈베리파이의 GIO핀에 연결되어 있는 co2 보드에서 센싱한 데이터를 받고 상태를 LED로 표시하며 원격과 로컬에 전송
    - serial_ttyUSB0_rest.py : USB 포트에 연결되어 있는 베이스노드를 통해 들어오는 센싱 데이터를 원격과 로컬에 전송

    - 기능 구분
      - S.Berry(센서기능의 라즈베리파이)
        -  CO2를 센싱하고 상태를 LED로 표시
        -  온도(습도)를 센싱하고 상태를 LED로 표시
      - G.Berry(게이트웨이 기능의 라즈베리파이)
        - Kmote를 연결하고 통합센서와 같은 일반적인 RF 센서의 데이터를 원격의 서버로 전송
        - 온도, 습도, 조도, Co2, 인체감지 통합센서 + (스마트플러그)
      - L.Berry(로거(홈서버) 기능의 라즈베리파이)
        - 시계열데이터베이스(openTSDB)
        - 센싱데이터 로컬에 저장 및 원격 전송

## 라즈베리파이에 시계열데이터베이스(openTSDB)설치

### 자바 설정
<pre>
    이제는 ..../hbase/hbase-env.conf 에 설정을 해 주면됨, JAVA_HOME=/usr/

    (참고)  이전방법
      java -version
      (1.6 이상의 JDK가 설치되어 있어야 함)
      which java
      (라즈베리파이 오라클 자바 설치 방법 : sudo apt-get update && sudo apt-get install oracle-java7-jdk )
      vi /etc/profile
      제일 마지막 줄에 아래 3출 추가
      JAVA_HOME=/usr/
      export JAVA_HOME
      export PATH=$PATH:$JAVA_HOME/bin
      이후 실행 : source /etc/profile
</pre>

<pre>    
     Ubuntu  JDK 설치
      1. OpenJDK 제거
       $ sudo apt-get purge openjdk*

      2. repository 추가
       $ sudo add-apt-repository ppa:webupd8team/java

      3. repository index 업데이트
       $ sudo apt-get update

      4. JDK 설치
       아래의 세가지 버전 중에 자신이 필요한 버전을 설치한다.
       – Java 8 설치
       $ sudo apt-get install oracle-java8-installer
       – Java 7 설치
       $ sudo apt-get install oracle-java7-installer
       – Java 6 설치
       $ sudo apt-get install oracle-java6-installer

       근래 ubuntu 버전7은 없고, 8로 설치
       raspberrypi는 버전7 설치 가능

</pre>

<pre>
  '/etc/hosts' 파일에서 '127.0.1.1'을 찾아서 '127.0.0.1'로 수정
   $ sudo vi /etc/hosts
   127.0.0.1       server01

   Telnet 설치, root 로그인 확인
   (ubuntu) Telnet 설치 및 root 접속 허가
   sudo apt-get install telnetd
   sudo apt-get install xinetd
   
   http://thisstory.tistory.com/entry/%EC%9A%B0%EB%B6%84%ED%88%AC-%ED%85%94%EB%84%B7-%EC%84%A4%EC%B9%98-%ED%85%94%EB%84%B7-%EB%A3%A8%ED%8A%B8-%EB%A1%9C%EA%B7%B8%EC%9D%B8-%ED%97%88%EC%9A%A9
   
   그런데, 과연 root 로그인이 되어야 하는지는 확인 못함. 
   ubuntu의 경우 root 로그인이 안되어도 hbase 동작함

</pre>

### hbase 설치

```
    cd /usr/local
    sudo mkdir hadoop
    
    sudo wget http://www.apache.org/dist/hbase/1.1.3/hbase-1.1.3-bin.tar.gz
    (1.1.3은 아직 설치 성공 못 했음, hadoop native lib 문제, http://archive.apache.org/dist/hbase/1.0.1.1/hbase-1.0.1.1-bin.tar.gz)
    sudo tar xvf hbase-1.1.1-bin.tar.gz   
    cd hbase-1.1.1
    ## 주의  -- 현재 지원 버전확인 필요 hbase/1.1.10 (PC Ubuntu에서는 동작 확인)

    sudo wget http://www.apache.org/dist/hbase/1.1.13/hbase-1.1.13-bin.tar.gz
    
    (아래 두줄은 사용하지 않아도 됨)
       hbase_rootdir=${TMPDIR-'/usr/local/hadoop'}/tsdhbase
       iface=lo`uname | sed -n s/Darwin/0/p`

    sudo vim conf/hbase-site.xml

    configuration 태그 사이의 내용을 넣어주면 됨
    (DIRECTORY 경로는 hbase 와 zookeeper 의 temp 파일들을 저장할 위치)

     <?xml version="1.0"?>
     <?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
     <configuration>

       <property>
         <name>hbase.rootdir</name>
         <value>file:///DIRECTORY/hbase</value>
       </property>
       <property>
         <name>hbase.zookeeper.property.dataDir</name>
         <value>/DIRECTORY/zookeeper</value>
        </property>

     </configuration>
```


```
  작성사례
  <configuration>
    <property>
      <name>hbase.rootdir</name>
      <value>file:///usr/local/hadoop/tmp/hbase</value>
    </property>
    <property>
      <name>hbase.zookeeper.property.dataDir</name>
      <value>/usr/local/hadoop/tmp/zookeeper</value>
    </property>
  </configuration>
  ** 주의 : file:// 까지 작성하고, 이후 경로 작성
```


```
  (중요, 실행)  sudo sh ./bin/start-hbase.sh
  근래 사용하는 쉘명령
  cd /usr/local/hadoop/hbase-1.1.13/bin
  JAVA_HOME=/usr/lib/jvm/java-8-oracle/jre sh start-hbase.sh

  (확인 방법)
  zookeeper 연결 확인, http://hbase.apache.org/book.html#getting_started
  telnet localhost 2181
  stats
   아래처럼 회신이 와야 함
    Zookeeper version: 3.4.3-cdh4.0.1--1, built on 06/28/2012 23:59 GMT
    Clients:

    Latency min/avg/max: 0/0/677
    Received: 4684478
    Sent: 4687034
    Outstanding: 0
    Zxid: 0xb00187dd0
    Mode: leader
    Node count: 127182
    Connection closed by foreign host.

```

### GnuPlot 설치
```
     cd /usr/local
     sudo apt-get install gcc
     sudo apt-get install libgd2-xpm-dev
     sudo wget http://sourceforge.net/projects/gnuplot/files/gnuplot/4.6.3/gnuplot-4.6.3.tar.gz
     sudo tar xvf gnuplot-4.6.3.tar.gz
     cd gnuplot-4.6.3
     sudo ./configure
     sudo make install
     sudo apt-get install gnuplot

     sudo apt-get install dh-autoreconf
```

### openTSDB 설치
```
     cd /usr/local
     git clone git://github.com/OpenTSDB/opentsdb.git

     sudo apt-get install dh-autoreconf
   
     cd opentsdb
     sudo ./build.sh
     sudo env COMPRESSION=NONE HBASE_HOME=/usr/local/hbase-1.0.1.1 ./src/create_table.sh
     (HBASE_HOME은 설치되어 있는 위치)
     sudo env JAVA_HOME=/usr/lib/jvm/java-8-oracle/jre COMPRESSION=NONE HBASE_HOME=/usr/local/hbase-1.1.13 ./src/create_table.sh

     // 여기서 부터는 자동실행 할시 안해도 되는 부분임 //
     tsdtmp=${TMPDIR-'/usr/local/data'}/tsd
     mkdir -p "$tsdtmp"

     여기서 screen 으로
     screen -dmS tsdb
     screen -list
     tsdb로 -r tsdb

     ./build/tsdb tsd --port=4242 --staticroot=./build/staticroot --cachedir=/usr/local/data --auto-metric

     실행 후에는 Ctl + a + d 로 빠져나옴

     // 여기까지 //

```
  - 로그파일 설정
    - 설정 파일 위치 : /opentsdb/src/logback.xml
```
    <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
  <file>/var/log/opentsdb/opentsdb.log</file>
  <append>true</append>

  <rollingPolicy class="ch.qos.logback.core.rolling.FixedWindowRollingPolicy">
    <fileNamePattern>/var/log/opentsdb/opentsdb.log.%i</fileNamePattern>
    <minIndex>1</minIndex>
    <maxIndex>3</maxIndex>
  </rollingPolicy>

  <triggeringPolicy class="ch.qos.logback.core.rolling.SizeBasedTriggeringPolicy">
    <maxFileSize>128MB</maxFileSize>
  </triggeringPolicy>

  <!-- encoders are assigned the type
       ch.qos.logback.classic.encoder.PatternLayoutEncoder by default -->
  <encoder>
    <pattern>%d{HH:mm:ss.SSS} %-5level [%logger{0}.%M] - %msg%n</pattern>
  </encoder>
</appender>
그리고
<root level="info">
   <appender-ref ref="FILE"/>
</root>
```

  -  자동실행 내용
<pre>
  cd /usr/local/hbase-1.0.1.1/bin/
  sudo ./stop-hbase.sh
  sudo ./start-hbase.sh
  cd /usr/local/opentsdb
  sudo screen -dmS tsdb ./build/tsdb tsd --port=4242 --staticroot=build/staticroot --cachedir=/usr/local/data --auto-metric &
  cd /usr/local/tcollector
  sudo ./startstop start
  (openTSDB 2.3 부터는 sudo python /usr/local/tcollector/tcollector.py -H 127.0.0.1 -p 4242 -D 로 변경)
  (2017/5/30) sudo ./build/tsdb tsd --port=4242 --staticroot=build/staticroot --cachedir=/usr/local/hadoop/tmp/opentsdb --auto-metric

</pre>

  - Tcollector 설치 (2018년 기준. 사용하지 않아도 됨)
```
     Tcollector 굳이 설치안해도 됨.
     현재는 openTSDB의 CLI put 방식으로 socket 입력하면 데이터가 잘 들어가서 그것을 사용   
     cd /usr/local
     sudo git clone git://github.com/OpenTSDB/tcollector.git
     cd tcollector
     sudo python tcollector.py -H <TSDB Host IP> -p <TSDB port> -D
     < 아래는 OLD version >
     sudo vim startstop

     #TSD_HOST=dns.name.of.tsd 이부분에서 주석해제하고 IP를 적어주면 됨(아래처럼)
     TSD_HOST=127.0.0.1 (ip주소)

     wget https://raw.githubusercontent.com/kowonsik/tsdb/master/sect_tcp.py
```

-----

< openTSDB 자동 실행 >

```
    첨부된 /setup/rc.local 파일 참조

```

-----

< Duplication error>
  - 동일한 시간에 동리 메트릭에 여러개의 데이터가 들어가면 TSD 는 한개의 데이터만 선택을 못해서, 에러가 발생함
  - 그중 제일 마지막 값으로 선택하고, 실행에러 없애려면,
  - sudo ./build/tsdb fsck --fix --resolve-duplicates 2016/03/00 2017/05/01 sum {metric_name} 를 실행해주면 됨
  - 매번 이렇게 fix 작업해 주기가 어려우니, 아예 컴파일타임에 옵션으로 올리면 됨
  - sudo vim src/opentsdb.conf 에 tsd.storage.fix_duplicates = true 입력하고,
  - 이 설정 파일을 /etc/opentsdb.conf 로 복사하면, open tsdb 실행시, 설정을 읽어들임
  - 확인 : http://IP:4242/api/config


< /etc/opentsdb.conf 에 추가해야할 내용 >

   - tsd.storage.fix_duplicates = true
   - tsd.http.request.max_chunk = 65536
   - tsd.http.request.enable_chunked=true



< 센서 >

```
      tmp_temp = 175.72 * float(temp) / pow(2,16) - 46.85
      tmp_humi = 125 * float(humi) / pow(2,16) - 6
```
-----
< stalk >
```
    로거 : python talk.py server LOGGER-001-4242 localhost 4242
    놋북 : python talk.py client LOGGER-001-4242 4242
    웹   : localhost:4242

    채널 : http://125.7.128.54/stalk/master/admin/api/entry/

    stalk ddns 안될경우---

    sudo service stalk restart
    sudo service stalk-binder restart
    sudo service stlak-revproxy restart
    sudo service nginx restart
```
