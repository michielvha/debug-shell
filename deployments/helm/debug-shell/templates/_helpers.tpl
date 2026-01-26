{{/*
Expand the name of the chart.
*/}}
{{- define "debug-shell.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "debug-shell.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "debug-shell.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "debug-shell.labels" -}}
helm.sh/chart: {{ include "debug-shell.chart" . }}
{{ include "debug-shell.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.labels }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "debug-shell.selectorLabels" -}}
app.kubernetes.io/name: {{ include "debug-shell.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
component: debug-tool
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "debug-shell.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "debug-shell.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Determine if volumes should be enabled based on security profile
*/}}
{{- define "debug-shell.volumesEnabled" -}}
{{- if eq .Values.securityProfile "enhanced" -}}
true
{{- else if eq .Values.securityProfile "maximum" -}}
true
{{- else if .Values.volumes.enabled -}}
true
{{- else -}}
false
{{- end }}
{{- end }}

{{/*
Determine read-only filesystem based on security profile
*/}}
{{- define "debug-shell.readOnlyRootFilesystem" -}}
{{- if eq .Values.securityProfile "enhanced" -}}
true
{{- else if eq .Values.securityProfile "maximum" -}}
true
{{- else -}}
{{- .Values.securityContext.readOnlyRootFilesystem }}
{{- end }}
{{- end }}

{{/*
Determine capabilities based on security profile
*/}}
{{- define "debug-shell.capabilities" -}}
{{- if eq .Values.securityProfile "maximum" -}}
drop:
  - ALL
{{- else -}}
{{- toYaml .Values.capabilities }}
{{- end }}
{{- end }}
