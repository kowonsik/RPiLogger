# RPiLogger (라즈베리파이 데이터로거)

1. 개요
  - 대용의 측정데이터를 장시간 저장하는 안정적인 데이터로거 제품은 고가임
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

      - L.Berry(로거(홈서버) 기능의 라즈베리파이)
        - 시계열데이터베이스(openTSDB)
        - 센싱데이터 로컬에 저장 및 원격 전송

1. 설치
  - 자바 설정
```
    java -version
    which java

    vi /etc/profile

      JAVA_HOME=/usr/
      export JAVA_HOME
      export PATH=$PATH:$JAVA_HOME/bin

    source /etc/profile
```

  - hbase 설치
```
    - cd /usr/local
    - mkdir data
    - wget http://www.apache.org/dist/hbase/stable/hbase-1.0.1.1-bin.tar.gz
    - tar xvfz hbase-1.0.1.1-bin.tar.gz
    - cd hbase-1.0.1.1

    - hbase_rootdir=${TMPDIR-'/usr/local/data'}/tsdhbase
    - iface=lo`uname | sed -n s/Darwin/0/p`

    - vi conf/hbase-site.xml

     <?xml version="1.0"?>
     <?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
     <configuration>
       <property>
         <name>hbase.rootdir</name>
         <value>file:/DIRECTORY/hbase</value>
       </property>
       <property>
         <name>hbase.zookeeper.property.dataDir</name>
         <value>/DIRECTORY/zookeeper</value>
        </property>
     </configuration>
```
     위 DIRECTORY에는 hbase를 구동할 디렉토리명을 써준다. (보통 /tmp/hbase-[version명]으로 한다고 함)

```
    ./bin/start-hbase.sh
```

  - GnuPlot 설치
```
     cd /usr/local
     apt-get install gcc
     apt-get install libgd2-xpm-dev
     wget http://sourceforge.net/projects/gnuplot/files/gnuplot/4.6.3/gnuplot-4.6.3.tar.gz
     tar zxvf /gnuplot-4.6.3.tar.gz
     cd gnuplot-4.6.3
     ./configure
     make install
     apt-get install gnuplot

     apt-get install dh-autoreconf
```

  - openTSDB 설치
```
     cd /usr/local
     git clone git://github.com/OpenTSDB/opentsdb.git

     cd opentsdb
     ./build.sh

     env COMPRESSION=NONE HBASE_HOME=/usr/local/hbase-1.0.0 ./src/create_table.sh

     tsdtmp=${TMPDIR-'/usr/local/data'}/tsd
     mkdir -p "$tsdtmp"
     ./build/tsdb tsd --port=4242 --staticroot=build/staticroot --cachedir=/usr/local/data --auto-metric
```

  - Tcollector 설치
```
     git clone git://github.com/OpenTSDB/tcollector.git
     cd tcollector
     vi startstop

     #TSD_HOST=dns.name.of.tsd -> TSD_HOST=192.168.x.x (ip주소)
```
