FROM alpine:3.6
RUN apk --update --no-progress add jq zip curl bash
ENV OUTDIR /OUTDIR
COPY entrypoint.sh entrypoint.sh
WORKDIR ${OUTDIR}
ENTRYPOINT ["/entrypoint.sh"]
CMD ["-h"]
