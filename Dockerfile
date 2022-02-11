FROM mcr.microsoft.com/dotnet/runtime:6.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["ConsoleApp/ConsoleApp.csproj", "ConsoleApp/"]
RUN dotnet restore "ConsoleApp/ConsoleApp.csproj"
COPY . .
WORKDIR "/src/ConsoleApp"
RUN dotnet build "ConsoleApp.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ConsoleApp.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Install Datadog APM
RUN apt-get update
RUN apt-get install -y curl
RUN curl -LO https://github.com/DataDog/dd-trace-dotnet/releases/download/v2.3.0/datadog-dotnet-apm_2.3.0_amd64.deb
RUN dpkg -i ./datadog-dotnet-apm_2.3.0_amd64.deb

ENV CORECLR_ENABLE_PROFILING=1 \
	CORECLR_PROFILER={846F5F1C-F9AE-4B07-969E-05C26BC060D8} \
	CORECLR_PROFILER_PATH=/opt/datadog/Datadog.Trace.ClrProfiler.Native.so \
	DD_INTEGRATIONS=/opt/datadog/integrations.json \
	DD_DOTNET_TRACER_HOME=/opt/datadog \
	DD_TRACE_ANALYTICS_ENABLED=true \
	DD_TRACE_LOG_DIRECTORY=/tmp \
	DD_LOGS_INJECTION=true \
	DD_RUNTIME_METRICS_ENABLED=true
	
# Setting env vars to reproduce issue
ENV DD_AGENT_HOST=localhost
ENV DD_TRACE_AGENT_URL unix:///var/run/datadog/apm.socket


ENTRYPOINT ["dotnet", "ConsoleApp.dll"]