FROM harbor.alacasa.uk/library/defaults:latest as builder

RUN helm create __TARGET_NAME__ --starter common-configmap



FROM harbor.alacasa.uk/library/hgv:v0.1.11 as values-builder

WORKDIR /workspace

COPY ./.meta.yaml /workspace/.meta.yaml
COPY ./gp/targets/helm/target.yaml /targets/target.yaml
COPY ./data /data

USER appuser

RUN python /home/appuser/app/helm.py /workspace/.meta.yaml /targets/target.yaml /workspace/values.yaml


FROM scratch as result

COPY --from=builder /home/appuser/__TARGET_NAME__ ./charts/__TARGET_NAME__
COPY --from=values-builder /workspace/values.yaml ./charts/__TARGET_NAME__