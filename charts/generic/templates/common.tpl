{{- $_ := set .Values.common "nameOverride" .Release.Name -}}
{{- include "common.all" . -}}
