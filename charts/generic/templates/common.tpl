{{- /********/ -}}
{{- /* Name */ -}}
{{- /********/ -}}

{{- /* Set the default chart prefix to the release name */ -}}
{{- $_ := set .Values.common "nameOverride" .Release.Name -}}


{{- /************/ -}}
{{- /* Services */ -}}
{{- /************/ -}}

{{- /* If there's only one defined service, make it primary */ -}}
{{- with .Values.service -}}
	{{- if eq (len .) 1 -}}
		{{- range $_, $serviceSpec := . -}}
			{{- $_ := set $serviceSpec "primary" true -}}
		{{- end -}}
	{{- end -}}
{{- end -}}


{{- /***************************/ -}}
{{- /* Persistence: ConfigMaps */ -}}
{{- /***************************/ -}}

{{- range $name, $spec := .Values.persistence -}}
	{{- if eq $spec.type "configMap" -}}
		{{- /* Configure a configMap volume */ -}}
		{{- $_ := set $spec "type" "custom" -}}
		{{- $_ := set $spec "volumeSpec" (dict "configMap" (dict "name" $name)) -}}

		{{- /* Create the configmap */ -}}
		{{- with $spec.data -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $name }}
data:
{{ . | toYaml | indent 2 }}
---
		{{- end -}}
	{{- end -}}
{{- end -}}


{{- /************/ -}}
{{- /* Defaults */ -}}
{{- /************/ -}}

{{- /* Context:
	{
		overrides: map,
		key: current override key in `overrides` (or nil for root),
		defaults: map of defaults,
		regex: current default key (or nil for root),
	}
*/ -}}
{{- define "applyDefaults" -}}
	{{- printf "###### applying: %s, %s, %s\n" (keys .) .key .regex -}}
	{{- $recursionKinds := list "map" "slice" -}}

	{{- if not (or $.key $.regex) -}}
		{{- /* Initial call: haven't started regressing yet */ -}}
		{{- if $recursionKinds | has (kindOf $.overrides) -}}
			{{- if kindIs "map" $.defaults -}}
				{{- range $regex, $_ := $.defaults -}}
					{{- range $key, $_ := $.overrides -}}
						{{- template "applyDefaults" (dict "overrides" $.overrides "key" $key "defaults" $.defaults "regex" $regex) -}}
					{{- end -}}

					{{- template "applyDefaults" (dict "overrides" $.overrides "defaults" $.defaults "regex" $regex) -}}
				{{- end -}}
			{{- else if kindIs "slice" $.defaults -}}
				{{- range $_, $defaults := $.defaults -}}
					{{- template "applyDefaults" (dict "overrides" $.overrides "defaults" $defaults) -}}
				{{- end -}}
			{{- end -}}
		{{- end -}}
	{{- else if not $.key -}}
		{{- /* Only continue if an override doesn't exist */ -}}
		{{- if not (hasKey $.overrides $.regex) -}}
			{{- $defaultValue := get $.defaults $.regex -}}
			{{- $deniedKinds := list "map" "slice" -}}
			{{- if $deniedKinds | has (kindOf $defaultValue) | not -}}
				{{- /* Have a default value for a missing key */ -}}
				{{- $_ := set $.overrides $.regex $defaultValue -}}
			{{- end -}}
		{{- end -}}
	{{- else if $.regex -}}
		{{- $defaultValue := get $.defaults $.regex -}}
		{{- $regex := printf "^%s$" $.regex -}}

		{{- if regexMatch $regex $.key -}}
			{{- $overrideValue := get $.overrides $.key -}}

			{{- $overrideKind := kindOf $overrideValue -}}
			{{- $defaultKind := kindOf $defaultValue -}}
			{{- $allowedKinds := list "map" "slice" -}}

			{{- if and ($allowedKinds | has (kindOf $overrideValue)) ($allowedKinds | has (kindOf $defaultValue)) -}}
				{{- /* Recurse */ -}}
				{{- template "applyDefaults" (dict "overrides" $overrideValue "defaults" $defaultValue) -}}
			{{- end -}}
		{{- end -}}
	{{- end -}}
{{- end -}}

{{- /* Apply template defaults and remove them from values */ -}}
{{- /* template "applyDefaults" (dict "overrides" .Values "defaults" .Values.defaults) */ -}}
{{- $defaults := .Values.defaults -}}
{{- $_ := unset .Values "defaults" -}}
{{- template "applyDefaults" (dict "overrides" .Values "defaults" $defaults) -}}


{{- /*************/ -}}
{{- /* Debugging */ -}}
{{- /*************/ -}}

{{- $debug := .Values.debug -}}
{{- $_ := unset .Values "debug" -}}



{{- /****************/ -}}
{{- /* Common chart */ -}}
{{- /****************/ -}}

{{- if $debug -}}
	{{ .Values | toYaml }}
{{- else -}}
	{{- include "common.all" . -}}
{{- end -}}
