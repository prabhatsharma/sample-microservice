# A Go multistage docker file
FROM public.ecr.aws/bitnami/golang:1.16 as builder
RUN mkdir /build 
ADD . /build/
WORKDIR /build 
RUN go build -o main .

FROM public.ecr.aws/micahhausler/alpine:3.13.5
ENV PORT 8080
EXPOSE 8080
RUN adduser -S -D -H -h /app appuser
USER appuser
COPY --from=builder /build/main /app/
WORKDIR /app
RUN pwd && ls -alh && ls /
CMD ["./main"]