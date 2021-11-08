{{- /********/ -}}
{{- /* Name */ -}}
{{- /********/ -}}

{{- /* Set the default chart prefix to the release name */ -}}
{{- $_ := set .Values.common "nameOverride" .Release.Name -}}



{{- /************/ -}}
{{- /* Services */ -}}
{{- /************/ -}}

{{- range $serviceName, $service := .Values.service -}}

	{{- /* Enable all defined services by default */ -}}
	{{- $_ := set $service "enabled" (default true $service.enabled) -}}

	{{- /* Default to TCP protocol */ -}}
	{{- $_ := set $service "protocol" (default "TCP" $service.protocol) -}}

	{{- range $portName, $port := $service.ports -}}

		{{- /* Enable all defined ports by default */ -}}
		{{- $_ := set $port "enabled" (default true $port.enabled) -}}

	{{- end -}}
{{- end -}}

{{- /* If there's only one defined service, make it primary */ -}}
{{- with .Values.service -}}
	{{- if eq (len .) 1 -}}
		{{- range $_, $service := . -}}
			{{- $_ := set $service "primary" true -}}
		{{- end -}}
	{{- end -}}
{{- end -}}


{{- /*************/ -}}
{{- /* Debugging */ -}}
{{- /*************/ -}}

{{- if .Values.debug -}}
values:
  {{- .Values | toYaml  -}}
 {{- end -}}

{{- /****************/ -}}
{{- /* Common chart */ -}}
{{- /****************/ -}}

{{- include "common.all" . -}}
