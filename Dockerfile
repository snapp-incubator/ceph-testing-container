# Source(with modifications): https://github.com/ceph/go-ceph/blob/master/testing/containers/ceph/Dockerfile
ARG CEPH_IMG=quay.io/ceph/ceph
ARG CEPH_TAG=v16
FROM ${CEPH_IMG}:${CEPH_TAG}

# A CEPH_VERSION env var is already set in the base image.
# We save our build arg as GO_CEPH_VERSION and later ensure that
# the values agree to ensure we're building what we meant to build.
ARG GO_CEPH_VERSION
ENV GO_CEPH_VERSION=${GO_CEPH_VERSION:-$CEPH_VERSION}

RUN true && \
  echo "Check: [ ${CEPH_VERSION} = ${GO_CEPH_VERSION} ]" && \
  [ "${CEPH_VERSION}" = "${GO_CEPH_VERSION}" ] && \
  yum update -y --disablerepo=ganesha && \
  yum clean packages && \
  cv="$(rpm -q --queryformat '%{version}-%{release}' ceph-common)" && \
  yum install -y \
  git wget curl make \
  /usr/bin/cc /usr/bin/c++ \
  "libcephfs-devel-${cv}" "librados-devel-${cv}" "librbd-devel-${cv}" \
  gdb libcephfs2-debuginfo librados2-debuginfo librbd1-debuginfo && \
  yum clean all && \
  true

ARG GO_VERSION=1.21.8
ENV GO_VERSION=${GO_VERSION}
ARG GOARCH
ENV GOARCH=${GOARCH}
ARG GOPROXY
ENV GOPROXY=${GOPROXY}
RUN true && \
  gotar=go${GO_VERSION}.linux-${GOARCH}.tar.gz && \
  gourl="https://dl.google.com/go/${gotar}" && \
  curl -o /tmp/${gotar} "${gourl}" && \
  tar -x -C /opt/ -f /tmp/${gotar} && \
  rm -f /tmp/${gotar} && \
  true

ENV PATH="${PATH}:/opt/go/bin"
ENV GOROOT=/opt/go
ENV GO111MODULE=on
ENV GOPATH /go
ENV GOCACHE=/go/cache
WORKDIR /go/src/github.com/ceph/go-ceph
VOLUME /go/src/github.com/ceph/go-ceph

COPY micro-osd.sh /
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
