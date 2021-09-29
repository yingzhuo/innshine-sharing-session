### (一) Docker是什么？

微型化的虚拟机技术，是一个包含了**守护进程**和**环境**的集合。是现在最流行的计算机虚拟化技术之一。

### (二) 镜像与容器什么关系?

类比面向对象编程语言: **镜像是类， 容器是实例。镜像与容器是一对多的关系**。

### (三) 如何安装

#### 3.1 Linux: [官方文档](https://docs.docker.com/engine/install/)

#### 3.2 Windows / MacOS
* [DockerDesktop - MacOS](https://docs.docker.com/desktop/mac/install/)
    * 请注意要区分 M1芯片和英特尔芯片应当使用不同版本，搞错了一定安装失败。
* [DockerDesktop - Windows](https://docs.docker.com/desktop/windows/install/)

#### 3.3 理解

docker是一个C/S结构的东西：

* docker - 客户端 `which docker`
* dockerd - 服务端 `ps -ef | grep dockerd`
* 其实可以一台机器上值安装客户端，另一台机器只安装服务端。只不过这样做意义是不大的。

#### 3.4 docker版本hello-world

```bash
# 拉取镜像
docker image pull hello-world:latest

# 将容器启动
docker container run hello-world:latest
```

如果能正常出现提示信息，说明docker引擎安装没有问题。

### (四) DockerHub是什么？

docker官方使用[https://hub.docker.com/](https://hub.docker.com/)来保存已有的镜像，包含官方的和第三方的。免费使用，但是速度偏慢。

在国内可以使用阿里云之类的替代品。

* [DockerHub](https://hub.docker.com/)
* [**阿里云**](https://cr.console.aliyun.com/#/repositories)
* [红帽子](https://quay.io/)
* [**商决团队私服**](https://192.168.10.110/)
* 谷歌云gcr

其实，不用远程仓库，导入导出镜像也是可以的。但需要人工干预，效率极差，只应该在非常极端的情况下使用。

### (五) docker客户端的常用命令

* `docker image (命令集)`: 镜像管理: 拉取，推送，删除，构建，重命名等
* `docker container (命令集)`: 容器管理: 启动容器, 停止，删除等
* `docker login`: 登录到指定的镜像仓库
* `docker version`:  查看版本号

**注意:** 请多多使用`--help`

### (六) 如何制作个人镜像或公司镜像

#### 6.1 为什么要制作镜像

* 要运行某些守护进程
* 过程一般不适用docker技术
* 一般来说，一个镜像封装且只封装一个守护进程，但**凡事有例外**。

#### 6.2 镜像的标识

* 前缀: 指出镜像是从哪个镜像仓库里来的。前缀可以没有
* 名称: 镜像的名字表示镜像是干什么用的。
* tag: 镜像的版本或其他信息。 默认tag: `latest`

以下是几个合法的标识:

* yingzhuo/my-application:1.0.0
* quay.io/yingzhuo/my-application:1.0.0
* innshine.com/aiplot:1.0.0
* innshine.com/aiplot:latest
* innshine.com/aiplot
* hello-world

#### 6.3 基本镜像选型

* busybox: 非常神奇，整个基本镜像只有1M多一点点。但是所需的调试工具欠缺。
* alpine: 推荐
* ubuntu: 有点大
* centos: 挺大的

我的一个基本理念: "小就是美"。一个严肃的团队，应该有专人来维护公司用的基本镜像。
基本镜像一般来说还需要再做调整才可以被程序开发团队使用。如需要JRE，Python解释器等。

商决团队`Java-Base` 基本镜像:

```Dockerfile
FROM alpine:3.13.5

COPY --from=yingzhuo/gosu     /bin/gosu     /usr/local/bin/gosu
COPY --from=yingzhuo/docktool /bin/docktool /usr/local/bin/docktool

USER root:root

WORKDIR /opt

RUN addgroup -g 1001 -S app && \
    adduser  -u 1001 -S app -G app -s /bin/sh --no-create-home --disabled-password && \
    chmod +x /usr/local/bin/gosu && \
    chmod +x /usr/local/bin/docktool && \
    mkdir -p /var/data && \
    mkdir -p /var/tmp && \
    chmod 777 /opt && \
    chmod 777 /var/log && \
    chmod 777 /var/data && \
    chmod 777 /var/tmp && \
    chmod 777 /var/run && \
    chmod 777 /run && \
    rm -rf /var/cache/apk/*
```

```Dockerfile
FROM registry.cn-shanghai.aliyuncs.com/yingzhuo/alpine

LABEL maintainer="应卓 <yingzhor@gmail.com>"

ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk
ENV PATH=$PATH:$JAVA_HOME/bin

RUN apk add --update bash ca-certificates openjdk8 font-adobe-100dpi ttf-dejavu fontconfig && \
    rm -rf /usr/bin/java && \
    rm -rf /var/cache/apk/* && \
    rm -rf "$JAVA_HOME/man/" && \
    rm -rf "$JAVA_HOME/demo/" && \
    rm -rf "$JAVA_HOME/release" && \
    rm -rf "$JAVA_HOME/THIRD_PARTY_README" && \
    rm -rf "$JAVA_HOME/ASSEMBLY_EXCEPTION" && \
    rm -rf "$JAVA_HOME/LICENSE" && \
    rm -rf "$JAVA_HOME/README" && \
    rm -rf "$JAVA_HOME/jre/ASSEMBLY_EXCEPTION" && \
    rm -rf "$JAVA_HOME/jre/LICENSE" && \
    rm -rf "$JAVA_HOME/jre/THIRD_PARTY_README" && \
    rm -rf "$JAVA_HOME/lib/missioncontrol" && \
    rm -rf "$JAVA_HOME/lib/visualvm" && \
    rm -rf "$JAVA_HOME/lib/*javafx*" && \
    rm -rf "$JAVA_HOME/jre/lib/plugin.jar" && \
    rm -rf "$JAVA_HOME/jre/lib/ext/jfxrt.jar" && \
    rm -rf "$JAVA_HOME/jre/bin/javaws" && \
    rm -rf "$JAVA_HOME/jre/lib/javaws.jar" && \
    rm -rf "$JAVA_HOME/jre/lib/desktop" && \
    rm -rf "$JAVA_HOME/jre/plugin" && \
    rm -rf "$JAVA_HOME/jre/lib/deploy*" && \
    rm -rf "$JAVA_HOME/jre/lib/*javafx*" && \
    rm -rf "$JAVA_HOME/jre/lib/*jfx*" && \
    rm -rf "$JAVA_HOME/jre/lib/amd64/libdecora_sse.so" && \
    rm -rf "$JAVA_HOME/jre/lib/amd64/libprism_*.so" && \
    rm -rf "$JAVA_HOME/jre/lib/amd64/libfxplugins.so" && \
    rm -rf "$JAVA_HOME/jre/lib/amd64/libglass.so" && \
    rm -rf "$JAVA_HOME/jre/lib/amd64/libgstreamer-lite.so" && \
    rm -rf "$JAVA_HOME/jre/lib/amd64/libjavafx*.so" && \
    rm -rf "$JAVA_HOME/jre/lib/amd64/libjfx*.so"

WORKDIR /root
```

#### 6.4 构建目录

构建目录又被称为构建上下文

一般包含一下几个文件

* Dockerfile
* .dockerignore
* docker-entrypoint.sh
* 其他程序必须品 如jar文件/二进制文件(需要注意交叉编译)/python源文件

对于Java程序员，如何利用gradle或maven搞定构建目录，有一定技巧。

#### 6.5 Dockerfile基本指令

```Dockerfile
# 预构建
ARG BASE_IMG=192.168.10.110/lib/java:8

FROM $BASE_IMG AS builder

WORKDIR /tmp

COPY *.jar app.jar

RUN java -Djarmode=layertools -jar /tmp/app.jar extract && \
    rm -rf /tmp/dependencies/BOOT-INF/lib/java-boot-jarmode-layertools-*.jar && \
    rm -rf /tmp/application/META-INF/maven && \
    rm -rf /tmp/application/BOOT-INF/classpath.idx && \
    rm -rf /tmp/application/BOOT-INF/layers.idx

# 构建
FROM $BASE_IMG

LABEL maintainer="汇尚网络科技有限公司"

WORKDIR /opt

COPY --from=builder /tmp/internal-dependencies/ ./
COPY --from=builder /tmp/dependencies/ ./
COPY --from=builder /tmp/spring-boot-loader/ ./
COPY --from=builder /tmp/snapshot-dependencies/ ./
COPY --from=builder /tmp/application/ ./
COPY --chown=root:root docker-entrypoint.sh /bin/entrypoint.sh

ENV SPRING_PROFILES_ACTIVE=kube

STOPSIGNAL 15

EXPOSE 8080 8443

ENTRYPOINT ["sh", "/bin/entrypoint.sh"]
```

```bash
#!/bin/bash -e

mkdir -p "/var/log"

cd /opt

exec java \
  -Djava.security.egd=file:/dev/./urandom \
  -Duser.timezone="Asia/Shanghai" \
  -Duser.language="zh" \
  -Duser.country="CN" \
  -Djava.io.tmpdir=/var/tmp/ \
  org.springframework.boot.loader.JarLauncher \
  --spring.pid.file=/opt/pid \
  "$@"

exit 0
```

#### 6.6 构建镜像并保存到仓库

```bash
docker image build -t 192.168.10.110/yingzhuo/hello:1.0.0 /my/context
docker login 192.168.10.110
docker image push 192.168.10.110/yingzhuo/hello:1.0.0
```

### (七) 其他技巧

#### 7.1 翻墙技术

#### 7.2 清理垃圾

```bash
docker system prune -a -f
```

#### 7.3 zsh & oh-my-zsh
