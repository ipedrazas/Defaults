FROM harbor.alacasa.uk/library/defaults:latest as builder

RUN helm create __TARGET_NAME__ --starter common-configmap



FROM harbor.alacasa.uk/library/hgv:v0.1.11 as values-builder

WORKDIR /workspace

COPY . .

USER appuser

RUN python /home/appuser/app/helm.py .meta.yaml gp/targets/helm/target.yaml values.yaml


FROM scratch as result

COPY --from=builder /home/appuser/__TARGET_NAME__ ./charts/__TARGET_NAME__
COPY --from=values-builder /workspace/values.yaml ./charts/__TARGET_NAME__