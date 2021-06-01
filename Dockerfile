FROM registry.cn-shenzhen.aliyuncs.com/titanide/golang:1.16.4-alpine3.13 as builder

ARG APP_NAME=foo
ARG CONTEXT=cmd/${APP_NAME}
ARG GOPROXY=https://goproxy.cn
ARG GIT_USER="nothing"
ARG GIT_ACCESS_TOKEN="nothing"
ARG PRIVATE_GIT="nothing"

RUN mkdir -p /root/workspace
WORKDIR /root/workspace

RUN go env -w GOPROXY=${GOPROXY} && \
  go env -w GOPRIVATE=${PRIVATE_GIT} && \
  go env -w GOINSECURE=${PRIVATE_GIT} && \
  go env -w GONOSUMDB=${PRIVATE_GIT}

# Create a netrc file using the credentials specified using --build-arg
RUN printf "machine ${PRIVATE_GIT}\n\
  login ${GIT_USER}\n\
  password ${GIT_ACCESS_TOKEN}\n"\
  >> /root/.netrc

COPY . .
# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN go mod download

# Build
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GO111MODULE=on go build -a -o app ${CONTEXT}/main.go

# restore dependencies
RUN find . \( -name app -or -name "config*" \) | xargs tar cvfz app.tar.gz

FROM registry.cn-shenzhen.aliyuncs.com/titanide/base-go:v1.0.0 as release
ARG APP_NAME=foo
ARG APP_VERSION=v1
ENV APP_NAME=${APP_NAME}
ENV APP_VERSION=${APP_VERSION}
COPY --from=builder /root/workspace/app.tar.gz /opt/app-root
RUN tar xvf /opt/app-root/app.tar.gz

WORKDIR /opt/app-root/

EXPOSE 8080
ENTRYPOINT ["/opt/app-root/app"]
